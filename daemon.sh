#!/bin/bash

declare -i night
declare -i day
declare -i flowrate
declare -i dayrate
declare -i house
declare -i housemidnight

if [ -z "$METERID" ]; then
  echo "METERID not set, launching in debug mode"
  echo "Enter Terminal via Resin and run 'rtlamr -msgtype=r900' to see all the local water meters and find your meter ID"
  rtl_tcp
  exit 0
fi

if [ -z "$METERID2" ]; then
  echo "METERID2 not set, launching in debug mode"
  echo "Enter Terminal via Resin and run 'rtlamr -msgtype=r900' to see all the local water meters and find your meter ID"
  rtl_tcp
  exit 0
fi

# Kill this script (and restart the container) if we haven't seen an update in 30 minutes
./watchdog.sh 30 updated.log &

while true; do
  # Suppress the very verbose output of rtl_tcp and background the process
  rtl_tcp &> /dev/null &
  rtl_tcp_pid=$! # Save the pid for murder later
  sleep 10 #Let rtl_tcp startup and open a port

  json=$(rtlamr -msgtype=r900 -filterid=$METERID -single=true -format=json)
  echo "Meter info: $json"
  
  #Collect data from Irrigation meter
  consumption=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1000')
  echo "Consumption Irrigation Meter: $consumption Cubic Meters"
  irrmeter=$consumption
  irr=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1')
  
  #Now process that data from Irrigation meter
  #convert to integer
  irrint=${irr%.*}
  
  # record data for nightly consumption of Irrigation meter at 9 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 3 && `date +%H` -lt 4 ]];then
    t9PM=$irrint
    echo $t9PM > /data/bin9PM
  fi
  # record data for nightly consumption of Irrigation meter at 12 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 6 && `date +%H` -lt 7 ]];then
    t12AM=$irrint
    echo $t12AM > /data/bin12AM
  fi
  # record data for nightly consumption of Irrigation meter at 3 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 9 && `date +%H` -lt 10 ]];then
    t3AM=$irrint
    echo $t3AM > /data/bin3AM
  fi
  # record data for nightly consumption of Irrigation meter at 6 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 12 && `date +%H` -lt 13 ]];then
    t6AM=$irrint
    echo $t6AM > /data/bin6AM
  fi
  # record data for nightly consumption of Irrigation meter at 9 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 15 && `date +%H` -lt 16 ]];then
    t9AM=$irrint
    echo $t9AM > /data/bin9AM
  fi
  
  #Collect data from Pit meter
  json=$(rtlamr -msgtype=r900 -filterid=$METERID2 -single=true -format=json)
  echo "Pit meter info: $json"
  consumption=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1000')
  pitmeter=$consumption
  pit=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1')
  
  #Now process data 
  #convert to integer
  pitint=${pit%.*}
  # subtract irrigation meter from main pit meter
  house=$(echo $((pitint - irrint)))
  #convert to cubic meters
  housemeter=$(echo $((house / 1000)))
  
  # record data for daily house consumption of House at 1 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 7 && `date +%H` -lt 8 ]];then
     echo $house > /data/binhouse1AM
  fi
  
  # record data for daily house consumption of House at 12 AM (time is adjusted due to UTC)
  # and then compute daily consumption
  if [[ `date +%H` -ge 6 && `date +%H` -lt 7 ]];then
     house1AM=$(cat /data/binhouse1AM)
     housemidnight=$(echo $((house - house1AM)))
     echo $housemidnight > /data/binhousemidnight
  fi
  
  #calculate irrigation consumption for previous night done after 9 AM (adjusted for UTC)
  if [[ `date +%H` -ge 16 && `date +%H` -lt 17 ]];then
    t9PM=$(cat /data/bin9PM)
    t12AM=$(cat /data/bin12AM)
    t3AM=$(cat /data/bin3AM)
    t6AM=$(cat /data/bin6AM)
    t9AM=$(cat /data/bin9AM)
    night=$(echo $((t9AM - t9PM)))
    zone1=$(echo $((t12AM - t9PM)))
    zone2=$(echo $((t3AM - t12AM)))
    zone3=$(echo $((t6AM - t3AM)))
    zone4=$(echo $((t9AM - t6AM)))
    flowrate=$(echo $((night / 720)))
    flowzone1=$(echo $((zone1 / 180)))
    flowzone2=$(echo $((zone2 / 180)))
    flowzone3=$(echo $((zone3 / 180)))
    flowzone4=$(echo $((zone4 / 180)))
    echo $night > /data/binnight
    echo $zone1 > /data/binzone1
    echo $zone2 > /data/binzone2
    echo $zone3 > /data/binzone3
    echo $zone4 > /data/binzone4
    echo $flowrate > /data/binflowrate
    echo $flowzone1 > /data/binflowzone1
    echo $flowzone2 > /data/binflowzone2
    echo $flowzone3 > /data/binflowzone3
    echo $flowzone4 > /data/binflowzone4
  fi
  
  #calculate irrigation consumption for previous day performed after 9 PM (adjusted for UTC)
  if [[ `date +%H` -ge 4 && `date +%H` -lt 5 ]];then
    t9PM=$(cat /data/bin9PM)
    t9AM=$(cat /data/bin9AM)
    day=$(echo $((t9PM - t9AM)))
    dayrate=$(echo $((day / 720)))
    echo $day > /data/binday
    echo $dayrate > /data/bindayrate
  fi
  
  # recall data from disk as program may have rebooted
  housemidnight=$(cat /data/binhousemidnight)
  t9PM=$(cat /data/bin9PM)
  t9AM=$(cat /data/bin9AM)
  night=$(cat /data/binnight)
  zone1=$(cat /data/binzone1)
  zone2=$(cat /data/binzone2)
  zone3=$(cat /data/binzone3)
  zone4=$(cat /data/binzone4)
  flowrate=$(cat /data/binflowrate)
  flowzone1=$(cat /data/binflowzone1)
  flowzone2=$(cat /data/binflowzone2)
  flowzone3=$(cat /data/binflowzone3)
  flowzone4=$(cat /data/binflowzone4)
  day=$(cat /data/binday)
  dayrate=$(cat /data/bindayrate)
  
  #display the information in resin log
  echo " ----------------------------------------------------------------------------------"
  echo "It is presently the "`date +%H`"th hour (UTC) of the day"
  echo "Irrigation Consumption 9PM to 12AM PDT was Zone 1: $zone1 Litres : $flowzone1 Litres per min"
  echo "Irrigation Consumption 12AM to 3AM PDT was Zone 2: $zone2 Litres : $flowzone2 Litres per min"
  echo "Irrigation Consumption 3AM to 6AM PDT was  Zone 3: $zone3 Litres : $flowzone3 Litres per min"
  echo "Irrigation Consumption 6AM to 9AM PDT was  Zone 4: $zone4 Litres : $flowzone4 Litres per min"
  echo "Daily Consumption Data in Litres --------------------------------------------------"
  echo "Total Consumption of Irrigation meter at 9 PM (PDT)    : $t9PM Litres"
  echo "Total Consumption of Irrigation meter at 9 AM (PDT)    : $t9AM Litres"
  echo "Irrigation Consumption last night (9PM to 9AM PDT)     : $night Litres"
  echo "Irrigation Consumption yesterday  (9AM to 9PM PDT)     : $day Litres"
  echo "Average Irrigation rate of flow last night (9PM to 9AM): $flowrate Litres per min"
  echo "Average Irrigation rate of flow yesterday  (9AM to 9PM): $dayrate Litres per min"
  echo "House Consumption for the previous calandar day        : $housemidnight Litres"
  echo "Total Consumption Data in Cubic Meters ---------------------------------------------"
  echo "Consumption Pit Meter                                  : $pitmeter Cubic Meters"
  echo "Consumption Irrigation                                 : $irrmeter Cubic Meters"
  echo "Consumption Non-Irrigation                             : $housemeter Cubic Meters"
  echo " -----------------------------------------------------------------------------------"
 
  # Replace with your custom logging code
  if [ ! -z "$STATX_APIKEY" ]; then
    echo "Logging to StatX"
    statx --apikey $STATX_APIKEY --authtoken $STATX_AUTHTOKEN update --group $STATX_GROUPID --stat $STATX_STATID --value $consumption
  fi

  kill $rtl_tcp_pid # rtl_tcp has a memory leak and hangs after frequent use, restarts required - https://github.com/bemasher/rtlamr/issues/49
  sleep 30 # I don't need THAT many updates

  # Let the watchdog know we've done another cycle
  touch updated.log
done


#!/bin/bash

declare -i night
declare -i day
declare -i flowrate
declare -i dayrate
declare -i house
declare -i housemidnight
declare -i ZONETIMEA
declare -i ZONETIMEB
declare -i ZONETIMEC
declare -i ZONETIMED
declare -i ZONETIMEE
declare -i ZONETIMEF

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
if [ -z "$ZONETIMEA" ]; then
  echo "ZONETIMEA not set, launching in debug mode"
  echo "Enter Environment variable ZONETIMEA with an integer (use 180 or flow time setting on auto valve)"
  rtl_tcp
  exit 0
fi
if [ -z "$ZONETIMEB" ]; then
  echo "ZONETIMEB not set, launching in debug mode"
  echo "Enter Environment variable ZONETIMEB with an integer (use 180 or flow time setting on auto valve)"
  rtl_tcp
  exit 0
fi
if [ -z "$ZONETIMEC" ]; then
  echo "ZONETIMEC not set, launching in debug mode"
  echo "Enter Environment variable ZONETIMEC with an integer (use 180 or flow time setting on auto valve)"
  rtl_tcp
  exit 0
fi
if [ -z "$ZONETIMED" ]; then
  echo "ZONETIMED not set, launching in debug mode"
  echo "Enter Environment variable ZONETIMED with an integer (use 180 or flow time setting on auto valve)"
  rtl_tcp
  exit 0
fi
if [ -z "$ZONETIMEE" ]; then
  echo "ZONETIMEE not set, launching in debug mode"
  echo "Enter Environment variable ZONETIMEE with an integer (use 180 or flow time setting on auto valve)"
  rtl_tcp
  exit 0
fi
if [ -z "$ZONETIMEF" ]; then
  echo "ZONETIMEF not set, launching in debug mode"
  echo "Enter Environment variable ZONETIMEF with an integer (use 180 or flow time setting on auto valve)"
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
  
  # record data for nightly consumption of Irrigation meter at 6 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 0 && `date +%H` -lt 1 ]];then
    t6PM=$irrint
    echo $t6PM > /data/bin6PM
  fi
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
  # record data for nightly consumption of Irrigation meter at 12 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 18 && `date +%H` -lt 19 ]];then
    t12PM=$irrint
    echo $t12PM > /data/bin12PM
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
  
  #calculate irrigation consumption for previous night done after 12 PM (adjusted for UTC)
  if [[ `date +%H` -ge 19 && `date +%H` -lt 20 ]];then
    t6PM=$(cat /data/bin6PM)
    t9PM=$(cat /data/bin9PM)
    t12AM=$(cat /data/bin12AM)
    t3AM=$(cat /data/bin3AM)
    t6AM=$(cat /data/bin6AM)
    t9AM=$(cat /data/bin9AM)
    t12PM=$(cat /data/bin12PM)
    night=$(echo $((t9AM - t9PM)))
    zoneA=$(echo $((t9PM - t6PM)))
    zoneB=$(echo $((t12AM - t9PM)))
    zoneC=$(echo $((t3AM - t12AM)))
    zoneD=$(echo $((t6AM - t3AM)))
    zoneE=$(echo $((t9AM - t6AM)))
    zoneF=$(echo $((t12PM - t9AM)))
    flowrate=$(echo $((night / 720)))
    flowzoneA=$(echo $((zoneA / ZONETIMEA)))
    flowzoneB=$(echo $((zoneB / ZONETIMEB)))
    flowzoneC=$(echo $((zoneC / ZONETIMEC)))
    flowzoneD=$(echo $((zoneD / ZONETIMED)))
    flowzoneE=$(echo $((zoneE / ZONETIMEE)))
    flowzoneF=$(echo $((zoneF / ZONETIMEF)))
    echo $night > /data/binnight
    echo $zoneA > /data/binzoneA
    echo $zoneB > /data/binzoneB
    echo $zoneC > /data/binzoneC
    echo $zoneD > /data/binzoneD
    echo $zoneE > /data/binzoneE
    echo $zoneF > /data/binzoneF
    echo $flowrate > /data/binflowrate
    echo $flowzoneA > /data/binflowzoneA
    echo $flowzoneB > /data/binflowzoneB
    echo $flowzoneC > /data/binflowzoneC
    echo $flowzoneD > /data/binflowzoneD
    echo $flowzoneE > /data/binflowzoneE
    echo $flowzoneF > /data/binflowzoneF
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
  zoneA=$(cat /data/binzoneA)
  zoneB=$(cat /data/binzoneB)
  zoneC=$(cat /data/binzoneC)
  zoneD=$(cat /data/binzoneD)
  zoneE=$(cat /data/binzoneE)
  zoneF=$(cat /data/binzoneF)
  flowrate=$(cat /data/binflowrate)
  flowzoneA=$(cat /data/binflowzoneA)
  flowzoneB=$(cat /data/binflowzoneB)
  flowzoneC=$(cat /data/binflowzoneC)
  flowzoneD=$(cat /data/binflowzoneD)
  flowzoneE=$(cat /data/binflowzoneE)
  flowzoneF=$(cat /data/binflowzoneF)
  day=$(cat /data/binday)
  dayrate=$(cat /data/bindayrate)
  
  #display the information in resin log
  echo " ----------------------------------------------------------------------------------"
  echo "It is presently the "`date +%H`"th hour (UTC) of the day"
  echo "Irrigation Consumption 6PM to 9PM PDT was  Zone A: $zoneA Litres : $flowzoneA Litres per min"
  echo "Irrigation Consumption 9PM to 12AM PDT was Zone B: $zoneB Litres : $flowzoneB Litres per min"
  echo "Irrigation Consumption 12AM to 3AM PDT was Zone C: $zoneC Litres : $flowzoneC Litres per min"
  echo "Irrigation Consumption 3AM to 6AM PDT was  Zone D: $zoneD Litres : $flowzoneD Litres per min"
  echo "Irrigation Consumption 6AM to 9AM PDT was  Zone E: $zoneE Litres : $flowzoneE Litres per min"
  echo "Irrigation Consumption 9AM to 12PM PDT was Zone F: $zoneF Litres : $flowzoneF Litres per min"
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


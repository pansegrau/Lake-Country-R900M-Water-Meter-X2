#!/bin/bash

declare -i night
declare -i day
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
    echo "in 6PM the if statement"
    t6PM=$irrint
    echo $t6PM > /data/bin6PM
  fi
  # record data for nightly consumption of Irrigation meter at 7 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 1 && `date +%H` -lt 2 ]];then
    echo "in 7PM the if statement"
    t7PM=$irrint
    echo $t7PM > /data/bin7PM
  fi
  # record data for nightly consumption of Irrigation meter at 8 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 2 && `date +%H` -lt 3 ]];then
    echo "in 8PM the if statement"
    t8PM=$irrint
    echo $t8PM > /data/bin8PM
  fi
  # record data for nightly consumption of Irrigation meter at 9 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 3 && `date +%H` -lt 4 ]];then
    echo "in 9PM the if statement"
    t9PM=$irrint
    echo $t9PM > /data/bin9PM
  fi
  # record data for nightly consumption of Irrigation meter at 10 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 4 && `date +%H` -lt 5 ]];then
    echo "in 10PM the if statement"
    t10PM=$irrint
    echo $t10PM > /data/bin10PM
  fi
  # record data for nightly consumption of Irrigation meter at 11 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 5 && `date +%H` -lt 6 ]];then
    echo "in 11PM the if statement"
    t10PM=$irrint
    echo $t10PM > /data/bin10PM
  fi
  # record data for nightly consumption of Irrigation meter at 12 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 6 && `date +%H` -lt 7 ]];then
    echo "in 12PM the if statement"
    t12AM=$irrint
    echo $t12AM > /data/bin12AM
    echo $t12AM > /data/bin3AM
  fi
  # record data for nightly consumption of Irrigation meter at 1 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 7 && `date +%H` -lt 8 ]];then
    echo "in 1AM the if statement"
    t1AM=$irrint
    echo $t1AM > /data/bin1AM
    echo $t1AM > /data/bin3AM
  fi
  # record data for nightly consumption of Irrigation meter at 2 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 8 && `date +%H` -lt 9 ]];then
    echo "in 2AM the if statement"
    t2AM=$irrint
    echo $t2AM > /data/bin2AM
    echo $t2AM > /data/bin3AM
  fi
  # record data for nightly consumption of Irrigation meter at 3 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 9 && `date +%H` -lt 10 ]];then
    echo "in 3AM the if statement"
    t3AM=$irrint
    echo $t3AM > /data/bin3AM
  fi
  # record data for nightly consumption of Irrigation meter at 4 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 10 && `date +%H` -lt 11 ]];then
    echo "in 4AM the if statement"
    t4AM=$irrint
    echo $t4AM > /data/bin4AM
  fi
  # record data for nightly consumption of Irrigation meter at 5 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 11 && `date +%H` -lt 12 ]];then
    echo "in 5AM the if statement"
    t5AM=$irrint
    echo $t5AM > /data/bin5AM
  fi
  # record data for nightly consumption of Irrigation meter at 6 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 12 && `date +%H` -lt 13 ]];then
    echo "in 6AM the if statement"
    t6AM=$irrint
    echo $t6AM > /data/bin6AM
  fi
  # record data for nightly consumption of Irrigation meter at 7 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 13 && `date +%H` -lt 14 ]];then
    echo "in 7AM the if statement"
    t7AM=$irrint
    echo $t7AM > /data/bin7AM
  fi
  # record data for nightly consumption of Irrigation meter at 8 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 14 && `date +%H` -lt 15 ]];then
    echo "in 8AM the if statement"
    t8AM=$irrint
    echo $t8AM > /data/bin8AM
  fi
  # record data for nightly consumption of Irrigation meter at 9 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 15 && `date +%H` -lt 16 ]];then
    echo "in 9AM the if statement"
    t9AM=$irrint
    echo $t9AM > /data/bin9AM
  fi
  # record data for nightly consumption of Irrigation meter at 10 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 16 && `date +%H` -lt 17 ]];then
    echo "in 10AM the if statement"
    t10AM=$irrint
    echo $t10AM > /data/bin10AM
  fi
  # record data for nightly consumption of Irrigation meter at 11 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 17 && `date +%H` -lt 18 ]];then
    echo "in 11AM the if statement"
    11AM=$irrint
    echo $t11AM > /data/bin11AM
  fi
  # record data for nightly consumption of Irrigation meter at 12 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 18 && `date +%H` -lt 19 ]];then
    echo "in12AM the if statement"
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
  housemeter=$(echo $((100 * house / 1000))| sed 's/..$/.&/')
  
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
  #need timely updates for irrigation troubleshooting
    echo "Timely updates for Irrigation trouble-shooting"
    t6PM=$(cat /data/bin6PM)
    t9PM=$(cat /data/bin9PM)
    t12AM=$(cat /data/bin12AM)
    t3AM=$(cat /data/bin3AM)
    t6AM=$(cat /data/bin6AM)
    t9AM=$(cat /data/bin9AM)
    t12PM=$(cat /data/bin12PM)
    zoneA=$(echo $((t9PM - t6PM)))
    zoneB=$(echo $((t12AM - t9PM)))
    zoneC=$(echo $((t3AM - t12AM)))
    zoneD=$(echo $((t6AM - t3AM)))
    zoneE=$(echo $((t9AM - t6AM)))
    zoneF=$(echo $((t12PM - t9AM)))
    flowzoneA=$(echo $((100 * zoneA / ZONETIMEA))| sed 's/..$/.&/') 
    flowzoneB=$(echo $((100 * zoneB / ZONETIMEB))| sed 's/..$/.&/')
    flowzoneC=$(echo $((100 * zoneC / ZONETIMEC))| sed 's/..$/.&/')
    flowzoneD=$(echo $((100 * zoneD / ZONETIMED))| sed 's/..$/.&/')
    flowzoneE=$(echo $((100 * zoneE / ZONETIMEE))| sed 's/..$/.&/')
    flowzoneF=$(echo $((100 * zoneF / ZONETIMEF))| sed 's/..$/.&/')
    echo "Zone A:$zoneA flowrate:$flowzoneA"
    echo "Zone B:$zoneB flowrate:$flowzoneB"
    echo "Zone C:$zoneC flowrate:$flowzoneC"
    echo "Zone D:$zoneD flowrate:$flowzoneD"
    echo "Zone E:$zoneE flowrate:$flowzoneE"
    echo "Zone F:$zoneF flowrate:$flowzoneF"
 
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
    flowrate=$(echo $((100 * night / 720))| sed 's/..$/.&/')
    flowzoneA=$(echo $((100 * zoneA / ZONETIMEA))| sed 's/..$/.&/')
    flowzoneB=$(echo $((100 * zoneB / ZONETIMEB))| sed 's/..$/.&/')
    flowzoneC=$(echo $((100 * zoneC / ZONETIMEC))| sed 's/..$/.&/')
    flowzoneD=$(echo $((100 * zoneD / ZONETIMED))| sed 's/..$/.&/')
    flowzoneE=$(echo $((100 * zoneE / ZONETIMEE))| sed 's/..$/.&/')
    flowzoneF=$(echo $((100 * zoneF / ZONETIMEF))| sed 's/..$/.&/')
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
    dayrate=$(echo $((100 * day / 720))| sed 's/..$/.&/')
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


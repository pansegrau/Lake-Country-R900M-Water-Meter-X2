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
declare -i ZONETIMEG
declare -i ZONETIMEH

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
if [ -z "$ZONETIMEG" ]; then
  echo "ZONETIMEG not set, launching in debug mode"
  echo "Enter Environment variable ZONETIMEG with an integer (use 180 or flow time setting on auto valve)"
  rtl_tcp
  exit 0
fi
if [ -z "$ZONETIMEH" ]; then
  echo "ZONETIMEH not set, launching in debug mode"
  echo "Enter Environment variable ZONETIMEH with an integer (use 180 or flow time setting on auto valve)"
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
  
  # record data for nightly consumption of Irrigation meter at 1 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 19 && `date +%H` -lt 20 ]];then
    echo "in 1PM the if statement"
    t1PM=$irrint
    echo $t1PM > /data/bin1PM
  fi
  # record data for nightly consumption of Irrigation meter at 2 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 20 && `date +%H` -lt 21 ]];then
    echo "in 2PM the if statement"
    t2PM=$irrint
    echo $t2PM > /data/bin2PM
  fi
  # record data for nightly consumption of Irrigation meter at 3 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 21 && `date +%H` -lt 22 ]];then
    echo "in 3PM the if statement"
    t3PM=$irrint
    echo $t3PM > /data/bin3PM
  fi
  # record data for nightly consumption of Irrigation meter at 4 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 22 && `date +%H` -lt 23 ]];then
    echo "in 4PM the if statement"
    t4PM=$irrint
    echo $t4PM > /data/bin4PM
  fi
  # record data for nightly consumption of Irrigation meter at 5 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 23 && `date +%H` -lt 0 ]];then
    echo "in 5PM the if statement"
    t5PM=$irrint
    echo $t5PM > /data/bin5PM
  fi
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
    t11PM=$irrint
    echo $t11PM > /data/bin11PM
  fi
  # record data for nightly consumption of Irrigation meter at 12 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 6 && `date +%H` -lt 7 ]];then
    echo "in 12AM the if statement"
    t12AM=$irrint
    echo $t12AM > /data/bin12AM
  fi
  # record data for nightly consumption of Irrigation meter at 1 AM (time is adjusted due to UTC)
  if [[ `date +%-H` -ge 7 && `date +%-H` -lt 8 ]];then
    echo "in 1AM the if statement"
    t1AM=$irrint
    echo $t1AM > /data/bin1AM
  fi
  # record data for nightly consumption of Irrigation meter at 2 AM (time is adjusted due to UTC)
  if [[ `date +%-H` -ge 8 && `date +%-H` -lt 9 ]];then
    echo "in 2AM the if statement"
    t2AM=$irrint
    echo $t2AM > /data/bin2AM
  fi
  # record data for nightly consumption of Irrigation meter at 3 AM (time is adjusted due to UTC)
  if [[ `date +%-H` -ge 9 && `date +%-H` -lt 10 ]];then
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
    echo "in12PM the if statement"
    t12PM=$irrint
    echo $t12PM > /data/bin12PM
  fi
  
  #Collect data from Pit meter
  json=$(rtlamr -msgtype=r900 -filterid=$METERID2 -single=true -format=json)
  echo "Pit meter info: $json"
  consumption=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1000')
  pitmeter=$consumption
  pit=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1')
  
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
  
  #calculate irrigation consumption for previous night done after 12 PM (adjusted for UTC)
  if [[ `date +%H` -ge 19 && `date +%H` -lt 20 ]];then
    t6PM=$(cat /data/bin6PM)
    t9PM=$(cat /data/bin9PM)
    t12AM=$(cat /data/bin12AM)
    t3AM=$(cat /data/bin3AM)
    t6AM=$(cat /data/bin6AM)
    t9AM=$(cat /data/bin9AM)
    t12PM=$(cat /data/bin12PM)
    t3PM=$(cat /data/bin3PM)
    night=$(echo $((t9AM - t9PM)))
    zoneA=$(echo $((t9PM - t6PM)))
    zoneB=$(echo $((t12AM - t9PM)))
    zoneC=$(echo $((t3AM - t12AM)))
    zoneD=$(echo $((t6AM - t3AM)))
    zoneE=$(echo $((t9AM - t6AM)))
    zoneF=$(echo $((t12PM - t9AM)))
    zoneG=$(echo $((t3PM - t12PM)))
    zoneH=$(echo $((t6PM - t3PM)))
    flowrate=$(echo $((100 * night / 720))| sed 's/..$/.&/')
    flowzoneA=$(echo $((100 * zoneA / ZONETIMEA))| sed 's/..$/.&/')
    flowzoneB=$(echo $((100 * zoneB / ZONETIMEB))| sed 's/..$/.&/')
    flowzoneC=$(echo $((100 * zoneC / ZONETIMEC))| sed 's/..$/.&/')
    flowzoneD=$(echo $((100 * zoneD / ZONETIMED))| sed 's/..$/.&/')
    flowzoneE=$(echo $((100 * zoneE / ZONETIMEE))| sed 's/..$/.&/')
    flowzoneF=$(echo $((100 * zoneF / ZONETIMEF))| sed 's/..$/.&/')
    flowzoneG=$(echo $((100 * zoneE / ZONETIMEG))| sed 's/..$/.&/')
    flowzoneH=$(echo $((100 * zoneF / ZONETIMEH))| sed 's/..$/.&/')
    echo $night > /data/binnight
    echo $zoneA > /data/binzoneA
    echo $zoneB > /data/binzoneB
    echo $zoneC > /data/binzoneC
    echo $zoneD > /data/binzoneD
    echo $zoneE > /data/binzoneE
    echo $zoneF > /data/binzoneF
    echo $zoneG > /data/binzoneG
    echo $zoneH > /data/binzoneH
    echo $flowrate > /data/binflowrate
    echo $flowzoneA > /data/binflowzoneA
    echo $flowzoneB > /data/binflowzoneB
    echo $flowzoneC > /data/binflowzoneC
    echo $flowzoneD > /data/binflowzoneD
    echo $flowzoneE > /data/binflowzoneE
    echo $flowzoneF > /data/binflowzoneF
    echo $flowzoneG > /data/binflowzoneG
    echo $flowzoneH > /data/binflowzoneH
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
  
  #need timely updates for irrigation troubleshooting
  echo "Timely updates for Irrigation trouble-shooting"
  t1PM=$(cat /data/bin1PM)
  t2PM=$(cat /data/bin2PM)
  t3PM=$(cat /data/bin3PM)
  t4PM=$(cat /data/bin4PM)
  t5PM=$(cat /data/bin5PM)
  t6PM=$(cat /data/bin6PM)
  t7PM=$(cat /data/bin7PM)
  t8PM=$(cat /data/bin8PM)
  t9PM=$(cat /data/bin9PM)
  t10PM=$(cat /data/bin10PM)
  t11PM=$(cat /data/bin11PM)
  t12AM=$(cat /data/bin12AM)
  t1AM=$(cat /data/bin1AM)
  t2AM=$(cat /data/bin2AM)
  t3AM=$(cat /data/bin3AM)
  t4AM=$(cat /data/bin4AM)
  t5AM=$(cat /data/bin5AM)
  t6AM=$(cat /data/bin6AM)
  t7AM=$(cat /data/bin7AM)
  t8AM=$(cat /data/bin8AM)
  t9AM=$(cat /data/bin9AM)
  t10AM=$(cat /data/bin10AM)
  t11AM=$(cat /data/bin11AM)
  t12PM=$(cat /data/bin12PM)
  q1AM=$(echo $((t1AM - t12AM)))
  q2AM=$(echo $((t2AM - t1AM)))
  q3AM=$(echo $((t3AM - t2AM)))
  q4AM=$(echo $((t4AM - t3AM)))
  q5AM=$(echo $((t5AM - t4AM)))
  q6AM=$(echo $((t6AM - t5AM)))
  q7AM=$(echo $((t7AM - t6AM)))
  q8AM=$(echo $((t8AM - t7AM)))
  q9AM=$(echo $((t9AM - t8AM)))
  q10AM=$(echo $((t10AM - t9AM)))
  q11AM=$(echo $((t11AM - t10AM)))
  q12PM=$(echo $((t12PM - t11AM)))
  q1PM=$(echo $((t1PM - t12PM)))
  q2PM=$(echo $((t2PM - t1PM)))
  q3PM=$(echo $((t3PM - t2PM)))
  q4PM=$(echo $((t4PM - t3PM)))
  q5PM=$(echo $((t5PM - t4PM)))
  q6PM=$(echo $((t6PM - t5PM)))
  q7PM=$(echo $((t7PM - t6PM)))
  q8PM=$(echo $((t8PM - t7PM)))
  q9PM=$(echo $((t9PM - t8PM)))
  q10PM=$(echo $((t10PM - t9PM)))
  q11PM=$(echo $((t11PM - t10PM)))
  q12AM=$(echo $((t12AM - t11PM)))
  
  f1AM=$(echo $((100 * q1AM / 60))| sed 's/..$/.&/')
  f2AM=$(echo $((100 * q2AM / 60))| sed 's/..$/.&/')
  f3AM=$(echo $((100 * q3AM / 60))| sed 's/..$/.&/')
  f4AM=$(echo $((100 * q4AM / 60))| sed 's/..$/.&/')
  f5AM=$(echo $((100 * q5AM / 60))| sed 's/..$/.&/')
  f6AM=$(echo $((100 * q6AM / 60))| sed 's/..$/.&/')
  f7AM=$(echo $((100 * q7AM / 60))| sed 's/..$/.&/')
  f8AM=$(echo $((100 * q8AM / 60))| sed 's/..$/.&/')
  f9AM=$(echo $((100 * q9AM / 60))| sed 's/..$/.&/')
  f10AM=$(echo $((100 * q10AM / 60))| sed 's/..$/.&/')
  f11AM=$(echo $((100 * q11AM / 60))| sed 's/..$/.&/')
  f12PM=$(echo $((100 * q12PM / 60))| sed 's/..$/.&/')
  f1PM=$(echo $((100 * q1PM / 60))| sed 's/..$/.&/')
  f2PM=$(echo $((100 * q2PM / 60))| sed 's/..$/.&/')
  f3PM=$(echo $((100 * q3PM / 60))| sed 's/..$/.&/')
  f4PM=$(echo $((100 * q4PM / 60))| sed 's/..$/.&/')
  f5PM=$(echo $((100 * q5PM / 60))| sed 's/..$/.&/')
  f6PM=$(echo $((100 * q6PM / 60))| sed 's/..$/.&/')
  f7PM=$(echo $((100 * q7PM / 60))| sed 's/..$/.&/')
  f8PM=$(echo $((100 * q8PM / 60))| sed 's/..$/.&/')
  f9PM=$(echo $((100 * q9PM / 60))| sed 's/..$/.&/')
  f10PM=$(echo $((100 * q10PM / 60))| sed 's/..$/.&/')
  f11PM=$(echo $((100 * q11PM / 60))| sed 's/..$/.&/')
  f12AM=$(echo $((100 * q12AM / 60))| sed 's/..$/.&/')
  echo "------------------------------------------------------------------------------"
  echo "Quantity and the Approximate Average Flow-rate each hour"
  echo "1 AM  :$q1AM     litres,     :$f1AM litres per min"    
  echo "2 AM  :$q2AM     litres,     :$f2AM litres per min" 
  echo "3 AM  :$q3AM     litres,     :$f3AM litres per min" 
  echo "4 AM  :$q4AM     litres,     :$f4AM litres per min" 
  echo "5 AM  :$q5AM     litres,     :$f5AM litres per min" 
  echo "6 AM  :$q6AM     litres,     :$f6AM litres per min" 
  echo "7 AM  :$q7AM     litres,     :$f7AM litres per min" 
  echo "8 AM  :$q8AM     litres,     :$f8AM litres per min" 
  echo "9 AM  :$q9AM     litres,     :$f9AM litres per min" 
  echo "10 AM :$q10AM    litres,    :$f10AM litres per min" 
  echo "11 AM :$q11AM    litres,    :$f11AM litres per min"
  echo "12 PM :$q12PM    litres,    :$f12PM litres per min"
  echo "1 PM  :$q1PM     litres,     :$f1PM litres per min"
  echo "2 PM  :$q2PM     litres,     :$f2PM litres per min"
  echo "3 PM  :$q3PM     litres,     :$f3PM litres per min"
  echo "4 PM  :$q4PM     litres,     :$f4PM litres per min"
  echo "5 PM  :$q5PM     litres,     :$f5PM litres per min"
  echo "6 PM  :$q6PM     litres,     :$f6PM litres per min"
  echo "7 PM  :$q7PM     litres,     :$f7PM litres per min"
  echo "8 PM  :$q8PM     litres,     :$f8PM litres per min"
  echo "9 PM  :$q9PM     litres,     :$f9PM litres per min"
  echo "10 PM :$q10PM    litres,    :$f10PM litres per min"
  echo "11 PM :$q11PM    litres,    :$f11PM litres per min"
  echo "12 AM :$q12AM    litres,    :$f12AM litres per min"
  
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
  zoneG=$(cat /data/binzoneG)
  zoneH=$(cat /data/binzoneH)
  flowrate=$(cat /data/binflowrate)
  flowzoneA=$(cat /data/binflowzoneA)
  flowzoneB=$(cat /data/binflowzoneB)
  flowzoneC=$(cat /data/binflowzoneC)
  flowzoneD=$(cat /data/binflowzoneD)
  flowzoneE=$(cat /data/binflowzoneE)
  flowzoneF=$(cat /data/binflowzoneF)
  flowzoneG=$(cat /data/binflowzoneG)
  flowzoneH=$(cat /data/binflowzoneH)
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
  echo "Irrigation Consumption 12PM to 3PM PDT was Zone F: $zoneG Litres : $flowzoneG Litres per min"
  echo "Irrigation Consumption 3PM to 6PM PDT was  Zone F: $zoneH Litres : $flowzoneH Litres per min"
  echo "Daily Consumption Data in Litres --------------------------------------------------"
  echo "Total Consumption of Irrigation meter at 9 PM (PDT)    : $t9PM  Litres"
  echo "Total Consumption of Irrigation meter at 9 AM (PDT)    : $t9AM  Litres"
  echo "Irrigation Consumption last night (9PM to 9AM PDT)     : $night Litres"
  echo "Irrigation Consumption yesterday  (9AM to 9PM PDT)     : $day   Litres"
  echo "Average Irrigation rate of flow last night (9PM to 9AM): $flowrate Litres per min"
  echo "Average Irrigation rate of flow yesterday  (9AM to 9PM): $dayrate  Litres per min"
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

#!/bin/bash

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

UNIT_DIVISOR=1000
UNIT="Cubic Meters"
UNIT2="Warning"

# Kill this script (and restart the container) if we haven't seen an update in 30 minutes
# Nasty issue probably related to a memory leak, but this works really well, so not changing it
./watchdog.sh 30 updated.log &

while true; do
  # Suppress the very verbose output of rtl_tcp and background the process
  rtl_tcp &> /dev/null &
  rtl_tcp_pid=$! # Save the pid for murder later
  sleep 10 #Let rtl_tcp startup and open a port

  json=$(rtlamr -msgtype=r900 -filterid=$METERID -single=true -format=json)
  echo "Meter2 info: $json"

  consumption=$(echo $json | python -c "import json,sys;obj=json.load(sys.stdin);print float(obj[\"Message\"][\"Consumption\"])/$UNIT_DIVISOR")
  echo "Total Consumption: $consumption $UNIT"

#Collect data from meter2

consumption=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1000')
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "Consumption Meter2: $consumption Cubic Meters"
  irrmeter=$consumption
  irr=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1')
  
  #Now process that data from meter2
  #convert to integer
  irrint=${irr%.*}
  
  leak=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Leak"])/1')
  leakcheck=$leak
  backflow=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["BackFlow"])/1')
  backflowcheck=$backflow
  leaknow=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["LeakNow"])/1')
  leaknowcheck=$leaknow
   
  testnumber=0
  echo "test number is: $testnumber"
    
#convert to integers
leakcheckint=${leakcheck%.*}
backflowcheckint=${backflowcheck%.*}
leaknowcheckint=${leaknowcheck%.*}

  
  # record data for nightly consumption of Irrigation meter at 1 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 19 && `date +%H` -lt 20 ]];then
    echo "Presently processing 12 PM noon to 1 PM"
    t1PM=$irrint
    echo $t1PM > /data/bin1PM
  fi
  # record data for nightly consumption of Irrigation meter at 2 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 20 && `date +%H` -lt 21 ]];then
    echo "Presently processing 1 PM to 2 PM"
    t2PM=$irrint
    echo $t2PM > /data/bin2PM
  fi
  # record data for nightly consumption of Irrigation meter at 3 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 21 && `date +%H` -lt 22 ]];then
    echo "Presently processing 2 PM to 3 PM"
    t3PM=$irrint
    echo $t3PM > /data/bin3PM
  fi
  # record data for nightly consumption of Irrigation meter at 4 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 22 && `date +%H` -lt 23 ]];then
    echo "Presently processing 3 PM to 4 PM"
    t4PM=$irrint
    echo $t4PM > /data/bin4PM
  fi
  # record data for nightly consumption of Irrigation meter at 5 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 23 && `date +%H` -lt 24 ]];then
    echo "Presently processing 4 PM to 5 PM"
    t5PM=$irrint
    echo $t5PM > /data/bin5PM
  fi
  # record data for nightly consumption of Irrigation meter at 6 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 0 && `date +%H` -lt 1 ]];then
    echo "Presently processing 5 to 6 PM"
    t6PM=$irrint
    echo $t6PM > /data/bin6PM
  fi
  # record data for nightly consumption of Irrigation meter at 7 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 1 && `date +%H` -lt 2 ]];then
    echo "Presently processing 6 PM to 7 PM"
    t7PM=$irrint
    echo $t7PM > /data/bin7PM
  fi
  # record data for nightly consumption of Irrigation meter at 8 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 2 && `date +%H` -lt 3 ]];then
    echo "Presently processing 7 PM to 8 PM"
    t8PM=$irrint
    echo $t8PM > /data/bin8PM
  fi
  # record data for nightly consumption of Irrigation meter at 9 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 3 && `date +%H` -lt 4 ]];then
    echo "Presently processing 8 PM to 9 PM"
    t9PM=$irrint
    echo $t9PM > /data/bin9PM
  fi
  # record data for nightly consumption of Irrigation meter at 10 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 4 && `date +%H` -lt 5 ]];then
    echo "Presently processing 9 PM to 10 PM"
    t10PM=$irrint
    echo $t10PM > /data/bin10PM
  fi
  # record data for nightly consumption of Irrigation meter at 11 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 5 && `date +%H` -lt 6 ]];then
    echo "Presently processing 10 to 11 PM"
    t11PM=$irrint
    echo $t11PM > /data/bin11PM
  fi
  # record data for nightly consumption of Irrigation meter at 12 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 6 && `date +%H` -lt 7 ]];then
    echo "Presently processing 11 PM to 12 AM midnight"
    t12AM=$irrint
    echo $t12AM > /data/bin12AM
  fi
  # record data for nightly consumption of Irrigation meter at 1 AM (time is adjusted due to UTC)
  if [[ `date +%-H` -ge 7 && `date +%-H` -lt 8 ]];then
    echo "Presently processing 12 AM midnight to 1 AM"
    t1AM=$irrint
    echo $t1AM > /data/bin1AM
  fi
  # record data for nightly consumption of Irrigation meter at 2 AM (time is adjusted due to UTC)
  if [[ `date +%-H` -ge 8 && `date +%-H` -lt 9 ]];then
    echo "Presently processing 1 AM to 2 AM"
    t2AM=$irrint
    echo $t2AM > /data/bin2AM
  fi
  # record data for nightly consumption of Irrigation meter at 3 AM (time is adjusted due to UTC)
  if [[ `date +%-H` -ge 9 && `date +%-H` -lt 10 ]];then
    echo "Presently processing 2 AM to 3 AM"
    t3AM=$irrint
    echo $t3AM > /data/bin3AM
  fi
  # record data for nightly consumption of Irrigation meter at 4 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 10 && `date +%H` -lt 11 ]];then
    echo "Presently processing 3 AM to 4 AM"
    t4AM=$irrint
    echo $t4AM > /data/bin4AM
  fi
  # record data for nightly consumption of Irrigation meter at 5 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 11 && `date +%H` -lt 12 ]];then
    echo "Presently processing 4 AM to 5 AM"
    t5AM=$irrint
    echo $t5AM > /data/bin5AM
  fi
  # record data for nightly consumption of Irrigation meter at 6 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 12 && `date +%H` -lt 13 ]];then
    echo "Presently processing 5 AM to 6 AM"
    t6AM=$irrint
    echo $t6AM > /data/bin6AM
  fi
  # record data for nightly consumption of Irrigation meter at 7 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 13 && `date +%H` -lt 14 ]];then
    echo "Presently processing 6 AM to 7 AM"
    t7AM=$irrint
    echo $t7AM > /data/bin7AM
  fi
  # record data for nightly consumption of Irrigation meter at 8 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 14 && `date +%H` -lt 15 ]];then
    echo "Presently processing 7 AM to 8 AM"
    t8AM=$irrint
    echo $t8AM > /data/bin8AM
  fi
  # record data for nightly consumption of Irrigation meter at 9 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 15 && `date +%H` -lt 16 ]];then
    echo "Presently processing 8 AM to 9 AM"
    t9AM=$irrint
    echo $t9AM > /data/bin9AM
  fi
  # record data for nightly consumption of Irrigation meter at 10 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 16 && `date +%H` -lt 17 ]];then
    echo "Presently processing 9 AM to 10 AM"
    t10AM=$irrint
    echo $t10AM > /data/bin10AM
  fi
  # record data for nightly consumption of Irrigation meter at 11 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 17 && `date +%H` -lt 18 ]];then
    echo "Presently processing 10 AM to 11 AM"
    t11AM=$irrint
    echo $t11AM > /data/bin11AM
  fi
  # record data for nightly consumption of Irrigation meter at 12 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 18 && `date +%H` -lt 19 ]];then
    echo "Presently processing 11 AM to 12 PM noon"
    t12PM=$irrint
    echo $t12PM > /data/bin12PM
  fi
  
 echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
 
 #Collect data from meter1
  json=$(rtlamr -msgtype=r900 -filterid=$METERID2 -single=true -format=json)
  echo "Meter1 info: $json"
  consumption=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1000')
  pitmeter=$consumption
  echo "Total Consumption: $consumption $UNIT"
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "Consumption Meter1: $consumption Cubic Meters"
pit=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1')

#convert to integer
pitint=${pit%.*}
# subtract irrigation meter from main pit meter
  house=$(echo $((pitint - irrint)))
  #convert to cubic meters
  housemeter=$(echo $((100 * house / 1000))| sed 's/..$/.&/')
 
  leakp=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Leak"])/1')
  leakcheckp=$leakp
  backflowp=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["BackFlow"])/1')
  backflowcheckp=$backflowp
  leaknowp=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["LeakNow"])/1')
  leaknowcheckp=$leaknowp
 
 #convert to integers
 leakcheckintp=${leakcheckp%.*}
 backflowcheckintp=${backflowcheckp%.*}
 leaknowcheckintp=${leaknowcheckp%.*}
 
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

# record data for nightly consumption of Pit meter at 1 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 19 && `date +%H` -lt 20 ]];then
    echo "Presently processing 12 PM noon to 1 PM"
    t1PMb=$pitint
    echo $t1PMb > /data/bin1PMb
  fi
  # record data for nightly consumption of Pit meter at 2 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 20 && `date +%H` -lt 21 ]];then
    echo "Presently processing 1 PM to 2 PM"
    t2PMb=$pitint
    echo $t2PMb > /data/bin2PMb
  fi
  # record data for nightly consumption of Pit meter at 3 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 21 && `date +%H` -lt 22 ]];then
    echo "Presently processing 2 PM to 3 PM"
    t3PMb=$pitint
    echo $t3PMb > /data/bin3PMb
  fi
  # record data for nightly consumption of Pit meter at 4 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 22 && `date +%H` -lt 23 ]];then
    echo "Presently processing 3 PM to 4 PM"
    t4PMb=$pitint
    echo $t4PMb > /data/bin4PMb
  fi
  # record data for nightly consumption of Pit meter at 5 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 23 && `date +%H` -lt 24 ]];then
    echo "Presently processing 4 PM to 5 PM"
    t5PMb=$pitint
    echo $t5PMb > /data/bin5PMb
  fi
  # record data for nightly consumption of Pit meter at 6 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 0 && `date +%H` -lt 1 ]];then
    echo "Presently processing 5 to 6 PM"
    t6PMb=$pitint
    echo $t6PMb > /data/bin6PMb
  fi
  # record data for nightly consumption of Pit meter at 7 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 1 && `date +%H` -lt 2 ]];then
    echo "Presently processing 6 PM to 7 PM"
    t7PMb=$pitint
    echo $t7PMb > /data/bin7PMb
  fi
  # record data for nightly consumption of Pit meter at 8 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 2 && `date +%H` -lt 3 ]];then
    echo "Presently processing 7 PM to 8 PM"
    t8PMb=$pitint
    echo $t8PMb > /data/bin8PMb
  fi
  # record data for nightly consumption of Pit meter at 9 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 3 && `date +%H` -lt 4 ]];then
    echo "Presently processing 8 PM to 9 PM"
    t9PMb=$pitint
    echo $t9PMb > /data/bin9PMb
  fi
  # record data for nightly consumption of Pit meter at 10 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 4 && `date +%H` -lt 5 ]];then
    echo "Presently processing 9 PM to 10 PM"
    t10PMb=$pitint
    echo $t10PMb > /data/bin10PMb
  fi
  # record data for nightly consumption of Pit meter at 11 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 5 && `date +%H` -lt 6 ]];then
    echo "Presently processing 10 to 11 PM"
    t11PMb=$pitint
    echo $t11PMb > /data/bin11PMb
  fi
  # record data for nightly consumption of Pit meter at 12 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 6 && `date +%H` -lt 7 ]];then
    echo "Presently processing 11 PM to 12 AM midnight"
    t12AMb=$pitint
    echo $t12AMb > /data/bin12AMb
  fi
  # record data for nightly consumption of Pit meter at 1 AM (time is adjusted due to UTC)
  if [[ `date +%-H` -ge 7 && `date +%-H` -lt 8 ]];then
    echo "Presently processing 12 AM midnight to 1 AM"
    t1AMb=$pitint
    echo $t1AMb > /data/bin1AMb
  fi
  # record data for nightly consumption of Pit meter at 2 AM (time is adjusted due to UTC)
  if [[ `date +%-H` -ge 8 && `date +%-H` -lt 9 ]];then
    echo "Presently processing 1 AM to 2 AM"
    t2AMb=$pitint
    echo $t2AMb > /data/bin2AMb
  fi
  # record data for nightly consumption of Pit meter at 3 AM (time is adjusted due to UTC)
  if [[ `date +%-H` -ge 9 && `date +%-H` -lt 10 ]];then
    echo "Presently processing 2 AM to 3 AM"
    t3AMb=$pitint
    echo $t3AMb > /data/bin3AMb
  fi
  # record data for nightly consumption of Pit meter at 4 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 10 && `date +%H` -lt 11 ]];then
    echo "Presently processing 3 AM to 4 AM"
    t4AMb=$pitint
    echo $t4AMb > /data/bin4AMb
  fi
  # record data for nightly consumption of Pit meter at 5 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 11 && `date +%H` -lt 12 ]];then
    echo "Presently processing 4 AM to 5 AM"
    t5AMb=$pitint
    echo $t5AMb > /data/bin5AMb
  fi
  # record data for nightly consumption of Pit meter at 6 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 12 && `date +%H` -lt 13 ]];then
    echo "Presently processing 5 AM to 6 AM"
    t6AMb=$pitint
    echo $t6AMb > /data/bin6AMb
  fi
  # record data for nightly consumption of Pit meter at 7 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 13 && `date +%H` -lt 14 ]];then
    echo "Presently processing 6 AM to 7 AM"
    t7AMb=$pitint
    echo $t7AMb > /data/bin7AMb
  fi
  # record data for nightly consumption of Pit meter at 8 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 14 && `date +%H` -lt 15 ]];then
    echo "Presently processing 7 AM to 8 AM"
    t8AMb=$pitint
    echo $t8AMb > /data/bin8AMb
  fi
  # record data for nightly consumption of Pit meter at 9 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 15 && `date +%H` -lt 16 ]];then
    echo "Presently processing 8 AM to 9 AM"
    t9AMb=$pitint
    echo $t9AMb > /data/bin9AMb
  fi
  # record data for nightly consumption of Pit meter at 10 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 16 && `date +%H` -lt 17 ]];then
    echo "Presently processing 9 AM to 10 AM"
    t10AMb=$pitint
    echo $t10AMb > /data/bin10AMb
  fi
  # record data for nightly consumption of Pit meter at 11 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 17 && `date +%H` -lt 18 ]];then
    echo "Presently processing 10 AM to 11 AM"
    t11AMb=$pitint
    echo $t11AMb > /data/bin11AMb
  fi
  # record data for nightly consumption of Pit meter at 12 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 18 && `date +%H` -lt 19 ]];then
    echo "Presently processing 11 AM to 12 PM noon"
    t12PMb=$pitint
    echo $t12PMb > /data/bin12PMb
  fi
  
 echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#need timely updates for irrigation troubleshooting
  echo "Hourly updates for Irrigation trouble-shooting"
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
  
  echo "Quantity and the Approximate Average Flow-Rate each hour"
  echo "___________________________________________________________________________________________"
  echo "1 AM  $q1AM     litres,     $f1AM litres per min"    
  echo "2 AM  $q2AM     litres,     $f2AM litres per min" 
  echo "3 AM  $q3AM     litres,     $f3AM litres per min" 
  echo "4 AM  $q4AM     litres,     $f4AM litres per min" 
  echo "5 AM  $q5AM     litres,     $f5AM litres per min" 
  echo "6 AM  $q6AM     litres,     $f6AM litres per min" 
  echo "7 AM  $q7AM     litres,     $f7AM litres per min" 
  echo "8 AM  $q8AM     litres,     $f8AM litres per min" 
  echo "9 AM  $q9AM     litres,     $f9AM litres per min" 
  echo "10 AM $q10AM     litres,     $f10AM litres per min" 
  echo "11 AM $q11AM     litres,     $f11AM litres per min"
  echo "12 PM $q12PM     litres,     $f12PM litres per min"
  echo "1 PM  $q1PM     litres,     $f1PM litres per min"
  echo "2 PM  $q2PM     litres,     $f2PM litres per min"
  echo "3 PM  $q3PM     litres,     $f3PM litres per min"
  echo "4 PM  $q4PM     litres,     $f4PM litres per min"
  echo "5 PM  $q5PM     litres,     $f5PM litres per min"
  echo "6 PM  $q6PM     litres,     $f6PM litres per min"
  echo "7 PM  $q7PM     litres,     $f7PM litres per min"
  echo "8 PM  $q8PM     litres,     $f8PM litres per min"
  echo "9 PM  $q9PM     litres,     $f9PM litres per min"
  echo "10 PM $q10PM     litres,     $f10PM litres per min"
  echo "11 PM $q11PM     litres,     $f11PM litres per min"
  echo "12 AM $q12AM     litres,     $f12AM litres per min"

#need timely updates for pit troubleshooting
  echo "Hourly updates for Pit trouble-shooting"
  t1PMb=$(cat /data/bin1PMb)
  t2PMb=$(cat /data/bin2PMb)
  t3PMb=$(cat /data/bin3PMb)
  t4PMb=$(cat /data/bin4PMb)
  t5PMb=$(cat /data/bin5PMb)
  t6PMb=$(cat /data/bin6PMb)
  t7PMb=$(cat /data/bin7PMb)
  t8PMb=$(cat /data/bin8PMb)
  t9PMb=$(cat /data/bin9PMb)
  t10PMb=$(cat /data/bin10PMb)
  t11PMb=$(cat /data/bin11PMb)
  t12AMb=$(cat /data/bin12AMb)
  t1AMb=$(cat /data/bin1AMb)
  t2AMb=$(cat /data/bin2AMb)
  t3AMb=$(cat /data/bin3AMb)
  t4AMb=$(cat /data/bin4AMb)
  t5AMb=$(cat /data/bin5AMb)
  t6AMb=$(cat /data/bin6AMb)
  t7AMb=$(cat /data/bin7AMb)
  t8AMb=$(cat /data/bin8AMb)
  t9AMb=$(cat /data/bin9AMb)
  t10AMb=$(cat /data/bin10AMb)
  t11AMb=$(cat /data/bin11AMb)
  t12PMb=$(cat /data/bin12PMb)
  q1AMb=$(echo $((t1AMb - t12AMb)))
  q2AMb=$(echo $((t2AMb - t1AMb)))
  q3AMb=$(echo $((t3AMb - t2AMb)))
  q4AMb=$(echo $((t4AMb - t3AMb)))
  q5AMb=$(echo $((t5AMb - t4AMb)))
  q6AMb=$(echo $((t6AMb - t5AMb)))
  q7AMb=$(echo $((t7AMb - t6AMb)))
  q8AMb=$(echo $((t8AMb - t7AMb)))
  q9AMb=$(echo $((t9AMb - t8AMb)))
  q10AMb=$(echo $((t10AMb - t9AMb)))
  q11AMb=$(echo $((t11AMb - t10AMb)))
  q12PMb=$(echo $((t12PMb - t11AMb)))
  q1PMb=$(echo $((t1PMb - t12PMb)))
  q2PMb=$(echo $((t2PMb - t1PMb)))
  q3PMb=$(echo $((t3PMb - t2PMb)))
  q4PMb=$(echo $((t4PMb - t3PMb)))
  q5PMb=$(echo $((t5PMb - t4PMb)))
  q6PMb=$(echo $((t6PMb - t5PMb)))
  q7PMb=$(echo $((t7PMb - t6PMb)))
  q8PMb=$(echo $((t8PMb - t7PMb)))
  q9PMb=$(echo $((t9PMb - t8PMb)))
  q10PMb=$(echo $((t10PMb - t9PMb)))
  q11PMb=$(echo $((t11PMb - t10PMb)))
  q12AMb=$(echo $((t12AMb - t11PMb)))
  
  f1AMb=$(echo $((100 * q1AMb / 60))| sed 's/..$/.&/')
  f2AMb=$(echo $((100 * q2AMb / 60))| sed 's/..$/.&/')
  f3AMb=$(echo $((100 * q3AMb / 60))| sed 's/..$/.&/')
  f4AMb=$(echo $((100 * q4AMb / 60))| sed 's/..$/.&/')
  f5AMb=$(echo $((100 * q5AMb / 60))| sed 's/..$/.&/')
  f6AMb=$(echo $((100 * q6AMb / 60))| sed 's/..$/.&/')
  f7AMb=$(echo $((100 * q7AMb / 60))| sed 's/..$/.&/')
  f8AMb=$(echo $((100 * q8AMb / 60))| sed 's/..$/.&/')
  f9AMb=$(echo $((100 * q9AMb / 60))| sed 's/..$/.&/')
  f10AMb=$(echo $((100 * q10AMb / 60))| sed 's/..$/.&/')
  f11AMb=$(echo $((100 * q11AMb / 60))| sed 's/..$/.&/')
  f12PMb=$(echo $((100 * q12PMb / 60))| sed 's/..$/.&/')
  f1PMb=$(echo $((100 * q1PMb / 60))| sed 's/..$/.&/')
  f2PMb=$(echo $((100 * q2PMb / 60))| sed 's/..$/.&/')
  f3PMb=$(echo $((100 * q3PMb / 60))| sed 's/..$/.&/')
  f4PMb=$(echo $((100 * q4PMb / 60))| sed 's/..$/.&/')
  f5PMb=$(echo $((100 * q5PMb / 60))| sed 's/..$/.&/')
  f6PMb=$(echo $((100 * q6PMb / 60))| sed 's/..$/.&/')
  f7PMb=$(echo $((100 * q7PMb / 60))| sed 's/..$/.&/')
  f8PMb=$(echo $((100 * q8PMb / 60))| sed 's/..$/.&/')
  f9PMb=$(echo $((100 * q9PMb / 60))| sed 's/..$/.&/')
  f10PMb=$(echo $((100 * q10PMb / 60))| sed 's/..$/.&/')
  f11PMb=$(echo $((100 * q11PMb / 60))| sed 's/..$/.&/')
  f12AMb=$(echo $((100 * q12AMb / 60))| sed 's/..$/.&/')
  
  echo "Quantity and the Approximate Average Flow-Rate each hour"
  echo "___________________________________________________________________________________________"
  echo "1 AM  $q1AMb     litres,     $f1AMb litres per min"    
  echo "2 AM  $q2AMb     litres,     $f2AMb litres per min" 
  echo "3 AM  $q3AMb     litres,     $f3AMb litres per min" 
  echo "4 AM  $q4AMb     litres,     $f4AMb litres per min" 
  echo "5 AM  $q5AMb     litres,     $f5AMb litres per min" 
  echo "6 AM  $q6AMb     litres,     $f6AMb litres per min" 
  echo "7 AM  $q7AMb     litres,     $f7AMb litres per min" 
  echo "8 AM  $q8AMb     litres,     $f8AMb litres per min" 
  echo "9 AM  $q9AMb     litres,     $f9AMb litres per min" 
  echo "10 AM $q10AMb     litres,     $f10AMb litres per min" 
  echo "11 AM $q11AMb     litres,     $f11AMb litres per min"
  echo "12 PM $q12PMb     litres,     $f12PMb litres per min"
  echo "1 PM  $q1PMb     litres,     $f1PMb litres per min"
  echo "2 PM  $q2PMb     litres,     $f2PMb litres per min"
  echo "3 PM  $q3PMb     litres,     $f3PMb litres per min"
  echo "4 PM  $q4PMb     litres,     $f4PMb litres per min"
  echo "5 PM  $q5PMb     litres,     $f5PMb litres per min"
  echo "6 PM  $q6PMb     litres,     $f6PMb litres per min"
  echo "7 PM  $q7PMb     litres,     $f7PMb litres per min"
  echo "8 PM  $q8PMb     litres,     $f8PMb litres per min"
  echo "9 PM  $q9PMb     litres,     $f9PMb litres per min"
  echo "10 PM $q10PMb     litres,     $f10PMb litres per min"
  echo "11 PM $q11PMb     litres,     $f11PMb litres per min"
  echo "12 AM $q12AMb     litres,     $f12AMb litres per min"
  
  # recall data from disk as program may have rebooted
 housemidnight=$(cat /data/binhousemidnight)
 
 echo "********************************************************************************************" 
 echo "House Consumption for the previous calandar day     :$housemidnight Litres"
  echo "********************************************************************************************"
  echo "*                Total Consumption Data in Cubic Meters                                    "
  echo "*    Consumption Meter One                           $pitmeter Cubic Meters                "
  echo "*    Consumption Meter Two                          $irrmeter Cubic Meters                "
  echo "*    Consumption Difference                      $housemeter Cubic Meters              "
  echo "********************************************************************************************"
  echo "Meter1 Leaks             : $leakcheckp $UNIT2"
  echo "Meter1 Leaknow           : $leaknowcheckp $UNIT2"
  echo "Meter1 Backflow          : $backflowcheckp $UNIT2"
  echo "Meter2 Leaks             : $leakcheck $UNIT2"
  echo "Meter2 Leaknow           : $leaknowcheck $UNIT2"
  echo "Meter2 Backflow          : $backflowcheck $UNIT2"

if [ "$leakcheckintp" -gt "$testnumber" ]; then
  echo "Yes there was a leak this week in Meter1 System" ; else
  echo ":)"  
fi
if [ "$leaknowcheckintp" -gt "$testnumber" ]; then
  echo "Yes there is a leak today in Meter1 System" ; else
  echo ":)  :)"    
fi
if [ "$backflowcheckintp" -gt "$testnumber" ]; then
  echo "HELP! there is a backflow in Meter1 System"; else
  echo ":)  :)  :)"    
fi  
if [[ "$leakcheckint" -gt "$testnumber" ]]; then
  echo "Yes there was a leak this week in Meter2 System" ; else
  echo ";)"
fi
if [[ "$leaknowcheckint" -gt "$testnumber" ]]; then
  echo "Yes there is a leak today in Meter2 System" ; else
  echo ";)  ;)"  
fi
if [[ "$backflowcheckint" -gt "$testnumber" ]]; then
  echo "HELP! there is a backflow in Meter2 System" ; else
  echo ";)  ;)  ;)"  
fi


echo "********************************************************************************************"
echo "Compare the consumption of two meters connected in series"
  echo "******************************************************************************************"
  echo "Meter Two,        Meter One"
  echo "___________________________________________________________________________________________"
  echo "1 AM  $q1AM ,  $q1AMb  litres, "    
  echo "2 AM  $q2AM ,  $q2AMb  litres, " 
  echo "3 AM  $q3AM ,  $q3AMb  litres, " 
  echo "4 AM  $q4AM ,  $q4AMb  litres, " 
  echo "5 AM  $q5AM ,  $q5AMb  litres, " 
  echo "6 AM  $q6AM ,  $q6AMb  litres, " 
  echo "7 AM  $q7AM ,  $q7AMb  litres, " 
  echo "8 AM  $q8AM ,  $q8AMb  litres, " 
  echo "9 AM  $q9AM ,  $q9AMb  litres, " 
  echo "10 AM $q10AM ,  $q10AMb litres, " 
  echo "11 AM $q11AM ,  $q11AMb litres, "
  echo "12 PM $q12PM ,  $q12PMb litres, "
  echo "1 PM  $q1PM ,  $q1PMb  litres, "
  echo "2 PM  $q2PM ,  $q2PMb  litres, "
  echo "3 PM  $q3PM ,  $q3PMb  litres, "
  echo "4 PM  $q4PM ,  $q4PMb  litres, "
  echo "5 PM  $q5PM ,  $q5PMb  litres, "
  echo "6 PM  $q6PM ,  $q6PMb  litres, "
  echo "7 PM  $q7PM ,  $q7PMb  litres, "
  echo "8 PM  $q8PM ,  $q8PMb  litres, "
  echo "9 PM  $q9PM ,  $q9PMb  litres, "
  echo "10 PM $q10PM ,  $q10PMb litres, "
  echo "11 PM $q11PM ,  $q11PMb litres, "
  echo "12 AM $q12AM ,  $q12AMb litres, "
  # Replace with your custom logging code
  if [ ! -z "$CURL_API" ]; then
    echo "Logging to custom API"
    # For example, CURL_API would be "https://mylogger.herokuapp.com?value="
    # Currently uses a GET request
    curl -L "$CURL_API$consumption"
  fi

  kill $rtl_tcp_pid # rtl_tcp has a memory leak and hangs after frequent use, restarts required - https://github.com/bemasher/rtlamr/issues/49
  sleep 60 # I don't need THAT many updates

  # Let the watchdog know we've done another cycle
  touch updated.log
done

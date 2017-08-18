#!/bin/bash

declare -i evening
declare -i morning
declare -i night
declare -i flowrate

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

  consumption=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1000')
  echo "Consumption Irrigation Meter: $consumption Cubic Meters"
  irrmeter=$consumption
  
  irr=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1')
  
  #convert to integer
  irrint=${irr%.*}
  
  # record data for nightly consumption of Irrigation meter at 9 PM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 3 && `date +%H` -lt 4 ]];then
    evening=$irrint
    echo $evening > /data/binevening
  fi
  
  # record data for nightly consumption of Irrigation meter at 9 AM (time is adjusted due to UTC)
  if [[ `date +%H` -ge 15 && `date +%H` -lt 16 ]];then
    morning=$irrint
    echo $morning > /data/binmorning
  fi

  json=$(rtlamr -msgtype=r900 -filterid=$METERID2 -single=true -format=json)
  echo "Pit meter info: $json"
  
  consumption=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1000')
  #echo "Consumption Pit Meter: $consumption Cubic Meters"
  pitmeter=$consumption
  
  pit=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/1')
  
  #convert to integer
  pitint=${pit%.*}
  
  # subtract irrigation meter from main pit meter
  house=$(echo $((pitint - irrint)))
  #convert to cubic meters
  housemeter=$(echo $((house / 1000)))
  
  #calculate irrigation consumption for previous night done after 9 AM (adjusted for UTC)
  evening=$(cat /data/binevening)
  morning=$(cat /data/binmorning)
  if [[ `date +%H` -ge 16 && `date +%H` -lt 17 ]];then
    night=$(echo $((morning - evening)))
    flowrate=$(echo $((night / 720)))
    echo $night > /data/binnight
    echo $flowrate > /data/binflowrate
  fi
  
  # recall data from disk
  night=$(cat /data/binnight)
  flowrate=$(cat /data/binflowrate)
  
  echo "It is presently the "`date +%H`"th hour (UTC) of the day"
  echo "Total Consumption of Irrigation meter at 9 PM (PDT)          : $evening Litres"
  echo "Total Consumption of Irrigation meter at 9 AM (PDT)          : $morning Litres"
  echo "Irrigation consumption last night from 9 PM to 9 AM (PDT) was: $night Litres"
  echo "Average Irrigation rate of flow last night                   : $flowrate Litres per min"
   
  #now echo all three together
  echo "Consumption Pit Meter     : $pitmeter Cubic Meters"
  echo "Consumption Irrigation    : $irrmeter Cubic Meters"
  echo "Consumption Non-Irrigation: $housemeter Cubic Meters"
  
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


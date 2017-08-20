# Raspberry Pi tracker for two Neptune R900M smart water meters.

### Goals
- A Raspberry Pi and a RTL-SDR to track my smart water meter
- Docker to simplify the installation and setup of RTLAMR
- Resin.io to deploy this docker container to the Raspberry Pi in my house
- Since I have two meters in series with deductive billing, I deduct the consumption of the second meter from the consumption of the main meter.
- Be aware the R900M does not transmit rate of flow information in its FM radio signal. My original intention was to track the rate of flow (that can be read on the digital display of the meter) on my cell phone to know if my drip irrigartion system is functioning correctly.

## Credit

- I copied everything from Atlanta Water Meter (https://github.com/mdp/AtlantaWaterMeter) and modified the daemon.sh file to fit my two meter deductive billing situation here in Lake Country Canada.  I also changed the units from Cubic Feet to Cubic Meters as Lake Country uses the Neptune R900M meters which measure consumption in metric.
- @besmasher - Built the excellent [RTLAMR](https://github.com/bemasher/rtlamr) library which actually does all the work of reading the meters.
- [Frederik Granna's](https://bitbucket.org/fgranna/) docker base for setting up RTL-SDR on the Raspberry Pi

## Requirements

- Raspberry Pi 3 (Might work on others, only tested on the 3)
- [RTL-SDR](https://www.amazon.com/NooElec-NESDR-Mini-Compatible-Packages/dp/B009U7WZCA)
- [Resin.io](https://resin.io) for deployment and installation to the Raspberry pi
- Optional: [StatX](https://statx.io) for reporting

## Installation

- Signup for [Resin.io](https://resin.io)
- Create a new Application and download the image for the Raspberry Pi
- Install the image on the Raspberry Pi
- Plug in your RTL-SDR into the USB port on the Raspberry Pi
- git push this repository to your Resin application
- SSH into your Raspberry Pi via Resin and start 'rtlamr' to find water meters in your area
- Once you find your Irrigation meter, enter it as an environment variable in the Resin dashboard under "METERID"
- Once you find your Main meter, enter it as an environment variable in the Resin dashboard under "METERID2"
- For the very first installation the program needs to run for 24 hours to obtain correct output data.
- Decide what you want to do with the meter readings (I use [StatX](https://statx.io) to log the readings and view them on my phone)
## Sample Output

- 19.08.17 23:36:31 (-0700) Daily Consumption Data in Litres --------------------------------------------------
- 19.08.17 23:36:31 (-0700) Total Consumption of Irrigation meter at 9 PM (PDT)    : 915888 Litres
- 19.08.17 23:36:31 (-0700) Total Consumption of Irrigation meter at 9 AM (PDT)    : 911094 Litres
- 19.08.17 23:36:31 (-0700) Irrigation Consumption last night (9PM to 9AM PDT) was : 10221 Litres
- 19.08.17 23:36:31 (-0700) Irrigation Consumption yesterday  (9AM to 9PM PDT) was : 4794 Litres
- 19.08.17 23:36:31 (-0700) Average Irrigation rate of flow last night (9PM to 9AM): 14 Litres per min
- 19.08.17 23:36:31 (-0700) Average Irrigation rate of flow yesterday  (9AM to 9PM): 6 Litres per min
- 19.08.17 23:36:31 (-0700) House Consumption for the previous calandar day        : 504 Litres
- 19.08.17 23:36:31 (-0700) Total Consumption Data in Cubic Meters ---------------------------------------------
- 19.08.17 23:36:31 (-0700) Consumption Pit Meter                                  : 998.155 Cubic Meters
- 19.08.17 23:36:31 (-0700) Consumption Irrigation                                 : 916.294 Cubic Meters
- 19.08.17 23:36:31 (-0700) Consumption Non-Irrigation                             : 81 Cubic Meters

## My current setup
![Raspberry Pi](https://cloud.githubusercontent.com/assets/2868/21464807/14e7c1b6-c957-11e6-8049-69b19969f817.jpg)

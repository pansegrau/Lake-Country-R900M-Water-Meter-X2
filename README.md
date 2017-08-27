# Raspberry Pi tracker for two Neptune R900M smart water meters.

### Goals
- A Raspberry Pi and a RTL-SDR to track a farmer's smart water meters
- The program reports consumption and flow information about the domestic and irrigation system by comparing instances of consumption over time.  By knowing which hours the zone valves are open, the farmer is better able to follow how each of his zones are acting throughout the day.  It also tracks house consumption for billing purposes.
- Docker to simplify the installation and setup of RTLAMR
- Resin.io to deploy this docker container to the Raspberry Pi at the farm.
- Since the two meters are in series with deductive billing, the consumption of the irrigation meter is deducted from the consumption of the principal meter.
- Be aware the R900M does not transmit rate of flow information in its FM radio signal. My original intention was to track the rate of flow (that can be read on the digital display of the meter) on my cell phone to know if my drip irrigartion system is functioning correctly.
 

## Credit

- I copied the program from Atlanta Water Meter (https://github.com/mdp/AtlantaWaterMeter) and then modified the daemon.sh file to fit my two meter deductive billing situation on my farm here in Lake Country Canada.  I also changed the units from Cubic Feet to Cubic Meters as Lake Country uses the Neptune R900M meters which measure consumption in metric.
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
- Enter four separate environment variables (ZONETIMEA, ZONETIMEB, ZONETIMEC, ZONETIMED, ZONETIMEE, ZONETIMEF, ZONETIMEG, ZONETIMEH) to 180.  Or set them to the flowtime (<180) for each control valve to output a correct flowrate calculation.
- For the very first installation the program needs to run for 24 hours to obtain correct output data.
- Decide what you want to do with the meter readings (I use [StatX](https://statx.io) to log the readings and view them on my phone)
## Sample Output

- ____________________________________________________________________________________________
-  Hourly updates for Irrigation trouble-shooting
-  Quantity and the Approximate Average Flow-Rate each hour
- ___________________________________________________________________________________________
- 27.08.17 06:44:47 (-0700)  1 AM  0         litres,     0 litres per min
- 27.08.17 06:44:47 (-0700)  2 AM  0         litres,     0 litres per min
- 27.08.17 06:44:47 (-0700)  3 AM  1         litres,     1 litres per min
- 27.08.17 06:44:47 (-0700)  4 AM  258     litres,     4.30 litres per min
- 27.08.17 06:44:47 (-0700)  5 AM  951     litres,     15.85 litres per min
- 27.08.17 06:44:47 (-0700)  6 AM  706     litres,     11.76 litres per min
- 27.08.17 06:44:47 (-0700)  7 AM  110     litres,     1.83 litres per min
- ....
- 
- Daily Consumption Data in Litres
- Total Consumption of Irrigation meter at 9 PM (PDT)    : 980758  Litres
- Total Consumption of Irrigation meter at 9 AM (PDT)    : 978364  Litres
- Irrigation Consumption last night (9PM to 9AM PDT)     : 3054 Litres
- Irrigation Consumption yesterday  (9AM to 9PM PDT)     : 2394   Litres
- Average Irrigation rate of flow last night (9PM to 9AM): 4.24 Litres per min
- Average Irrigation rate of flow yesterday  (9AM to 9PM): 3.32  Litres per min
- House Consumption for the previous calandar day        : 275 Litres
 
 ********************************************************************************************
 *                Total Consumption Data in Cubic Meters
 *    Consumption Pit Meter                           1067.875 Cubic Meters
 *    Consumption Irrigation                          983.11 Cubic Meters
 *    Consumption Non-Irrigation                      84.76 Cubic Meters
 ********************************************************************************************

....
## My current setup
![Raspberry Pi](https://cloud.githubusercontent.com/assets/2868/21464807/14e7c1b6-c957-11e6-8049-69b19969f817.jpg)

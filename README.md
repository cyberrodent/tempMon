TempMon
=======
Some quick scripting to help deal with running Ubuntu linux on a Mac Mini where the fan control is fubarred out of the box.

bin
---
These scripts can be used to directly set the fan speed.

TempMon2.rb
-----------
I run this via cron to check the various temprature sensors, squirt the temp readings into graphite, and if the temp passes certain thressholds, spin the fan
faster or slower.

Tempmon.rb
----------
Earlier simpler version of TempMon2.rb

raw
---
<pre>
➜  ~  sensors -u
coretemp-isa-0000
Adapter: ISA adapter
Core 0:
  temp1_input: 35.00
  temp1_crit: 100.00
  temp1_crit_alarm: 0.00

applesmc-isa-0300
Adapter: ISA adapter
Master :
  fan1_input: 2098.00
  fan1_min: 1500.00
TA0P:
  temp1_input: 128.00
TC0D:
  temp2_input: 45.00
TC0H:
  temp3_input: 38.75
TC0P:
  temp4_input: 44.00
TC1P:
  temp5_input: 45.50
TN0P:
  temp6_input: 42.75
TN1P:
  temp7_input: 43.50
</pre>


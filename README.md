# lm393_speed_sensor_vhdl
Main goal of this code is to get rev/s values from speed sensor based in lm393.

System Interface :
----------------
pulse_counter.vhd
| Pins   | Io | Notes |
| -------- | ---- | --------------------- |
| i_clk | clock | Master clock (50 MHz) |
| i_reset | input | Asynchronious reset active high | 
| i_en | input | enable |
| i_data | input | sensor data in |
| o_pulse | output | 12 bit rev/s |


Contains:
1. ANTIREBOTE.vhd   ---- digital filter low pass filter
2. CLOCK_DIV_50.vhd ---- Clock divisor for getting low pass cut freqyuenc

3. pulse_counter.vhd ---- it counts the amount of high flanks during 1 second
4. pulse_counter_avalon.vhd --- setup a digital filter low pass filter to eliminate noise and gives you rev/seg through avalon mm

How to use:
1. Create a new quartus project
2. Go to qsys (platform designer) and add a new component , select pulse_counter_avalon.vhd
3. Connect pulse_counter to your nios data bus and export data in from pulse_counter.
4. Test it in Eclipse

It will give you rev/seg.


Questions:
dmorang@hotmail.com

https://www.linkedin.com/in/danmorang/

Daniel Moran.

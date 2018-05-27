# AXI_Stream_counter
Counts the clock cycles and sends through AXI stream

1) Reads some data and streams using AXIS_M
2) Gets that data puts in FIFO
3) Reads from FIFO and writes in memory
4) Use AXIS DMA to translate stream data into the memory mapped data
5) Reads from the memory and compares with the wrote data



Schematic:
=========

Clock Counter
=============

Counts the number of clocks, after counting 10 cycles sends that value through the S_AXIS .
The counter can wait for 10 cycles, than get the some input value and send through the S_AXIS, or just increase some another counter value and send.
Clock counter sends its data bit-by-bit through the tdata port
It contains dual port FIFO to keep the counted data, while the slave AXIS is not ready to accept it.
Also the module send the counted data by 2 nibbles enabling tlast at the second nibble


AXIS Clocking
==============
AXIS clocking is global i.e. AXIS assumes that  there is single global, clock for TX and RX. 


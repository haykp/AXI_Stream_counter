# AXI_Stream_counter
Counts the clock cycles and sends through AXI stream

1)  Reads some data and streams using AXIS_M
2) Gets that data puts in FIFO
3) Reads from FIFO and writes in memory
4) Use AXIS DMA to translate stream data into the memory mapped data
5) Reads from the memory and compares with the wrote data

// Calculates the number of clock cycles
// counts 10 clocks and at each 10th clock sends the data
// when total counter number of clocks equals to cntLimit than enabled tlast

`timescale 1us/1us

module clockCounter (input start, rst, clk, input [5:0] cntLimit, input tready, 
                     output reg tvalid,tlast, output [2:0] tdata);

reg [3:0] clkCntr;
reg [5:0] clkPkgCntr;

reg sendData_pulse,sendData_pulse_1d,sendData_pulse_2d;

//reg rd_clk;
wire rd_en;
wire fifo_empty;
wire fifo_full;
wire fifo_wr_ack;

parameter sendState1=3'o1,
          sendState2=3'o2,
          idle = 3'o0;

reg [2:0] state, state_nxt;


wire clk0, clk90;
wire rst;
wire locked;

// Simple clock counter
always @ (posedge clk)
    if (rst)
		{sendData_pulse_1d,sendData_pulse_2d } <= 2'b00;
	else 
		{sendData_pulse_1d,sendData_pulse_2d } <= {sendData_pulse, sendData_pulse_1d};

// Simple clock counter
always @ (posedge clk)
    if (rst)
        clkCntr <= 4'h0;
    else
        clkCntr <= (clkCntr== 4'd10) ? 4'h0 : clkCntr + 1; //just counts the clock cycles

// count the clock packages, resets the packages when they become equal to cntLimit
/// pulse to initiate data sending by AXIS
always @ (posedge clk)
    if (rst) begin
        clkPkgCntr <= 6'h00;
        sendData_pulse <=  #1 1'b0;
        end
    else
        if (clkPkgCntr == cntLimit )
            clkPkgCntr <= 6'h00;
        else
            if (start)
            begin
                clkPkgCntr <= (clkCntr==4'd10)? clkPkgCntr+1 : clkPkgCntr;
                sendData_pulse <= (clkCntr==4'd10)? 1 : 0;
            end
            else
            begin
                clkPkgCntr <= clkPkgCntr;
                sendData_pulse <= 1'b0;
            end
        
wire wr_en;
assign wr_en = (~fifo_full) && sendData_pulse_2d;        

// internal FIFO block, to hold the data if the slave is not ready to accept it.
// Read latency is 1 clock cycle, from rising edge of the read clock
fifo_generator_0 dataFifo (
  .rst(rst),        // input wire rst
  .wr_clk(clk),  // input wire wr_clk
  .wr_en(wr_en),    // input wire wr_en
  .din(clkPkgCntr),        // input wire [5 : 0] din
  .wr_ack(fifo_wr_ack),
  
  .rd_clk(clk),  // input wire rd_clk
  .rd_en(rd_en),    // input wire rd_en
  .dout(tdata),      // output wire [2 : 0] dout
  
  .full(fifo_full),      // output wire fifo_full
  .empty(fifo_empty)  // output wire empty
);

// as soon as the fifo becomes no empty the tvalid goes high
always @ (posedge clk)
    if (rst)
        tvalid <= 1'b0;
    else if (~fifo_empty )
            tvalid <= 1'b1;
        else
            tvalid <= 1'b0;

assign rd_en  = tvalid & tready;
			
// single clkPkgCntr is send by 2 nibbles
reg nibble;

always @ (posedge clk)
    if (rst) begin
        nibble <= 1'b0;
    end
    else
        if ( tvalid && tready)
            begin
                nibble <= (rd_en) ? nibble+ 1 : nibble;
            end
            else begin
                nibble <= 1'b0;
            end
        
// so tlast must be high when sending the 2nd nibble
always @ (posedge clk)
    if (rst) begin
        tlast <= 1'b0;
    end
    else
        if (nibble && tready) 
            tlast <= 1'b1;
        else 
            tlast <= 1'b0;
         

endmodule

// Calculates the number of clock cycles
// counts 10 clocks and at each 10th clock sends the data
// when total counter number of clocks equals to cntLimit than enabled tlast

`timescale 1us/1us

module clockCounter (input start, rst, clk, input [5:0] cntLimit, input tready, 
                     output reg tvalid,tlast, output [2:0] tdata);

reg [3:0] clkCntr;
reg [5:0] clkPkgCntr;

reg sendData_pulse;

//reg rd_clk;
reg rd_en;
wire empty;
wire full;

parameter sendState1=3'o1,
          sendState2=3'o2,
          idle = 3'o0;

reg [2:0] state, state_nxt;

// Simple clock counter
always @ (posedge clk)
    if (rst)
        clkCntr <= 4'h0;
    else
        clkCntr <= (clkCntr== 4'd10) ? 4'h0 : clkCntr + 1; //just counts the clock cycles

// count the clock packages, resets the packages when they become equal to
// cntLimit
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
                sendData_pulse <= #1 (clkCntr==4'd10)? 1 : 0;
            end
            else
            begin
                clkPkgCntr <= clkPkgCntr;
                sendData_pulse <= #1 1'b0;
            end
        
wire wr_en;
assign wr_en = (~full) && sendData_pulse;        

// as soon as the fifo becomes no empty the tvalid goes high
always @ (posedge clk)
    if (rst)
        tvalid <= 1'b0;
    else if (~empty )
            tvalid <= 1'b1;
        else
            tvalid <= 1'b0;

// single clkPkgCntr is send by 2 nibbles
reg nibble;

always @ (posedge clk)
    if (rst) begin
        nibble <= 1'b0;
    end
    else
        if ( ~empty && tready)
            begin
                nibble <= nibble+ 1;
            end
            else begin
                nibble <= 1'b0;
            end
        

// so tlast must be high when sending the 2nd nibble
always @ (negedge clk)
    if (rst) begin
        tlast <= 1'b0;
    end
    else
        if (nibble && tready) 
            tlast <= 1'b1;
        else 
            tlast <= 1'b0;
         
//if fifo is not empty and slave is ready to accept the data
// starts reading the data from the FIFO
always @ (negedge clk)
    if (rst) begin
        rd_en <= 1'b0;
    end
    else
        if ( ~empty && tready)
                rd_en <= 1'b1;
            else 
			rd_en <= 1'b0;
           
wire wr_ack;
fifo_generator_0 dataFifo (
  .rst(rst),        // input wire rst
  .wr_clk(clk),  // input wire wr_clk
  .wr_en(wr_en),    // input wire wr_en
  .din(clkPkgCntr),        // input wire [5 : 0] din
  .wr_ack(wr_ack),
  
  .rd_clk(clk),  // input wire rd_clk
  .rd_en(rd_en),    // input wire rd_en
  .dout(tdata),      // output wire [2 : 0] dout
  
  .full(full),      // output wire full
  .empty(empty)  // output wire empty
);



endmodule

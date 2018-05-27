`timescale 1us/1us

module TB_fifo ();

default clocking cb @(posedge clk);
endclocking

bit clk, rst, start;
logic [5:0] cntLimit;

logic [2:0] tdata;
logic [5 : 0] din = 6'o12;
bit wr_en, rd_en;
logic full, empty, wr_ack;

// write depth 16
fifo_generator_0 dataFifo (
  .rst(rst),        // input wire rst
  .wr_clk(clk),  // input wire wr_clk
  .rd_clk(clk),  // input wire rd_clk
  .din(din),        // input wire [5 : 0] din
  .wr_en(wr_en),    // input wire wr_en
  .rd_en(rd_en),    // input wire rd_en
  .dout(tdata),      // output wire [2 : 0] dout
  .full(full),      // output wire full
  .empty(empty)  ,  // output wire empty
  .wr_ack(wr_ack)
);

initial
begin
    wr_en <= 0;
    @ (negedge full) ;
    #2 wr_en <= 1;
    ##16 wr_en <= 0;
    //##20 wr_en <= 0;
    //@ (posedge wr_ack)
    #1 wr_en = 0;
//    #2 wr_en = 0;
end

initial 
begin
    rd_en <= 0;
   // @ (negedge full);
   // ##15 rd_en <= 1;
   // ##29 rd_en <=0;
end

initial 
 forever #5 clk++;

initial
begin
    rst <= 1;
    ##4 rst <= 0;
end

initial
begin
##20    start <= 1;
end

endmodule

`timescale 1us/1us

module TB_clockCounter ();

default clocking cb @(posedge clk);
endclocking

bit clk, rst, start;
logic [5:0] cntLimit;

logic tready; 
logic tvalid, tlast;
logic [2:0] tdata;


assign cntLimit=6'd40;

clockCounter inst (.start(start), .rst(rst), .clk(clk), .cntLimit(cntLimit), .tready(tready), 
                    .tvalid(tvalid),.tlast(tlast),.tdata(tdata));

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


initial
begin
    tready =0;
    ##50 tready = 1;
    ##60 tready = 0 ;
end


endmodule

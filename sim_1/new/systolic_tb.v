`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/16 10:44:06
// Design Name: 
// Module Name: systolic_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`define cycle_period 3.01
module systolic_tb;


localparam DATA_WIDTH = 16;
localparam OUT_DATA_WIDTH = 16;
localparam SRAM_DATA_WIDTH = 32;
localparam WEIGHT_NUM = 25, WEIGHT_WIDTH = 4;
localparam ARRAY_SIZE = 8;


reg clk;
reg rst;

wire [4*DATA_WIDTH-1:0]data_out;

reg [DATA_WIDTH-1:0] data_fifo_0;
reg [DATA_WIDTH-1:0] data_fifo_1;
reg [DATA_WIDTH-1:0] weight_fifo_0;
reg [DATA_WIDTH-1:0] weight_fifo_1;

reg systolic_en;

initial begin
     rst = 1'b1;
    clk = 1'b1;
    #(`cycle_period/2);
    while(1) begin
      #(`cycle_period/2) clk = ~clk; 
    end
end


initial begin 
 #100 rst = 0 ;
 #100 rst = 1 ;
 #100 data_fifo_0 = 16'h0001;
  #100 data_fifo_1 = 16'h0002;
  #100 weight_fifo_0 = 16'h0003;
  #100 weight_fifo_1 = 16'h0004;
  #100 data_fifo_0 = 16'h0005;
  #100 data_fifo_1 = 16'h0006;
  #100 weight_fifo_0 = 16'h0007;
  #100 weight_fifo_1 = 16'h0008;
  #100 systolic_en = 1'b1;

  #1000 systolic_en = 1'b0;



end



systolic #(.datawith(DATA_WIDTH))  systolic1(
    .clk(clk),
    .rst(rst),
    .weight_1(weight_fifo_0),
    .weight_2(weight_fifo_1),
    .data_1(data_fifo_0),
    .data_2(data_fifo_1),
    .systolic_en(systolic_en),
    .data_out(data_out)
);  
endmodule
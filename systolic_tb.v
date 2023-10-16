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




initial begin
    rst = 1'b1;
    clk = 1'b1;
    #(`cycle_period/2);
    while(1) begin
      #(`cycle_period/2) clk = ~clk; 
    end
end




systolic #(.datawith(DATA_WIDTH))  systolic1(
 .clk(clk),
     .rst(rst),
     .weight_1(),
     .weight_2(),
     .data_1(),
    .data_2(),
    .systolic_en(),
    .data_out()
);
endmodule
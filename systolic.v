`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/16 10:35:10
// Design Name: 
// Module Name: systolic
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

module systolic#(
    parameter datawith = 16,
    parameter array_size = 4                                                                                                                                                                                                                                                                                                                                                                                                 
)
(
    input clk,
    input rst,
    input [datawith-1:0] weight_1,
    input [datawith-1:0] weight_2,
    input [datawith-1:0] data_1,
    input [datawith-1:0] data_2,

    input systolic_en,
    output [4*datawith-1:0] data_out
);

//pe array
wire [datawith-1:0] data_shitf [0:array_size-1][0:array_size-1];
wire [datawith-1:0] weight_shitf [0:array_size-1][0:array_size-1];

wire [datawith-1:0] data_fifo_0;
wire [datawith-1:0] data_fifo_1;
wire [datawith-1:0] weight_fifo_0;
wire [datawith-1:0] weight_fifo_1;


wire [datawith-1:0] data_out00,data_out01,data_out10,data_out11;

assign data_out = {data_out00,data_out01,data_out10,data_out11};
pe #(.datawith(datawith)) pe_00(
    .clk(clk),
    .rst(rst),
    .data_in(data_fifo_0),
    .weight_in(weight_fifo_0),
    .data_out(data_shitf[0][0]),
    .weight_out(weight_shitf[0][0]),
    .result(data_out00)
);

pe #(.datawith(datawith)) pe_01(
    .clk(clk),
    .rst(rst),
    .data_in(data_shitf[0][0]),
    .weight_in(weight_fifo_1),
    .data_out(data_shitf[0][1]),
    .weight_out(weight_shitf[0][1]),
    .result(data_out01)
);

pe #(.datawith(datawith)) pe_10(
    .clk(clk),
    .rst(rst),
    .data_in(data_fifo_1),
    .weight_in(weight_shitf[0][0]),
    .data_out(data_shitf[1][0]),
    .weight_out(weight_shitf[1][0]),
    .result(data_out10)
);

pe #(.datawith(datawith)) pe_11(
    .clk(clk),
    .rst(rst),
    .data_in(data_shitf[1][0]),
    .weight_in(weight_shitf[0][1]),
    .data_out(data_shitf[1][1]),
    .weight_out(weight_shitf[1][1]),
    .result(data_out11)
);



endmodule


///result station 
module pe
#(
        parameter datawith = 16
)
(
    input clk,
    input rst,
    inout [datawith-1:0] data_in,
    inout [datawith-1:0] weight_in,
    output reg [datawith-1:0] data_out,
    output reg  [datawith-1:0] weight_out,
    //output [datawith-1:0] mul_result_out,
    output reg [datawith-1:0] result


);
wire [datawith-1:0] mul_result_out;
reg [datawith-1:0] add_result_out;

assign  mul_result_out = data_in * weight_in;

always @(posedge clk,negedge rst) begin
    if(!rst) begin 
        add_result_out <= 0;
    end
       ///////////here is int multiply
    result <= mul_result_out + result;   
end


// always @(posedge clk,negedge rst) begin
//     if(!rst) begin 
//         result <= 0;
//     end
//     result <=  add_result_out;
// end



always @(posedge clk,negedge rst)begin
    if(!rst)begin
    data_out <= 0;
    weight_out <=0;
    end
    else 
    begin
    data_out <= data_in;
    weight_out <= weight_in;
    end
end

endmodule




// module 

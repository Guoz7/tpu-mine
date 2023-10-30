`timescale 1ns / 100ps
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
    parameter array_size = 2                                                                                                                                                                                                                                                                                                                                                                                                 
)
(
    input clk,
    input rst,
    input [array_size*datawith-1:0] weight_in,
    input [array_size*datawith-1:0] data_in,

    input systolic_en,
    output [array_size*array_size*datawith-1:0] data_out
);


wire [datawith-1:0] weight_1;
wire [datawith-1:0] weight_2;
wire [datawith-1:0] data_1;
wire [datawith-1:0] data_2;
// we need check the bit location 
assign weight_1 = weight_in[datawith-1:0];
assign weight_2 = weight_in[2*datawith-1:datawith];
assign data_1 = data_in[datawith-1:0];
assign data_2 = data_in[2*datawith-1:datawith];

reg [array_size*array_size-1:0]pe_count;


//pe array
wire [datawith-1:0] data_shitf [0:array_size-1][0:array_size-1];
wire [datawith-1:0] weight_shitf [0:array_size-1][0:array_size-1];

wire [datawith-1:0] data_fifo_0;
wire [datawith-1:0] data_fifo_1;
wire [datawith-1:0] weight_fifo_0;
wire [datawith-1:0] weight_fifo_1;


assign data_fifo_0 = data_1;
assign data_fifo_1 = data_2;
assign weight_fifo_0 = weight_1;
assign weight_fifo_1 = weight_2;

wire [datawith-1:0] data_out00,data_out01,data_out10,data_out11;

assign data_out = {data_out00,data_out01,data_out10,data_out11};

always @(posedge clk,negedge rst,negedge systolic_en)begin
    if(!rst || !systolic_en) begin
        pe_count <= 0;
    end
    else 
    begin
        if(systolic_en && pe_count < 16) 
            pe_count <= pe_count + 1;
    end
end

integer i;

wire [16 -1:0] pe_en;


assign pe_en[0] = (pe_count > 0) ;
assign pe_en[1] = (pe_count > 1) ;
assign pe_en[2] = (pe_count > 2) ;
assign pe_en[3] = (pe_count > 3) ;



// assign pe_en = (pe_count == 3);
// assign pe11_en = (pe_count == 4);

pe #(.datawith(datawith)) pe_00(
    .clk(clk),
    .rst(rst),
    .data_in(data_fifo_0),
    .weight_in(weight_fifo_0),
    .data_out(data_shitf[0][0]),
    .weight_out(weight_shitf[0][0]),
    .result(data_out00),
    .pe_en(pe_en[0])
);

pe #(.datawith(datawith)) pe_01(
    .clk(clk),
    .rst(rst),
    .data_in(data_shitf[0][0]),
    .weight_in(weight_fifo_1),
    .data_out(data_shitf[0][1]),
    .weight_out(weight_shitf[0][1]),
    .result(data_out01),
    .pe_en(pe_en[1])
);

pe #(.datawith(datawith)) pe_10(
    .clk(clk),
    .rst(rst),
    .data_in(data_fifo_1),
    .weight_in(weight_shitf[0][0]),
    .data_out(data_shitf[1][0]),
    .weight_out(weight_shitf[1][0]),
    .result(data_out10),
    .pe_en(pe_en[1])
);

pe #(.datawith(datawith)) pe_11(
    .clk(clk),
    .rst(rst),
    .data_in(data_shitf[1][0]),
    .weight_in(weight_shitf[0][1]),
    .data_out(data_shitf[1][1]),
    .weight_out(weight_shitf[1][1]),
    .result(data_out11),
    .pe_en(pe_en[2])
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

    input pe_en,

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
        result <= 0;
    end
       ///////////here is int multiply
   else
   begin
    if (pe_en) 
    result <= mul_result_out + result;
    else result <=  result;
    end   
end





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

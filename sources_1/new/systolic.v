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
    parameter datawidth = 16,
    parameter array_size =2                          
)
(
    input clk,
    input rst,
    input [array_size*datawidth-1:0] weight_in,
    input [array_size*datawidth-1:0] data_in,
    input read_all_data,

    input systolic_en,
    output [array_size*array_size*datawidth-1:0] data_out,
    output reg compute_done
);


wire [datawidth-1:0] weight_1;
wire [datawidth-1:0] weight_2;
wire [datawidth-1:0] data_1;
wire [datawidth-1:0] data_2;
// we need check the bit location 
assign weight_1 = weight_in[datawidth-1:0];
assign weight_2 = weight_in[2*datawidth-1:datawidth];
assign data_1 = data_in[datawidth-1:0];
assign data_2 = data_in[2*datawidth-1:datawidth];

reg [array_size*array_size-1:0]pe_count;


//pe array
wire [datawidth-1:0] data_shitf [0:array_size-1][0:array_size-1];
wire [datawidth-1:0] weight_shitf [0:array_size-1][0:array_size-1];

wire [datawidth-1:0] data_fifo_0;
wire [datawidth-1:0] data_fifo_1;
wire [datawidth-1:0] weight_fifo_0;
wire [datawidth-1:0] weight_fifo_1;


assign data_fifo_0 = data_1;
assign data_fifo_1 = data_2;
assign weight_fifo_0 = weight_1;
assign weight_fifo_1 = weight_2;

reg [$clog2(array_size*2)-1:0]pe_done_count;


wire [array_size* datawidth-1:0] mul_result_out;

assign data_out = {data_out11,data_out10,data_out01,data_out00};

always @(posedge clk,negedge rst,negedge systolic_en)begin
    if(!rst || !systolic_en) begin
        pe_count <= 0;
    end
    else if(systolic_en && pe_count < array_size*2) begin
            pe_count <= pe_count + 1;
    end
end

integer i,j;

always @(posedge clk,negedge rst) begin
    if(!rst) begin
        pe_done_count <= 0;
    end
    else if(read_all_data && pe_done_count < array_size*2-1) begin
        pe_done_count <= pe_done_count + 1;
    end
end



/////generate the pe enable signal
wire [array_size * array_size - 1:0] pe_en;

for (i = 0; i < array_size ; i++) begin
    for (j = 0; j < array_size ; j++) begin
        assign pe_en[i*array_size+j] = (pe_done_count > i*array_size+j) ? 0 : (pe_count > i*array_size+j);
    end
end
assign pe_en[0] = (pe_done_count >0 && read_all_data)?0: (pe_count > 0 && systolic_en ) ;   //systolic_en is computer start
// assign pe_en[1] = (pe_done_count >1) ? 0 : (pe_count > 1  ) ;
// assign pe_en[2] = (pe_done_count >2) ? 0 : (pe_count > 2   ) ;
// assign pe_en[3] = (pe_done_count >3) ? 0 : (pe_count > 3   ) ;


////////generate the data_shift and weight_shift
wire [datawidth-1:0] data_shitf [0:array_size-1][0:array_size-1];
wire [datawidth-1:0] weight_shitf [0:array_size-1][0:array_size-1];

// for (i = 0; i < array_size ; i++) begin
//     for (j = 0; j < array_size ; j++) begin
//         if(i == 0 ) begin
//             assign weight_shitf[i][j] = weight_in[j*datawidth+7,j*datawidth];
//         end
//         else if( j == 0) begin
//             assign data_shitf[i][j] = data_in[i*datawidth+7,i*datawidth];
//         end
//     end
// end




always @ (posedge clk,negedge rst) begin
if(!rst)begin
    compute_done <= 0;
end
else
begin
    if(pe_done_count == array_size*2-1) begin
        compute_done <= 1;
    end
    else begin
        compute_done <= compute_done;
    end

end



end



genvar row   , col;
generate
for(row = 0; row < array_size; row = row + 1) begin : row_gen

    for(col = 0; col < array_size; col = col + 1) begin  : col_gen
        if (row == 0 && col == 0) begin
            pe #(.datawidth(datawidth)) pe_00(
                .clk(clk),
                .rst(rst),
                .data_in(data_in[7:0]),
                .weight_in(weight_in[7:0]),
                .data_out(data_shitf[0][0]),
                .weight_out(weight_shitf[0][0]),
                .result(mul_result_out[15:0]),
                .pe_en(pe_en[0][0])
            );
        end else if (row == 0 && col != 0) begin
            pe #(.datawidth(datawidth)) pe_0j(
                .clk(clk),
                .rst(rst),
                .data_in(data_shitf[0][col-1]),
                .weight_in(weight_in[col*datawidth+7,col*datawidth]),
                .data_out(data_shitf[0][col]),
                .weight_out(weight_shitf[0][col]),
                .result(mul_result_out[col*datawidth+7:col*datawidth]),
                .pe_en(pe_en[0][col])
            );
        end else if (row != 0 && col == 0) begin
            pe #(.datawidth(datawidth)) pe_i0(
                .clk(clk),
                .rst(rst),
                .data_in(data_in[row*datawidth+7,row*datawidth]),
                .weight_in(weight_shitf[row-1][0]),
                .data_out(data_shitf[row][0]),
                .weight_out(weight_shitf[row][0]),
                .result(mul_result_out[row*datawidth+7:row*datawidth]),
                .pe_en(pe_en[row][0])
            );
        end else begin
            pe #(.datawidth(datawidth)) pe_ij(
                .clk(clk),
                .rst(rst),
                .data_in(data_shitf[row][col-1]),
                .weight_in(weight_shitf[row-1][col]),
                .data_out(data_shitf[row][col]),
                .weight_out(weight_shitf[row][col]),
                .result(mul_result_out[row*datawidth+col+7:row*datawidth+col]),
                .pe_en(pe_en[row][col])
            );
        end
    end
end
endgenerate





// assign pe_en = (pe_count == 3);
// assign pe11_en = (pe_count == 4);

pe #(.datawidth(datawidth)) pe_00(
    .clk(clk),
    .rst(rst),
    .data_in(data_fifo_0),
    .weight_in(weight_fifo_0),
    .data_out(data_shitf[0][0]),
    .weight_out(weight_shitf[0][0]),
    .result(data_out00),
    .pe_en(pe_en[0])
);

pe #(.datawidth(datawidth)) pe_01(
    .clk(clk),
    .rst(rst),
    .data_in(data_shitf[0][0]),
    .weight_in(weight_fifo_1),
    .data_out(data_shitf[0][1]),
    .weight_out(weight_shitf[0][1]),
    .result(data_out01),
    .pe_en(pe_en[1])
);

pe #(.datawidth(datawidth)) pe_10(
    .clk(clk),
    .rst(rst),
    .data_in(data_fifo_1),
    .weight_in(weight_shitf[0][0]),
    .data_out(data_shitf[1][0]),
    .weight_out(weight_shitf[1][0]),
    .result(data_out10),
    .pe_en(pe_en[1])
);

pe #(.datawidth(datawidth)) pe_11(
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
        parameter datawidth = 16
)
(
    input clk,
    input rst,

    input pe_en,

    inout [datawidth-1:0] data_in,
    inout [datawidth-1:0] weight_in,
    output reg [datawidth-1:0] data_out,
    output reg  [datawidth-1:0] weight_out,
    //output [datawidth-1:0] mul_result_out,
    output reg [datawidth-1:0] result


);
wire [datawidth-1:0] mul_result_out;

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



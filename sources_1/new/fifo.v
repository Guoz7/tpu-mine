`timescale 1ns/1ns
/**********************************RAM************************************/
module dual_port_RAM #(parameter DEPTH = 16,
					   parameter WIDTH = 8)(
	 input wclk
	,input wenc
	,input [$clog2(DEPTH)-1:0] waddr  //深度对2取对数，得到地址的位宽。
	,input [WIDTH-1:0] wdata      	//数据写入
	,input rclk
	,input renc
	,input [$clog2(DEPTH)-1:0] raddr  //深度对2取对数，得到地址的位宽。
	,output reg [WIDTH-1:0] rdata 		//数据输出
);

reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

always @(posedge wclk) begin
	if(wenc)
		RAM_MEM[waddr] <= wdata;
end 

always @(posedge rclk) begin
	if(renc)
		rdata <= RAM_MEM[raddr];
end 

endmodule  

/**********************************SFIFO************************************/
module sfifo#(
	parameter	WIDTH = 8,
	parameter 	DEPTH = 16
)(
	input 					clk		, 
	input 					rst_n	,
	input 					winc	,
	input 			 		rinc	,
	input 		[WIDTH-1:0]	wdata	,

	output 			reg	wfull	,
	output 			reg	rempty	,
	output wire [WIDTH-1:0]	rdata
);

localparam addr = $clog2(DEPTH);
// generate addr
reg [$clog2(DEPTH):0] wr_ptr;
reg [$clog2(DEPTH):0] rd_ptr;

wire [addr:0] count;
wire w_en;
wire r_en;

assign count = (wr_ptr[addr] == rd_ptr[addr] )? (wr_ptr[addr:0] - rd_ptr[addr:0]):(DEPTH +wr_ptr[addr-1:0] - rd_ptr[addr-1:0]);

assign w_en = winc && !wfull;
assign r_en = rinc && !rempty;




// write loogic
always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        wr_ptr <= 0;
    end
    else begin
        if(w_en) begin
            wr_ptr <= wr_ptr + 1;
    end
    end
end

//read logic
always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        rd_ptr <= 0;
    end
    else begin
        if(r_en) begin
            rd_ptr <= rd_ptr + 1;
    end
    end
end


//   full_flag
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        wfull <= 'd0;
        rempty <= 'd0;
    end 
    else if(count == 'd0)begin
        rempty <= 1'd1;
    end
    else if(count == DEPTH)begin
        wfull <= 1'd1;
    end
    else begin
        wfull <= 'd0;
        rempty <= 'd0;
    end 
end

endmodule




// module sram1#(
//     parameter WIDTH = 16,
//     parameter DEPTH = 1024
// )

// (
//     input clk,
//     input rst_n,
//     input [9:0] addr,
//     input [WIDTH-1:0] w_data,
//     input wr,
//     output reg [WIDTH-1:0] read_data

// );


// localparam len = $clog2(DEPTH);
// reg [WIDTH-1:0] sram [0:len-1];

// always @(posedge clk,negedge rst_n) begin
//     if(!rst_n) begin
//         sram[0] <= 0;
//     end
//     else begin
//         if(wr == 1) begin
//             sram[addr] <= w_data;
//         end
//     end
// end

// always @(posedge clk,negedge rst_n) begin
//     if(!rst_n) begin
//         read_data <= 0;
//     end
//     else begin
//         if(wr == 0) begin
//             read_data <= sram[addr];
//         end
//     end
// end

// endmodule
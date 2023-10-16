module systolic_control(
    parameter datawith = 16,
    parameter array_size = 8
)(
    input clk,
    input rst,
    input tpu_start,																//total enable signal
	
	output reg sram_write_enable,

	//addr_sel
	output reg [6:0] addr_serial_num,

	//systolic array
	output reg alu_start,																//shift & multiplcation start
	output reg [8:0] cycle_num,													//for systolic.v
	output reg [5:0] matrix_index,													//index for write-out SRAM data
	output reg [1:0] data_set,

    output reg [2 * datawith -1 :0] fifo_start_alu,

	output reg tpu_done	

);
// status machine 

localparam  states1 = 3'b000;
localparam states2 = 3'b001;
localparam states3 = 3'b010;

reg [array_size -1:0] data_start;
reg [array_size -1:0] weight_start;

assign fifo_start_alu = {data_start,weight_start};

reg states;


addr_serial_num


endmodule
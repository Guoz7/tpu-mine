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
localparam  states_wait = 3'b000;   // wait for the start signal
localparam states_read = 3'b001;    // laod the data and weight
localparam states_compu = 3'b010;	// shift and multiplcation
localparam states_write = 3'b011;	// write out the data

reg [2:0] states;
reg [2:0] next_states;

reg [array_size -1:0] data_start;
reg [array_size -1:0] weight_start;

assign fifo_start_alu = {data_start,weight_start};

reg read_start,read_done;
reg compute_start,compute_done;
reg write_start,write_done;



always @(posedge clk or posedge rst)begin
	if(rst) begin
		states <= states_wait;
		new_states <= states_wait;	
	end
	else begin
		states <= states;
		new_states <= next_states;
	end
end

always @(posedge clk,negedge rst)	begin
	if(!rst) begin
		states <= states_wait;
		negedge
end



always @(*)




always @(posedge clk or posedge rst)begin
    
end

reg states;


addr_serial_num


endmodule
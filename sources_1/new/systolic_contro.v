module systolic_control#(
    parameter datawith = 16,
    parameter array_size = 2
)(
    input clk,
    input rst,
    input tpu_start,																//total enable signal
	
	//fifo
	input rempty,
	input wfull,

	input read_done,
	input compute_done,
	input write_done,

	output reg read_start,
	output reg compute_start,
	output reg write_start,
	output reg tpu_done	
);
// status machine 
localparam  states_wait = 3'b000;   // wait for the start signal
localparam states_read = 3'b001;    // laod the data and weight
localparam states_compu = 3'b010;	// shift and multiplcation
localparam states_write = 3'b011;	// write out the data

reg [2:0] states;
reg [2:0] next_states;

// reg [array_size -1:0] data_start;
// reg [array_size -1:0] weight_start;

// assign fifo_start_alu = {data_start,weight_start};

// reg read_start,read_done;
// reg compute_start,compute_done;
// reg write_start,write_done;


always@(posedge clk,negedge rst) begin
		if(!rst) begin
		states <= states_wait;
		//next_states <= states_wait;
	end
	else 
	begin
	states <= next_states;
	end
	end


always @(*)	begin
	begin
		// states <= next_states;
		case(states)
			states_wait:begin
				if(tpu_start) begin
					next_states <= states_read;
				end
				else begin
					next_states <= states_wait;
				end
			end
			states_read:begin
				if(read_done) begin
					next_states <= states_compu;
				end
				else begin
					next_states <= states_read;
				end
			end
			states_compu:begin
				if(compute_done) begin
					next_states <= states_write;
				end
				else begin
					next_states <= states_compu;
				end
			end
			states_write:begin
				if(write_done) begin
					next_states <= states_wait;
				end
				else begin
					next_states <= states_write;
				end
			end
			default:begin
				next_states <= states_wait;
			end
		endcase
	end
end


always @(*) begin
	case(states)
		states_wait:begin
			read_start = 1'b0;
			compute_start = 1'b0;
			write_start = 1'b0;
		end
		states_read:begin
			read_start = 1'b1;
			compute_start = 1'b0;
			write_start = 1'b0;
		end
		states_compu:begin
			read_start = 1'b0;
			compute_start = 1'b1;
			write_start = 1'b0;
		end
		states_write:begin
			read_start = 1'b0;
			compute_start = 1'b0;
			write_start = 1'b1;
		end
		default:begin
			read_start = 1'b0;
			compute_start = 1'b0;
			write_start = 1'b0;
		end
	endcase
end


always @(posedge clk,negedge rst) begin
	if(!rst) begin
		tpu_done <= 0;
	end
	else if(write_done  ) begin
		tpu_done <= 1;
	end
end

///read states  


// always @(posedge clk,negedge rst) begin
// 	if(!rst) begin
// 		data_start <= 0;
// 		weight_start <= 0;
// 	end
// 	else begin
// 		if(read_start) begin
// 			if(rempty) begin
// 				data_start <= 0;
// 				weight_start <= 0;
// 			end
// 			else begin
// 				data_start <= data_start + 1;
// 				weight_start <= weight_start + 1;
// 			end
// 		end
// 		else begin
// 			data_start <= 0;
// 			weight_start <= 0;
// 		end
// 	end
// end	

endmodule
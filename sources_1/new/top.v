module tpuv1 #(parameter datawith = 16)
(
    input clk,
    input rst_n,
    input tpu_start,
    input [9:0]data_addr,
    input [3:0] data_size,
    input [datawith-1:0] data_in,
    input [datawith-1:0] weight_in,
    output [4*datawith-1:0] data_out
);

// wire [data_with-1:0] data_2_sys[3:0];
// wire [data_with-1:0] weight_2_sys[3:0];



wire [array_size*datawith-1:0] data_2_sys;
wire [array_size*datawith-1:0] weight_2_sys;



queue_array #(.datawith(datawith),.array_size(array_size)) queue_array_0(
    .clk(clk),
    .rst_n(rst_n),
    .data_addr(data_addr),
    .data_size(data_size),
    .read_start(read_start),
    .read_done(read_done),
    .compute_start(compute_start),
    .data_2_sys(data_2_sys),
    .weight_2_sys(weight_2_sys),
    .rempty(rempty),
    .wfull(wfull)
);


///control
systolic_control #(.datawith(datawith),.array_size(array_size)) systolic_control_0(
    .clk(clk),
    .rst_n(rst_n),
    .tpu_start(tpu_start),
    .rempty(rempty),
    .wfull(wfull),
    .read_done(read_done),
    .compute_done(compute_done),
    .write_done(write_done),
    .read_start(read_start),
    .compuate_start(compuate_start),
    .write_start(write_start),
    .tpu_done(tpu_done)
);


systolic #(.datawith(datawith),.array_size(array_size)) systolic_0(
    .clk(clk),
    .rst_n(rst_n),
    .weight_in(weight_2_sys),
    .data_in(data_2_sys),
    .systolic_en(compuate_start),
    .data_out(data_out)
);

endmodule



module tpuv1 #(parameter datawith = 16,
    parameter array_size = 2)
(
    input clk,
    input rst_n,
    input tpu_start,
    input [9:0]write_addr,
    input [3:0] data_size,
    input [datawith-1:0] data_in,
    input write_en,
    // input [datawith-1:0] weight_in,
    output [datawith-1:0] data_out


    // to ruduce the port of the tpu,we can use the addr to load all of the data and weight
);

// wire [data_with-1:0] data_2_sys[3:0];
// wire [data_with-1:0] weight_2_sys[3:0];



wire [array_size*datawith-1:0] data_2_sys;
wire [array_size*datawith-1:0] weight_2_sys;

// wire [array_size*datawith-1:0] data_out;
wire [9:0] data_addr;
wire [9:0] data_addr1;

wire read_start;
wire read_done;
wire compute_start;
wire compute_done;
wire write_start;
wire write_done;
wire tpu_done;
wire rempty;
wire wfull;


wire [array_size*array_size*datawith-1:0] data_out_array;
wire [9:0] read_from_sram_addr;
wire [9:0]write_back_addr;

wire [datawith-1:0]sram_data_2_fifo;

queue_array #(.datawith(datawith),.array_size(array_size)) queue_array_0(
    .clk(clk),
    .rst_n(rst_n),
    // .data_addr(data_addr),
    .data_size(data_size),
    .data_2_fifo(sram_data_2_fifo),
    .read_start(read_start),
    .read_done(read_done),
    .compute_start(compute_start),
    .data_2_sys(data_2_sys),
    .weight_2_sys(weight_2_sys),
    .rempty(rempty),
    .wfull(wfull),
    .fifo_write_addr(read_from_sram_addr)
);


///control
systolic_control #(.datawith(datawith),.array_size(array_size)) systolic_control_0(
    .clk(clk),
    .rst(rst_n),
    .tpu_start(tpu_start),
    .rempty(rempty),
    .wfull(wfull),
    .read_done(read_done),
    .compute_done(compute_done),
    .write_done(write_done),
    .read_start(read_start),
    .compute_start(compute_start),
    .write_start(write_start),
    .tpu_done(tpu_done)
);


systolic #(.datawith(datawith),.array_size(array_size)) systolic_0(
    .clk(clk),
    .rst(rst_n),
    .weight_in(weight_2_sys),
    .data_in(data_2_sys),
    .systolic_en(compute_start),
    .data_out(data_out_array)
);


write_back #(.datawith(datawith)) write_back_0(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_out_array),
    .write_start(write_start),
    // .addr_des(),//write bach to sram
    .write_done(write_done),
    .data_out(data_out),
    .addr_out(write_back_addr)//write bach to sram
);

assign data_addr1 = read_start?write_addr:read_from_sram_addr;
assign data_addr = write_start?write_back_addr:data_addr1;
sram1 #(.WIDTH(datawith) )sram_data (
    .clk(clk),
    .rst_n(rst_n),
    .addr(data_addr),
    .w_data(data_in),
    .wr(write_en ),   //  wr must be 0  ,but we nedd change the value to load data form tb to sram
    .read_data(sram_data_2_fifo)
);








endmodule



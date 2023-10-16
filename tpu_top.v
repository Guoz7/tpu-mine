module tpu_top(
    parameter datawith = 16,
    parameter array_size = 4                                                         
)(
    input clk,
    input rst,
    ////////  read data from sram
    input [datawith-1:0] weight_addr,
    input [datawith-1:0] data_addr,
    //control
    input tpu_en,
    //output
    output [datawith-1:0] data_out[0:array_size-1][0:array_size-1],
);


wire [datawith-1:0] data_read[0:array_size-1];
wire [datawith-1:0] weight_read[0:array_size-1];


systolic #(.parameter(datawith)) systolic_0(
    .clk(clk),
    .rst(rst),
    .weight_1(weight_read[0]),
    .weight_2(weight_read[1]),
    .data_1(data_read[0]),
    .data_2(data_read[1],)
    .systolic_en(systolic_en),
    .data_out(data_out)
);


//systolic control


syn_fifo#(
    .width(datawith),
    .depth8(8),
    .addr(3)
) data_fifo_0(
    .clk(clk),
    .rstn(rst),
    .wr_en(),
    .rd_en(),
    .wr_data(), 
    .rd_data(), 
    .fifo_full(), 
    .fifo_empty()
)

// syn_fifo #()




systolic_control(
    .clk(clk),
    .rst(rst),
    .tpu_start(tpu_start),
    .tpu
)




//// mem 



//write_back

endmodule
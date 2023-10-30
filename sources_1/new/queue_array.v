
module queue_array#(
    parameter datawith = 16,
    parameter array_size = 2
)
(
    input clk,
    input rst_n,
    input [9:0]data_addr,
    input [3:0] data_size,
    // cotrol 
    input read_start,
    output reg read_done,

    input compute_start,

    output [array_size*datawith-1:0] data_2_sys,
    output [array_size*datawith-1:0] weight_2_sys,
    output reg rempty,
    output reg wfull
);


localparam fifo_depth = 8;
reg  [9:0] sram_data_addr; 
reg  [9:0] sram_weigth_addr; 
// assign sram_raddr_d = data_addr;
// assign sram_weigth_addr = data_addr + data_size * data_with;

wire [2*4-1:0] fifo_write_en;
wire [2*4-1:0] fifo_read_en;

reg [datawith-1:0] data_2_fifo[3:0];


wire [datawith-1:0] weight_2_sys_tmp[3:0];
wire [datawith-1:0] data_2_sys_tmp[3:0];
assign data_2_sys = {data_2_sys_tmp[3],data_2_sys_tmp[2],data_2_sys_tmp[1],data_2_sys_tmp[0]};
assign weight_2_sys = {weight_2_sys_tmp[3],weight_2_sys_tmp[2],weight_2_sys_tmp[1],weight_2_sys_tmp[0]};
wire wfull_tmp [array_size*2-1:0];
wire rempty_tmp [array_size*2-1:0];


genvar  v_idx;
generate 
    for (v_idx = 0; v_idx < array_size; v_idx = v_idx + 1) begin: gen_data_fifo
        sfifo #(.WIDTH(datawith),.DEPTH(8)) fifo_sys(
            .clk(clk),
            .rst_n(rst_n),
            .winc(fifo_write_en[v_idx]),
            .rinc(fifo_read_en[v_idx]),
            .wdata(data_2_fifo[v_idx]),
            .wfull(wfull_tmp[v_idx]),
            .rempty(rempty_tmp[v_idx]),
            .rdata(data_2_sys_tmp[v_idx])
        );
    end

    for (v_idx = 0; v_idx < array_size; v_idx = v_idx + 1) begin: gen_weight_fifo
        sfifo #(.WIDTH(datawith),.DEPTH(8)) fifo_sys(
            .clk(clk),
            .rst_n(rst_n),
            .winc(fifo_write_en[array_size+v_idx]),
            .rinc(fifo_read_en[v_idx]),
            .wdata(data_2_fifo[v_idx]),
            .wfull(wfull_tmp[array_size+v_idx]),
            .rempty(rempty_tmp[array_size+v_idx]),
            .rdata(weight_2_sys_tmp[v_idx])
        );
    end
endgenerate

always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        wfull <= 0;
        rempty <= 0;
    end
    else begin
        if(wfull_tmp[0] && wfull_tmp[1]) begin
            wfull <= 1;
        end
        else begin
            wfull <= 0;
        end
        if(rempty_tmp[0] && rempty_tmp[1]) begin
            rempty <= 1;
        end
        else begin
            rempty <= 0;
        end
    end
end

wire [9:0] sram_data_nx;   // addr
wire [9:0] sram_weigth_nx;
assign sram_data_nx = sram_data_addr;
assign sram_weigth_nx = sram_weigth_addr ;
wire [datawith-1:0] sram_data_2_fifo;
sram1 #(.WIDTH(datawith) )sram_data (
    .clk(clk),
    .rst_n(rst_n),
    .addr(sram_data_nx),
    .w_data(),
    .wr(1'b0),   //  wr must be 0  ,but we nedd change the value to load data form tb to sram
    .read_data(sram_data_2_fifo)
);

// sram #(WIDTH, DEPTH) sram_weigth (
//     .clk(clk),
//     .rst_n(rst_n),
//     .addr(sram_raddr_nx),
//     .data(sram_weigth),
//     .read_data(weight_2_fifo),
//     .data_size(data_size)
// );

//load data to fifo 
reg w_en; //control the sram en flag

always @(posedge clk,negedge rst_n) begin
    if (!rst_n) begin
        w_en <= 0;  
    end
    else begin
        if(read_start) begin
            w_en <= 1;
        end
        else begin
            w_en <= 0;
        end
    end
end


// always @(posedge clk,negedge rst_n) begin
//     if(!rst_n) begin
//         sram_raddr_d <= data_addr;
//     end
//     else begin
//         if(w_en && wfull !=1) begin
//             sram_raddr_d <= sram_raddr_d + 1;
//     end
//     end
// end
reg [9:0] count_data ;


always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        count_data <= 0;
    end
    else begin
        if(w_en && wfull !=1 ) begin
            count_data <= count_data + 1;
    end
    end
end

//generate sel flag
wire[9:0] sram_data_nx_temp;
assign sram_data_nx_temp = sram_data_nx - data_addr;
assign fifo_write_en[0] = (count_data < fifo_depth && count_data !=0);
assign fifo_write_en[1] = ( count_data< 2*fifo_depth && count_data >= fifo_depth);
assign fifo_write_en[2] = ( count_data< 3*fifo_depth && count_data >= 2*fifo_depth);
assign fifo_write_en[3] = ( count_data< 4*fifo_depth && count_data >= 3*fifo_depth);
assign fifo_write_en[4] = ( count_data< 5*fifo_depth && count_data >= 4*fifo_depth);
assign fifo_write_en[5] = ( count_data< 6*fifo_depth && count_data >= 5*fifo_depth);
assign fifo_write_en[6] = ( count_data< 7*fifo_depth && count_data >= 6*fifo_depth);
assign fifo_write_en[7] = ( count_data< 8*fifo_depth && count_data >= 7*fifo_depth);


always @(posedge clk,negedge rst_n) begin
    if(!rst_n)begin
        read_done <= 0;
    end
    else
    begin
        if(count_data == 8*fifo_depth) begin
            read_done <= 1;
    end
    end
end
//generate compuate
reg [9:0] read_count;
always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        read_count <= 0;
    end
    else if(compute_start && !rempty) begin
            read_count <= read_count + 1;
    end
    else
     begin
        read_count <= 0;
     end
end

assign fifo_read_en[0] = ( read_count >= 1);    
assign fifo_read_en[1] = ( read_count >= 2);
assign fifo_read_en[2] = ( read_count >= 3);
assign fifo_read_en[3] = ( read_count >= 4);



endmodule



module sram1#(
    parameter WIDTH = 16,
    parameter DEPTH = 1024
)

(
    input clk,
    input rst_n,
    input [9:0] addr,
    input [WIDTH-1:0] w_data,
    input wr,
    output reg [WIDTH-1:0] read_data

);


localparam len = $clog2(DEPTH);
reg [WIDTH-1:0] sram [0:len-1];

always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        sram[0] <= 0;
    end
    else begin
        if(wr == 1) begin
            sram[addr] <= w_data;
        end
    end
end

always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        read_data <= 0;
    end
    else begin
        if(wr == 0) begin
            read_data <= sram[addr];
        end
    end
end

endmodule

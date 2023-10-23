
module queue_array#(
    parameter datawith = 16,
    parameter array_size = 8
)
(
    input clk,
    input rst_n,
    input [9:0]data_addr,
    input [3:0] data_size,
    // cotrol 
    input read_start,
    output read_done,

    input compute_start,

    output [array_size*datawith-1:0] data_2_sys,
    output [array_size*datawith-1:0] weight_2_sys,
    output reg rempty,
    output reg wfull
)

reg  [9:0] sram_data_addr; 
reg  [9:0] sram_weigth_addr; 
// assign sram_raddr_d = data_addr;
// assign sram_weigth_addr = data_addr + data_size * data_with;

wire [2*4-1:0] fifo_write_en;
wire [2*4-1:0] fifo_read_en;

reg [data_with-1:0] data_2_fifo[3:0];




wire [datawith-1:0] weight_2_fifo_tmp[3:0];
wire [datawith-1:0] data_2_sys_tmp[3:0];
assign data_2_sys = {data_2_sys_tmp[3],data_2_sys_tmp[2],data_2_sys_tmp[1],data_2_sys_tmp[0]};
assign weight_2_sys = {weight_2_fifo_tmp[3],weight_2_fifo_tmp[2],weight_2_fifo_tmp[1],weight_2_fifo_tmp[0]};




genvar  v_idx;
generate 
    for (v_idx = 0; v_idx < 4; v_idx = v_idx + 1) begin: gen_data_fifo
        sfifo #(.WIDTH(datawith),.DEPTH(8)) fifo_sys(
            .clk(clk),
            .rst_n(rst_n),
            .winc(fifo_write_en[v_idx]),
            .rinc(fifo_read_en[v_idx]),
            .wdata(data_2_fifo),
            .wfull(wfull),
            .rempty(rempty),
            .rdata(data_2_sys_tmp[v_idx])
        );
    end

    for (v_idx = 0; v_idx < 4; v_idx = v_idx + 1) begin: gen_weight_fifo
        sfifo #(.WIDTH(datawith),.DEPTH(8)) fifo_sys(
            .clk(clk),
            .rst_n(rst_n),
            .winc(fifo_write_en[4+v_idx]),
            .rinc(fifo_read_en[v_idx]),
            .wdata(data_2_fifo),
            .wfull(wfull),
            .rempty(rempty),
            .rdata(weight_2_fifo_tmp[v_idx])
        );
    end
endgenerate

wire [9:0] sram_data_nx; 
wire [9:0] sram_weigth_nx;
assign sram_data_nx = sram_data_addr;
assign sram_weigth_nx = sram_weigth_addr ;

sram #(WIDTH, DEPTH) sram_data (
    .clk(clk),
    .rst_n(rst_n),
    .addr(sram_raddr_nx),
    .data(sram_data),
    .read_data(data_2_fifo),
    .data_size(data_size)
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


always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        sram_raddr_d <= data_addr;
    end
    else begin
        if(w_en && wfull !=1) begin
            sram_raddr_d <= sram_raddr_d + 1;
    end
    end
end
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
assign fifo_write_en[0] = (count_data < DEPTH && count_data !=0);
assign fifo_write_en[1] = ( count_data< 2*DEPTH && count_data >= DEPTH);
assign fifo_write_en[2] = ( count_data< 3*DEPTH && count_data >= 2*DEPTH);
assign fifo_write_en[3] = ( count_data< 4*DEPTH && count_data >= 3*DEPTH);
assign fifo_write_en[4] = ( count_data< 5*DEPTH && count_data >= 4*DEPTH);
assign fifo_write_en[5] = ( count_data< 6*DEPTH && count_data >= 5*DEPTH);
assign fifo_write_en[6] = ( count_data< 7*DEPTH && count_data >= 6*DEPTH);
assign fifo_write_en[7] = ( count_data< 8*DEPTH && count_data >= 7*DEPTH);


always @(posedge clk,negedge rst_n) begin
    if(!rst_n)begin
        read_done <= 0;
        // compuate_start <= 0;
    end
    else
    begin
        if(count_data == 8*DEPTH) begin
            read_done <= 1;
            // compute_start <= 1;
    end
    end
end
//generate compuate
reg [9:0] read_count;
always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        read_count <= 0;
    end
    else if(compuate_start && !rempty) begin
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



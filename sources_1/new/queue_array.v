
module queue_array#(
    parameter datawith = 16,
    parameter array_size = 2
)
(
    input clk,
    input rst_n,
    // input [9:0]data_addr,
    input [3:0] data_size,
    input [datawith-1:0] data_2_fifo,
    // cotrol 
    input read_start,
    output reg read_done,

    input compute_start,
    
    
    output reg [9:0] fifo_write_addr,
    output [array_size*datawith-1:0] data_2_sys,
    output [array_size*datawith-1:0] weight_2_sys,
    output reg rempty,
    output reg wfull,
    output reg  read_all_data
);


localparam fifo_depth = array_size;
// assign sram_raddr_d = data_addr;
// assign sram_weigth_addr = data_addr + data_size * data_with;

wire [2*4-1:0] fifo_write_en;
wire [2*4-1:0] fifo_read_en;

// reg [datawith-1:0] data_2_fifo[3:0];


wire [datawith-1:0] weight_2_sys_tmp[3:0];
wire [datawith-1:0] data_2_sys_tmp[3:0];
assign data_2_sys = {data_2_sys_tmp[1],data_2_sys_tmp[0]};
assign weight_2_sys = {weight_2_sys_tmp[1],weight_2_sys_tmp[0]};
wire wfull_tmp_data [array_size-1:0];
wire wfull_tmp_weight[array_size-1:0] ;
wire rempty_tmp_data [array_size-1:0];
wire rempty_tmp_weight[array_size-1:0] ;

reg w_en;



genvar  v_idx;
generate 
    for (v_idx = 0; v_idx < array_size; v_idx = v_idx + 1) begin: gen_data_fifo
        sfifo #(.WIDTH(datawith),.DEPTH(2)) fifo_sys(
            .clk(clk),
            .rst_n(rst_n),
            .winc(fifo_write_en[v_idx]),
            .rinc(fifo_read_en[v_idx]),
            .wdata(data_2_fifo),
            .wfull(wfull_tmp_data[v_idx]),
            .rempty(rempty_tmp_data[v_idx]),
            .rdata(data_2_sys_tmp[v_idx])
        );
    end

    for (v_idx = 0; v_idx < array_size; v_idx = v_idx + 1) begin: gen_weight_fifo
        sfifo #(.WIDTH(datawith),.DEPTH(2)) fifo_sys(
            .clk(clk),
            .rst_n(rst_n),
            .winc(fifo_write_en[array_size+v_idx]),
            .rinc(fifo_read_en[v_idx]),
            .wdata(data_2_fifo),
            .wfull(wfull_tmp_weight[v_idx]),
            .rempty(rempty_tmp_weight[v_idx]),
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
            wfull <= (wfull_tmp_data[0] == 1 || wfull_tmp_data[1] == 1 || wfull_tmp_weight[0] == 1 || wfull_tmp_weight[1] == 1);
            rempty <= (rempty_tmp_data[0] == 1 || rempty_tmp_data[1] == 1 || rempty_tmp_weight[0] == 1 || rempty_tmp_weight[1] == 1);
        end
    end


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
// reg [9:0] count_data ;


always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        fifo_write_addr <= 0;
    end
    else begin
        if(w_en && wfull_tmp_weight[array_size-1] !=1 ) begin
            fifo_write_addr <= fifo_write_addr + 1;
    end
    end
end

//generate sel flag
assign fifo_write_en[0] = (fifo_write_addr <= fifo_depth && fifo_write_addr !=0);
assign fifo_write_en[1] = ( fifo_write_addr<= 2*fifo_depth && fifo_write_addr >fifo_depth);
assign fifo_write_en[2] = ( fifo_write_addr<= 3*fifo_depth && fifo_write_addr > 2*fifo_depth);
assign fifo_write_en[3] = ( fifo_write_addr<=4*fifo_depth && fifo_write_addr > 3*fifo_depth);
assign fifo_write_en[4] = ( fifo_write_addr<= 5*fifo_depth && fifo_write_addr > 4*fifo_depth);
assign fifo_write_en[5] = ( fifo_write_addr<= 6*fifo_depth && fifo_write_addr >5*fifo_depth);
assign fifo_write_en[6] = ( fifo_write_addr<= 7*fifo_depth && fifo_write_addr >6*fifo_depth);
assign fifo_write_en[7] = ( fifo_write_addr<= 8*fifo_depth && fifo_write_addr >7*fifo_depth);


always @(posedge clk,negedge rst_n) begin
    if(!rst_n)begin
        read_done <= 0;
    end
    else
    begin
        if(fifo_write_addr == array_size*array_size*fifo_depth) begin   //load all the data to data fiof and weight fifo
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
    else if(compute_start && rempty_tmp_weight[array_size-1] != 1) begin
            read_count <= read_count + 1;
    end
    else
     begin
        read_count <= 0;
     end
end

assign fifo_read_en[0] = ( compute_start && read_count >= 0 && rempty_tmp_data[0] == 0 && rempty_tmp_weight[0] == 0 ) ;    
assign fifo_read_en[1] = ( read_count >= 1 && rempty_tmp_data[1] == 0 && rempty_tmp_weight[1] == 0);
assign fifo_read_en[2] = ( read_count >= 2 && rempty_tmp_data[2] == 0 && rempty_tmp_weight[2] == 0) ;
assign fifo_read_en[3] = ( read_count >= 3 & rempty_tmp_data[3] == 0 && rempty_tmp_weight[3] == 0) ;


//////generate compute_done

always @ (posedge clk,negedge rst_n) begin
    if(!rst_n)begin
        read_all_data <= 0;
    end
    else if(compute_start && rempty_tmp_weight[array_size-1] == 1) begin
        read_all_data <= 1;
    end
end






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


// localparam len = $clog2(DEPTH);
reg [WIDTH-1:0] sram [0:DEPTH-1];

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

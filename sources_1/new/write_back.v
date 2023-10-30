module write_back#(parameter datawith = 16,
parameter array_size = 2
)(
    input clk,
    input rst_n,
    input [array_size*array_size*datawith-1:0] data_in,
    input write_start,

    // input [9:0]addr_des,
    output reg write_done,
    output reg [datawith-1:0] data_out,
    output reg [9:0] addr_out
);

// reg result_count;
reg [array_size*array_size*datawith-1:0] data_in_temp;

always@(posedge clk,negedge rst_n) begin
    if(!rst_n) begin 
        data_in_temp <= 0;
    end
    else if(write_start) 
    begin
        data_in_temp <= {data_in_temp[15:0],data_in_temp[array_size*array_size*datawith-1:16]};
    end
    else begin
        data_in_temp <= data_in;
    end
end


always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        write_done <= 0;
        addr_out <= 0;
    end
    else begin
        if(write_start) begin
            // write_done <= 1;
            data_out <= data_in_temp[15:0];
            addr_out <= addr_out + 1;
        end
        else if(addr_out == array_size *array_size -1)begin
            write_done <= 1;
        end
        else begin
            write_done <= 0;
        end
    end
end

endmodule

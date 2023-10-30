module write_back#(parameter datawith = 16)(
    input clk,
    input rst_n,

    input write_start,
    input [9:0]addr_des,
    output reg write_done
);


always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        write_done <= 0;
    end
    else begin
        if(write_start) begin
            write_done <= 1;
        end
        else begin
            write_done <= 0;
        end
    end
end

endmodule

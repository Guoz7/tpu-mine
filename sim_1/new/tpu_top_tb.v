`timescale 1ns/1ns

module tpu_top;
    reg clk;
    reg reset;
    // wire [1:0] address;
    // wire [15:0] data_in;
    wire [15:0] data_out;

    // // Instantiate your SRAM module
    // sram_module sram (
    //     .clk(clk),
    //     .reset(reset),
    //     .address(address),
    //     .data_in(data_in),
    //     .data_out(data_out)
    // );

    reg [15:0] mem [0:15]; // Memory to hold data read from the text file
    integer file;
    reg [15:0] file_data[0:3];
    integer i;
    reg tpu_start;
    reg [9:0] address;
    reg [15:0] data_in;
    reg write_en;




    initial begin
        // Initialize clock and reset
        clk = 0;
        reset = 1;

        // Apply reset
        #10 reset = 0;

        #50 reset = 1;





        // Open the text file for reading
        file = $fopen("D:/vspro/TPU_mine/data/data.txt", "r");
        if (file == 0)
            $display("Error opening the file");

        // Read data from the text file and write it to SRAM
        for ( i = 0; i < 4; i = i + 1) begin
            // Read data from the file
            if (!$feof(file)) begin
                $fscanf(file, "%h %h %h %h", 
                        file_data[0], file_data[1], file_data[2], file_data[3]);
                // Write data to SRAM
                address = i*4;
                data_in = file_data[0];
                #5 write_en = 1;
                #5 write_en = 0; // Add a delay to simulate SRAM write operation
                address = i*4+1;
                data_in = file_data[1];
                #5 write_en = 1;
                #5 write_en = 0; // Add a delay to simulate SRAM write operation
                data_in = file_data[2];
                address = i*4+2;
                #5 write_en = 1;
                #5 write_en = 0; // Add a delay to simulate SRAM write operation
                data_in = file_data[3];
                address = i*4+3;
                #5 write_en = 1;
                #5 write_en = 0; // Add a delay to simulate SRAM write operation
                
            end
        end

        // Close the file
        $fclose(file);

        file = $fopen("D:/vspro/TPU_mine/data/weight.txt", "r");
        if (file == 0)
            $display("Error opening the file");

        for ( i = 0; i < 4; i = i + 1) begin
            // Read weights from the file
            if (!$feof(file)) begin
                $fscanf(file, "%h %h %h %h", 
                        file_data[3], file_data[2], file_data[1], file_data[0]);
                // Write weights to SRAM
                address = i*4+16;
                data_in = file_data[0];
                #5 write_en = 1;
                #5 write_en = 0; // Add a delay to simulate SRAM write operation
                address = i*4+17;
                data_in = file_data[1];
                #5 write_en = 1;
                #5 write_en = 0; // Add a delay to simulate SRAM write operation
                data_in = file_data[2];
                address = i*4+18;
                #5 write_en = 1;
                #5 write_en = 0; // Add a delay to simulate SRAM write operation
                data_in = file_data[3];
                address = i*4+19;
                #5 write_en = 1;
                #5 write_en = 0; // Add a delay to simulate SRAM write operation

            end

        // Perform read operations from SRAM and verify the data
        // ...
        end

        // Finish the simulation
//        $finish;

    #100 tpu_start = 1;
    #1000 tpu_start = 0;
    end

    always begin
        #5 clk = ~clk; // Toggle the clock every 5 time units
    end

tpuv1 #(.datawith(16),.array_size(2)) tpuv1_0(
    .clk(clk),
    .rst_n(reset),
    .tpu_start(tpu_start),
    .write_addr(address),
    .data_size(),
    .data_in(data_in),
    .write_en(write_en),
    .data_out(data_out)
); 







endmodule

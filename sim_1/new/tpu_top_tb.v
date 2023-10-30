`timescale 1ns/1ns

module tpu_top;
    reg clk;
    reg reset;
    // wire [1:0] address;
    // wire [15:0] data_in;
    wire [15:0] data_out;

    // Instantiate your SRAM module
    sram_module sram (
        .clk(clk),
        .reset(reset),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    reg [15:0] mem [0:15]; // Memory to hold data read from the text file
    integer file;
    reg [15:0] file_data;
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




        #100 tpu_start = 1;
        // Open the text file for reading
        file = $fopen("data.txt", "r");
        if (file == 0)
            $display("Error opening the file");

        // Read data from the text file and write it to SRAM
        for ( i = 0; i < 16; i = i + 1) begin
            // Read data from the file
            if (!$feof(file)) begin
                $fscanf(file, "%h %h %h %h", 
                        file_data[15], file_data[14], file_data[13], file_data[12]);
                $fscanf(file, "%h %h %h %h", 
                        file_data[11], file_data[10], file_data[9], file_data[8]);
                $fscanf(file, "%h %h %h %h", 
                        file_data[7], file_data[6], file_data[5], file_data[4]);
                $fscanf(file, "%h %h %h %h", 
                        file_data[3], file_data[2], file_data[1], file_data[0]);

                // Write data to SRAM
                address = i;
                data_in = file_data;
                #5 write_en = 1;
                #5 write_en = 0; // Add a delay to simulate SRAM write operation
                
            end
        end

        // Close the file
        $fclose(file);

        file = $fopen("weights.txt", "r");
        if (file == 0)
            $display("Error opening the file");

        for ( i = 0; i < 16; i = i + 1) begin
            // Read weights from the file
            if (!$feof(file)) begin
                $fscanf(file, "%h %h %h %h", 
                        file_data[15], file_data[14], file_data[13], file_data[12]);
                $fscanf(file, "%h %h %h %h", 
                        file_data[11], file_data[10], file_data[9], file_data[8]);
                $fscanf(file, "%h %h %h %h", 
                        file_data[7], file_data[6], file_data[5], file_data[4]);
                $fscanf(file, "%h %h %h %h", 
                        file_data[3], file_data[2], file_data[1], file_data[0]);

                // Write weights to SRAM
                address = i + 16;
                data_in = file_data;
                #5 write_en = 1;
                #5 write_en = 0;; // Add a delay to simulate SRAM write operation
            end

        // Perform read operations from SRAM and verify the data
        // ...
        end




        // Finish the simulation
        $finish;
    end

    always begin
        #5 clk = ~clk; // Toggle the clock every 5 time units
    end

tpuv1 #(.datawith(16),.array_size(2)) tpuv1_0(
    .clk(clk),
    .rst_n(reset),
    .tpu_start(tpu_start),
    .write_addr(),
    .data_size(),
    .data_in(data_in),
    .write_en(write_en),
    .data_out(data_out)
); 







endmodule

`timescale 1ns/1ps

module FIFO_TB;

// Parameters
parameter DATA_WIDTH = 8;
parameter FIFO_DEPTH = 8;
parameter P_SIZE = $clog2(FIFO_DEPTH) + 1;
parameter W_CLK_PERIOD = 10;  // 100MHz
parameter R_CLK_PERIOD = 25;  // 40MHz
parameter TEST_CASES = 100;

// DUT Signals
reg                     W_CLK_tb, W_RST_tb, R_CLK_tb, R_RST_tb;
reg                     W_INC_tb, R_INC_tb;
reg  [DATA_WIDTH-1:0]   WR_DATA_tb;
wire [DATA_WIDTH-1:0]   RD_DATA_tb;
wire                    FULL_tb, EMPTY_tb;

// Test Variables
integer write_ptr = 0;
integer read_ptr = 0;
integer errors = 0;
integer test_stage = 0;
reg [DATA_WIDTH-1:0] test_data [0:TEST_CASES-1];

// Clock Generation
initial begin
    W_CLK_tb = 0;
    forever #(W_CLK_PERIOD/2) W_CLK_tb = ~W_CLK_tb;
end

initial begin
    R_CLK_tb = 0;
    forever #(R_CLK_PERIOD/2) R_CLK_tb = ~R_CLK_tb;
end

// DUT Instantiation
FIFO_TOP #(
    .DATA_WIDTH(DATA_WIDTH),
    .FIFO_DEPTH(FIFO_DEPTH),
    .P_SIZE(P_SIZE)
) DUT (
    .W_CLK(W_CLK_tb),
    .W_RST(W_RST_tb),
    .R_CLK(R_CLK_tb),
    .R_RST(R_RST_tb),
    .W_INC(W_INC_tb),
    .R_INC(R_INC_tb),
    .WR_DATA(WR_DATA_tb),
    .RD_DATA(RD_DATA_tb),
    .FULL(FULL_tb),
    .EMPTY(EMPTY_tb)
);

// Test Stimulus
initial begin
    // Initialize
    initialize();
    
    // Test 1: Fill FIFO to maximum capacity
    $display("Test 1: Testing maximum capacity...");
    test_stage = 1;
    fill_fifo();
    
    // Test 2: empty_fifo operations
    $display("Test 2: Testing empty_fifo...");
    test_stage = 2;
    empty_fifo();

    // Test 3: Concurrent read/write operations
    $display("Test 3: Testing concurrent read/write...");
    test_stage = 3;
    concurrent_rw_test();
    
	empty_fifo();

    // Test 4: Burst write followed by burst read
    $display("Test 4: Testing burst operations...");
    test_stage = 4;
    burst_test();
    
    empty_fifo();
    
    // End simulation
    $display("Simulation completed with %0d errors", errors);
    $finish;
end

// Tasks
task initialize;
    begin
        // Generate test data
        for(integer i = 0; i < TEST_CASES; i = i + 1) begin
            test_data[i] = $random;
        end
        
        // Reset signals
        W_RST_tb = 0;
        R_RST_tb = 0;
        W_INC_tb = 0;
        R_INC_tb = 0;
        WR_DATA_tb = 0;
        
        // Apply reset
        #(W_CLK_PERIOD*2);
        W_RST_tb = 1;
        R_RST_tb = 1;
        #(W_CLK_PERIOD*2);
    end
endtask

task fill_fifo;
    begin
        // Write until FULL
        @(negedge W_CLK_tb);
        while (!FULL_tb) begin
            W_INC_tb = 1;
            WR_DATA_tb = test_data[write_ptr];
            write_ptr = write_ptr + 1;
            @(negedge W_CLK_tb);
        end
        W_INC_tb = 0;
        
        // Verify FULL flag
        if (!FULL_tb) begin
            $display("Error: FIFO should be FULL");
            errors = errors + 1;
        end
    end
endtask

task empty_fifo;
    begin
        // read until Empty
        @(negedge R_CLK_tb);
        while (!EMPTY_tb) begin
            R_INC_tb = 1;
            check_read_data();
            read_ptr = read_ptr + 1;
            @(negedge R_CLK_tb);
        end
        R_INC_tb = 0;
    end
endtask

task concurrent_rw_test;
    begin
        // Start concurrent read and write
        fork
            begin
                // Writer process
                repeat(10) begin
                    @(negedge W_CLK_tb);
                    if (!FULL_tb) begin
                        W_INC_tb = 1;
                        WR_DATA_tb = test_data[write_ptr];
                        write_ptr = write_ptr + 1;
                    end else begin
                        W_INC_tb = 0;
                    end
                end
            end
            
            begin
                // Reader process
                repeat(10) begin
                    @(negedge R_CLK_tb);
                    if (!EMPTY_tb) begin
                        R_INC_tb = 1;
                        check_read_data();
                        read_ptr = read_ptr + 1;
                    end else begin
                        R_INC_tb = 0;
                    end
                end
            end
        join
    end
endtask

task burst_test;
    begin
        // Reset pointers
        write_ptr = 0;
        read_ptr = 0;
        
        // Burst write
        repeat(FIFO_DEPTH) begin
            @(negedge W_CLK_tb);
            if (!FULL_tb) begin
                W_INC_tb = 1;
                WR_DATA_tb = test_data[write_ptr];
                write_ptr = write_ptr + 1;
            end
        end
        W_INC_tb = 0;
        
        // Burst read
        repeat(FIFO_DEPTH) begin
            @(negedge R_CLK_tb);
            if (!EMPTY_tb) begin
                R_INC_tb = 1;
                check_read_data();
                read_ptr = read_ptr + 1;
            end
        end
        R_INC_tb = 0;
    end
endtask

task check_read_data;
    begin
        //@(negedge R_CLK_tb);
        if (RD_DATA_tb !== test_data[read_ptr]) begin
            $display("Error: Read data mismatch. Expected %h, Got %h", test_data[read_ptr], RD_DATA_tb);
            errors = errors + 1;
        end
    end
endtask

// Monitor FULL/EMPTY flags
always @(FULL_tb) begin
    if (test_stage != 0) begin
        $display("Time %0t: FULL flag changed to %b", $time, FULL_tb);
    end
end

always @(EMPTY_tb) begin
    if (test_stage != 0) begin
        $display("Time %0t: EMPTY flag changed to %b", $time, EMPTY_tb);
    end
end

endmodule
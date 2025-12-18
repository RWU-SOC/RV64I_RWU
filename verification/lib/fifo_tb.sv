// ============================================================================
// Simple FIFO Testbench
// ============================================================================
// Basic verification for the simplified FIFO module
// ============================================================================

`timescale 1ns/1ps

module fifo_tb;

    // ------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------
    parameter int DATA_WIDTH = 8;
    parameter int DEPTH      = 16;
    parameter int CLK_PERIOD = 10;  // 100 MHz

    // ------------------------------------------------------------
    // DUT signals
    // ------------------------------------------------------------
    logic                  clk;
    logic                  rst_n;  // Active-low reset
    logic                  wr_en;
    logic [DATA_WIDTH-1:0] wdata;
    logic                  rd_en;
    logic [DATA_WIDTH-1:0] rdata;
    logic                  full;
    logic                  empty;

    // ------------------------------------------------------------
    // Test control
    // ------------------------------------------------------------
    int error_count = 0;
    int check_count = 0;  // Number of checks, not test cases

    // ------------------------------------------------------------
    // Clock generation
    // ------------------------------------------------------------
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ------------------------------------------------------------
    // DUT instantiation
    // ------------------------------------------------------------
    fifo #(
        .DATA_WIDTH (DATA_WIDTH),
        .DEPTH      (DEPTH)
    ) dut (
        .clk_i   (clk),
        .rst_i   (rst_n),
        .wr_en_i (wr_en),
        .wdata_i (wdata),
        .rd_en_i (rd_en),
        .rdata_o (rdata),
        .full_o  (full),
        .empty_o (empty)
    );

    // ------------------------------------------------------------
    // Protocol Assertions (Concurrent)
    // ------------------------------------------------------------
    // Note: These assertions use white-box verification (accessing internal
    // signals like dut.count, dut.wr_ptr, dut.rd_ptr). This is appropriate
    // for unit-level testing. For black-box/system-level testing, only
    // verify external behavior through the public interface.
    // ------------------------------------------------------------
    
    // Write when full should be ignored (forgiving FIFO)
    property write_when_full_ignored;
        @(posedge clk) disable iff (!rst_n)
        (wr_en && full) |-> ##1 ($stable(dut.count) && $stable(dut.wr_ptr));
    endproperty
    assert property (write_when_full_ignored)
        else $error("FIFO error: Write when full modified state");
    
    // Read when empty should be ignored (forgiving FIFO)
    property read_when_empty_ignored;
        @(posedge clk) disable iff (!rst_n)
        (rd_en && empty) |-> ##1 ($stable(dut.count) && $stable(dut.rd_ptr));
    endproperty
    assert property (read_when_empty_ignored)
        else $error("FIFO error: Read when empty modified state");
    
    // Count should never exceed DEPTH
    property count_in_range;
        @(posedge clk) disable iff (!rst_n)
        dut.count <= DEPTH;
    endproperty
    assert property (count_in_range)
        else $fatal(1, "Internal error: FIFO count exceeded DEPTH");
    
    // Full and empty are mutually exclusive (unless DEPTH=0, but that's invalid)
    property full_empty_mutex;
        @(posedge clk) disable iff (!rst_n)
        !(full && empty);
    endproperty
    assert property (full_empty_mutex)
        else $fatal(1, "Internal error: FIFO both full and empty");

    // ------------------------------------------------------------
    // Coverage Properties (measure test quality)
    // ------------------------------------------------------------
    // Note: XSIM does not support 'cover property' for functional coverage.
    // For coverage analysis, use a formal verification tool or a simulator
    // with full SVA coverage support (e.g., VCS, Questa).
    // 
    // Corner cases exercised by directed tests:
    // - Reset transitions (test_reset)
    // - Full condition (test_fill_fifo, test_write_when_full)
    // - Empty condition (test_empty_fifo, test_read_when_empty)
    // - Invalid operations: write when full, read when empty
    // - Simultaneous read/write (test_simultaneous_rw)
    // - Half-full condition (test_simultaneous_rw)

    // ------------------------------------------------------------
    // Helper tasks
    // ------------------------------------------------------------
    
    // Reset task (active-low, synchronous)
    task reset_dut();
        rst_n = 0;  // Assert reset (active-low)
        wr_en = 0;
        rd_en = 0;
        wdata = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;  // Deassert reset
        repeat(2) @(posedge clk);
    endtask

    // Write single entry
    task write_entry(input logic [DATA_WIDTH-1:0] data);
        @(posedge clk);
        wr_en = 1;
        wdata = data;
        @(posedge clk);
        wr_en = 0;
    endtask

    // Read single entry (registered output - 1 cycle delay)
    // Note: Does not check if FIFO is empty - allows testing illegal reads.
    // Protocol assertions will catch any state corruption.
    task read_entry(output logic [DATA_WIDTH-1:0] data);
        @(posedge clk);
        rd_en = 1;
        @(posedge clk);
        data = rdata;  // Sample after read completes (registered output)
        rd_en = 0;
    endtask

    // Check condition with immediate assertion
    task check(input string name, input logic condition);
        check_count++;
        assert (condition) begin
            $display("[PASS] Check %0d: %s", check_count, name);
        end else begin
            $error("[FAIL] Check %0d: %s", check_count, name);
            error_count++;
        end
    endtask

    // ------------------------------------------------------------
    // Test cases
    // ------------------------------------------------------------

    // Test 1: Reset behavior
    task test_reset();
        $display("\n=== Test 1: Reset Behavior ===");
        reset_dut();
        check("Empty after reset", empty == 1);
        check("Not full after reset", full == 0);
    endtask

    // Test 2: Single write and read
    task test_single_write_read();
        logic [DATA_WIDTH-1:0] read_data;
        $display("\n=== Test 2: Single Write and Read ===");
        reset_dut();
        
        write_entry(8'hAA);
        check("Not empty after write", empty == 0);
        
        read_entry(read_data);
        check("Read correct data", read_data == 8'hAA);
        check("Empty after read", empty == 1);
    endtask

    // Test 3: Multiple writes and reads
    task test_multiple_operations();
        logic [DATA_WIDTH-1:0] read_data;
        $display("\n=== Test 3: Multiple Operations ===");
        reset_dut();
        
        // Write 3 entries
        write_entry(8'h11);
        write_entry(8'h22);
        write_entry(8'h33);
        check("Not empty after writes", empty == 0);
        
        // Read them back in order
        read_entry(read_data);
        check("Read data 1", read_data == 8'h11);
        read_entry(read_data);
        check("Read data 2", read_data == 8'h22);
        read_entry(read_data);
        check("Read data 3", read_data == 8'h33);
        check("Empty after all reads", empty == 1);
    endtask

    // Test 4: Fill FIFO completely
    task test_fill_fifo();
        $display("\n=== Test 4: Fill FIFO ===");
        reset_dut();
        
        // Write DEPTH entries
        for (int i = 0; i < DEPTH; i++) begin
            write_entry(i[DATA_WIDTH-1:0]);
        end
        
        check("Full after DEPTH writes", full == 1);
        check("Not empty", empty == 0);
    endtask

    // Test 5: Empty FIFO completely
    task test_empty_fifo();
        logic [DATA_WIDTH-1:0] read_data;
        $display("\n=== Test 5: Empty FIFO ===");
        reset_dut();
        
        // Fill it first
        for (int i = 0; i < DEPTH; i++) begin
            write_entry(i[DATA_WIDTH-1:0]);
        end
        
        // Read all entries
        for (int i = 0; i < DEPTH; i++) begin
            read_entry(read_data);
            check($sformatf("Read data %0d", i), read_data == i[DATA_WIDTH-1:0]);
        end
        
        check("Empty after all reads", empty == 1);
        check("Not full", full == 0);
    endtask

    // Test 6: Write when full (should be ignored)
    task test_write_when_full();
        logic [DATA_WIDTH-1:0] read_data;
        $display("\n=== Test 6: Write When Full ===");
        reset_dut();
        
        // Fill FIFO
        for (int i = 0; i < DEPTH; i++) begin
            write_entry(i[DATA_WIDTH-1:0]);
        end
        check("FIFO full", full == 1);
        
        // Try to write when full (should be ignored)
        write_entry(8'hFF);
        check("Still full", full == 1);
        
        // Read first entry, should be 0, not 0xFF
        read_entry(read_data);
        check("First entry correct", read_data == 8'h00);
    endtask

    // Test 7: Read when empty (should not change anything)
    task test_read_when_empty();
        logic [DATA_WIDTH-1:0] read_data;
        $display("\n=== Test 7: Read When Empty ===");
        reset_dut();
        
        check("Empty initially", empty == 1);
        
        // Try to read when empty
        read_entry(read_data);
        check("Still empty", empty == 1);
    endtask

    // Test 8: Simultaneous read/write
    task test_simultaneous_rw();
        logic [DATA_WIDTH-1:0] read_data;
        $display("\n=== Test 8: Simultaneous Read/Write ===");
        reset_dut();
        
        // Fill FIFO halfway
        for (int i = 0; i < DEPTH/2; i++) begin
            write_entry(i[DATA_WIDTH-1:0]);
        end
        
        // Simultaneous read/write
        // Note: For a registered read FIFO, this reads the OLD head value
        // (before write), which is correct FIFO semantics.
        @(posedge clk);
        wr_en = 1;
        rd_en = 1;
        wdata = 8'hAA;
        @(posedge clk);
        read_data = rdata;  // Sample registered output (1 cycle after rd_en)
        wr_en = 0;
        rd_en = 0;
        
        check("Read first value", read_data == 8'h00);
        check("Not empty", empty == 0);
        check("Not full", full == 0);
    endtask

    // ------------------------------------------------------------
    // Main test sequence
    // ------------------------------------------------------------
    initial begin
        $display("========================================");
        $display("FIFO Testbench");
        $display("DATA_WIDTH: %0d, DEPTH: %0d", DATA_WIDTH, DEPTH);
        $display("========================================");

        test_reset();
        test_single_write_read();
        test_multiple_operations();
        test_fill_fifo();
        test_empty_fifo();
        test_write_when_full();
        test_read_when_empty();
        test_simultaneous_rw();

        $display("\n========================================");
        $display("Test Summary");
        $display("========================================");
        $display("Total Checks: %0d", check_count);
        $display("Passed: %0d", check_count - error_count);
        $display("Failed: %0d", error_count);
        
        if (error_count == 0) begin
            $display("\n*** ALL TESTS PASSED ***");
        end else begin
            $display("\n*** TESTS FAILED ***");
        end
        
        $finish;
    end

    // Timeout watchdog
    initial begin
        #100000;
        $error("Testbench timeout!");
        $finish;
    end

endmodule : fifo_tb

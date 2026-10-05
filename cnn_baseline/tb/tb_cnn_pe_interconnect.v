`timescale 1ns/1ps

module tb_cnn_pe_interconnect;

    reg clk;
    reg rst;
    reg valid;

    reg signed [7:0] data_in;
    reg signed [7:0] weight0;
    reg signed [7:0] weight1;
    reg signed [7:0] weight2;
    reg signed [7:0] weight3;

    wire signed [31:0] result;
    wire valid_out;

    integer i;
    integer pass_count;
    integer fail_count;
    integer result_count;

    reg signed [31:0] expected_queue [0:127];
    integer queue_write;
    integer queue_read;

    cnn_pe_interconnect dut (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .data_in(data_in),
        .weight0(weight0),
        .weight1(weight1),
        .weight2(weight2),
        .weight3(weight3),
        .result(result),
        .valid_out(valid_out)
    );

    // 50 MHz clock
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    // Monitor pipeline results
    always @(posedge clk) begin
        #1;

        if (valid_out) begin
            result_count = result_count + 1;

            if (result === expected_queue[queue_read]) begin
                pass_count = pass_count + 1;

                $display(
                    "[%0t ns] PASS  result=%0d expected=%0d",
                    $time,
                    result,
                    expected_queue[queue_read]
                );
            end
            else begin
                fail_count = fail_count + 1;

                $display(
                    "[%0t ns] FAIL  result=%0d expected=%0d",
                    $time,
                    result,
                    expected_queue[queue_read]
                );
            end

            queue_read = queue_read + 1;
        end
    end

    // Apply one workload
    task apply_workload;
        input signed [7:0] d;
        input signed [7:0] w0;
        input signed [7:0] w1;
        input signed [7:0] w2;
        input signed [7:0] w3;
        input signed [31:0] expected;

        begin
            @(negedge clk);

            data_in = d;
            weight0 = w0;
            weight1 = w1;
            weight2 = w2;
            weight3 = w3;

            valid = 1'b1;

            expected_queue[queue_write] = expected;
            queue_write = queue_write + 1;

            @(negedge clk);

            valid = 1'b0;

            // Gap between workloads
            repeat (3) @(negedge clk);
        end
    endtask

    initial begin

        pass_count = 0;
        fail_count = 0;
        result_count = 0;

        queue_write = 0;
        queue_read = 0;

        clk = 1'b0;
        rst = 1'b1;
        valid = 1'b0;

        data_in = 0;
        weight0 = 0;
        weight1 = 0;
        weight2 = 0;
        weight3 = 0;

        // Reset
        repeat (5) @(negedge clk);
        rst = 1'b0;

        /*
         * ---------------------------------------------------------
         * EXTENDED HEALTHY WORKLOAD
         * ---------------------------------------------------------
         *
         * Result =
         * data * (w0 + w1 + w2 + w3)
         *
         * because the same data value propagates through all 4 PEs.
         */

        // Positive workloads
        apply_workload(  1,  1,  2,  3,  4,  10);
        apply_workload(  2,  2,  3,  4,  5,  28);
        apply_workload(  3,  1,  1,  1,  1,  12);
        apply_workload(  4,  2,  2,  2,  2,  32);
        apply_workload( 5,  1,  2,  1,  2, 30);
        apply_workload( 6,  3,  1,  2,  1, 42);
        apply_workload( 7,  4,  1,  2,  3, 70);
        apply_workload( 8,  1,  3,  2,  4, 80);
        apply_workload( 9,  2,  4,  1,  3, 90);
        apply_workload(10,  3,  2,  4,  1,100);

        // Negative data
        apply_workload(-1,  1,  2,  3,  4,-10);
        apply_workload(-2,  2,  3,  4,  5,-28);
        apply_workload(-3,  1,  1,  1,  1,-12);
        apply_workload(-4,  2,  2,  2,  2,-32);
        apply_workload(-5,  1,  2,  1,  2,-30);
        apply_workload(-6,  3,  1,  2,  1,-42);
        apply_workload(-7,  4,  1,  2,  3,-70);
        apply_workload(-8,  1,  3,  2,  4,-80);

        // Mixed positive/negative weights
        apply_workload( 3,  5, -2,  4, -1, 18);
        apply_workload( 4, -3,  6, -2,  1,  8);
        apply_workload( 5, -4,  2,  3, -1,  0);
        apply_workload( 6,  7, -3, -2,  1, 18);
        apply_workload(-3,  5, -2,  4, -1,-18);
        apply_workload(-4, -3,  6, -2,  1, -8);
        apply_workload(-5, -4,  2,  3, -1,  0);
        apply_workload(-6,  7, -3, -2,  1,-18);

        /*
         * Repeated varied workloads.
         *
         * This section increases the switching activity so that
         * Power Analyzer receives a more representative workload.
         */

        for (i = 0; i < 20; i = i + 1) begin

            apply_workload(
                i + 1,
                (i % 5) + 1,
                (i % 4) + 1,
                (i % 3) + 1,
                (i % 6) + 1,
                (i + 1) *
                (((i % 5) + 1) +
                 ((i % 4) + 1) +
                 ((i % 3) + 1) +
                 ((i % 6) + 1))
            );

            apply_workload(
                -(i + 1),
                -((i % 5) + 1),
                ((i % 4) + 1),
                -((i % 3) + 1),
                ((i % 6) + 1),
                -(i + 1) *
                (-((i % 5) + 1) +
                 ((i % 4) + 1) -
                 ((i % 3) + 1) +
                 ((i % 6) + 1))
            );

        end

        // Allow pipeline to drain
        repeat (10) @(negedge clk);

        $display("");
        $display("==============================================");
        $display("EXTENDED HEALTHY BASELINE SIMULATION");
        $display("==============================================");
        $display("Results checked : %0d", result_count);
        $display("PASS count      : %0d", pass_count);
        $display("FAIL count      : %0d", fail_count);
        $display("==============================================");

        if ((fail_count == 0) && (result_count > 0)) begin
            $display("FINAL STATUS: PASS");
        end
        else begin
            $display("FINAL STATUS: FAIL");
        end

        $display("==============================================");

        $finish;
    end

    // Generate VCD for Power Analyzer
    initial begin
        $dumpfile("../cnn_pe_interconnect_extended.vcd");
        $dumpvars(0, tb_cnn_pe_interconnect);
    end

endmodule

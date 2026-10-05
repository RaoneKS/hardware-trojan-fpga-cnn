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

    integer pass_count;
    integer fail_count;
    integer expected_queue [0:7];
    integer test_index;
    integer result_count;

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

    // 10 ns clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---------------------------------------------------------
    // Monitor healthy accelerator output
    // ---------------------------------------------------------
    always @(posedge clk) begin
        #1;

        $display("[%0t ns] valid=%b data=%0d weights=%0d,%0d,%0d,%0d | valid_out=%b result=%0d",
                 $time,
                 valid,
                 data_in,
                 weight0,
                 weight1,
                 weight2,
                 weight3,
                 valid_out,
                 result);

        if (valid_out) begin
            if (result == expected_queue[result_count]) begin
                $display("PASS: Test %0d | expected=%0d result=%0d",
                         result_count + 1,
                         expected_queue[result_count],
                         result);
                pass_count = pass_count + 1;
            end
            else begin
                $display("FAIL: Test %0d | expected=%0d result=%0d",
                         result_count + 1,
                         expected_queue[result_count],
                         result);
                fail_count = fail_count + 1;
            end

            result_count = result_count + 1;
        end
    end

    initial begin

        $dumpfile("cnn_pe_interconnect.vcd");
        $dumpvars(0, tb_cnn_pe_interconnect);

        pass_count = 0;
        fail_count = 0;
        result_count = 0;

        // Expected results in pipeline order
        expected_queue[0] = 70;
        expected_queue[1] = 30;
        expected_queue[2] = 56;
        expected_queue[3] = 56;
        expected_queue[4] = 66;
        expected_queue[5] = 44;
        expected_queue[6] = -18;
        expected_queue[7] = 10;

        rst = 1;
        valid = 0;

        data_in = 0;
        weight0 = 0;
        weight1 = 0;
        weight2 = 0;
        weight3 = 0;

        // Reset
        repeat (2) @(negedge clk);
        rst = 0;

        // ---------------------------------------------------------
        // Test 1
        // 5*2 + 5*3 + 5*4 + 5*5 = 70
        // ---------------------------------------------------------
        @(negedge clk);
        data_in = 5;
        weight0 = 2;
        weight1 = 3;
        weight2 = 4;
        weight3 = 5;
        valid = 1;

        @(negedge clk);
        valid = 0;

        repeat (6) @(negedge clk);

        // ---------------------------------------------------------
        // Test 2
        // 3*1 + 3*2 + 3*3 + 3*4 = 30
        // ---------------------------------------------------------
        data_in = 3;
        weight0 = 1;
        weight1 = 2;
        weight2 = 3;
        weight3 = 4;
        valid = 1;

        @(negedge clk);
        valid = 0;

        repeat (6) @(negedge clk);

        // ---------------------------------------------------------
        // Test 3
        // 7*2 + 7*1 + 7*2 + 7*3 = 56
        // ---------------------------------------------------------
        data_in = 7;
        weight0 = 2;
        weight1 = 1;
        weight2 = 2;
        weight3 = 3;
        valid = 1;

        @(negedge clk);
        valid = 0;

        repeat (6) @(negedge clk);

        // ---------------------------------------------------------
        // Test 4
        // 4*5 + 4*4 + 4*3 + 4*2 = 56
        // ---------------------------------------------------------
        data_in = 4;
        weight0 = 5;
        weight1 = 4;
        weight2 = 3;
        weight3 = 2;
        valid = 1;

        @(negedge clk);
        valid = 0;

        repeat (6) @(negedge clk);

        // ---------------------------------------------------------
        // Test 5
        // 6*1 + 6*3 + 6*5 + 6*2 = 66
        // ---------------------------------------------------------
        data_in = 6;
        weight0 = 1;
        weight1 = 3;
        weight2 = 5;
        weight3 = 2;
        valid = 1;

        @(negedge clk);
        valid = 0;

        repeat (6) @(negedge clk);

        // ---------------------------------------------------------
        // Test 6
        // 2*7 + 2*6 + 2*5 + 2*4 = 44
        // ---------------------------------------------------------
        data_in = 2;
        weight0 = 7;
        weight1 = 6;
        weight2 = 5;
        weight3 = 4;
        valid = 1;

        @(negedge clk);
        valid = 0;

        repeat (6) @(negedge clk);

        // ---------------------------------------------------------
        // Test 7
        // (-3)*2 + (-3)*1 + (-3)*2 + (-3)*1 = -18
        // ---------------------------------------------------------
        data_in = -3;
        weight0 = 2;
        weight1 = 1;
        weight2 = 2;
        weight3 = 1;
        valid = 1;

        @(negedge clk);
        valid = 0;

        repeat (6) @(negedge clk);

        // ---------------------------------------------------------
        // Test 8
        // 5*2 + 5*(-3) + 5*4 + 5*(-1) = 10
        // ---------------------------------------------------------
        data_in = 5;
        weight0 = 2;
        weight1 = -3;
        weight2 = 4;
        weight3 = -1;
        valid = 1;

        @(negedge clk);
        valid = 0;

        // Allow final pipeline result to emerge
        repeat (8) @(negedge clk);

        $display("");
        $display("==============================================");
        $display("HEALTHY PE INTERCONNECT CHARACTERIZATION");
        $display("==============================================");
        $display("PASS count = %0d", pass_count);
        $display("FAIL count = %0d", fail_count);
        $display("RESULT count = %0d", result_count);

        if (fail_count == 0 && pass_count == 8)
            $display("FINAL STATUS: PASS");
        else
            $display("FINAL STATUS: FAIL");

        $display("==============================================");
        $display("");

        $finish;
    end

endmodule

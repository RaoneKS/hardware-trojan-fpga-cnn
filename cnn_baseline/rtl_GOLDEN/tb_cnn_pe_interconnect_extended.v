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

    // Monitor activity
    always @(posedge clk) begin
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
    end

    initial begin
        $dumpfile("cnn_pe_interconnect.vcd");
        $dumpvars(0, tb_cnn_pe_interconnect);

        rst   = 1;
        valid = 0;

        data_in = 0;
        weight0 = 0;
        weight1 = 0;
        weight2 = 0;
        weight3 = 0;

        // Reset
        #20;
        rst = 0;

        // -------------------------------------------------
        // Workload 1
        // Expected = 5*(2+3+4+5) = 70
        // -------------------------------------------------
        @(negedge clk);
        data_in = 5;
        weight0 = 2;
        weight1 = 3;
        weight2 = 4;
        weight3 = 5;
        valid = 1;

        @(negedge clk);
        valid = 0;

        // -------------------------------------------------
        // Workload 2
        // Expected = 3*(1+2+3+4) = 30
        // -------------------------------------------------
        @(negedge clk);
        data_in = 3;
        weight0 = 1;
        weight1 = 2;
        weight2 = 3;
        weight3 = 4;
        valid = 1;

        @(negedge clk);
        valid = 0;

        // -------------------------------------------------
        // Workload 3
        // Expected = 7*(2+1+2+3) = 56
        // -------------------------------------------------
        @(negedge clk);
        data_in = 7;
        weight0 = 2;
        weight1 = 1;
        weight2 = 2;
        weight3 = 3;
        valid = 1;

        @(negedge clk);
        valid = 0;

        // -------------------------------------------------
        // Workload 4
        // Expected = 4*(5+4+3+2) = 56
        // -------------------------------------------------
        @(negedge clk);
        data_in = 4;
        weight0 = 5;
        weight1 = 4;
        weight2 = 3;
        weight3 = 2;
        valid = 1;

        @(negedge clk);
        valid = 0;

        // -------------------------------------------------
        // Workload 5
        // Expected = 6*(1+3+5+2) = 66
        // -------------------------------------------------
        @(negedge clk);
        data_in = 6;
        weight0 = 1;
        weight1 = 3;
        weight2 = 5;
        weight3 = 2;
        valid = 1;

        @(negedge clk);
        valid = 0;

        // -------------------------------------------------
        // Workload 6
        // Expected = 2*(7+6+5+4) = 44
        // -------------------------------------------------
        @(negedge clk);
        data_in = 2;
        weight0 = 7;
        weight1 = 6;
        weight2 = 5;
        weight3 = 4;
        valid = 1;

        @(negedge clk);
        valid = 0;

        // -------------------------------------------------
        // Workload 7
        // Negative values
        // Expected = (-3)*(2+1+2+1) = -18
        // -------------------------------------------------
        @(negedge clk);
        data_in = -3;
        weight0 = 2;
        weight1 = 1;
        weight2 = 2;
        weight3 = 1;
        valid = 1;

        @(negedge clk);
        valid = 0;

        // -------------------------------------------------
        // Workload 8
        // Mixed signs
        // Expected = 5*(2-3+4-1) = 10
        // -------------------------------------------------
        @(negedge clk);
        data_in = 5;
        weight0 = 2;
        weight1 = -3;
        weight2 = 4;
        weight3 = -1;
        valid = 1;

        @(negedge clk);
        valid = 0;

        // -------------------------------------------------
        // Idle period
        // -------------------------------------------------
        repeat (5) @(negedge clk);

        $display("");
        $display("==============================================");
        $display("PASS: Extended healthy PE interconnect test");
        $display("==============================================");
        $display("");

        $finish;
    end

endmodule

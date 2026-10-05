`timescale 1ns/1ps

module tb_cnn_conv3x3;

    reg clk;
    reg rst;
    reg valid;

    reg signed [7:0] pixel0;
    reg signed [7:0] pixel1;
    reg signed [7:0] pixel2;
    reg signed [7:0] pixel3;
    reg signed [7:0] pixel4;
    reg signed [7:0] pixel5;
    reg signed [7:0] pixel6;
    reg signed [7:0] pixel7;
    reg signed [7:0] pixel8;

    reg signed [7:0] weight0;
    reg signed [7:0] weight1;
    reg signed [7:0] weight2;
    reg signed [7:0] weight3;
    reg signed [7:0] weight4;
    reg signed [7:0] weight5;
    reg signed [7:0] weight6;
    reg signed [7:0] weight7;
    reg signed [7:0] weight8;

    wire signed [31:0] result;
    wire valid_out;

    cnn_conv3x3 uut (
        .clk(clk),
        .rst(rst),
        .valid(valid),

        .pixel0(pixel0),
        .pixel1(pixel1),
        .pixel2(pixel2),
        .pixel3(pixel3),
        .pixel4(pixel4),
        .pixel5(pixel5),
        .pixel6(pixel6),
        .pixel7(pixel7),
        .pixel8(pixel8),

        .weight0(weight0),
        .weight1(weight1),
        .weight2(weight2),
        .weight3(weight3),
        .weight4(weight4),
        .weight5(weight5),
        .weight6(weight6),
        .weight7(weight7),
        .weight8(weight8),

        .result(result),
        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    initial begin

        clk   = 0;
        rst   = 1;
        valid = 0;

        pixel0 = 0;
        pixel1 = 0;
        pixel2 = 0;
        pixel3 = 0;
        pixel4 = 0;
        pixel5 = 0;
        pixel6 = 0;
        pixel7 = 0;
        pixel8 = 0;

        weight0 = 0;
        weight1 = 0;
        weight2 = 0;
        weight3 = 0;
        weight4 = 0;
        weight5 = 0;
        weight6 = 0;
        weight7 = 0;
        weight8 = 0;

        #20;

        rst = 0;

        /*
         * Input:
         *
         * 1 2 3
         * 4 5 6
         * 7 8 9
         *
         * Kernel:
         *
         * 1 1 1
         * 1 1 1
         * 1 1 1
         *
         * Expected:
         *
         * 1+2+3+4+5+6+7+8+9 = 45
         */

        @(negedge clk);

        valid = 1;

        pixel0 = 1;
        pixel1 = 2;
        pixel2 = 3;
        pixel3 = 4;
        pixel4 = 5;
        pixel5 = 6;
        pixel6 = 7;
        pixel7 = 8;
        pixel8 = 9;

        weight0 = 1;
        weight1 = 1;
        weight2 = 1;
        weight3 = 1;
        weight4 = 1;
        weight5 = 1;
        weight6 = 1;
        weight7 = 1;
        weight8 = 1;

        @(negedge clk);

        valid = 0;

        #10;

        $display("");
        $display("========== 3x3 CONVOLUTION TEST ==========");
        $display("Expected result : 45");
        $display("Actual result   : %0d", result);
        $display("Valid output    : %b", valid_out);

        if (result == 45 && valid_out == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $display("===========================================");
        $display("");

        $finish;

    end

endmodule

`timescale 1ns/1ps

module tb_cnn_conv_relu;

    reg clk;
    reg rst;
    reg valid;

    reg signed [7:0] pixel0, pixel1, pixel2;
    reg signed [7:0] pixel3, pixel4, pixel5;
    reg signed [7:0] pixel6, pixel7, pixel8;

    reg signed [7:0] weight0, weight1, weight2;
    reg signed [7:0] weight3, weight4, weight5;
    reg signed [7:0] weight6, weight7, weight8;

    wire signed [31:0] conv_result;
    wire signed [31:0] relu_result;
    wire valid_out;

    cnn_conv_relu dut (
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

        .conv_result(conv_result),
        .relu_result(relu_result),
        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    initial begin

        clk   = 0;
        rst   = 1;
        valid = 0;

        pixel0 = 0; pixel1 = 0; pixel2 = 0;
        pixel3 = 0; pixel4 = 0; pixel5 = 0;
        pixel6 = 0; pixel7 = 0; pixel8 = 0;

        weight0 = 0; weight1 = 0; weight2 = 0;
        weight3 = 0; weight4 = 0; weight5 = 0;
        weight6 = 0; weight7 = 0; weight8 = 0;

        #20;
        rst = 0;

        // Test 1:
        // Pixels = 1..9
        // All weights = 1
        // Expected convolution = 45
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

        valid = 1;

        #10;
        valid = 0;

        #10;

        $display("========== CONV + RELU TEST 1 ==========");
        $display("Expected convolution : 45");
        $display("Actual convolution   : %0d", conv_result);
        $display("Actual ReLU          : %0d", relu_result);

        if (conv_result == 45 && relu_result == 45)
            $display("TEST 1 PASSED");
        else
            $display("TEST 1 FAILED");

        // Test 2:
        // Same pixels, all weights = -1
        // Expected convolution = -45
        // ReLU should produce 0

        weight0 = -1;
        weight1 = -1;
        weight2 = -1;
        weight3 = -1;
        weight4 = -1;
        weight5 = -1;
        weight6 = -1;
        weight7 = -1;
        weight8 = -1;

        valid = 1;

        #10;
        valid = 0;

        #10;

        $display("");
        $display("========== CONV + RELU TEST 2 ==========");
        $display("Expected convolution : -45");
        $display("Actual convolution   : %0d", conv_result);
        $display("Expected ReLU        : 0");
        $display("Actual ReLU          : %0d", relu_result);

        if (conv_result == -45 && relu_result == 0)
            $display("TEST 2 PASSED");
        else
            $display("TEST 2 FAILED");

        $display("");
        $display("=========================================");
        $finish;
    end

endmodule

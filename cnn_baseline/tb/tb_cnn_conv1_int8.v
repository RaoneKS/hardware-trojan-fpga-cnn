`timescale 1ns/1ps

module tb_cnn_conv1_int8;

    reg clk;
    reg rst;
    reg valid_in;

    reg signed [7:0] pixel0, pixel1, pixel2;
    reg signed [7:0] pixel3, pixel4, pixel5;
    reg signed [7:0] pixel6, pixel7, pixel8;

    wire signed [31:0] result0;
    wire signed [31:0] result1;
    wire signed [31:0] result2;
    wire signed [31:0] result3;
    wire signed [31:0] result4;
    wire signed [31:0] result5;
    wire signed [31:0] result6;
    wire signed [31:0] result7;

    wire valid_out;

    cnn_conv1_int8 dut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),

        .pixel0(pixel0),
        .pixel1(pixel1),
        .pixel2(pixel2),
        .pixel3(pixel3),
        .pixel4(pixel4),
        .pixel5(pixel5),
        .pixel6(pixel6),
        .pixel7(pixel7),
        .pixel8(pixel8),

        .result0(result0),
        .result1(result1),
        .result2(result2),
        .result3(result3),
        .result4(result4),
        .result5(result5),
        .result6(result6),
        .result7(result7),

        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        rst = 1;
        valid_in = 0;

        pixel0 = 0;
        pixel1 = 0;
        pixel2 = 0;
        pixel3 = 0;
        pixel4 = 0;
        pixel5 = 0;
        pixel6 = 0;
        pixel7 = 0;
        pixel8 = 0;

        #20;

        rst = 0;

        // Test 3x3 pixel window
        // Same deterministic input used for RTL verification.
        pixel0 = 1;
        pixel1 = 2;
        pixel2 = 3;
        pixel3 = 4;
        pixel4 = 5;
        pixel5 = 6;
        pixel6 = 7;
        pixel7 = 8;
        pixel8 = 9;

        valid_in = 1;

        #10;

        valid_in = 0;

        #10;

        $display("");
        $display("========================================");
        $display("REAL TRAINED CONV1 INT8 TEST");
        $display("========================================");

        $display("Filter 0 = %0d", result0);
        $display("Filter 1 = %0d", result1);
        $display("Filter 2 = %0d", result2);
        $display("Filter 3 = %0d", result3);
        $display("Filter 4 = %0d", result4);
        $display("Filter 5 = %0d", result5);
        $display("Filter 6 = %0d", result6);
        $display("Filter 7 = %0d", result7);

        $display("valid_out = %0d", valid_out);

        $display("========================================");

        $finish;

    end

endmodule

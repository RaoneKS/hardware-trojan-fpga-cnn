`timescale 1ns/1ps

module tb_cnn_conv3x3;

    reg clk;
    reg rst;
    reg valid;

    reg signed [7:0] pixel0, pixel1, pixel2;
    reg signed [7:0] pixel3, pixel4, pixel5;
    reg signed [7:0] pixel6, pixel7, pixel8;

    reg signed [7:0] weight0, weight1, weight2;
    reg signed [7:0] weight3, weight4, weight5;
    reg signed [7:0] weight6, weight7, weight8;

    wire signed [31:0] result;
    wire valid_out;

    integer i;

    cnn_conv3x3 dut (
        .clk(clk),
        .rst(rst),
        .valid(valid),

        .pixel0(pixel0), .pixel1(pixel1), .pixel2(pixel2),
        .pixel3(pixel3), .pixel4(pixel4), .pixel5(pixel5),
        .pixel6(pixel6), .pixel7(pixel7), .pixel8(pixel8),

        .weight0(weight0), .weight1(weight1), .weight2(weight2),
        .weight3(weight3), .weight4(weight4), .weight5(weight5),
        .weight6(weight6), .weight7(weight7), .weight8(weight8),

        .result(result),
        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("cnn_baseline.vcd");
        $dumpvars(0, tb_cnn_conv3x3);

        clk = 0;
        rst = 1;
        valid = 0;

        pixel0 = 0; pixel1 = 0; pixel2 = 0;
        pixel3 = 0; pixel4 = 0; pixel5 = 0;
        pixel6 = 0; pixel7 = 0; pixel8 = 0;

        weight0 = 0; weight1 = 0; weight2 = 0;
        weight3 = 0; weight4 = 0; weight5 = 0;
        weight6 = 0; weight7 = 0; weight8 = 0;

        // Reset
        repeat (3) @(posedge clk);
        rst = 0;

        // ----------------------------------------------------
        // 100 convolution transactions
        // ----------------------------------------------------

        for (i = 0; i < 100; i = i + 1) begin

            @(negedge clk);

            // Varying signed pixel values
            pixel0 = (i * 3)  - 100;
            pixel1 = (i * 5)  - 110;
            pixel2 = (i * 7)  - 120;

            pixel3 = (i * 2)  - 90;
            pixel4 = (i * 4)  - 80;
            pixel5 = (i * 6)  - 70;

            pixel6 = (i * 8)  - 60;
            pixel7 = (i * 9)  - 50;
            pixel8 = (i * 10) - 40;

            // Varying signed weights
            weight0 = (i % 7) - 3;
            weight1 = (i % 5) - 2;
            weight2 = (i % 9) - 4;

            weight3 = (i % 6) - 3;
            weight4 = (i % 8) - 4;
            weight5 = (i % 5) - 2;

            weight6 = (i % 7) - 3;
            weight7 = (i % 9) - 4;
            weight8 = (i % 6) - 3;

            valid = 1;

            @(negedge clk);
            valid = 0;
        end

        // Allow final pipeline results to emerge
        repeat (8) @(posedge clk);

        $display("========================================");
        $display("LONG CNN BASELINE SIMULATION COMPLETE");
        $display("100 convolution transactions processed");
        $display("Final result = %0d", result);
        $display("========================================");

        $finish;
    end

endmodule

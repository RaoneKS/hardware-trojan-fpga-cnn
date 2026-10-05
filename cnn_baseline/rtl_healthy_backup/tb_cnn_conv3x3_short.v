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

        #20;

        rst = 0;

        // Pixels = 1..9
        pixel0 = 8'sd1;
        pixel1 = 8'sd2;
        pixel2 = 8'sd3;
        pixel3 = 8'sd4;
        pixel4 = 8'sd5;
        pixel5 = 8'sd6;
        pixel6 = 8'sd7;
        pixel7 = 8'sd8;
        pixel8 = 8'sd9;

        // All-one kernel
        weight0 = 8'sd1;
        weight1 = 8'sd1;
        weight2 = 8'sd1;
        weight3 = 8'sd1;
        weight4 = 8'sd1;
        weight5 = 8'sd1;
        weight6 = 8'sd1;
        weight7 = 8'sd1;
        weight8 = 8'sd1;

        valid = 1;

        @(posedge clk);
        #1 valid = 0;

        // Wait for pipeline
        repeat (5) begin
            @(posedge clk);
            #1;
            $display(
                "[%0t ns] valid_out=%b result=%0d",
                $time,
                valid_out,
                result
            );
        end

        if (valid_out && result == 45)
            $display("PASS: 3x3 convolution result = %0d", result);
        else if (result == 45)
            $display("PASS: result = 45");
        else
            $display("ERROR: expected 45, got %0d", result);

        $finish;
    end

endmodule

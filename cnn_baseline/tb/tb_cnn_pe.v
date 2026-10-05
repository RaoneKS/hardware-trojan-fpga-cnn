`timescale 1ns/1ps

module tb_cnn_pe;

    reg clk;
    reg rst;
    reg valid;

    reg signed [7:0] data_in;
    reg signed [7:0] weight;
    reg signed [31:0] acc_in;

    wire signed [31:0] acc_out;
    wire valid_out;

    cnn_pe uut (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .data_in(data_in),
        .weight(weight),
        .acc_in(acc_in),
        .acc_out(acc_out),
        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    initial begin
        $monitor(
            "Time=%0t | rst=%b valid=%b data=%d weight=%d acc_in=%d | acc_out=%d valid_out=%b",
            $time, rst, valid, data_in, weight, acc_in,
            acc_out, valid_out
        );

        clk     = 0;
        rst     = 1;
        valid   = 0;
        data_in = 0;
        weight  = 0;
        acc_in  = 0;

        #20;

        rst = 0;

        // Test 1: 3 x 4 + 10 = 22
        @(negedge clk);
        valid   = 1;
        data_in = 8'sd3;
        weight  = 8'sd4;
        acc_in  = 32'sd10;

        @(negedge clk);

        // Test 2: -2 x 5 + 7 = -3
        data_in = -8'sd2;
        weight  = 8'sd5;
        acc_in  = 32'sd7;

        @(negedge clk);

        // Test 3: 6 x -3 + 20 = 2
        data_in = 8'sd6;
        weight  = -8'sd3;
        acc_in  = 32'sd20;

        @(negedge clk);

        valid = 0;

        #20;

        $finish;
    end

endmodule

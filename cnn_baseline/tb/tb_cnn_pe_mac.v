`timescale 1ns/1ps

module tb_cnn_pe_mac;

    reg clk;
    reg rst;
    reg valid_in;
    reg signed [7:0] data_in;
    reg signed [7:0] weight_in;
    reg signed [63:0] psum_in;
    wire valid_out;
    wire signed [63:0] psum_out;

    cnn_pe_mac dut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .data_in(data_in),
        .weight_in(weight_in),
        .psum_in(psum_in),
        .valid_out(valid_out),
        .psum_out(psum_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        valid_in = 0;
        data_in = 0;
        weight_in = 0;
        psum_in = 0;

        #12;
        rst = 0;

        data_in = 3;
        weight_in = 4;
        psum_in = 10;
        valid_in = 1;
        #10;
        valid_in = 0;
        #1;
        $display("TEST 1: 3*4+10 = %0d", psum_out);

        data_in = -2;
        weight_in = 5;
        psum_in = 7;
        valid_in = 1;
        #10;
        valid_in = 0;
        #1;
        $display("TEST 2: -2*5+7 = %0d", psum_out);

        data_in = 6;
        weight_in = -3;
        psum_in = 20;
        valid_in = 1;
        #10;
        valid_in = 0;
        #1;
        $display("TEST 3: 6*(-3)+20 = %0d", psum_out);

        $finish;
    end
endmodule

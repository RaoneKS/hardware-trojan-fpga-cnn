`timescale 1ns/1ps

module tb_cnn_pe_array_4x4;

    reg clk;
    reg rst;
    reg valid_in;

    reg signed [7:0] data_in [0:3];
    reg signed [7:0] weight_in[0:3];

    wire signed [31:0] psum_out [0:3];
    wire signed [7:0] data_out [0:3];

    wire valid_out;

    cnn_pe_array_4x4 dut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),

        .data_in(data_in),
        .weight_in(weight_in),

        .psum_out(psum_out),
        .data_out(data_out),

        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        rst = 1;
        valid_in = 0;

        data_in[0] = 0;
        data_in[1] = 0;
        data_in[2] = 0;
        data_in[3] = 0;

        weight_in[0] = 0;
        weight_in[1] = 0;
        weight_in[2] = 0;
        weight_in[3] = 0;

        #20;

        rst = 0;

        // -----------------------------------------------------
        // Row 0:
        //
        // 5*2 + 5*3 + 5*4 + 5*5 = 70
        // -----------------------------------------------------

        data_in[0] = 8'sd5;
        data_in[1] = 8'sd5;
        data_in[2] = 8'sd5;
        data_in[3] = 8'sd5;

        weight_in[0] = 8'sd2;
        weight_in[1] = 8'sd3;
        weight_in[2] = 8'sd4;
        weight_in[3] = 8'sd5;

        valid_in = 1;

        #10;

        valid_in = 0;

        wait(valid_out);

        #1;

        $display("");
        $display("======================================");
        $display(" 4x4 PE ARRAY TEST");
        $display("======================================");

        $display("Row 0 PSUM = %0d", psum_out[0]);
        $display("Row 1 PSUM = %0d", psum_out[1]);
        $display("Row 2 PSUM = %0d", psum_out[2]);
        $display("Row 3 PSUM = %0d", psum_out[3]);

        if (psum_out[0] == 70) begin
            $display("PASS: PE array MAC result = 70");
        end
        else begin
            $display("FAIL: Expected 70");
        end

        $display("======================================");

        $finish;

    end

endmodule

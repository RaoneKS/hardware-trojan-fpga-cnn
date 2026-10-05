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

    always #5 clk = ~clk;

    initial begin
        $dumpfile("cnn_pe_interconnect.vcd");
        $dumpvars(0, tb_cnn_pe_interconnect);

        clk = 0;
        rst = 1;
        valid = 0;

        data_in = 0;
        weight0 = 0;
        weight1 = 0;
        weight2 = 0;
        weight3 = 0;

        // Reset
        repeat(2) @(posedge clk);
        rst = 0;

        // Test:
        // 5×2 + 5×3 + 5×4 + 5×5
        // = 10 + 15 + 20 + 25
        // = 70

        @(negedge clk);

        data_in = 5;
        weight0 = 2;
        weight1 = 3;
        weight2 = 4;
        weight3 = 5;
        valid = 1;

        @(negedge clk);
        valid = 0;

        // Wait for PE pipeline
        repeat(6) begin
            @(posedge clk);
            #1;
            $display(
                "[%0t ns] valid_out=%b result=%0d",
                $time,
                valid_out,
                result
            );
        end

        if (result == 70)
            $display("PASS: 4-PE interconnect result = 70");
        else
            $display("FAIL: expected 70, got %0d", result);

        $finish;
    end

endmodule

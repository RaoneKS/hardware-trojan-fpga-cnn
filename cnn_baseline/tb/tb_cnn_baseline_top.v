`timescale 1ns/1ps

module tb_cnn_baseline_top;

    reg clk;
    reg rst;

    wire signed [31:0] conv_result;
    wire signed [31:0] relu_result;
    wire valid_out;

    cnn_baseline_top dut (
        .clk(clk),
        .rst(rst),
        .conv_result(conv_result),
        .relu_result(relu_result),
        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        rst = 1;

        #20;
        rst = 0;

        // Wait for convolution result
        #20;

        $display("========================================");
        $display("       CNN BASELINE TOP TEST");
        $display("========================================");
        $display("Expected convolution : 45");
        $display("Actual convolution   : %0d", conv_result);
        $display("Expected ReLU        : 45");
        $display("Actual ReLU          : %0d", relu_result);
        $display("Valid output         : %b", valid_out);

        if ((conv_result == 45) &&
            (relu_result == 45) &&
            (valid_out == 1'b1)) begin

            $display("");
            $display("CNN BASELINE TEST PASSED");
            $display("");

        end
        else begin

            $display("");
            $display("CNN BASELINE TEST FAILED");
            $display("");

        end

        $display("========================================");

        $finish;
    end

endmodule

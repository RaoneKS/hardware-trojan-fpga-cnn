`timescale 1ns/1ps

module tb_cnn_healthy_inference_int8;

    reg clk;
    reg rst;
    reg start;

    wire done;
    wire [3:0] predicted_class;

    cnn_healthy_inference_int8 dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .predicted_class(predicted_class)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin

        clk   = 0;
        rst   = 1;
        start = 0;
        $dumpfile("reports/healthy_cnn.vcd");
        $dumpvars(0, tb_cnn_healthy_inference_int8);

        $display("");
        $display("==============================================");
        $display(" HEALTHY CNN INT8 END-TO-END RTL TEST");
        $display("==============================================");

        // Reset
        #20;
        rst = 0;

        // Start inference
        #10;
        start = 1;

        #10;
        start = 0;

        // Wait for completion
        wait(done == 1'b1);

        #1;

        $display("");
        $display("==============================================");
        $display(" INFERENCE COMPLETE");
        $display("==============================================");

        $display("RTL predicted class = %0d", predicted_class);
        $display("Expected class      = 7");

        if (predicted_class == 4'd7) begin

            $display("");
            $display("PASS: RTL prediction matches expected class 7.");

        end
        else begin

            $display("");
            $display("FAIL: RTL prediction does not match expected class.");

        end

        $display("");
        $display("==============================================");

        $finish;

    end

endmodule

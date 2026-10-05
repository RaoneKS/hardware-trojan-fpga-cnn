`timescale 1ns/1ps

module tb_healthy_activity;

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

    always #5 clk = ~clk;

    initial begin

        $dumpfile(
            "reports/healthy_cnn_internal.vcd"
        );

        $dumpvars(
            0,
            tb_healthy_activity
        );

        clk = 0;

        rst = 1;

        start = 0;

        #20;

        rst = 0;

        #20;

        start = 1;

        #10;

        start = 0;

        wait(done);

        #100;

        $finish;

    end

endmodule

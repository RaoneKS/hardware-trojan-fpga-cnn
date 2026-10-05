`timescale 1ns/1ps

module tb_cnn_fc_int8;

    reg clk;
    reg rst;
    reg start;

    wire done;
    wire valid_out;

    wire signed [63:0] output_score;
    wire [3:0] output_class;

    cnn_fc_int8 dut (
        .clk(clk),
        .rst(rst),
        .start(start),

        .done(done),
        .valid_out(valid_out),

        .output_score(output_score),
        .output_class(output_class)
    );

    integer i;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        rst   = 1;
        start = 0;

        #20;

        rst = 0;

        // Deterministic FC input
        for (i = 0; i < 784; i = i + 1)
            dut.input_data[i] = i % 16;

        #20;

        start = 1;
        #10;
        start = 0;

        wait(done);

        $display("");
        $display("====================================");
        $display("FC TEST COMPLETE");
        $display("====================================");

        $display("Predicted class = %d", output_class);

        $finish;

    end

endmodule

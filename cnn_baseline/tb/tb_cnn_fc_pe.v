`timescale 1ns/1ps

module tb_cnn_fc_pe;

    reg clk;
    reg rst;
    reg start;

    wire signed [63:0] result;
    wire [3:0] class_id;
    wire valid_out;
    wire done;

    cnn_fc_pe dut (
        .clk        (clk),
        .rst        (rst),
        .start      (start),
        .result     (result),
        .class_id   (class_id),
        .valid_out  (valid_out),
        .done       (done)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        rst   = 1;
        start = 0;

        #20;
        rst = 0;

        #20;
        start = 1;

        #10;
        start = 0;

        wait(done);

        #20;

        $display("======================================");
        $display("FC PE TEST COMPLETE");
        $display("======================================");
        $display("Predicted class = %0d", class_id);
        $display("Final result    = %0d", result);
        $display("======================================");

        $finish;
    end

    always @(posedge clk) begin
        if (valid_out)
            $display("FC output: class=%0d result=%0d",
                     class_id, result);
    end

endmodule

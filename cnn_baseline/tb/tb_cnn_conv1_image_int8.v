`timescale 1ns/1ps

module tb_cnn_conv1_image_int8;

    reg clk;
    reg rst;
    reg start;

    wire signed [31:0] result;
    wire [3:0] filter_index;
    wire [4:0] row;
    wire [4:0] col;
    wire valid_out;
    wire busy;
    wire done;

    cnn_conv1_image_int8 dut (
        .clk(clk),
        .rst(rst),
        .start(start),

        .result(result),
        .filter_index(filter_index),
        .row(row),
        .col(col),
        .valid_out(valid_out),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    integer count;

    initial begin

        clk = 0;
        rst = 1;
        start = 0;
        count = 0;

        #20;

        rst = 0;

        #10;

        start = 1;

        #10;

        start = 0;

        // Wait until the complete 26x26x8
        // convolution finishes.

        wait(done);

        #10;

        $display("");
        $display("========================================");
        $display("FULL CONV1 IMAGE TEST");
        $display("========================================");
        $display("Total expected outputs = %0d", 28*28*8);
        $display("========================================");
        $display("PASS: Full Conv1 processing completed.");
        $display("========================================");

        $finish;

    end

    // Display selected outputs
    always @(posedge clk) begin

        if (valid_out) begin

            count = count + 1;

            if (count <= 10) begin
                $display(
                    "Output %0d: row=%0d col=%0d filter=%0d result=%0d",
                    count,
                    row,
                    col,
                    filter_index,
                    result
                );
            end

        end

    end

endmodule

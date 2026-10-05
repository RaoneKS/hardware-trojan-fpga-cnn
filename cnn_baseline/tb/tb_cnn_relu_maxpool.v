`timescale 1ns/1ps

module tb_cnn_relu_maxpool;

    reg clk;
    reg rst;
    reg start;

    wire signed [31:0] result;
    wire [3:0] filter_index;
    wire [3:0] row;
    wire [3:0] col;
    wire valid_out;
    wire busy;
    wire done;

    integer count;

    cnn_relu_maxpool dut (
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

    initial begin

        clk   = 0;
        rst   = 1;
        start = 0;
        count = 0;

        #20;

        rst = 0;

        #10;

        start = 1;

        #10;

        start = 0;

        // Wait until all 1568 outputs have been generated.
        wait(count == 1568);

        // Allow final signal updates to settle.
        #10;

        $display("");
        $display("========================================");
        $display("RELU + 2x2 MAXPOOL TEST");
        $display("========================================");
        $display("Expected outputs = %0d", 14*14*8);
        $display("Actual outputs   = %0d", count);
        $display("========================================");

        if (count == 14*14*8)
            $display("PASS: ReLU + MaxPool completed.");
        else
            $display("FAIL: Incorrect output count.");

        $display("========================================");

        $finish;

    end

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

            if (count == 1568) begin

                $display("");
                $display("LAST OUTPUT:");
                $display(
                    "row=%0d col=%0d filter=%0d result=%0d",
                    row,
                    col,
                    filter_index,
                    result
                );

            end

        end

    end

endmodule

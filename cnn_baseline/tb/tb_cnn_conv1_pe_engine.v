`timescale 1ns/1ps

module tb_cnn_conv1_pe_engine;

    reg clk;
    reg rst;
    reg start;

    wire signed [63:0] result;
    wire [4:0] row;
    wire [4:0] col;
    wire [2:0] filter;

    wire valid_out;
    wire done;

    integer count;

    cnn_conv1_pe_engine dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .result(result),
        .row(row),
        .col(col),
        .filter(filter),
        .valid_out(valid_out),
        .done(done)
    );

    always #5 clk = ~clk;

    always @(negedge clk) begin
        if (valid_out) begin
            count = count + 1;

            if (count <= 10) begin
                $display(
                    "OUT %0d : row=%0d col=%0d filter=%0d result=%0d",
                    count, row, col, filter, result
                );
            end
        end
    end

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

        wait(done);

        #10;

        $display("");
        $display("====================================");
        $display("Total Conv1 outputs = %0d", count);
        $display("Expected outputs    = 6272");
        $display("====================================");

        if (count == 6272)
            $display("PASS");
        else
            $display("FAIL");

        $finish;

    end

endmodule

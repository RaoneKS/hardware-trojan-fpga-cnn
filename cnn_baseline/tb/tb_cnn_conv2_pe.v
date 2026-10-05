`timescale 1ns/1ps

module tb_cnn_conv2_pe;

    reg clk;
    reg rst;
    reg start;

    wire signed [63:0] result;
    wire [3:0] row;
    wire [3:0] col;
    wire [3:0] filter;
    wire valid_out;
    wire done;

    integer valid_count;
    integer fd;

    cnn_conv2_pe dut (
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

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    always @(negedge clk) begin
        if (valid_out) begin
            valid_count = valid_count + 1;

            $fdisplay(fd, "%0d %0d %0d %0d",
                      row, col, filter, result);
        end
    end

    initial begin

        valid_count = 0;

        fd = $fopen("reports/rtl_conv2_results.txt", "w");

        if (fd == 0) begin
            $display("ERROR: Could not open output file.");
            $finish;
        end

        rst = 1;
        start = 0;

        #20;

        rst = 0;

        #10;

        start = 1;

        #10;

        start = 0;

        wait(done);

        #20;

        $fclose(fd);

        $display("");
        $display("==============================================");
        $display(" CONV2 PE RTL TEST");
        $display("==============================================");
        $display("");

        $display("RTL outputs = %0d", valid_count);
        $display("Expected    = 3136");
        $display("");

        if (valid_count == 3136)
            $display("PASS: Conv2 generated all 3136 outputs.");
        else
            $display("FAIL: Expected 3136, got %0d",
                     valid_count);

        $display("");
        $display("Final output:");
        $display("Row    = %0d", row);
        $display("Column = %0d", col);
        $display("Filter = %0d", filter);
        $display("Result = %0d", result);

        $display("");
        $display("Results saved to:");
        $display("reports/rtl_conv2_results.txt");

        $display("");
        $display("==============================================");

        $finish;
    end

endmodule

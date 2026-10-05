`timescale 1ns/1ps

module tb_cnn_conv1_8pe_parallel;

    reg clk;
    reg rst;
    reg start;

    wire signed [63:0] pe_result0;
    wire signed [63:0] pe_result1;
    wire signed [63:0] pe_result2;
    wire signed [63:0] pe_result3;
    wire signed [63:0] pe_result4;
    wire signed [63:0] pe_result5;
    wire signed [63:0] pe_result6;
    wire signed [63:0] pe_result7;

    wire [4:0] row;
    wire [4:0] col;

    wire valid_out;
    wire done;

    integer count;
    integer fd;

    cnn_conv1_8pe_parallel dut (
        .clk(clk),
        .rst(rst),
        .start(start),

        .pe_result0(pe_result0),
        .pe_result1(pe_result1),
        .pe_result2(pe_result2),
        .pe_result3(pe_result3),
        .pe_result4(pe_result4),
        .pe_result5(pe_result5),
        .pe_result6(pe_result6),
        .pe_result7(pe_result7),

        .row(row),
        .col(col),

        .valid_out(valid_out),
        .done(done)
    );

    always #5 clk = ~clk;

    always @(negedge clk) begin
        if (valid_out) begin

            count = count + 1;

            $fwrite(fd,
                "%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n",
                row,
                col,
                pe_result0,
                pe_result1,
                pe_result2,
                pe_result3,
                pe_result4,
                pe_result5,
                pe_result6,
                pe_result7
            );

        end
    end

    initial begin

        fd = $fopen("reports/rtl_conv1_8pe_results.txt", "w");

        if (fd == 0) begin
            $display("ERROR: Cannot open output file");
            $finish;
        end

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

        wait(done);

        #10;

        $fclose(fd);

        $display("");
        $display("======================================");
        $display("Conv1 PE positions = %0d", count);
        $display("Expected positions = 784");
        $display("Total PE outputs    = %0d", count * 8);
        $display("Expected PE outputs = 6272");
        $display("======================================");

        if (count == 784)
            $display("PASS");
        else
            $display("FAIL");

        $finish;

    end

endmodule

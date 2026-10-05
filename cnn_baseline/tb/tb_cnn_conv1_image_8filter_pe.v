`timescale 1ns/1ps

module tb_cnn_conv1_image_8filter_pe;

    reg clk;
    reg rst;
    reg start;

    wire signed [31:0] result;
    wire [4:0] row;
    wire [4:0] col;
    wire [2:0] filter;
    wire valid_out;
    wire done;

    integer valid_count;
    integer fd;

    cnn_conv1_image_8filter_pe dut (
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

    /*
     * Capture every RTL result.
     * Falling edge avoids the DUT NBA timing race.
     */
    always @(negedge clk) begin
        if (valid_out) begin
            valid_count = valid_count + 1;

            $fdisplay(fd, "%0d %0d %0d %0d",
                      row, col, filter, result);
        end
    end

    initial begin

        valid_count = 0;

        fd = $fopen("reports/rtl_conv1_pe_results.txt", "w");

        if (fd == 0) begin
            $display("ERROR: Could not open result file.");
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
        $display("----------------------------------------");
        $display("CONV1 PE RTL VERIFICATION");
        $display("----------------------------------------");

        $display("RTL outputs checked = %0d", valid_count);
        $display("Expected outputs    = 6272");
        $display("");

        if (valid_count == 6272) begin
            $display("PASS: RTL generated all 6272 Conv1 outputs.");
        end
        else begin
            $display("FAIL: RTL generated %0d outputs.",
                     valid_count);
        end

        $display("");
        $display("RTL results saved to:");
        $display("reports/rtl_conv1_pe_results.txt");

        $display("----------------------------------------");

        $finish;
    end

endmodule

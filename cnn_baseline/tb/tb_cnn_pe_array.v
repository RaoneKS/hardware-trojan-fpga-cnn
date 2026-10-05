`timescale 1ns/1ps

module tb_cnn_pe_array;

    reg clk;
    reg rst;
    reg valid;

    reg signed [7:0] data_in [0:3];
    reg signed [7:0] weight_in [0:3];

    wire signed [31:0] acc_out [0:3][0:3];
    wire valid_out [0:3][0:3];

    cnn_pe_array uut (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .data_in(data_in),
        .weight_in(weight_in),
        .acc_out(acc_out),
        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    integer r;
    integer c;

    initial begin

        clk   = 0;
        rst   = 1;
        valid = 0;

        for (r = 0; r < 4; r = r + 1)
            data_in[r] = 0;

        for (c = 0; c < 4; c = c + 1)
            weight_in[c] = 0;

        #20;

        rst = 0;

        /*
         * Input vector:
         *
         * data   = [1, 2, 3, 4]
         * weight = [1, 2, 3, 4]
         */

        @(negedge clk);

        valid = 1;

        data_in[0] = 8'sd1;
        data_in[1] = 8'sd2;
        data_in[2] = 8'sd3;
        data_in[3] = 8'sd4;

        weight_in[0] = 8'sd1;
        weight_in[1] = 8'sd2;
        weight_in[2] = 8'sd3;
        weight_in[3] = 8'sd4;

        /*
         * Keep valid high long enough
         * for the accumulation pipeline.
         */

        repeat (6)
            @(negedge clk);

        valid = 0;

        #10;

        $display("");
        $display("========== FINAL PE ARRAY RESULTS ==========");

        for (r = 0; r < 4; r = r + 1) begin
            $display(
                "ROW %0d : %0d  %0d  %0d  %0d",
                r,
                acc_out[r][0],
                acc_out[r][1],
                acc_out[r][2],
                acc_out[r][3]
            );
        end

        $display("============================================");
        $display("");

        $finish;
    end

endmodule

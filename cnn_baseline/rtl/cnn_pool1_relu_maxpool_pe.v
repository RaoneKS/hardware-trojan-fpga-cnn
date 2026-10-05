`timescale 1ns/1ps

module cnn_pool1_relu_maxpool_pe #(
    parameter ACC_WIDTH = 32
)(
    input  wire clk,
    input  wire rst,
    input  wire start,

    output reg signed [ACC_WIDTH-1:0] result,
    output reg [3:0] row,
    output reg [3:0] col,
    output reg [2:0] filter,
    output reg valid_out,
    output reg done
);

    localparam IN_SIZE  = 28;
    localparam OUT_SIZE = 14;
    localparam FILTERS  = 8;

    reg signed [ACC_WIDTH-1:0] conv1_mem [0:6271];

    reg running;

    integer i;
    integer base;
    integer r0;
    integer c0;

    reg signed [ACC_WIDTH-1:0] a;
    reg signed [ACC_WIDTH-1:0] b;
    reg signed [ACC_WIDTH-1:0] c;
    reg signed [ACC_WIDTH-1:0] d;

    reg signed [ACC_WIDTH-1:0] max_val;

    /*
     * Load the previously captured Conv1 PE results.
     *
     * rtl_conv1_pe_results.txt contains:
     * row col filter result
     *
     * We only need the result field here.
     */
    initial begin
        $readmemh("reports/conv1_pool_input.mem", conv1_mem);
    end

    /*
     * ReLU + 2x2 MaxPool.
     */
    always @(*) begin

        r0 = row * 2;
        c0 = col * 2;

        /*
         * Layout:
         * index = row*28*8 + col*8 + filter
         */
        base = (r0 * IN_SIZE * FILTERS) +
               (c0 * FILTERS) +
               filter;

        a = conv1_mem[base];
        b = conv1_mem[base + FILTERS];
        c = conv1_mem[base + IN_SIZE*FILTERS];
        d = conv1_mem[base + IN_SIZE*FILTERS + FILTERS];

        /*
         * ReLU
         */
        if (a < 0) a = 0;
        if (b < 0) b = 0;
        if (c < 0) c = 0;
        if (d < 0) d = 0;

        max_val = a;

        if (b > max_val)
            max_val = b;

        if (c > max_val)
            max_val = c;

        if (d > max_val)
            max_val = d;
    end

    /*
     * Controller.
     *
     * 14 x 14 x 8 = 1568 outputs.
     */
    always @(posedge clk) begin

        if (rst) begin
            row       <= 0;
            col       <= 0;
            filter    <= 0;
            result    <= 0;
            valid_out <= 0;
            done      <= 0;
            running   <= 0;
        end

        else begin

            valid_out <= 0;
            done      <= 0;

            if (start && !running) begin

                row     <= 0;
                col     <= 0;
                filter  <= 0;
                running <= 1;

            end

            else if (running) begin

                result    <= max_val;
                valid_out <= 1;

                if ((row == 13) &&
                    (col == 13) &&
                    (filter == 7)) begin

                    running <= 0;
                    done    <= 1;

                end

                else if (filter < 7) begin

                    filter <= filter + 1;

                end

                else begin

                    filter <= 0;

                    if (col < 13) begin

                        col <= col + 1;

                    end

                    else begin

                        col <= 0;

                        if (row < 13)
                            row <= row + 1;

                    end
                end
            end
        end
    end

endmodule

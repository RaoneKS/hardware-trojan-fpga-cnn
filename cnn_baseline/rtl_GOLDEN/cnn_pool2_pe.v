`timescale 1ns/1ps

module cnn_pool2_pe #(
    parameter ACC_WIDTH = 64
)(
    input  wire clk,
    input  wire rst,
    input  wire start,

    output reg signed [ACC_WIDTH-1:0] result,
    output reg [2:0] row,
    output reg [2:0] col,
    output reg [3:0] filter,
    output reg valid_out,
    output reg done
);

    localparam IN_SIZE  = 14;
    localparam OUT_SIZE = 7;
    localparam FILTERS  = 16;

    reg signed [ACC_WIDTH-1:0] conv2_mem [0:3135];

    reg running;

    integer base;
    integer r0;
    integer c0;

    reg signed [ACC_WIDTH-1:0] a;
    reg signed [ACC_WIDTH-1:0] b;
    reg signed [ACC_WIDTH-1:0] c;
    reg signed [ACC_WIDTH-1:0] d;
    reg signed [ACC_WIDTH-1:0] max_val;

    initial begin
        $readmemh("reports/conv2_pool2_input.mem", conv2_mem);
    end

    always @(*) begin

        r0 = row * 2;
        c0 = col * 2;

        // Layout:
        // [row][column][filter]

        base = (r0 * IN_SIZE * FILTERS) +
               (c0 * FILTERS) +
               filter;

        a = conv2_mem[base];
        b = conv2_mem[base + FILTERS];

        c = conv2_mem[base + IN_SIZE*FILTERS];

        d = conv2_mem[
                base +
                IN_SIZE*FILTERS +
                FILTERS
            ];

        // Conv2 already has ReLU, but keep this
        // here so Pool2 explicitly represents
        // ReLU + MaxPool.

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

    always @(posedge clk) begin

        if (rst) begin
            result    <= 0;
            row       <= 0;
            col       <= 0;
            filter    <= 0;
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

                if ((row == 6) &&
                    (col == 6) &&
                    (filter == 15)) begin

                    running <= 0;
                    done    <= 1;

                end

                else if (filter < 15) begin

                    filter <= filter + 1;

                end

                else begin

                    filter <= 0;

                    if (col < 6) begin

                        col <= col + 1;

                    end

                    else begin

                        col <= 0;

                        if (row < 6)
                            row <= row + 1;

                    end
                end
            end
        end
    end

endmodule

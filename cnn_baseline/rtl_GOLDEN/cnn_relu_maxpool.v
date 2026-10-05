`timescale 1ns/1ps

module cnn_relu_maxpool #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire clk,
    input  wire rst,
    input  wire start,

    output reg signed [ACC_WIDTH-1:0] result,
    output reg [3:0] filter_index,
    output reg [3:0] row,
    output reg [3:0] col,
    output reg valid_out,
    output reg busy,
    output reg done
);

    // ------------------------------------------------------------
    // Conv1 output: 8 filters × 28 × 28
    // ------------------------------------------------------------
    reg signed [ACC_WIDTH-1:0] conv1 [0:7][0:27][0:27];

    integer f;
    integer r;
    integer c;

    reg signed [ACC_WIDTH-1:0] a;
    reg signed [ACC_WIDTH-1:0] b;
    reg signed [ACC_WIDTH-1:0] d;
    reg signed [ACC_WIDTH-1:0] e;

    reg signed [ACC_WIDTH-1:0] max1;
    reg signed [ACC_WIDTH-1:0] max2;
    reg signed [ACC_WIDTH-1:0] max_value;

    reg [3:0] current_filter;
    reg [3:0] current_row;
    reg [3:0] current_col;

    // ------------------------------------------------------------
    // Temporary test data
    //
    // This block will later receive the actual Conv1 output.
    // For now it is initialized with deterministic values so
    // ReLU + MaxPool can be verified independently.
    // ------------------------------------------------------------

    initial begin

        for (f = 0; f < 8; f = f + 1) begin
            for (r = 0; r < 28; r = r + 1) begin
                for (c = 0; c < 28; c = c + 1) begin

                    conv1[f][r][c] =
                        (f * 100) +
                        (r * 10) +
                        c - 150;

                end
            end
        end

    end

    always @(posedge clk) begin

        if (rst) begin

            result         <= 0;
            filter_index   <= 0;
            row            <= 0;
            col            <= 0;
            valid_out      <= 0;
            busy           <= 0;
            done           <= 0;

            current_filter <= 0;
            current_row    <= 0;
            current_col    <= 0;

        end

        else begin

            valid_out <= 0;
            done      <= 0;

            // ----------------------------------------------------
            // Start
            // ----------------------------------------------------

            if (start && !busy) begin

                busy           <= 1;
                current_filter <= 0;
                current_row    <= 0;
                current_col    <= 0;

            end

            // ----------------------------------------------------
            // Process one pooled output per clock
            // ----------------------------------------------------

            else if (busy) begin

                // 2×2 window

                a = conv1[current_filter]
                           [current_row * 2]
                           [current_col * 2];

                b = conv1[current_filter]
                           [current_row * 2]
                           [current_col * 2 + 1];

                d = conv1[current_filter]
                           [current_row * 2 + 1]
                           [current_col * 2];

                e = conv1[current_filter]
                           [current_row * 2 + 1]
                           [current_col * 2 + 1];

                // ReLU

                if (a < 0)
                    a = 0;

                if (b < 0)
                    b = 0;

                if (d < 0)
                    d = 0;

                if (e < 0)
                    e = 0;

                // Max of first pair

                if (a > b)
                    max1 = a;
                else
                    max1 = b;

                // Max of second pair

                if (d > e)
                    max2 = d;
                else
                    max2 = e;

                // Final maximum

                if (max1 > max2)
                    max_value = max1;
                else
                    max_value = max2;

                result       <= max_value;
                filter_index <= current_filter;
                row          <= current_row;
                col          <= current_col;
                valid_out    <= 1;

                // ------------------------------------------------
                // Advance filter
                // ------------------------------------------------

                if (current_filter < 7) begin

                    current_filter <= current_filter + 1;

                end

                else begin

                    current_filter <= 0;

                    // --------------------------------------------
                    // Advance column
                    // --------------------------------------------

                    if (current_col < 13) begin

                        current_col <= current_col + 1;

                    end

                    else begin

                        current_col <= 0;

                        // ----------------------------------------
                        // Advance row
                        // ----------------------------------------

                        if (current_row < 13) begin

                            current_row <= current_row + 1;

                        end

                        else begin

                            // ------------------------------------
                            // Complete
                            // ------------------------------------

                            busy <= 0;
                            done <= 1;

                        end
                    end
                end
            end
        end
    end

endmodule

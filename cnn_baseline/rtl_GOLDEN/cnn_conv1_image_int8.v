`timescale 1ns/1ps

module cnn_conv1_image_int8 #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire clk,
    input  wire rst,
    input  wire start,

    output reg signed [ACC_WIDTH-1:0] result,
    output reg [3:0] filter_index,
    output reg [4:0] row,
    output reg [4:0] col,
    output reg valid_out,
    output reg busy,
    output reg done
);

    // ------------------------------------------------------------
    // MNIST image: 28 x 28 = 784 pixels
    // ------------------------------------------------------------
    reg signed [DATA_WIDTH-1:0] image [0:783];

    // Conv1: 8 filters x 3 x 3 = 72 weights
    reg signed [DATA_WIDTH-1:0] weights [0:71];

    // Current output position
    reg [4:0] current_row;
    reg [4:0] current_col;
    reg [3:0] current_filter;

    integer base;
    integer wbase;
    integer r;
    integer c;
    integer idx;
    integer widx;

    reg signed [ACC_WIDTH-1:0] acc;

    initial begin
        $readmemh("data/mnist_image0_int8.mem", image);
        $readmemh("data/int8/conv1_weight.mem", weights);
    end

    always @(posedge clk) begin

        if (rst) begin
            result        <= 0;
            filter_index  <= 0;
            row           <= 0;
            col           <= 0;
            valid_out     <= 0;
            busy          <= 0;
            done          <= 0;

            current_row   <= 0;
            current_col   <= 0;
            current_filter <= 0;
        end

        else begin

            valid_out <= 0;
            done      <= 0;

            // ----------------------------------------------------
            // Start processing
            // ----------------------------------------------------
            if (start && !busy) begin
                busy           <= 1;
                current_row    <= 0;
                current_col    <= 0;
                current_filter <= 0;
            end

            // ----------------------------------------------------
            // Process one output per clock
            // ----------------------------------------------------
            else if (busy) begin

                acc = 0;

                // 3x3 convolution with padding = 1
                for (r = -1; r <= 1; r = r + 1) begin
                    for (c = -1; c <= 1; c = c + 1) begin

                        // Weight index
                        idx = (r + 1) * 3 + (c + 1);
                        widx = current_filter * 9 + idx;

                        // Zero padding outside 28x28 image
                        if (((current_row + r) < 0) ||
                            ((current_row + r) >= 28) ||
                            ((current_col + c) < 0) ||
                            ((current_col + c) >= 28)) begin

                            acc = acc;

                        end
                        else begin

                            base = (current_row + r) * 28 +
                                   (current_col + c);

                            acc = acc +
                                  image[base] *
                                  weights[widx];

                        end
                    end
                end

                result       <= acc;
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

                // ------------------------------------------------
                // Advance column
                // ------------------------------------------------
                else begin

                    current_filter <= 0;

                    if (current_col < 27) begin

                        current_col <= current_col + 1;

                    end

                    // --------------------------------------------
                    // Advance row
                    // --------------------------------------------
                    else begin

                        current_col <= 0;

                        if (current_row < 27) begin

                            current_row <= current_row + 1;

                        end

                        // ----------------------------------------
                        // Complete
                        // ----------------------------------------
                        else begin

                            busy <= 0;
                            done <= 1;

                        end
                    end
                end
            end
        end
    end

endmodule

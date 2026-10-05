`timescale 1ns/1ps

module cnn_conv1_pe_engine #(
    parameter IMG_SIZE    = 28,
    parameter NUM_FILTERS = 8,
    parameter DATA_WIDTH  = 8,
    parameter ACC_WIDTH   = 64
)(
    input  wire clk,
    input  wire rst,
    input  wire start,

    output reg signed [ACC_WIDTH-1:0] result,
    output reg [4:0] row,
    output reg [4:0] col,
    output reg [2:0] filter,

    output reg valid_out,
    output reg done
);

    // ------------------------------------------------------------
    // Memories
    // ------------------------------------------------------------

    reg signed [DATA_WIDTH-1:0] image [0:IMG_SIZE*IMG_SIZE-1];

    reg signed [DATA_WIDTH-1:0] weights
        [0:NUM_FILTERS*9-1];

    reg signed [ACC_WIDTH-1:0] biases
        [0:NUM_FILTERS-1];

    // ------------------------------------------------------------
    // Control
    // ------------------------------------------------------------

    reg busy;

    integer r;
    integer c;
    integer f;
    integer k;

    integer rr;
    integer cc;
    integer img_index;
    integer weight_index;

    reg signed [ACC_WIDTH-1:0] acc;

    reg signed [DATA_WIDTH-1:0] pixel;
    reg signed [DATA_WIDTH-1:0] weight;

    reg signed [2*DATA_WIDTH-1:0] product;

    // ------------------------------------------------------------
    // Load image and weights
    // ------------------------------------------------------------

    initial begin
        $readmemh("data/mnist_image0_int8.mem", image);
        $readmemh("data/int8/conv1_weight.mem", weights);
        $readmemh("data/int8/conv1_bias.mem", biases);
    end

    // ------------------------------------------------------------
    // Conv1
    // Padding = 1
    // Kernel = 3x3
    // One filter calculated per cycle
    // ------------------------------------------------------------

    always @(posedge clk) begin

        if (rst) begin

            result    <= 0;
            row       <= 0;
            col       <= 0;
            filter    <= 0;

            valid_out <= 0;
            done      <= 0;
            busy      <= 0;

        end
        else begin

            valid_out <= 0;
            done      <= 0;

            // Start operation
            if (start && !busy) begin
                busy  <= 1;
                r     <= 0;
                c     <= 0;
                f     <= 0;
            end

            // ----------------------------------------------------
            // Calculate one complete 3x3 convolution
            // ----------------------------------------------------

            if (busy) begin

                acc = biases[f];

                for (k = 0; k < 9; k = k + 1) begin

                    rr = r + (k / 3) - 1;
                    cc = c + (k % 3) - 1;

                    if ((rr >= 0) && (rr < IMG_SIZE) &&
                        (cc >= 0) && (cc < IMG_SIZE)) begin

                        img_index = rr * IMG_SIZE + cc;
                        weight_index = f * 9 + k;

                        pixel  = image[img_index];
                        weight = weights[weight_index];

                        product = pixel * weight;

                        acc = acc + product;

                    end

                end

                // ReLU
                if (acc < 0)
                    result <= 0;
                else
                    result <= acc;

                row    <= r;
                col    <= c;
                filter <= f;

                valid_out <= 1;

                // ------------------------------------------------
                // Next filter
                // ------------------------------------------------

                if (f == NUM_FILTERS-1) begin

                    f <= 0;

                    // Next column
                    if (c == IMG_SIZE-1) begin

                        c <= 0;

                        // Next row
                        if (r == IMG_SIZE-1) begin

                            r    <= 0;
                            busy <= 0;
                            done <= 1;

                        end
                        else begin
                            r <= r + 1;
                        end

                    end
                    else begin
                        c <= c + 1;
                    end

                end
                else begin
                    f <= f + 1;
                end

            end

        end
    end

endmodule

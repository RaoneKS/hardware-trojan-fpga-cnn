`timescale 1ns/1ps

module cnn_conv1_8pe_parallel #(
    parameter IMG_SIZE = 28,
    parameter NUM_FILTERS = 8,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 64
)(
    input wire clk,
    input wire rst,
    input wire start,

    output reg signed [ACC_WIDTH-1:0] pe_result0,
    output reg signed [ACC_WIDTH-1:0] pe_result1,
    output reg signed [ACC_WIDTH-1:0] pe_result2,
    output reg signed [ACC_WIDTH-1:0] pe_result3,
    output reg signed [ACC_WIDTH-1:0] pe_result4,
    output reg signed [ACC_WIDTH-1:0] pe_result5,
    output reg signed [ACC_WIDTH-1:0] pe_result6,
    output reg signed [ACC_WIDTH-1:0] pe_result7,

    output reg [4:0] row,
    output reg [4:0] col,

    output reg valid_out,
    output reg done
);

    reg signed [DATA_WIDTH-1:0] image [0:IMG_SIZE*IMG_SIZE-1];
    reg signed [DATA_WIDTH-1:0] weights [0:NUM_FILTERS*9-1];
    reg signed [ACC_WIDTH-1:0] biases [0:NUM_FILTERS-1];

    reg busy;

    integer r;
    integer c;
    integer f;
    integer k;
    integer rr;
    integer cc;
    integer img_index;

    reg signed [ACC_WIDTH-1:0] acc [0:7];

    initial begin
        $readmemh("data/mnist_image0_int8.mem", image);
        $readmemh("data/int8/conv1_weight.mem", weights);
        $readmemh("data/int8/conv1_bias.mem", biases);
    end

    always @(posedge clk) begin

        if (rst) begin
            busy <= 0;

            row <= 0;
            col <= 0;

            pe_result0 <= 0;
            pe_result1 <= 0;
            pe_result2 <= 0;
            pe_result3 <= 0;
            pe_result4 <= 0;
            pe_result5 <= 0;
            pe_result6 <= 0;
            pe_result7 <= 0;

            valid_out <= 0;
            done <= 0;
        end
        else begin

            valid_out <= 0;
            done <= 0;

            if (start && !busy) begin
                busy <= 1;
                r <= 0;
                c <= 0;
            end

            if (busy) begin

                for (f = 0; f < 8; f = f + 1) begin

                    acc[f] = biases[f];

                    for (k = 0; k < 9; k = k + 1) begin

                        rr = r + (k / 3) - 1;
                        cc = c + (k % 3) - 1;

                        if ((rr >= 0) &&
                            (rr < IMG_SIZE) &&
                            (cc >= 0) &&
                            (cc < IMG_SIZE)) begin

                            img_index = rr * IMG_SIZE + cc;

                            acc[f] =
                                acc[f] +
                                image[img_index] *
                                weights[f*9+k];

                        end
                    end

                    if (acc[f] < 0)
                        acc[f] = 0;

                end

                pe_result0 <= acc[0];
                pe_result1 <= acc[1];
                pe_result2 <= acc[2];
                pe_result3 <= acc[3];
                pe_result4 <= acc[4];
                pe_result5 <= acc[5];
                pe_result6 <= acc[6];
                pe_result7 <= acc[7];

                row <= r;
                col <= c;

                valid_out <= 1;

                if (c == IMG_SIZE-1) begin

                    c <= 0;

                    if (r == IMG_SIZE-1) begin
                        r <= 0;
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
        end
    end

endmodule

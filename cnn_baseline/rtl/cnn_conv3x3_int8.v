module cnn_conv3x3_int8 #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire clk,
    input  wire rst,
    input  wire valid_in,

    input wire signed [DATA_WIDTH-1:0] pixel0,
    input wire signed [DATA_WIDTH-1:0] pixel1,
    input wire signed [DATA_WIDTH-1:0] pixel2,
    input wire signed [DATA_WIDTH-1:0] pixel3,
    input wire signed [DATA_WIDTH-1:0] pixel4,
    input wire signed [DATA_WIDTH-1:0] pixel5,
    input wire signed [DATA_WIDTH-1:0] pixel6,
    input wire signed [DATA_WIDTH-1:0] pixel7,
    input wire signed [DATA_WIDTH-1:0] pixel8,

    input wire signed [DATA_WIDTH-1:0] weight0,
    input wire signed [DATA_WIDTH-1:0] weight1,
    input wire signed [DATA_WIDTH-1:0] weight2,
    input wire signed [DATA_WIDTH-1:0] weight3,
    input wire signed [DATA_WIDTH-1:0] weight4,
    input wire signed [DATA_WIDTH-1:0] weight5,
    input wire signed [DATA_WIDTH-1:0] weight6,
    input wire signed [DATA_WIDTH-1:0] weight7,
    input wire signed [DATA_WIDTH-1:0] weight8,

    output reg signed [ACC_WIDTH-1:0] result,
    output reg valid_out
);

    reg signed [ACC_WIDTH-1:0] sum;

    always @(posedge clk) begin

        if (rst) begin
            sum       <= 0;
            result    <= 0;
            valid_out <= 0;
        end

        else begin

            valid_out <= valid_in;

            if (valid_in) begin

                sum <=
                    pixel0 * weight0 +
                    pixel1 * weight1 +
                    pixel2 * weight2 +
                    pixel3 * weight3 +
                    pixel4 * weight4 +
                    pixel5 * weight5 +
                    pixel6 * weight6 +
                    pixel7 * weight7 +
                    pixel8 * weight8;

                result <=
                    pixel0 * weight0 +
                    pixel1 * weight1 +
                    pixel2 * weight2 +
                    pixel3 * weight3 +
                    pixel4 * weight4 +
                    pixel5 * weight5 +
                    pixel6 * weight6 +
                    pixel7 * weight7 +
                    pixel8 * weight8;
            end
        end
    end

endmodule

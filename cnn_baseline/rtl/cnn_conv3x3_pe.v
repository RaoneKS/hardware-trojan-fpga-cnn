module cnn_conv3x3_pe #(
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

    wire signed [ACC_WIDTH-1:0] mac0;
    wire signed [ACC_WIDTH-1:0] mac1;
    wire signed [ACC_WIDTH-1:0] mac2;
    wire signed [ACC_WIDTH-1:0] mac3;
    wire signed [ACC_WIDTH-1:0] mac4;
    wire signed [ACC_WIDTH-1:0] mac5;
    wire signed [ACC_WIDTH-1:0] mac6;
    wire signed [ACC_WIDTH-1:0] mac7;
    wire signed [ACC_WIDTH-1:0] mac8;

    assign mac0 = pixel0 * weight0;
    assign mac1 = pixel1 * weight1;
    assign mac2 = pixel2 * weight2;
    assign mac3 = pixel3 * weight3;
    assign mac4 = pixel4 * weight4;
    assign mac5 = pixel5 * weight5;
    assign mac6 = pixel6 * weight6;
    assign mac7 = pixel7 * weight7;
    assign mac8 = pixel8 * weight8;

    always @(posedge clk) begin
        if (rst) begin
            result    <= 0;
            valid_out <= 1'b0;
        end
        else begin
            valid_out <= valid_in;

            if (valid_in) begin
                result <= mac0 + mac1 + mac2 +
                          mac3 + mac4 + mac5 +
                          mac6 + mac7 + mac8;
            end
        end
    end

endmodule

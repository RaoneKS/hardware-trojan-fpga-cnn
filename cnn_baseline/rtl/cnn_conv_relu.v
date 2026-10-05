module cnn_conv_relu #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         valid,

    input  wire signed [DATA_WIDTH-1:0] pixel0,
    input  wire signed [DATA_WIDTH-1:0] pixel1,
    input  wire signed [DATA_WIDTH-1:0] pixel2,
    input  wire signed [DATA_WIDTH-1:0] pixel3,
    input  wire signed [DATA_WIDTH-1:0] pixel4,
    input  wire signed [DATA_WIDTH-1:0] pixel5,
    input  wire signed [DATA_WIDTH-1:0] pixel6,
    input  wire signed [DATA_WIDTH-1:0] pixel7,
    input  wire signed [DATA_WIDTH-1:0] pixel8,

    input  wire signed [DATA_WIDTH-1:0] weight0,
    input  wire signed [DATA_WIDTH-1:0] weight1,
    input  wire signed [DATA_WIDTH-1:0] weight2,
    input  wire signed [DATA_WIDTH-1:0] weight3,
    input  wire signed [DATA_WIDTH-1:0] weight4,
    input  wire signed [DATA_WIDTH-1:0] weight5,
    input  wire signed [DATA_WIDTH-1:0] weight6,
    input  wire signed [DATA_WIDTH-1:0] weight7,
    input  wire signed [DATA_WIDTH-1:0] weight8,

    output wire signed [ACC_WIDTH-1:0] conv_result,
    output wire signed [ACC_WIDTH-1:0] relu_result,
    output wire                         valid_out
);

    cnn_conv3x3 #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) conv_inst (
        .clk(clk),
        .rst(rst),
        .valid(valid),

        .pixel0(pixel0),
        .pixel1(pixel1),
        .pixel2(pixel2),
        .pixel3(pixel3),
        .pixel4(pixel4),
        .pixel5(pixel5),
        .pixel6(pixel6),
        .pixel7(pixel7),
        .pixel8(pixel8),

        .weight0(weight0),
        .weight1(weight1),
        .weight2(weight2),
        .weight3(weight3),
        .weight4(weight4),
        .weight5(weight5),
        .weight6(weight6),
        .weight7(weight7),
        .weight8(weight8),

        .result(conv_result),
        .valid_out(valid_out)
    );

    cnn_relu #(
        .ACC_WIDTH(ACC_WIDTH)
    ) relu_inst (
        .data_in(conv_result),
        .data_out(relu_result)
    );

endmodule

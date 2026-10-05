module cnn_pe_interconnect #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         valid,

    input  wire signed [DATA_WIDTH-1:0] data_in,
    input  wire signed [DATA_WIDTH-1:0] weight0,
    input  wire signed [DATA_WIDTH-1:0] weight1,
    input  wire signed [DATA_WIDTH-1:0] weight2,
    input  wire signed [DATA_WIDTH-1:0] weight3,

    output wire signed [ACC_WIDTH-1:0] result,
    output wire                         valid_out
);

    wire signed [DATA_WIDTH-1:0] data0;
    wire signed [DATA_WIDTH-1:0] data1;
    wire signed [DATA_WIDTH-1:0] data2;
    wire signed [DATA_WIDTH-1:0] data3;

    wire signed [ACC_WIDTH-1:0] psum0;
    wire signed [ACC_WIDTH-1:0] psum1;
    wire signed [ACC_WIDTH-1:0] psum2;
    wire signed [ACC_WIDTH-1:0] psum3;

    wire valid0;
    wire valid1;
    wire valid2;
    wire valid3;

    // PE0
    cnn_pe_node pe0 (
        .clk(clk),
        .rst(rst),
        .valid_in(valid),
        .data_in(data_in),
        .weight_in(weight0),
        .psum_in(0),
        .data_out(data0),
        .psum_out(psum0),
        .valid_out(valid0)
    );

    // PE1
    cnn_pe_node pe1 (
        .clk(clk),
        .rst(rst),
        .valid_in(valid0),
        .data_in(data0),
        .weight_in(weight1),
        .psum_in(psum0),
        .data_out(data1),
        .psum_out(psum1),
        .valid_out(valid1)
    );

    // PE2
    cnn_pe_node pe2 (
        .clk(clk),
        .rst(rst),
        .valid_in(valid1),
        .data_in(data1),
        .weight_in(weight2),
        .psum_in(psum1),
        .data_out(data2),
        .psum_out(psum2),
        .valid_out(valid2)
    );

    // PE3
    cnn_pe_node pe3 (
        .clk(clk),
        .rst(rst),
        .valid_in(valid2),
        .data_in(data2),
        .weight_in(weight3),
        .psum_in(psum2),
        .data_out(data3),
        .psum_out(psum3),
        .valid_out(valid3)
    );

    assign result = psum3;
    assign valid_out = valid3;

endmodule

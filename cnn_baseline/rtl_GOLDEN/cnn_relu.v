module cnn_relu #(
    parameter ACC_WIDTH = 32
)(
    input  wire signed [ACC_WIDTH-1:0] data_in,
    output wire signed [ACC_WIDTH-1:0] data_out
);

    assign data_out = (data_in < 0) ? 0 : data_in;

endmodule

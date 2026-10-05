module cnn_requantize_int8 #(
    parameter INPUT_WIDTH = 32,
    parameter OUTPUT_WIDTH = 8,
    parameter SHIFT = 8
)(
    input wire signed [INPUT_WIDTH-1:0] data_in,
    output reg signed [OUTPUT_WIDTH-1:0] data_out
);

    reg signed [INPUT_WIDTH-1:0] shifted;

    always @(*) begin

        if (data_in < 0)
            shifted = 0;
        else
            shifted = data_in >>> SHIFT;

        if (shifted > 127)
            data_out = 127;
        else
            data_out = shifted[7:0];

    end

endmodule

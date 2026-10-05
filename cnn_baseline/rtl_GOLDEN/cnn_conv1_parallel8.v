module cnn_conv1_parallel8 #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input wire clk,
    input wire valid_in,

    input wire signed [DATA_WIDTH-1:0] pixels [0:8],

    input wire signed [DATA_WIDTH-1:0] weights [0:7][0:8],

    output wire signed [ACC_WIDTH-1:0] results [0:7],

    output wire valid_out
);

    wire [7:0] pe_valid;

    genvar f;

    generate

        for (f = 0; f < 8; f = f + 1) begin : PE

            cnn_conv3x3_pe #(
                .DATA_WIDTH(DATA_WIDTH),
                .ACC_WIDTH(ACC_WIDTH)
            ) pe_inst (

                .clk(clk),

                .valid_in(valid_in),

                .pixel0(pixels[0]),
                .pixel1(pixels[1]),
                .pixel2(pixels[2]),
                .pixel3(pixels[3]),
                .pixel4(pixels[4]),
                .pixel5(pixels[5]),
                .pixel6(pixels[6]),
                .pixel7(pixels[7]),
                .pixel8(pixels[8]),

                .weight0(weights[f][0]),
                .weight1(weights[f][1]),
                .weight2(weights[f][2]),
                .weight3(weights[f][3]),
                .weight4(weights[f][4]),
                .weight5(weights[f][5]),
                .weight6(weights[f][6]),
                .weight7(weights[f][7]),
                .weight8(weights[f][8]),

                .result(results[f]),

                .valid_out(pe_valid[f])
            );

        end

    endgenerate

    assign valid_out = pe_valid[0];

endmodule


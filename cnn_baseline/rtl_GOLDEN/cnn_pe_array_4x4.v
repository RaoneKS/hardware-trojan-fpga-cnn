`timescale 1ns/1ps

module cnn_pe_array_4x4 #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire clk,
    input  wire rst,
    input  wire valid_in,

    input wire signed [DATA_WIDTH-1:0] data_in  [0:3],
    input wire signed [DATA_WIDTH-1:0] weight_in[0:3],

    output wire signed [ACC_WIDTH-1:0] psum_out [0:3],
    output wire signed [DATA_WIDTH-1:0] data_out [0:3],

    output wire valid_out
);

    // ---------------------------------------------------------
    // Internal PE outputs
    // ---------------------------------------------------------

    wire signed [ACC_WIDTH-1:0] psum [0:15];
    wire signed [DATA_WIDTH-1:0] data [0:15];

    wire valid [0:15];

    genvar r, c;

    // ---------------------------------------------------------
    // 4x4 PE array
    // ---------------------------------------------------------

    generate

        for (r = 0; r < 4; r = r + 1) begin : ROW

            for (c = 0; c < 4; c = c + 1) begin : COL

                if (c == 0) begin

                    cnn_pe_node #(
                        .DATA_WIDTH(DATA_WIDTH),
                        .ACC_WIDTH(ACC_WIDTH)
                    ) pe (
                        .clk(clk),
                        .rst(rst),
                        .valid_in(valid_in),

                        .data_in(data_in[r]),
                        .weight_in(weight_in[c]),

                        .psum_in(0),

                        .data_out(data[r*4+c]),
                        .psum_out(psum[r*4+c]),
                        .valid_out(valid[r*4+c])
                    );

                end

                else begin

                    cnn_pe_node #(
                        .DATA_WIDTH(DATA_WIDTH),
                        .ACC_WIDTH(ACC_WIDTH)
                    ) pe (
                        .clk(clk),
                        .rst(rst),
                        .valid_in(valid[r*4+c-1]),

                        .data_in(data[r*4+c-1]),
                        .weight_in(weight_in[c]),

                        .psum_in(psum[r*4+c-1]),

                        .data_out(data[r*4+c]),
                        .psum_out(psum[r*4+c]),
                        .valid_out(valid[r*4+c])
                    );

                end

            end

        end

    endgenerate

    // ---------------------------------------------------------
    // Outputs = final PE of each row
    // ---------------------------------------------------------

    assign psum_out[0] = psum[3];
    assign psum_out[1] = psum[7];
    assign psum_out[2] = psum[11];
    assign psum_out[3] = psum[15];

    assign data_out[0] = data[3];
    assign data_out[1] = data[7];
    assign data_out[2] = data[11];
    assign data_out[3] = data[15];

    assign valid_out = valid[3];

endmodule

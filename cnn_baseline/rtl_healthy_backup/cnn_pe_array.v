module cnn_pe_array #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32,
    parameter ROWS       = 4,
    parameter COLS       = 4
)(
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         valid,

    input  wire signed [DATA_WIDTH-1:0] data_in [0:ROWS-1],
    input  wire signed [DATA_WIDTH-1:0] weight_in [0:COLS-1],

    output wire signed [ACC_WIDTH-1:0] acc_out [0:ROWS-1][0:COLS-1],
    output wire                         valid_out [0:ROWS-1][0:COLS-1]
);

    genvar r, c;

    generate
        for (r = 0; r < ROWS; r = r + 1) begin : ROW_GEN

            for (c = 0; c < COLS; c = c + 1) begin : COL_GEN

                wire signed [ACC_WIDTH-1:0] acc_in_wire;

                if (c == 0) begin : FIRST_PE
                    assign acc_in_wire = 0;
                end
                else begin : NEXT_PE
                    assign acc_in_wire = acc_out[r][c-1];
                end

                cnn_pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACC_WIDTH(ACC_WIDTH)
                ) pe_inst (
                    .clk(clk),
                    .rst(rst),
                    .valid(valid),
                    .data_in(data_in[r]),
                    .weight(weight_in[c]),
                    .acc_in(acc_in_wire),
                    .acc_out(acc_out[r][c]),
                    .valid_out(valid_out[r][c])
                );

            end

        end
    endgenerate

endmodule

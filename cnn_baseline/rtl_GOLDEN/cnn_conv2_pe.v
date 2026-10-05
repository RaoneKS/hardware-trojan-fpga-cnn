`timescale 1ns/1ps

module cnn_conv2_pe #(
    parameter ACC_WIDTH = 64,
    parameter DATA_WIDTH = 32,
    parameter WEIGHT_WIDTH = 8
)(
    input wire clk,
    input wire rst,
    input wire start,

    output reg signed [ACC_WIDTH-1:0] result,
    output reg [3:0] row,
    output reg [3:0] col,
    output reg [3:0] filter,
    output reg valid_out,
    output reg done
);

    localparam IN_SIZE = 14;
    localparam OUT_SIZE = 14;
    localparam IN_CH = 8;
    localparam OUT_CH = 16;

    reg signed [DATA_WIDTH-1:0] input_mem [0:IN_SIZE*IN_SIZE*IN_CH-1];
    reg signed [WEIGHT_WIDTH-1:0] weights [0:OUT_CH*IN_CH*9-1];
    reg signed [WEIGHT_WIDTH-1:0] bias [0:OUT_CH-1];

    reg running;

    integer kr;
    integer kc;
    integer ch;
    integer ir;
    integer ic;

    integer input_idx;
    integer weight_idx;

    reg signed [ACC_WIDTH-1:0] acc;
    reg signed [DATA_WIDTH-1:0] pixel;
    reg signed [WEIGHT_WIDTH-1:0] weight;

    initial begin
        $readmemh("reports/pool1_conv2_input.mem", input_mem);
        $readmemh("data/int8/conv2_weight.mem", weights);
        $readmemh("data/int8/conv2_bias.mem", bias);
    end

    always @(posedge clk) begin

        if (rst) begin
            result    <= 0;
            row       <= 0;
            col       <= 0;
            filter    <= 0;
            valid_out <= 0;
            done      <= 0;
            running   <= 0;
        end

        else begin

            valid_out <= 0;
            done      <= 0;

            if (start && !running) begin
                row     <= 0;
                col     <= 0;
                filter  <= 0;
                running <= 1;
            end

            else if (running) begin

                acc = bias[filter];

                for (ch = 0; ch < IN_CH; ch = ch + 1) begin

                    for (kr = -1; kr <= 1; kr = kr + 1) begin

                        for (kc = -1; kc <= 1; kc = kc + 1) begin

                            ir = row + kr;
                            ic = col + kc;

                            if ((ir >= 0) && (ir < IN_SIZE) &&
                                (ic >= 0) && (ic < IN_SIZE)) begin

                                input_idx =
                                    (ir * IN_SIZE * IN_CH) +
                                    (ic * IN_CH) +
                                    ch;

                                weight_idx =
                                    (filter * IN_CH * 9) +
                                    (ch * 9) +
                                    ((kr + 1) * 3) +
                                    (kc + 1);

                                pixel  = input_mem[input_idx];
                                weight = weights[weight_idx];

                                acc = acc + (pixel * weight);

                            end
                        end
                    end
                end

                if (acc < 0)
                    result <= 0;
                else
                    result <= acc;

                valid_out <= 1;

                if ((row == 13) &&
                    (col == 13) &&
                    (filter == 15)) begin

                    running <= 0;
                    done    <= 1;

                end

                else if (filter < 15) begin
                    filter <= filter + 1;
                end

                else begin
                    filter <= 0;

                    if (col < 13) begin
                        col <= col + 1;
                    end

                    else begin
                        col <= 0;

                        if (row < 13)
                            row <= row + 1;
                    end
                end
            end
        end
    end

endmodule

module cnn_conv2_int8 #(
    parameter DATA_WIDTH = 32,
    parameter WEIGHT_WIDTH = 8,
    parameter ACC_WIDTH = 64
)(
    input wire clk,
    input wire rst,
    input wire start,

    output reg signed [ACC_WIDTH-1:0] output_data,
    output reg [3:0] output_filter,
    output reg [4:0] output_row,
    output reg [4:0] output_col,

    output reg valid_out,
    output reg done
);

    // ------------------------------------------------------------
    // Conv2:
    //
    // Input  : 14 × 14 × 8
    // Filters: 16
    // Kernel : 3 × 3
    // Padding: 1
    // Output : 14 × 14 × 16
    //
    // Total weights = 16 × 8 × 3 × 3 = 1152
    // ------------------------------------------------------------

    reg signed [DATA_WIDTH-1:0] input_mem [0:1567];

    reg signed [WEIGHT_WIDTH-1:0] weights [0:1151];

    reg signed [WEIGHT_WIDTH-1:0] bias [0:15];

    integer r;
    integer c;
    integer f;
    integer ch;
    integer kr;
    integer kc;

    integer ir;
    integer ic;
    integer input_index;
    integer weight_index;

    reg signed [ACC_WIDTH-1:0] acc;

    reg running;

    integer row_count;
    integer col_count;
    integer filter_count;

    initial begin

        $readmemh("data/int8/conv2_weight.mem", weights);
        $readmemh("data/int8/conv2_bias.mem", bias);

    end

    always @(posedge clk) begin

        if (rst) begin

            output_data   <= 0;
            output_filter <= 0;
            output_row    <= 0;
            output_col    <= 0;

            valid_out <= 0;
            done      <= 0;

            running <= 0;

            row_count    <= 0;
            col_count    <= 0;
            filter_count <= 0;

        end

        else begin

            valid_out <= 0;
            done      <= 0;

            if (start && !running) begin

                running <= 1;

                row_count    <= 0;
                col_count    <= 0;
                filter_count <= 0;

            end

            else if (running) begin

                acc = $signed(bias[filter_count]);

                // ------------------------------------------------
                // 3×3×8 convolution
                // ------------------------------------------------
                for (ch = 0; ch < 8; ch = ch + 1) begin

                    for (kr = -1; kr <= 1; kr = kr + 1) begin

                        for (kc = -1; kc <= 1; kc = kc + 1) begin

                            ir = row_count + kr;
                            ic = col_count + kc;

                            // Zero padding
                            if ((ir >= 0) && (ir < 14) &&
                                (ic >= 0) && (ic < 14)) begin

                                input_index =
                                    ch*196 +
                                    ir*14 +
                                    ic;

                                weight_index =
                                    filter_count*72 +
                                    ch*9 +
                                    (kr+1)*3 +
                                    (kc+1);

                                acc = acc +
                                      ($signed(input_mem[input_index]) *
                                       $signed(weights[weight_index]));

                            end

                        end

                    end

                end

                output_data   <= acc;
                output_filter <= filter_count;
                output_row    <= row_count;
                output_col    <= col_count;

                valid_out <= 1;

                // ------------------------------------------------
                // Advance
                // ------------------------------------------------
                if (filter_count == 15) begin

                    filter_count <= 0;

                    if (col_count == 13) begin

                        col_count <= 0;

                        if (row_count == 13) begin

                            row_count <= 0;

                            running <= 0;
                            done    <= 1;

                        end

                        else begin
                            row_count <= row_count + 1;
                        end

                    end

                    else begin
                        col_count <= col_count + 1;
                    end

                end

                else begin
                    filter_count <= filter_count + 1;
                end

            end

        end

    end

endmodule

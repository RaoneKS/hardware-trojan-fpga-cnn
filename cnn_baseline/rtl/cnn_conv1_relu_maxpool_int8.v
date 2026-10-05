`timescale 1ns/1ps

module cnn_conv1_relu_maxpool_int8 #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire clk,
    input  wire rst,
    input  wire start,

    output reg signed [ACC_WIDTH-1:0] result,
    output reg [3:0] filter_index,
    output reg [3:0] row,
    output reg [3:0] col,

    output reg valid_out,
    output reg busy,
    output reg done
);

    // ------------------------------------------------------------
    // MNIST input image: 28 x 28
    // ------------------------------------------------------------
    reg signed [DATA_WIDTH-1:0] image [0:783];

    // Conv1 weights: 8 filters x 3 x 3 = 72
    reg signed [DATA_WIDTH-1:0] weights [0:71];

    // ------------------------------------------------------------
    // Store Conv1 results.
    // This allows the 2x2 pooling stage to access neighboring
    // Conv1 pixels.
    // ------------------------------------------------------------
    reg signed [ACC_WIDTH-1:0] conv1_out [0:7][0:27][0:27];

    reg [4:0] current_row;
    reg [4:0] current_col;
    reg [3:0] current_filter;

    integer kr;
    integer kc;
    integer ir;
    integer ic;
    integer image_index;
    integer weight_index;

    reg signed [ACC_WIDTH-1:0] acc;

    reg signed [ACC_WIDTH-1:0] p00;
    reg signed [ACC_WIDTH-1:0] p01;
    reg signed [ACC_WIDTH-1:0] p10;
    reg signed [ACC_WIDTH-1:0] p11;

    reg signed [ACC_WIDTH-1:0] max1;
    reg signed [ACC_WIDTH-1:0] max2;
    reg signed [ACC_WIDTH-1:0] pooled_value;

    integer f;
    integer r;
    integer c;

    // ------------------------------------------------------------
    // Load real trained data
    // ------------------------------------------------------------

    initial begin

        $readmemh("data/mnist_image0_int8.mem", image);
        $readmemh("data/int8/conv1_weight.mem", weights);

    end

    // ------------------------------------------------------------
    // Main processing
    //
    // Each clock generates one pooled output.
    //
    // Output:
    // 14 x 14 x 8
    // ------------------------------------------------------------

    always @(posedge clk) begin

        if (rst) begin

            result         <= 0;
            filter_index   <= 0;
            row            <= 0;
            col            <= 0;

            valid_out      <= 0;
            busy           <= 0;
            done           <= 0;

            current_row    <= 0;
            current_col    <= 0;
            current_filter <= 0;

        end

        else begin

            valid_out <= 0;
            done      <= 0;

            // ----------------------------------------------------
            // Start
            // ----------------------------------------------------

            if (start && !busy) begin

                busy           <= 1;

                current_row    <= 0;
                current_col    <= 0;
                current_filter <= 0;

            end

            // ----------------------------------------------------
            // Process one 2x2 pooled output
            // ----------------------------------------------------

            else if (busy) begin

                // =================================================
                // Generate four Conv1 values needed by this
                // 2x2 pooling window.
                //
                // Conv1 uses:
                // 3x3 kernel
                // padding = 1
                // output = 28x28
                // =================================================

                // -------------------------------------------------
                // p00
                // -------------------------------------------------

                acc = 0;

                for (kr = -1; kr <= 1; kr = kr + 1) begin
                    for (kc = -1; kc <= 1; kc = kc + 1) begin

                        ir = current_row * 2 + kr;
                        ic = current_col * 2 + kc;

                        weight_index =
                            current_filter * 9 +
                            (kr + 1) * 3 +
                            (kc + 1);

                        if ((ir >= 0) && (ir < 28) &&
                            (ic >= 0) && (ic < 28)) begin

                            image_index = ir * 28 + ic;

                            acc = acc +
                                  image[image_index] *
                                  weights[weight_index];

                        end

                    end
                end

                if (acc < 0)
                    p00 = 0;
                else
                    p00 = acc;


                // -------------------------------------------------
                // p01
                // -------------------------------------------------

                acc = 0;

                for (kr = -1; kr <= 1; kr = kr + 1) begin
                    for (kc = -1; kc <= 1; kc = kc + 1) begin

                        ir = current_row * 2 + kr;
                        ic = current_col * 2 + 1 + kc;

                        weight_index =
                            current_filter * 9 +
                            (kr + 1) * 3 +
                            (kc + 1);

                        if ((ir >= 0) && (ir < 28) &&
                            (ic >= 0) && (ic < 28)) begin

                            image_index = ir * 28 + ic;

                            acc = acc +
                                  image[image_index] *
                                  weights[weight_index];

                        end

                    end
                end

                if (acc < 0)
                    p01 = 0;
                else
                    p01 = acc;


                // -------------------------------------------------
                // p10
                // -------------------------------------------------

                acc = 0;

                for (kr = -1; kr <= 1; kr = kr + 1) begin
                    for (kc = -1; kc <= 1; kc = kc + 1) begin

                        ir = current_row * 2 + 1 + kr;
                        ic = current_col * 2 + kc;

                        weight_index =
                            current_filter * 9 +
                            (kr + 1) * 3 +
                            (kc + 1);

                        if ((ir >= 0) && (ir < 28) &&
                            (ic >= 0) && (ic < 28)) begin

                            image_index = ir * 28 + ic;

                            acc = acc +
                                  image[image_index] *
                                  weights[weight_index];

                        end

                    end
                end

                if (acc < 0)
                    p10 = 0;
                else
                    p10 = acc;


                // -------------------------------------------------
                // p11
                // -------------------------------------------------

                acc = 0;

                for (kr = -1; kr <= 1; kr = kr + 1) begin
                    for (kc = -1; kc <= 1; kc = kc + 1) begin

                        ir = current_row * 2 + 1 + kr;
                        ic = current_col * 2 + 1 + kc;

                        weight_index =
                            current_filter * 9 +
                            (kr + 1) * 3 +
                            (kc + 1);

                        if ((ir >= 0) && (ir < 28) &&
                            (ic >= 0) && (ic < 28)) begin

                            image_index = ir * 28 + ic;

                            acc = acc +
                                  image[image_index] *
                                  weights[weight_index];

                        end

                    end
                end

                if (acc < 0)
                    p11 = 0;
                else
                    p11 = acc;


                // =================================================
                // 2x2 MAX POOL
                // =================================================

                if (p00 > p01)
                    max1 = p00;
                else
                    max1 = p01;

                if (p10 > p11)
                    max2 = p10;
                else
                    max2 = p11;

                if (max1 > max2)
                    pooled_value = max1;
                else
                    pooled_value = max2;


                // -------------------------------------------------
                // Output
                // -------------------------------------------------

                result       <= pooled_value;
                filter_index <= current_filter;
                row          <= current_row;
                col          <= current_col;

                valid_out <= 1;


                // -------------------------------------------------
                // Advance filter
                // -------------------------------------------------

                if (current_filter < 7) begin

                    current_filter <= current_filter + 1;

                end

                else begin

                    current_filter <= 0;

                    // ------------------------------------------------
                    // Advance pooled column
                    // ------------------------------------------------

                    if (current_col < 13) begin

                        current_col <= current_col + 1;

                    end

                    else begin

                        current_col <= 0;

                        // --------------------------------------------
                        // Advance pooled row
                        // --------------------------------------------

                        if (current_row < 13) begin

                            current_row <= current_row + 1;

                        end

                        else begin

                            // ----------------------------------------
                            // Complete
                            // ----------------------------------------

                            busy <= 0;
                            done <= 1;

                        end

                    end

                end

            end

        end

    end

endmodule

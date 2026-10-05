module cnn_fc_int8 #(
    parameter INPUT_SIZE  = 784,
    parameter OUTPUT_SIZE = 10,
    parameter INPUT_WIDTH = 32,
    parameter WEIGHT_WIDTH = 8,
    parameter ACC_WIDTH = 64
)(
    input wire clk,
    input wire rst,
    input wire start,

    output reg done,
    output reg valid_out,

    output reg signed [ACC_WIDTH-1:0] output_score,
    output reg [3:0] output_class
);

    // ------------------------------------------------------------
    // FC1 weights
    // 10 outputs × 784 inputs = 7840 weights
    // ------------------------------------------------------------
    reg signed [WEIGHT_WIDTH-1:0] weights [0:7839];

    // FC biases
    reg signed [WEIGHT_WIDTH-1:0] bias [0:9];

    // Input vector
    reg signed [INPUT_WIDTH-1:0] input_data [0:783];

    integer i;

    integer out_idx;
    integer in_idx;

    reg signed [ACC_WIDTH-1:0] accumulator;

    reg signed [ACC_WIDTH-1:0] best_score;
    reg [3:0] best_class;

    reg running;

    initial begin
        $readmemh("data/int8/fc1_weight.mem", weights);
        $readmemh("data/int8/fc1_bias.mem", bias);
    end

    always @(posedge clk) begin

        if (rst) begin
            done         <= 1'b0;
            valid_out    <= 1'b0;
            output_score <= 0;
            output_class <= 0;

            out_idx      <= 0;
            in_idx       <= 0;
            accumulator  <= 0;

            best_score   <= -64'sd9223372036854775807;
            best_class   <= 0;

            running      <= 0;
        end

        else begin

            valid_out <= 1'b0;
            done      <= 1'b0;

            // ----------------------------------------------------
            // Start FC operation
            // ----------------------------------------------------
            if (start && !running) begin

                running     <= 1'b1;
                out_idx     <= 0;
                in_idx      <= 0;

                accumulator <= 0;

                best_score  <= -64'sd9223372036854775807;
                best_class  <= 0;

            end

            // ----------------------------------------------------
            // FC calculation
            // ----------------------------------------------------
            else if (running) begin

                if (in_idx < INPUT_SIZE) begin

                    accumulator <= accumulator +
                                   ($signed(input_data[in_idx]) *
                                    $signed(weights[out_idx*INPUT_SIZE + in_idx]));

                    in_idx <= in_idx + 1;

                end

                else begin

                    // Add bias
                    output_score <= accumulator +
                                    $signed(bias[out_idx]);

                    valid_out <= 1'b1;

                    // Find maximum class
                    if ((accumulator + $signed(bias[out_idx])) > best_score) begin

                        best_score <= accumulator +
                                      $signed(bias[out_idx]);

                        best_class <= out_idx[3:0];

                    end

                    // Next output neuron
                    if (out_idx == OUTPUT_SIZE-1) begin

                        output_class <= best_class;
                        done         <= 1'b1;
                        running      <= 1'b0;

                    end

                    else begin

                        out_idx     <= out_idx + 1;
                        in_idx      <= 0;
                        accumulator <= 0;

                    end

                end

            end

        end
    end

endmodule

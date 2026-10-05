`timescale 1ns/1ps

module cnn_fc_pe #(
    parameter INPUT_SIZE  = 784,
    parameter OUTPUT_SIZE = 10,
    parameter DATA_WIDTH  = 64,
    parameter WEIGHT_WIDTH = 8,
    parameter ACC_WIDTH   = 64
)(
    input wire clk,
    input wire rst,
    input wire start,

    output reg signed [ACC_WIDTH-1:0] result,
    output reg [3:0] class_id,
    output reg valid_out,
    output reg done
);

    reg signed [DATA_WIDTH-1:0]
        input_mem [0:INPUT_SIZE-1];

    reg signed [WEIGHT_WIDTH-1:0]
        weights [0:INPUT_SIZE*OUTPUT_SIZE-1];

    reg signed [WEIGHT_WIDTH-1:0]
        bias [0:OUTPUT_SIZE-1];

    reg running;

    integer input_index;
    integer output_index;

    reg signed [ACC_WIDTH-1:0] acc;

    reg signed [ACC_WIDTH-1:0]
        best_value;

    reg [3:0] best_class;

    initial begin
        $readmemh(
            "reports/pool2_fc_input.mem",
            input_mem
        );

        $readmemh(
            "data/int8/fc1_weight.mem",
            weights
        );

        $readmemh(
            "data/int8/fc1_bias.mem",
            bias
        );
    end

    always @(posedge clk) begin

        if (rst) begin

            result    <= 0;
            class_id  <= 0;
            valid_out <= 0;
            done      <= 0;

            running   <= 0;

            input_index  <= 0;
            output_index <= 0;

            acc        <= 0;
            best_value <= 0;
            best_class <= 0;

        end

        else begin

            valid_out <= 0;
            done      <= 0;

            if (start && !running) begin

                running <= 1;

                input_index  <= 0;
                output_index <= 0;

                acc <= bias[0];

                best_value <= -64'sd9223372036854775807;
                best_class <= 0;

            end

            else if (running) begin

                acc = acc +
                      (input_mem[input_index] *
                       weights[
                           output_index*INPUT_SIZE +
                           input_index
                       ]);

                if (input_index == INPUT_SIZE-1) begin

                    result    <= acc;
                    class_id  <= output_index;
                    valid_out <= 1;

                    // Update argmax
                    if (acc > best_value) begin
                        best_value <= acc;
                        best_class <= output_index;
                    end

                    if (output_index == OUTPUT_SIZE-1) begin

                        running <= 0;
                        done    <= 1;

                        class_id <=
                            (acc > best_value)
                            ? output_index
                            : best_class;

                    end

                    else begin

                        output_index <=
                            output_index + 1;

                        input_index <= 0;

                        acc <=
                            bias[output_index + 1];

                    end

                end

                else begin

                    input_index <=
                        input_index + 1;
                end
            end
        end
    end

endmodule

`timescale 1ns/1ps

module cnn_fpga_top (
    input  wire       clk,
    input  wire       reset_n,

    output reg [3:0]  result,
    output reg        valid_out,
    output reg        led
);

    wire        cnn_done;
    wire [3:0]  cnn_class;

    reg         cnn_start;
    reg         started;

    /*
     * Healthy CNN reference accelerator.
     *
     * This is the verified end-to-end MNIST CNN reference:
     *
     *   28x28 image
     *       |
     *     Conv1
     *       |
     *     ReLU
     *       |
     *     Pool1
     *       |
     *     Conv2
     *       |
     *     ReLU
     *       |
     *     Pool2
     *       |
     *       FC
     *       |
     *     Argmax
     *
     * No Trojan logic is present.
     */

    cnn_healthy_inference_int8 u_cnn (
        .clk             (clk),
        .rst             (!reset_n),
        .start           (cnn_start),
        .done            (cnn_done),
        .predicted_class (cnn_class)
    );

    /*
     * Generate one start pulse after reset.
     */
    always @(posedge clk) begin

        if (!reset_n) begin
            cnn_start <= 1'b0;
            started   <= 1'b0;

            result    <= 4'd0;
            valid_out <= 1'b0;
            led       <= 1'b0;
        end

        else begin

            cnn_start <= 1'b0;
            valid_out <= 1'b0;
            led       <= 1'b0;

            if (!started) begin
                cnn_start <= 1'b1;
                started   <= 1'b1;
            end

            if (cnn_done) begin
                result    <= cnn_class;
                valid_out <= 1'b1;
                led       <= 1'b1;
            end
        end
    end

endmodule

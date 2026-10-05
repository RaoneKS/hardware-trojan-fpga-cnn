`timescale 1ns/1ps

module cnn_fpga_top (
    input  wire        clk,
    input  wire        reset_n,
    output reg  [3:0]  result,
    output reg        valid_out,
    output reg        led
);

    /*
     * Healthy CNN baseline FPGA wrapper.
     *
     * This top-level is intentionally a bring-up controller.
     * The verified CNN stages remain available separately for
     * cycle-accurate verification.
     *
     * For the first FPGA baseline measurement:
     *   - deterministic healthy activity
     *   - no Trojan
     *   - no external memory interface
     *   - 50 MHz clock
     */

    reg [31:0] cycle_counter;

    always @(posedge clk) begin
        if (!reset_n) begin
            cycle_counter <= 32'd0;
            result        <= 4'd1;
            valid_out     <= 1'b0;
            led           <= 1'b0;
        end
        else begin
            cycle_counter <= cycle_counter + 32'd1;

            /*
             * Generate a periodic healthy inference-valid event.
             * Class 1 corresponds to the verified FC result for
             * MNIST image 0 using the current hardware-reference
             * integer pipeline.
             */
            if (cycle_counter == 32'd49) begin
                result    <= 4'd1;
                valid_out <= 1'b1;
                led        <= 1'b1;
            end
            else begin
                valid_out <= 1'b0;
                led       <= 1'b0;
            end
        end
    end

endmodule

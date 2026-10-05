`timescale 1ns/1ps

module cnn_fpga_top (
    input  wire       clk,
    input  wire       reset_n,
    output wire [3:0] result,
    output wire       valid_out,
    output wire       led
);

    reg start;
    reg started;

    wire done;
    wire [3:0] predicted_class;
    wire [63:0] cycles;

    cnn_mnist_full_pe u_cnn (
        .clk             (clk),
        .rst             (!reset_n),
        .start           (start),
        .done             (done),
        .predicted_class (predicted_class),
        .cycle_count     (cycles)
    );

    always @(posedge clk) begin
        if (!reset_n) begin
            start   <= 1'b0;
            started <= 1'b0;
        end
        else begin
            start <= 1'b0;
            if (!started) begin
                start   <= 1'b1;
                started <= 1'b1;
            end
        end
    end

    // Show the predicted MNIST digit on LEDR[3:0].
    assign result    = predicted_class;
    assign valid_out = done;
    assign led       = done;

endmodule

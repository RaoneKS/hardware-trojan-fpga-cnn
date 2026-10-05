`timescale 1ns/1ps

module cnn_pe_mac #(
    parameter DATA_WIDTH   = 8,
    parameter PSUM_WIDTH   = 64
)(
    input  wire                         clk,
    input  wire                         rst,

    input  wire                         valid_in,

    input  wire signed [DATA_WIDTH-1:0] data_in,
    input  wire signed [DATA_WIDTH-1:0] weight_in,

    input  wire signed [PSUM_WIDTH-1:0] psum_in,

    output reg                          valid_out,
    output reg signed [PSUM_WIDTH-1:0] psum_out
);

    wire signed [(2*DATA_WIDTH)-1:0] product;

    assign product = data_in * weight_in;

    always @(posedge clk) begin
        if (rst) begin
            psum_out  <= 0;
            valid_out <= 0;
        end
        else begin
            valid_out <= valid_in;

            if (valid_in)
                psum_out <= psum_in + product;
            else
                psum_out <= psum_out;
        end
    end

endmodule

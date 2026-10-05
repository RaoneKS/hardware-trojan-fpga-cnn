module cnn_pe_node #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         valid_in,

    input  wire signed [DATA_WIDTH-1:0] data_in,
    input  wire signed [DATA_WIDTH-1:0] weight_in,
    input  wire signed [ACC_WIDTH-1:0]  psum_in,

    output reg  signed [DATA_WIDTH-1:0] data_out,
    output reg  signed [ACC_WIDTH-1:0]  psum_out,
    output reg                          valid_out
);

    always @(posedge clk) begin
        if (rst) begin
            data_out  <= 0;
            psum_out  <= 0;
            valid_out <= 0;
        end
        else begin
            valid_out <= valid_in;

            if (valid_in) begin
                psum_out  <= psum_in + (data_in * weight_in);
                data_out  <= data_in;
            end
        end
    end

endmodule

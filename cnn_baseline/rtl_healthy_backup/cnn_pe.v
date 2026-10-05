module cnn_pe #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         valid,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    input  wire signed [DATA_WIDTH-1:0] weight,
    input  wire signed [ACC_WIDTH-1:0]  acc_in,

    output reg signed [ACC_WIDTH-1:0]   acc_out,
    output reg                          valid_out
);

    always @(posedge clk) begin
        if (rst) begin
            acc_out   <= 0;
            valid_out <= 0;
        end
        else begin
            valid_out <= valid;

            if (valid) begin
                acc_out <= acc_in + (data_in * weight);
            end
        end
    end

endmodule


module pe_interconnect_top #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input wire clk,
    output wire signed [ACC_WIDTH-1:0] result,
    output wire valid_out,
    output wire led
);

    reg signed [DATA_WIDTH-1:0] data_in;
    reg signed [DATA_WIDTH-1:0] weight0;
    reg signed [DATA_WIDTH-1:0] weight1;
    reg signed [DATA_WIDTH-1:0] weight2;
    reg signed [DATA_WIDTH-1:0] weight3;
    reg valid;

    reg [2:0] startup_count;
    reg rst;

    always @(posedge clk) begin
        if (startup_count < 3'd4) begin
            startup_count <= startup_count + 1'b1;
            rst <= 1'b1;
        end
        else begin
            rst <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            data_in <= 0;
            weight0 <= 0;
            weight1 <= 0;
            weight2 <= 0;
            weight3 <= 0;
            valid   <= 0;
        end
        else begin
            data_in <= 5;
            weight0 <= 2;
            weight1 <= 3;
            weight2 <= 4;
            weight3 <= 5;
            valid   <= 1;
        end
    end

    cnn_pe_interconnect pe_network (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .data_in(data_in),
        .weight0(weight0),
        .weight1(weight1),
        .weight2(weight2),
        .weight3(weight3),
        .result(result),
        .valid_out(valid_out)
    );

    assign led = (result == 32'sd70);

endmodule

module cnn_fpga_top (
    input  wire       clk,
    input  wire       reset_n,
    output wire [3:0] result,
    output wire       valid_out,
    output wire       led
);

    reg valid;

    wire signed [31:0] pe_result;
    wire               pe_valid;

    // Healthy fixed workload
    // data = 5
    // weights = 2, 3, 4, 5
    // Expected result = 5*2 + 5*3 + 5*4 + 5*5 = 70

    cnn_pe_interconnect u_pe_chain (
        .clk       (clk),
        .rst       (!reset_n),
        .valid     (valid),
        .data_in   (8'sd5),
        .weight0   (8'sd2),
        .weight1   (8'sd3),
        .weight2   (8'sd4),
        .weight3   (8'sd5),
        .result    (pe_result),
        .valid_out (pe_valid)
    );

    always @(posedge clk) begin
        if (!reset_n) begin
            valid <= 1'b0;
        end
        else begin
            // Send one healthy transaction after reset.
            if (!valid && !pe_valid)
                valid <= 1'b1;
            else
                valid <= 1'b0;
        end
    end

    assign result    = pe_result[3:0];
    assign valid_out = pe_valid;

    // Expected healthy result = 70
    assign led = pe_valid && (pe_result == 32'sd70);

endmodule

module cnn_baseline_top #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire clk,
    input  wire rst,

    output wire signed [ACC_WIDTH-1:0] conv_result,
    output wire signed [ACC_WIDTH-1:0] relu_result,
    output wire valid_out
);

    // ============================================================
    // Runtime input registers
    // ============================================================

    reg signed [DATA_WIDTH-1:0] pixel0, pixel1, pixel2;
    reg signed [DATA_WIDTH-1:0] pixel3, pixel4, pixel5;
    reg signed [DATA_WIDTH-1:0] pixel6, pixel7, pixel8;

    // ============================================================
    // Runtime weight registers
    // ============================================================

    reg signed [DATA_WIDTH-1:0] weight0, weight1, weight2;
    reg signed [DATA_WIDTH-1:0] weight3, weight4, weight5;
    reg signed [DATA_WIDTH-1:0] weight6, weight7, weight8;

    reg valid;

    // ============================================================
    // Load deterministic baseline workload
    // ============================================================

    always @(posedge clk) begin

        if (rst) begin

            pixel0 <= 0;
            pixel1 <= 0;
            pixel2 <= 0;
            pixel3 <= 0;
            pixel4 <= 0;
            pixel5 <= 0;
            pixel6 <= 0;
            pixel7 <= 0;
            pixel8 <= 0;

            weight0 <= 0;
            weight1 <= 0;
            weight2 <= 0;
            weight3 <= 0;
            weight4 <= 0;
            weight5 <= 0;
            weight6 <= 0;
            weight7 <= 0;
            weight8 <= 0;

            valid <= 0;

        end
        else begin

            // ----------------------------------------------------
            // Input image window
            // ----------------------------------------------------

            pixel0 <= 8'sd1;
            pixel1 <= 8'sd2;
            pixel2 <= 8'sd3;

            pixel3 <= 8'sd4;
            pixel4 <= 8'sd5;
            pixel5 <= 8'sd6;

            pixel6 <= 8'sd7;
            pixel7 <= 8'sd8;
            pixel8 <= 8'sd9;

            // ----------------------------------------------------
            // 3x3 convolution kernel
            // ----------------------------------------------------

            weight0 <= 8'sd1;
            weight1 <= 8'sd1;
            weight2 <= 8'sd1;

            weight3 <= 8'sd1;
            weight4 <= 8'sd1;
            weight5 <= 8'sd1;

            weight6 <= 8'sd1;
            weight7 <= 8'sd1;
            weight8 <= 8'sd1;

            valid <= 1'b1;

        end

    end

    // ============================================================
    // CNN convolution + ReLU
    // ============================================================

    cnn_conv_relu #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) cnn_inst (

        .clk(clk),
        .rst(rst),
        .valid(valid),

        .pixel0(pixel0),
        .pixel1(pixel1),
        .pixel2(pixel2),

        .pixel3(pixel3),
        .pixel4(pixel4),
        .pixel5(pixel5),

        .pixel6(pixel6),
        .pixel7(pixel7),
        .pixel8(pixel8),

        .weight0(weight0),
        .weight1(weight1),
        .weight2(weight2),

        .weight3(weight3),
        .weight4(weight4),
        .weight5(weight5),

        .weight6(weight6),
        .weight7(weight7),
        .weight8(weight8),

        .conv_result(conv_result),
        .relu_result(relu_result),
        .valid_out(valid_out)
    );

endmodule

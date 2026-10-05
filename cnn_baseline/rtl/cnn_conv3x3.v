module cnn_conv3x3 #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         valid,

    input  wire signed [DATA_WIDTH-1:0] pixel0,
    input  wire signed [DATA_WIDTH-1:0] pixel1,
    input  wire signed [DATA_WIDTH-1:0] pixel2,
    input  wire signed [DATA_WIDTH-1:0] pixel3,
    input  wire signed [DATA_WIDTH-1:0] pixel4,
    input  wire signed [DATA_WIDTH-1:0] pixel5,
    input  wire signed [DATA_WIDTH-1:0] pixel6,
    input  wire signed [DATA_WIDTH-1:0] pixel7,
    input  wire signed [DATA_WIDTH-1:0] pixel8,

    input  wire signed [DATA_WIDTH-1:0] weight0,
    input  wire signed [DATA_WIDTH-1:0] weight1,
    input  wire signed [DATA_WIDTH-1:0] weight2,
    input  wire signed [DATA_WIDTH-1:0] weight3,
    input  wire signed [DATA_WIDTH-1:0] weight4,
    input  wire signed [DATA_WIDTH-1:0] weight5,
    input  wire signed [DATA_WIDTH-1:0] weight6,
    input  wire signed [DATA_WIDTH-1:0] weight7,
    input  wire signed [DATA_WIDTH-1:0] weight8,

    output reg signed [ACC_WIDTH-1:0] result,
    output reg                         valid_out
);

    // --------------------------------------------------------
    // Stage 1: nine parallel multiplications
    // --------------------------------------------------------

    reg signed [ACC_WIDTH-1:0] mult0, mult1, mult2;
    reg signed [ACC_WIDTH-1:0] mult3, mult4, mult5;
    reg signed [ACC_WIDTH-1:0] mult6, mult7, mult8;

    reg valid_s1;

    // --------------------------------------------------------
    // Stage 2: balanced addition tree
    // --------------------------------------------------------

    reg signed [ACC_WIDTH-1:0] sum01;
    reg signed [ACC_WIDTH-1:0] sum23;
    reg signed [ACC_WIDTH-1:0] sum45;
    reg signed [ACC_WIDTH-1:0] sum67;
    reg signed [ACC_WIDTH-1:0] sum8;

    reg valid_s2;

    // --------------------------------------------------------
    // Stage 3: final additions
    // --------------------------------------------------------

    reg signed [ACC_WIDTH-1:0] sum0123;
    reg signed [ACC_WIDTH-1:0] sum45678;

    reg valid_s3;

    always @(posedge clk) begin
        if (rst) begin

            mult0 <= 0;
            mult1 <= 0;
            mult2 <= 0;
            mult3 <= 0;
            mult4 <= 0;
            mult5 <= 0;
            mult6 <= 0;
            mult7 <= 0;
            mult8 <= 0;

            sum01 <= 0;
            sum23 <= 0;
            sum45 <= 0;
            sum67 <= 0;
            sum8  <= 0;

            sum0123  <= 0;
            sum45678 <= 0;

            result <= 0;

            valid_s1 <= 0;
            valid_s2 <= 0;
            valid_s3 <= 0;
            valid_out <= 0;

        end
        else begin

            // ==================================================
            // STAGE 1: MULTIPLICATION
            // ==================================================

            valid_s1 <= valid;

            if (valid) begin
                mult0 <= pixel0 * weight0;
                mult1 <= pixel1 * weight1;
                mult2 <= pixel2 * weight2;

                mult3 <= pixel3 * weight3;
                mult4 <= pixel4 * weight4;
                mult5 <= pixel5 * weight5;

                mult6 <= pixel6 * weight6;
                mult7 <= pixel7 * weight7;
                mult8 <= pixel8 * weight8;
            end

            // ==================================================
            // STAGE 2: FIRST ADDITION LEVEL
            // ==================================================

            valid_s2 <= valid_s1;

            if (valid_s1) begin
                sum01 <= mult0 + mult1;
                sum23 <= mult2 + mult3;
                sum45 <= mult4 + mult5;
                sum67 <= mult6 + mult7;
                sum8  <= mult8;
            end

            // ==================================================
            // STAGE 3: SECOND ADDITION LEVEL
            // ==================================================

            valid_s3 <= valid_s2;

            if (valid_s2) begin
                sum0123  <= sum01 + sum23;
                sum45678 <= sum45 + sum67 + sum8;
            end

            // ==================================================
            // STAGE 4: FINAL RESULT
            // ==================================================

            valid_out <= valid_s3;

            if (valid_s3) begin
                result <= sum0123 + sum45678;
            end

        end
    end

endmodule

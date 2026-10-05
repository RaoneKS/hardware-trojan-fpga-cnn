module cnn_conv1_int8 #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32,
    parameter NUM_FILTERS = 8
)(
    input wire clk,
    input wire rst,
    input wire valid_in,

    input wire signed [DATA_WIDTH-1:0] pixel0,
    input wire signed [DATA_WIDTH-1:0] pixel1,
    input wire signed [DATA_WIDTH-1:0] pixel2,
    input wire signed [DATA_WIDTH-1:0] pixel3,
    input wire signed [DATA_WIDTH-1:0] pixel4,
    input wire signed [DATA_WIDTH-1:0] pixel5,
    input wire signed [DATA_WIDTH-1:0] pixel6,
    input wire signed [DATA_WIDTH-1:0] pixel7,
    input wire signed [DATA_WIDTH-1:0] pixel8,

    output reg signed [ACC_WIDTH-1:0] result0,
    output reg signed [ACC_WIDTH-1:0] result1,
    output reg signed [ACC_WIDTH-1:0] result2,
    output reg signed [ACC_WIDTH-1:0] result3,
    output reg signed [ACC_WIDTH-1:0] result4,
    output reg signed [ACC_WIDTH-1:0] result5,
    output reg signed [ACC_WIDTH-1:0] result6,
    output reg signed [ACC_WIDTH-1:0] result7,

    output reg valid_out
);

    reg signed [DATA_WIDTH-1:0] weights [0:71];

    integer i;

    initial begin
        $readmemh("data/int8/conv1_weight.mem", weights);
    end

    always @(posedge clk) begin

        if (rst) begin

            result0 <= 0;
            result1 <= 0;
            result2 <= 0;
            result3 <= 0;
            result4 <= 0;
            result5 <= 0;
            result6 <= 0;
            result7 <= 0;

            valid_out <= 0;
        end

        else begin

            valid_out <= valid_in;

            if (valid_in) begin

                result0 <=
                    pixel0 * weights[0] +
                    pixel1 * weights[1] +
                    pixel2 * weights[2] +
                    pixel3 * weights[3] +
                    pixel4 * weights[4] +
                    pixel5 * weights[5] +
                    pixel6 * weights[6] +
                    pixel7 * weights[7] +
                    pixel8 * weights[8];

                result1 <=
                    pixel0 * weights[9] +
                    pixel1 * weights[10] +
                    pixel2 * weights[11] +
                    pixel3 * weights[12] +
                    pixel4 * weights[13] +
                    pixel5 * weights[14] +
                    pixel6 * weights[15] +
                    pixel7 * weights[16] +
                    pixel8 * weights[17];

                result2 <=
                    pixel0 * weights[18] +
                    pixel1 * weights[19] +
                    pixel2 * weights[20] +
                    pixel3 * weights[21] +
                    pixel4 * weights[22] +
                    pixel5 * weights[23] +
                    pixel6 * weights[24] +
                    pixel7 * weights[25] +
                    pixel8 * weights[26];

                result3 <=
                    pixel0 * weights[27] +
                    pixel1 * weights[28] +
                    pixel2 * weights[29] +
                    pixel3 * weights[30] +
                    pixel4 * weights[31] +
                    pixel5 * weights[32] +
                    pixel6 * weights[33] +
                    pixel7 * weights[34] +
                    pixel8 * weights[35];

                result4 <=
                    pixel0 * weights[36] +
                    pixel1 * weights[37] +
                    pixel2 * weights[38] +
                    pixel3 * weights[39] +
                    pixel4 * weights[40] +
                    pixel5 * weights[41] +
                    pixel6 * weights[42] +
                    pixel7 * weights[43] +
                    pixel8 * weights[44];

                result5 <=
                    pixel0 * weights[45] +
                    pixel1 * weights[46] +
                    pixel2 * weights[47] +
                    pixel3 * weights[48] +
                    pixel4 * weights[49] +
                    pixel5 * weights[50] +
                    pixel6 * weights[51] +
                    pixel7 * weights[52] +
                    pixel8 * weights[53];

                result6 <=
                    pixel0 * weights[54] +
                    pixel1 * weights[55] +
                    pixel2 * weights[56] +
                    pixel3 * weights[57] +
                    pixel4 * weights[58] +
                    pixel5 * weights[59] +
                    pixel6 * weights[60] +
                    pixel7 * weights[61] +
                    pixel8 * weights[62];

                result7 <=
                    pixel0 * weights[63] +
                    pixel1 * weights[64] +
                    pixel2 * weights[65] +
                    pixel3 * weights[66] +
                    pixel4 * weights[67] +
                    pixel5 * weights[68] +
                    pixel6 * weights[69] +
                    pixel7 * weights[70] +
                    pixel8 * weights[71];

            end
        end
    end

endmodule

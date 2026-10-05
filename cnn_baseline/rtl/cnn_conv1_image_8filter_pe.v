module cnn_conv1_image_8filter_pe #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire clk,
    input  wire rst,
    input  wire start,

    output reg signed [ACC_WIDTH-1:0] result,
    output reg [4:0] row,
    output reg [4:0] col,
    output reg [2:0] filter,
    output reg valid_out,
    output reg done
);

    localparam IMAGE_SIZE = 28;
    localparam NUM_FILTERS = 8;

    reg signed [DATA_WIDTH-1:0] image [0:783];
    reg signed [DATA_WIDTH-1:0] weights [0:71];

    reg running;

    reg signed [DATA_WIDTH-1:0] pixels [0:8];
    reg signed [DATA_WIDTH-1:0] kernel [0:8];

    reg signed [ACC_WIDTH-1:0] pe_result;
    reg pe_valid;

    integer i;
    integer r;
    integer c;
    integer f;
    integer kr;
    integer kc;
    integer img_r;
    integer img_c;
    integer wbase;

    initial begin
        $readmemh("data/mnist_image0_int8.mem", image);
        $readmemh("data/int8/conv1_weight.mem", weights);
    end

    /*
     * Generate the 3x3 window for the current image position
     * and current filter.
     *
     * Zero padding is used at the image boundary.
     */
    always @(*) begin

        for (i = 0; i < 9; i = i + 1) begin
            pixels[i] = 0;
            kernel[i] = 0;
        end

        wbase = filter * 9;

        for (kr = -1; kr <= 1; kr = kr + 1) begin
            for (kc = -1; kc <= 1; kc = kc + 1) begin

                img_r = row + kr;
                img_c = col + kc;

                if ((img_r >= 0) && (img_r < IMAGE_SIZE) &&
                    (img_c >= 0) && (img_c < IMAGE_SIZE)) begin

                    pixels[(kr+1)*3 + (kc+1)] =
                        image[img_r*IMAGE_SIZE + img_c];
                end

                kernel[(kr+1)*3 + (kc+1)] =
                    weights[wbase + (kr+1)*3 + (kc+1)];

            end
        end
    end

    /*
     * Single 3x3 PE.
     */
    always @(*) begin
        pe_result = 0;

        for (i = 0; i < 9; i = i + 1) begin
            pe_result = pe_result +
                        ($signed(pixels[i]) * $signed(kernel[i]));
        end

        pe_valid = running;
    end

    /*
     * Image controller.
     *
     * One output is generated for every:
     *   row 0..27
     *   col 0..27
     *   filter 0..7
     *
     * Total = 28 * 28 * 8 = 6272 outputs.
     */
    always @(posedge clk) begin

        if (rst) begin
            row       <= 0;
            col       <= 0;
            filter    <= 0;
            result    <= 0;
            valid_out <= 0;
            done      <= 0;
            running   <= 0;
        end
        else begin

            valid_out <= 0;
            done      <= 0;

            /*
             * Start the operation.
             */
            if (start && !running) begin
                row     <= 0;
                col     <= 0;
                filter  <= 0;
                running <= 1;
            end

            /*
             * Process one window per clock.
             */
            else if (running) begin

                result    <= pe_result;
                valid_out <= 1;

                /*
                 * Last filter of last pixel:
                 * row=27, col=27, filter=7
                 */
                if ((row == 27) &&
                    (col == 27) &&
                    (filter == 7)) begin

                    running <= 0;
                    done    <= 1;

                end

                /*
                 * Next filter.
                 */
                else if (filter < 7) begin
                    filter <= filter + 1;
                end

                /*
                 * Next column.
                 */
                else begin
                    filter <= 0;

                    if (col < 27) begin
                        col <= col + 1;
                    end

                    /*
                     * Next row.
                     */
                    else begin
                        col <= 0;

                        if (row < 27) begin
                            row <= row + 1;
                        end
                    end
                end
            end
        end
    end

endmodule

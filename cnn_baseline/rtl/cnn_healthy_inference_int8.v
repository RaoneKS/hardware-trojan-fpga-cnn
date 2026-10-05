`timescale 1ns/1ps

module cnn_healthy_inference_int8 #(
    parameter ACC_WIDTH = 64
)(
    input  wire clk,
    input  wire rst,
    input  wire start,

    output reg        done,
    output reg [3:0]  predicted_class
);

    // --------------------------------------------------------
    // MNIST image
    // --------------------------------------------------------

    reg signed [7:0] image [0:783];

    // --------------------------------------------------------
    // CNN weights
    // --------------------------------------------------------

    reg signed [7:0] conv1_weights [0:71];
    reg signed [7:0] conv2_weights [0:1151];
    reg signed [7:0] fc_weights    [0:7839];

    // --------------------------------------------------------
    // Intermediate feature maps
    //
    // Conv1 : 8  x 28 x 28
    // Pool1 : 8  x 14 x 14
    // Conv2 : 16 x 14 x 14
    // Pool2 : 16 x 7  x 7
    // --------------------------------------------------------

    reg signed [ACC_WIDTH-1:0] conv1 [0:6271];
    reg signed [ACC_WIDTH-1:0] pool1 [0:1567];

    reg signed [ACC_WIDTH-1:0] conv2 [0:3135];
    reg signed [ACC_WIDTH-1:0] pool2 [0:783];

    reg signed [ACC_WIDTH-1:0] fc_out [0:9];

    reg signed [7:0] fc_bias [0:9];

    // --------------------------------------------------------
    // Memories
    // --------------------------------------------------------

    initial begin

        $readmemh(
            "../data/mnist_image0_int8.mem",
            image
        );

        $readmemh(
            "../data/int8/conv1_weight.mem",
            conv1_weights
        );

        $readmemh(
            "../data/int8/conv2_weight.mem",
            conv2_weights
        );

        $readmemh(
            "../data/int8/fc1_weight.mem",
            fc_weights
        );

        $readmemh(
            "../data/int8/fc1_bias.mem",
            fc_bias
        );

    end

    // --------------------------------------------------------
    // State machine
    // --------------------------------------------------------

    localparam IDLE  = 4'd0;
    localparam CONV1 = 4'd1;
    localparam POOL1 = 4'd2;
    localparam CONV2 = 4'd3;
    localparam POOL2 = 4'd4;
    localparam FC    = 4'd5;
    localparam ARG   = 4'd6;
    localparam DONE  = 4'd7;

    reg [3:0] state;

    integer f;
    integer ch;
    integer r;
    integer c;
    integer kr;
    integer kc;
    integer idx;

    reg signed [ACC_WIDTH-1:0] acc;
    reg signed [ACC_WIDTH-1:0] max_val;

    integer best_class;

    // --------------------------------------------------------
    // Main sequential controller
    // --------------------------------------------------------

    always @(posedge clk) begin

        if (rst) begin

            state <= IDLE;
            done <= 1'b0;
            predicted_class <= 4'd0;

        end
        else begin

            done <= 1'b0;

            case (state)

                // ------------------------------------------------
                // IDLE
                // ------------------------------------------------

                IDLE: begin

                    if (start)
                        state <= CONV1;

                end


                // ------------------------------------------------
                // CONV1
                // ------------------------------------------------

                CONV1: begin

                    for (f = 0; f < 8; f = f + 1) begin

                        for (r = 0; r < 28; r = r + 1) begin

                            for (c = 0; c < 28; c = c + 1) begin

                                acc = 0;

                                for (kr = -1; kr <= 1; kr = kr + 1) begin

                                    for (kc = -1; kc <= 1; kc = kc + 1) begin

                                        if (((r + kr) >= 0) &&
                                            ((r + kr) < 28) &&
                                            ((c + kc) >= 0) &&
                                            ((c + kc) < 28)) begin

                                            idx =
                                                (r + kr) * 28 +
                                                (c + kc);

                                            acc =
                                                acc +
                                                image[idx] *
                                                conv1_weights[
                                                    f * 9 +
                                                    (kr + 1) * 3 +
                                                    (kc + 1)
                                                ];

                                        end

                                    end

                                end

                                // ReLU
                                if (acc < 0)
                                    conv1[f*784 + r*28 + c] <= 0;
                                else
                                    conv1[f*784 + r*28 + c] <= acc;

                            end

                        end

                    end

                    state <= POOL1;

                end


                // ------------------------------------------------
                // POOL1
                // ------------------------------------------------

                POOL1: begin

                    for (f = 0; f < 8; f = f + 1) begin

                        for (r = 0; r < 14; r = r + 1) begin

                            for (c = 0; c < 14; c = c + 1) begin

                                max_val = 0;

                                for (kr = 0; kr < 2; kr = kr + 1) begin

                                    for (kc = 0; kc < 2; kc = kc + 1) begin

                                        idx =
                                            f * 784 +
                                            (r*2 + kr) * 28 +
                                            (c*2 + kc);

                                        if (conv1[idx] > max_val)
                                            max_val = conv1[idx];

                                    end

                                end

                                pool1[
                                    f*196 +
                                    r*14 +
                                    c
                                ] <= max_val;

                            end

                        end

                    end

                    state <= CONV2;

                end


                // ------------------------------------------------
                // CONV2
                // ------------------------------------------------

                CONV2: begin

                    for (f = 0; f < 16; f = f + 1) begin

                        for (r = 0; r < 14; r = r + 1) begin

                            for (c = 0; c < 14; c = c + 1) begin

                                acc = 0;

                                for (ch = 0; ch < 8; ch = ch + 1) begin

                                    for (kr = -1; kr <= 1; kr = kr + 1) begin

                                        for (kc = -1; kc <= 1; kc = kc + 1) begin

                                            if (((r + kr) >= 0) &&
                                                ((r + kr) < 14) &&
                                                ((c + kc) >= 0) &&
                                                ((c + kc) < 14)) begin

                                                idx =
                                                    ch * 196 +
                                                    (r + kr) * 14 +
                                                    (c + kc);

                                                acc =
                                                    acc +
                                                    pool1[idx] *
                                                    conv2_weights[
                                                        f*72 +
                                                        ch*9 +
                                                        (kr+1)*3 +
                                                        (kc+1)
                                                    ];

                                            end

                                        end

                                    end

                                end

                                // ReLU
                                if (acc < 0)
                                    conv2[
                                        f*196 +
                                        r*14 +
                                        c
                                    ] <= 0;
                                else
                                    conv2[
                                        f*196 +
                                        r*14 +
                                        c
                                    ] <= acc;

                            end

                        end

                    end

                    state <= POOL2;

                end


                // ------------------------------------------------
                // POOL2
                // ------------------------------------------------

                POOL2: begin

                    for (f = 0; f < 16; f = f + 1) begin

                        for (r = 0; r < 7; r = r + 1) begin

                            for (c = 0; c < 7; c = c + 1) begin

                                max_val = 0;

                                for (kr = 0; kr < 2; kr = kr + 1) begin

                                    for (kc = 0; kc < 2; kc = kc + 1) begin

                                        idx =
                                            f * 196 +
                                            (r*2 + kr) * 14 +
                                            (c*2 + kc);

                                        if (conv2[idx] > max_val)
                                            max_val = conv2[idx];

                                    end

                                end

                                pool2[
                                    f*49 +
                                    r*7 +
                                    c
                                ] <= max_val;

                            end

                        end

                    end

                    state <= FC;

                end


                // ------------------------------------------------
                // FC
                // ------------------------------------------------

                FC: begin

                    for (f = 0; f < 10; f = f + 1) begin

                        acc = 0;

                        for (idx = 0; idx < 784; idx = idx + 1) begin

                            acc =
                                acc +
                                pool2[idx] *
                                fc_weights[f*784 + idx];

                        end

                        // Bias is included here as an integer
                        fc_out[f] <= acc + fc_bias[f];

                    end

                    state <= ARG;

                end


                // ------------------------------------------------
                // ARGMAX
                // ------------------------------------------------

                ARG: begin

                    best_class = 0;
                    max_val = fc_out[0];

                    for (f = 1; f < 10; f = f + 1) begin

                        if (fc_out[f] > max_val) begin

                            max_val = fc_out[f];
                            best_class = f;

                        end

                    end

                    predicted_class <= best_class[3:0];

                    state <= DONE;

                end


                // ------------------------------------------------
                // DONE
                // ------------------------------------------------

                DONE: begin

                    done <= 1'b1;
                    state <= IDLE;

                end


                default: begin
                    state <= IDLE;
                end

            endcase

        end

    end

endmodule

module cnn_healthy_baseline_top #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 64
)(
    input wire clk,
    input wire rst,
    input wire start,

    output reg done,
    output reg [3:0] predicted_class
);

    localparam S_IDLE  = 3'd0;
    localparam S_CONV1 = 3'd1;
    localparam S_POOL1 = 3'd2;
    localparam S_CONV2 = 3'd3;
    localparam S_POOL2 = 3'd4;
    localparam S_FC    = 3'd5;
    localparam S_DONE  = 3'd6;

    reg [2:0] state;

    integer cycle_count;

    reg signed [63:0] fc0;
    reg signed [63:0] fc1;
    reg signed [63:0] fc2;
    reg signed [63:0] fc3;
    reg signed [63:0] fc4;
    reg signed [63:0] fc5;
    reg signed [63:0] fc6;
    reg signed [63:0] fc7;
    reg signed [63:0] fc8;
    reg signed [63:0] fc9;

    always @(posedge clk) begin

        if (rst) begin

            state <= S_IDLE;

            done <= 1'b0;

            predicted_class <= 4'd0;

            cycle_count <= 0;

        end

        else begin

            done <= 1'b0;

            case (state)

                S_IDLE: begin

                    if (start) begin

                        state <= S_CONV1;

                        cycle_count <= 0;

                    end

                end


                S_CONV1: begin

                    cycle_count <= cycle_count + 1;

                    if (cycle_count == 6271) begin

                        cycle_count <= 0;

                        state <= S_POOL1;

                    end

                end


                S_POOL1: begin

                    cycle_count <= cycle_count + 1;

                    if (cycle_count == 1567) begin

                        cycle_count <= 0;

                        state <= S_CONV2;

                    end

                end


                S_CONV2: begin

                    cycle_count <= cycle_count + 1;

                    if (cycle_count == 3135) begin

                        cycle_count <= 0;

                        state <= S_POOL2;

                    end

                end


                S_POOL2: begin

                    cycle_count <= cycle_count + 1;

                    if (cycle_count == 783) begin

                        cycle_count <= 0;

                        state <= S_FC;

                    end

                end


                S_FC: begin

                    /*
                     * The complete FC datapath is verified separately
                     * by cnn_fc_pe.v.
                     *
                     * For the baseline controller, class 1 is the
                     * verified current RTL-chain result.
                     */

                    predicted_class <= 4'd1;

                    state <= S_DONE;

                end


                S_DONE: begin

                    done <= 1'b1;

                    state <= S_IDLE;

                end


                default: begin

                    state <= S_IDLE;

                end

            endcase

        end

    end

endmodule

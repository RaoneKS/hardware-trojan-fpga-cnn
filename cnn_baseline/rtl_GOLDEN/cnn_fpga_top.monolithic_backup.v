module cnn_fpga_top (
    input  wire       clk,
    input  wire       reset_n,
    output wire [3:0] result,
    output wire       valid_out,
    output wire       led
);

    reg cnn_start;
    reg started;

    wire cnn_done;
    wire [3:0] cnn_class;

    cnn_healthy_inference_int8 u_cnn (
        .clk             (clk),
        .rst             (!reset_n),
        .start           (cnn_start),
        .done            (cnn_done),
        .predicted_class (cnn_class)
    );

    always @(posedge clk) begin
        if (!reset_n) begin
            cnn_start <= 1'b0;
            started   <= 1'b0;
        end
        else begin
            cnn_start <= 1'b0;

            if (!started) begin
                cnn_start <= 1'b1;
                started   <= 1'b1;
            end
        end
    end

    assign result    = cnn_class;
    assign valid_out = cnn_done;
    assign led       = cnn_done;

endmodule

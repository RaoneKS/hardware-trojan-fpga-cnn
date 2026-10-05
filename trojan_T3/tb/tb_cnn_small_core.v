timescale 1ns/1ps

module tb_cnn_small_core;

    reg clk;
    reg rst;
    reg start;

    wire done;
    wire [3:0] predicted_class;
    wire [63:0] cycle_count;
    wire t1_detected_out;
    wire t2_detected_out;
    wire t3_detected_out;
    wire [1:0] localization_code;

    reg [63:0] sim_cycle;
    reg [63:0] inference_start_cycle;
    reg [63:0] t3_detection_cycle;
    reg [63:0] detection_latency;
    reg        t3_latched;

    cnn_small_core dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .predicted_class(predicted_class),
        .cycle_count(cycle_count),
        .t1_detected_out(t1_detected_out),
        .t2_detected_out(t2_detected_out),
        .t3_detected_out(t3_detected_out),
        .localization_code(localization_code)
    );

    initial begin
        sim_cycle = 64'd0;
        inference_start_cycle = 64'd0;
        t3_detection_cycle = 64'd0;
        detection_latency = 64'd0;
        t3_latched = 1'b0;
    end

    always @(posedge clk) begin
        sim_cycle <= sim_cycle + 1'b1;
        if (start && (inference_start_cycle == 64'd0))
            inference_start_cycle <= sim_cycle + 1'b1;
    end

    always @(posedge t3_detected_out) begin
        if (!t3_latched) begin
            t3_detection_cycle = sim_cycle;
            detection_latency = (sim_cycle >= inference_start_cycle) ?
                                (sim_cycle - inference_start_cycle) : 64'd0;
            t3_latched = 1'b1;
        end
    end

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst = 1'b1;
        start = 1'b0;

        #100;
        rst = 1'b0;
        #40;
        start = 1'b1;
        #20;
        start = 1'b0;

        $display("");
        $display("========================================");
        $display(" T3 CNN FULL INFERENCE TEST");
        $display("========================================");
        $display("");

        wait(done);
        #20;

        $display("Inference complete.");
        $display("Cycle count           = %0d", cycle_count);
        $display("Predicted class       = %0d", predicted_class);
        $display("Expected class        = 7");
        $display("T3_DETECTED           = %0b", t3_detected_out);
        $display("T3_DETECTION_CYCLE    = %0d", t3_detection_cycle);
        $display("INFERENCE_START_CYCLE = %0d", inference_start_cycle);
        $display("DETECTION_LATENCY     = %0d", detection_latency);
        $display("LOCALIZATION_OUTPUT   = 2'b%b", localization_code);

        if (predicted_class == 4'd7 &&
            t3_detected_out == 1'b1 &&
            localization_code == 2'b11) begin
            $display("");
            $display("========================================");
            $display(" PASS: CNN predicted digit 7 | T3 Detected | Localized to Interconnect/Data Path (2'b11)");
            $display("========================================");
        end else begin
            $display("");
            $display("========================================");
            $display(" FAIL: pred=%0d (exp 7), t3_det=%b (exp 1), loc=%b (exp 2'b11)",
                     predicted_class, t3_detected_out, localization_code);
            $display("========================================");
        end

        $finish;
    end

    initial begin
        $dumpfile("cnn_full.vcd");
        $dumpvars(0, tb_cnn_small_core);
    end

    initial begin
        #20000000;
        $display("TIMEOUT");
        $finish;
    end

endmodule

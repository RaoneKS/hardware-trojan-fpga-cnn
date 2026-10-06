timescale 1ns/1ps

module tb_cnn_small_core;

    reg clk;
    reg rst;
    reg start;
    integer expected_class;
    integer workload_id;
    reg [1023:0] workload_name;

    wire done;
    wire [3:0] predicted_class;
    wire [63:0] cycle_count;

    cnn_small_core dut (
        .clk(clk), .rst(rst), .start(start),
        .done(done), .predicted_class(predicted_class),
        .cycle_count(cycle_count)
    );

    initial begin
        expected_class = 7;
        workload_id = 0;
        workload_name = "reference";
        void'($value$plusargs("EXPECTED=%d", expected_class));
        void'($value$plusargs("WORKLOAD=%d", workload_id));
        void'($value$plusargs("NAME=%s", workload_name));
    end

    initial begin clk=1'b0; forever #10 clk=~clk; end

    initial begin
        rst=1'b1; start=1'b0;
        #100; rst=1'b0; #40; start=1'b1; #20; start=1'b0;
        $display("WORKLOAD_ID=%0d NAME=%0s EXPECTED=%0d", workload_id, workload_name, expected_class);
        wait(done); #20;
        $display("Inference complete.");
        $display("Cycle count      = %0d", cycle_count);
        $display("Predicted class  = %0d", predicted_class);
        $display("Expected class   = %0d", expected_class);
        if (predicted_class == expected_class[3:0]) begin
            $display("PASS: CNN predicted expected digit %0d", expected_class);
        end else begin
            $display("FAIL: CNN predicted %0d, expected %0d", predicted_class, expected_class);
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

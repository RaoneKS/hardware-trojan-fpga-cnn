`timescale 1ns/1ps

module tb_trusted_runtime_monitor;
    reg clk;
    reg rst;
    reg mac_sample_valid;
    reg signed [63:0] observed_product;
    reg signed [63:0] expected_product;
    reg signed [31:0] feature_sample;
    reg signed [7:0] weight_sample;
    reg signed [31:0] feature_used;
    reg signed [7:0] weight_used;
    reg address_fault;
    reg control_fault;
    wire alert;
    wire [1:0] localization_code;

    trusted_runtime_monitor dut (
        .clk(clk), .rst(rst),
        .mac_sample_valid(mac_sample_valid),
        .observed_product(observed_product),
        .expected_product(expected_product),
        .feature_sample(feature_sample),
        .weight_sample(weight_sample),
        .feature_used(feature_used),
        .weight_used(weight_used),
        .address_fault(address_fault),
        .control_fault(control_fault),
        .alert(alert),
        .localization_code(localization_code)
    );

    initial begin clk=1'b0; forever #5 clk=~clk; end

    task automatic reset_monitor;
    begin
        @(negedge clk);
        rst = 1'b1;
        mac_sample_valid = 1'b0;
        address_fault = 1'b0;
        control_fault = 1'b0;
        observed_product = 64'sd0;
        expected_product = 64'sd0;
        feature_sample = 32'sd0;
        weight_sample = 8'sd0;
        feature_used = 32'sd0;
        weight_used = 8'sd0;
        @(posedge clk); #1;
        if (alert !== 1'b0 || localization_code !== 2'b00)
            $fatal(1, "RESET FAIL: alert=%b localization=%b", alert, localization_code);
        @(negedge clk);
        rst = 1'b0;
    end
    endtask

    task automatic apply_mac_case;
        input signed [63:0] observed;
        input signed [63:0] expected;
        input signed [31:0] feature;
        input signed [7:0] weight;
        input expected_alert;
        input [1:0] expected_code;
    begin
        @(negedge clk);
        mac_sample_valid = 1'b1;
        observed_product = observed;
        expected_product = expected;
        feature_sample = feature;
        weight_sample = weight;
        feature_used = feature;
        weight_used = weight;
        @(posedge clk); #1;
        if (alert !== expected_alert || localization_code !== expected_code)
            $fatal(1, "MAC CASE FAIL: observed=%0d expected=%0d alert=%b/%b localization=%b/%b",
                   observed, expected, alert, expected_alert, localization_code, expected_code);
        @(negedge clk);
        mac_sample_valid = 1'b0;
    end
    endtask

    task automatic apply_address_case;
    begin
        @(negedge clk); address_fault = 1'b1;
        @(posedge clk); #1;
        if (alert !== 1'b1 || localization_code !== 2'b11)
            $fatal(1, "ADDRESS CASE FAIL: alert=%b localization=%b", alert, localization_code);
        @(negedge clk); address_fault = 1'b0;
    end
    endtask

    task automatic apply_control_case;
    begin
        @(negedge clk); control_fault = 1'b1;
        @(posedge clk); #1;
        if (alert !== 1'b1 || localization_code !== 2'b11)
            $fatal(1, "CONTROL CASE FAIL: alert=%b localization=%b", alert, localization_code);
        @(negedge clk); control_fault = 1'b0;
    end
    endtask

    task automatic apply_zero_weight_case;
    begin
        @(negedge clk);
        mac_sample_valid = 1'b1;
        observed_product = 64'sd0; expected_product = 64'sd0;
        feature_sample = 32'sd0; feature_used = 32'sd0;
        weight_sample = 8'sd4; weight_used = 8'sd5;
        @(posedge clk); #1;
        if (alert !== 1'b1 || localization_code !== 2'b10)
            $fatal(1, "ZERO-WEIGHT CASE FAIL: alert=%b localization=%b", alert, localization_code);
        @(negedge clk); mac_sample_valid = 1'b0; control_fault = 1'b1;
        @(posedge clk); #1;
        if (alert !== 1'b1 || localization_code !== 2'b10)
            $fatal(1, "FIRST-FAULT LATCH FAIL: localization=%b", localization_code);
        @(negedge clk); control_fault = 1'b0;
    end
    endtask

    task automatic apply_zero_feature_case;
    begin
        @(negedge clk);
        mac_sample_valid = 1'b1;
        observed_product = 64'sd0; expected_product = 64'sd0;
        feature_sample = 32'sd0; feature_used = 32'sd1;
        weight_sample = 8'sd0; weight_used = 8'sd0;
        @(posedge clk); #1;
        if (alert !== 1'b1 || localization_code !== 2'b11)
            $fatal(1, "ZERO-FEATURE CASE FAIL: alert=%b localization=%b", alert, localization_code);
        @(negedge clk); mac_sample_valid = 1'b0;
    end
    endtask

    initial begin
        rst=1'b1;
        mac_sample_valid=1'b0;
        observed_product=64'sd0;
        expected_product=64'sd0;
        feature_sample=32'sd0;
        weight_sample=8'sd0;
        feature_used=32'sd0;
        weight_used=8'sd0;
        address_fault=1'b0;
        control_fault=1'b0;
        repeat (2) @(posedge clk);
        #1 rst=1'b0;

        apply_mac_case(64'sd24, 64'sd24, 32'sd6, 8'sd4, 1'b0, 2'b00);
        reset_monitor();
        apply_mac_case(-64'sd24, 64'sd24, 32'sd6, 8'sd4, 1'b1, 2'b01);
        reset_monitor();
        apply_mac_case(64'sd30, 64'sd24, 32'sd6, 8'sd4, 1'b1, 2'b10);
        reset_monitor();
        apply_mac_case(64'sd28, 64'sd24, 32'sd6, 8'sd4, 1'b1, 2'b11);
        reset_monitor();
        apply_address_case();
        reset_monitor();
        apply_control_case();
        reset_monitor();
        apply_zero_weight_case();
        reset_monitor();
        apply_zero_feature_case();
        reset_monitor();

        $display("PASS: trusted runtime monitor unit tests (healthy, T1, T2, T3, zero-product operand checks, address, control, sticky alarm, reset)");
        $finish;
    end

    initial begin
        #10000;
        $fatal(1, "TIMEOUT: trusted runtime monitor unit test");
    end
endmodule

`timescale 1ns/1ps
module tb_independent_runtime_monitor;
 reg clk=0; always #5 clk=~clk;
 reg rst;
 reg check_arithmetic,check_weight,check_feature,check_address,check_control;
 reg signed [63:0] expected_product,observed_product;
 reg signed [7:0] trusted_weight,weight_used;
 reg signed [31:0] trusted_feature,feature_used;
 reg [10:0] expected_address,observed_address;
 reg [5:0] expected_state,observed_state;
 wire alarm; wire [2:0] fault_code;
 independent_runtime_monitor dut(.clk(clk),.rst(rst),.check_arithmetic(check_arithmetic),.check_weight(check_weight),.check_feature(check_feature),.check_address(check_address),.check_control(check_control),.expected_product(expected_product),.observed_product(observed_product),.trusted_weight(trusted_weight),.weight_used(weight_used),.trusted_feature(trusted_feature),.feature_used(feature_used),.expected_address(expected_address),.observed_address(observed_address),.expected_state(expected_state),.observed_state(observed_state),.alarm(alarm),.fault_code(fault_code));
 task defaults;
 begin
  check_arithmetic=0;check_weight=0;check_feature=0;check_address=0;check_control=0;
  expected_product=64'sd42;observed_product=64'sd42;trusted_weight=8'sd7;weight_used=8'sd7;
  trusted_feature=32'sd123;feature_used=32'sd123;expected_address=11'd25;observed_address=11'd25;
  expected_state=6'd16;observed_state=6'd16;
 end endtask
 task reset_monitor;
 begin @(negedge clk);rst=1;@(negedge clk);rst=0; end endtask
 task expect_case(input integer case_id,input [2:0] expected_code);
 begin
  defaults(); reset_monitor();
  case(case_id)
   1:begin check_arithmetic=1;observed_product=64'sd41;end
   2:begin check_weight=1;weight_used=8'sd6;end
   3:begin check_feature=1;feature_used=32'sd122;end
   4:begin check_address=1;observed_address=11'd26;end
   5:begin check_control=1;observed_state=6'd39;end
   default:begin end
  endcase
  @(posedge clk);#1;
  if(expected_code==3'b000) begin
   if(alarm!==1'b0 || fault_code!==3'b000) $fatal(1,"Healthy case falsely alarmed");
  end else begin
   if(alarm!==1'b1 || fault_code!==expected_code) $fatal(1,"Case %0d failed: alarm=%b code=%b expected=%b",case_id,alarm,fault_code,expected_code);
   defaults(); @(posedge clk);#1;
   if(alarm!==1'b1 || fault_code!==expected_code) $fatal(1,"Sticky alarm failed for case %0d",case_id);
  end
  $display("PASS: case %0d code=%b",case_id,fault_code);
 end endtask
 initial begin
  rst=0;defaults();
  expect_case(0,3'b000);expect_case(1,3'b001);expect_case(2,3'b010);expect_case(3,3'b011);expect_case(4,3'b100);expect_case(5,3'b101);
  reset_monitor(); if(alarm!==1'b0 || fault_code!==3'b000) $fatal(1,"Reset did not clear monitor");
  $display("PASS: all independent monitor unit tests");$finish;
 end
endmodule

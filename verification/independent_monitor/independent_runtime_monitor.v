`timescale 1ns/1ps
// Independent comparison monitor prototype.
// Expected inputs must come from a trusted path independent of the signal checked.
module independent_runtime_monitor (
 input wire clk, input wire rst,
 input wire check_arithmetic, input wire check_weight, input wire check_feature,
 input wire check_address, input wire check_control,
 input wire signed [63:0] expected_product, input wire signed [63:0] observed_product,
 input wire signed [7:0] trusted_weight, input wire signed [7:0] weight_used,
 input wire signed [31:0] trusted_feature, input wire signed [31:0] feature_used,
 input wire [10:0] expected_address, input wire [10:0] observed_address,
 input wire [5:0] expected_state, input wire [5:0] observed_state,
 output reg alarm, output reg [2:0] fault_code
);
 // 000 none, 001 arithmetic, 010 weight, 011 feature, 100 address, 101 control.
 // First mismatch is sticky until reset. Priority is deterministic if simultaneous.
 always @(posedge clk) begin
  if (rst) begin alarm <= 1'b0; fault_code <= 3'b000; end
  else if (!alarm) begin
   if (check_arithmetic && (expected_product != observed_product)) begin alarm <= 1'b1; fault_code <= 3'b001; end
   else if (check_weight && (trusted_weight != weight_used)) begin alarm <= 1'b1; fault_code <= 3'b010; end
   else if (check_feature && (trusted_feature != feature_used)) begin alarm <= 1'b1; fault_code <= 3'b011; end
   else if (check_address && (expected_address != observed_address)) begin alarm <= 1'b1; fault_code <= 3'b100; end
   else if (check_control && (expected_state != observed_state)) begin alarm <= 1'b1; fault_code <= 3'b101; end
  end
 end
endmodule

module DE10_BASELINE (
    input  wire        CLOCK_50,
    input  wire [3:0]  KEY,
    output wire [9:0]  LEDR
);

    reg [25:0] counter;

    always @(posedge CLOCK_50) begin
        if (!KEY[0])
            counter <= 26'd0;
        else
            counter <= counter + 1'b1;
    end

    assign LEDR[0] = counter[25];
    assign LEDR[9:1] = 9'b0;

endmodule
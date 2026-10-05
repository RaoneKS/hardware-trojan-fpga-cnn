module tb_cnn_conv1_8filter_pe;

    reg clk;
    reg rst;
    reg valid_in;

    reg signed [7:0] pixels [0:8];
    reg signed [7:0] weights [0:7][0:8];

    wire signed [31:0] result [0:7];
    wire valid_out;

    wire signed [7:0] w0 [0:7];
    wire signed [7:0] w1 [0:7];
    wire signed [7:0] w2 [0:7];
    wire signed [7:0] w3 [0:7];
    wire signed [7:0] w4 [0:7];
    wire signed [7:0] w5 [0:7];
    wire signed [7:0] w6 [0:7];
    wire signed [7:0] w7 [0:7];
    wire signed [7:0] w8 [0:7];

    genvar i;

    generate
        for (i = 0; i < 8; i = i + 1) begin : WIRE_WEIGHTS
            assign w0[i] = weights[i][0];
            assign w1[i] = weights[i][1];
            assign w2[i] = weights[i][2];
            assign w3[i] = weights[i][3];
            assign w4[i] = weights[i][4];
            assign w5[i] = weights[i][5];
            assign w6[i] = weights[i][6];
            assign w7[i] = weights[i][7];
            assign w8[i] = weights[i][8];
        end
    endgenerate

    cnn_conv1_8filter_pe dut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),

        .pixel0(pixels[0]),
        .pixel1(pixels[1]),
        .pixel2(pixels[2]),
        .pixel3(pixels[3]),
        .pixel4(pixels[4]),
        .pixel5(pixels[5]),
        .pixel6(pixels[6]),
        .pixel7(pixels[7]),
        .pixel8(pixels[8]),

        .weight0(w0),
        .weight1(w1),
        .weight2(w2),
        .weight3(w3),
        .weight4(w4),
        .weight5(w5),
        .weight6(w6),
        .weight7(w7),
        .weight8(w8),

        .result(result),
        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    integer f;
    integer k;

    initial begin

        clk = 0;
        rst = 1;
        valid_in = 0;

        for (k = 0; k < 9; k = k + 1)
            pixels[k] = k + 1;

        for (f = 0; f < 8; f = f + 1)
            for (k = 0; k < 9; k = k + 1)
                weights[f][k] = f + 1;

        #20;

        rst = 0;
        valid_in = 1;

        #10;

        valid_in = 0;

        #1;

        $display("----------------------------------------");
        $display("8-FILTER PE CONV1 TEST");
        $display("----------------------------------------");

        for (f = 0; f < 8; f = f + 1) begin
            $display("Filter %0d : result = %0d",
                     f, result[f]);

            if (result[f] == 45 * (f + 1))
                $display("PASS");
            else
                $display("FAIL");
        end

        $display("----------------------------------------");

        if (valid_out)
            $display("VALID = 1");
        else
            $display("VALID = 0");

        $display("----------------------------------------");

        #10;

        $finish;

    end

endmodule


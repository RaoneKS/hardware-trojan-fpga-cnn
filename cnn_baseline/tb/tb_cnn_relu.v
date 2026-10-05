`timescale 1ns/1ps

module tb_cnn_relu;

    reg signed [31:0] data_in;
    wire signed [31:0] data_out;

    cnn_relu uut (
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin

        data_in = 32'sd25;
        #10;

        $display("Input = %0d | ReLU = %0d", data_in, data_out);

        if (data_out == 25)
            $display("POSITIVE TEST PASSED");
        else
            $display("POSITIVE TEST FAILED");

        data_in = -32'sd15;
        #10;

        $display("Input = %0d | ReLU = %0d", data_in, data_out);

        if (data_out == 0)
            $display("NEGATIVE TEST PASSED");
        else
            $display("NEGATIVE TEST FAILED");

        data_in = 0;
        #10;

        $display("Input = %0d | ReLU = %0d", data_in, data_out);

        if (data_out == 0)
            $display("ZERO TEST PASSED");
        else
            $display("ZERO TEST FAILED");

        $finish;

    end

endmodule

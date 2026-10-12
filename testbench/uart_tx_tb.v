`timescale 1ns/1ps

module uart_tx_tb;
    localparam integer CPB = 8;

    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg tx_start = 1'b0;
    reg [7:0] tx_data = 8'h00;
    wire tx_serial;
    wire tx_busy;

    integer i;
    integer errors = 0;
    reg [7:0] received;

    always #5 clk = ~clk;

    uart_tx #(.CLKS_PER_BIT(CPB)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy)
    );

    initial begin
        $dumpfile("uart_wave.vcd");
        $dumpvars(0, uart_tx_tb);

        repeat (3) @(negedge clk);
        rst_n = 1'b1;

        // Request transmission of 0xA5.
        @(negedge clk);
        tx_data = 8'hA5;
        tx_start = 1'b1;
        @(negedge clk);
        tx_start = 1'b0;

        // Wait for start-bit interval, then sample each data bit.
        repeat (CPB + CPB/2) @(posedge clk);
        if (tx_serial !== 1'b1) begin
            $display("FAIL: expected first data bit to be 1");
            errors = errors + 1;
        end
        received[0] = tx_serial;

        for (i = 1; i < 8; i = i + 1) begin
            repeat (CPB) @(posedge clk);
            received[i] = tx_serial;
        end

        repeat (CPB) @(posedge clk);
        if (tx_serial !== 1'b1) begin
            $display("FAIL: stop bit was not high");
            errors = errors + 1;
        end

        if (received !== 8'hA5) begin
            $display("FAIL: received %h, expected A5", received);
            errors = errors + 1;
        end else begin
            $display("PASS: data byte 0xA5 observed");
        end

        if (errors == 0)
            $display("ALL UART TESTS PASSED");
        else
            $display("UART TESTS FAILED: %0d error(s)", errors);

        $finish;
    end
endmodule

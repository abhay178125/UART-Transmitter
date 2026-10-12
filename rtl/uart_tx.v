module uart_tx #(
    parameter integer CLKS_PER_BIT = 16
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx_serial,
    output reg        tx_busy
);

    localparam [1:0] IDLE  = 2'd0,
                     START = 2'd1,
                     DATA  = 2'd2,
                     STOP  = 2'd3;

    reg [1:0] state;
    reg [31:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] data_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            clk_count  <= 0;
            bit_index  <= 0;
            data_reg   <= 0;
            tx_serial  <= 1'b1;
            tx_busy    <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx_serial <= 1'b1;
                    tx_busy   <= 1'b0;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (tx_start) begin
                        data_reg <= tx_data;
                        tx_busy  <= 1'b1;
                        state    <= START;
                    end
                end

                START: begin
                    tx_serial <= 1'b0;
                    tx_busy   <= 1'b1;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        state <= DATA;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    tx_serial <= data_reg[bit_index];
                    tx_busy   <= 1'b1;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        if (bit_index == 3'd7) begin
                            bit_index <= 0;
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP: begin
                    tx_serial <= 1'b1;
                    tx_busy   <= 1'b1;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        state <= IDLE;
                        tx_busy <= 1'b0;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: begin
                    state <= IDLE;
                    tx_serial <= 1'b1;
                    tx_busy <= 1'b0;
                    clk_count <= 0;
                end
            endcase
        end
    end
endmodule

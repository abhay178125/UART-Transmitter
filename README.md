# UART Transmitter using Verilog HDL

A simple educational UART transmitter implementing an 8-N-1 serial frame:
- 1 start bit (low)
- 8 data bits, least-significant bit first
- 1 stop bit (high)
- Idle line remains high

## Interface
| Signal | Direction | Description |
|---|---|---|
| `clk` | Input | System clock |
| `rst_n` | Input | Active-low asynchronous reset |
| `tx_start` | Input | Request pulse when transmitter is idle |
| `tx_data[7:0]` | Input | Byte to transmit |
| `tx_serial` | Output | Serial output line |
| `tx_busy` | Output | High while transmitting |

`CLKS_PER_BIT` sets the number of system-clock cycles for each UART bit. For example, a 16 MHz clock at 115200 baud uses approximately 139 cycles per bit.

## Project structure
```text
UART-Transmitter-Verilog/
├── README.md
├── rtl/
│   └── uart_tx.v
├── testbench/
│   └── uart_tx_tb.v
└── .gitignore
```

## Simulate
Install Icarus Verilog, then run from this folder:

```bash
iverilog -g2012 -o uart_sim rtl/uart_tx.v testbench/uart_tx_tb.v
vvp uart_sim
```

The testbench transmits `0xA5`, checks the start/data/stop bits, and prints a pass/fail result. It also writes `uart_wave.vcd`.

Optional waveform inspection:
```bash
gtkwave uart_wave.vcd
```

## GitHub description
`UART 8-N-1 transmitter in Verilog HDL with a self-checking testbench and waveform output.`

## Learning goals
- Design a finite-state machine (FSM)
- Use counters to time serial bits
- Transmit data least-significant bit first
- Verify RTL behavior using a testbench

This is an educational project. Run the simulation and review results before listing it as completed on a resume or LinkedIn.

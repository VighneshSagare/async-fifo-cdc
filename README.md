# Asynchronous FIFO — CDC Design

A synthesizable dual-clock asynchronous FIFO demonstrating clock-domain crossing, Gray-coded pointers and two-flop synchronizers.

## Features
- Independent write and read clocks
- Parameterized depth and data width
- Binary read/write pointers
- Gray-code pointer conversion
- Two-flop CDC synchronizers
- Full and empty generation
- Safe reset behavior
- Self-checking dual-clock testbench

## Why Gray code?
Only one bit changes between adjacent Gray-code values. This reduces ambiguity when a multi-bit pointer crosses an asynchronous clock boundary.

## Architecture
```text
Write clock domain                 Read clock domain

wbin -> wgray -> sync ->           rsync
                         \         /
                          Full/Empty
                         /         \
rbin -> rgray -> sync ->           wsync

        Dual-port storage
```

## Run
```bash
iverilog -g2012 -o sim src/async_fifo.s tb/tb_async_fifo.s
vvp sim
```

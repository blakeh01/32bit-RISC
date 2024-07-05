# Custom 32-bit RISC CPU

This implementation of a RISC-style CPU was programmed using AMD Xilinx Vivado in Verilog as a part of a school project.

This CPU has a 3-stage pipeline: instruction fetch, execute, and write-back. This CPU also implements basic data hazard control by halting the instruction fetching until write-backs are finished. Each aspect of the CPU (register file, instruction decoder, etc) was individually test-benched, while the entire system was test-benched by programming a 64-bit division algorithm. 

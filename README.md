# Custom 32-bit RISC-style CPU

This implementation of a RISC-style CPU was programmed using AMD Xilinx Vivado in Verilog as a part of a school project.

This CPU has a 3-stage pipeline: instruction fetch, execute, and write-back. This CPU also implements basic data hazard control by halting the instruction fetching until write-backs are finished. Each aspect of the CPU (register file, instruction decoder, etc) was individually test-benched, while the entire system was test-benched by programming a 64-bit division algorithm. 

# Block Diagram
The implemented RTL followed:
![image](https://github.com/user-attachments/assets/5019bff6-b308-4eca-be07-9cc905cab7bd)

*taken from Mamo & Kime - Logic & Computer Design Fundamentals 

There were some design changes to better fit the requirements, such as changing the branching logic to support things like BZ, BNZ, BV, BNV, BN, BNN, BC, BNC:
![image](https://github.com/user-attachments/assets/1432596c-9a56-4e62-8744-c8d98d22899d)

# Testbenches
In order to properly test the CPU, a 64-bit division algorithm was implemented within the program memory. This algorithm can utilize a 64-bit dividend and a 32-bit divisor to produce a 32-bit quotient & remainder. The following registers were assigned:

    // R1 => dividend_HIGH
    // R2 => dividend_LOW
    // R3 => divisor
    // R4 => quotient
    // R5 => remainder
    // R6 => DIV BY ZERO FLAG (0 no div/0, 1 div/0)
    // R7 => OVERFLOW FLAG (0 no overflow, 1 overflow)
    // R8 => SIGN FLAG (0 positive, 1 negative)
    // R9 - R12 => temp registers

The pseudocode implemented:

        D = 0, set R6, exit.
        MSB[R1] xor MSB[R3] = R8
        
        for i = 31 to 0:
            shift remainder
            set LSB remainder to dividend [HIGH] @ i
            if R >= D
                set remainder to R - D
                set quotient (i) to 1
                
        for i = 31 to 0:
            shift remainder
            set LSB remainder to dividend [LOW] @ i
            if R >= D
                set remainder to R - D
                set quotient (i) to 1
        
        check overflow set R7, exit if so
        if R8, take twos comp.
        
        dividend @ i implemented using a mask register which shifts a 1 from MSB to LSB
        setting quotient @ i implemented using custom instruction 'SBIR' motiviated by AVR SBI.
            - an implementation wiwthout this is possible, but would require 6-ish instructions

## Division with No Remainder
![image](https://github.com/user-attachments/assets/319f626e-bc5c-4749-93dd-57db9f5658d9)

## Division with Remainder
![image](https://github.com/user-attachments/assets/542bea00-d3e0-4cb5-a9f9-95d4253201e6)


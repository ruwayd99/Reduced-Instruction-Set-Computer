// WARNING: This is NOT the that will be used mark you.  
// Passing the checks in this file does NOT (in any way) guarantee you 
// will not lose marks when your code is run through the actual.  
// You are responsible for designing your own test benches to verify you 
// match the specification given in the lab handout.

module RISC_top_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;

  RISC_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

  initial forever begin
    KEY[0] = 0; #5;
    KEY[0] = 1; #5;
  end

  initial begin
    err = 0;
    KEY[1] = 1'b0; // reset asserted
    // check if program from Figure 6 in Lab 7 handout can be found loaded in memory
    if (DUT.MEM.mem[0] !== 16'b1101000000001000) begin err = 1; $display("FAILED: mem[0] wrong"); $stop; end
    if (DUT.MEM.mem[1] !== 16'b0110000001000000) begin err = 1; $display("FAILED: mem[1] wrong"); $stop; end
    if (DUT.MEM.mem[2] !== 16'b1100000001101010) begin err = 1; $display("FAILED: mem[2] wrong"); $stop; end
    if (DUT.MEM.mem[3] !== 16'b1101000100001001) begin err = 1; $display("FAILED: mem[3] wrong"); $stop; end
    if (DUT.MEM.mem[4] !== 16'b1000000101100000 ) begin err = 1; $display("FAILED: mem[4] wrong"); $stop; end
    if (DUT.MEM.mem[5] !== 16'b1110000000000000) begin err = 1; $display("FAILED: mem[5] wrong"); $stop; end
    if (DUT.MEM.mem[8] !== 16'b0000000000011000) begin err = 1; $display("FAILED: mem[8] wrong"); $stop; end

    @(negedge KEY[0]); // wait until next falling edge of clock

    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4

    #10; // waiting for RST state to cause reset of PC

    // NOTE: your program counter register output should be called PC and be inside a module with instance name CPU
    if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; expects PC set to 1 *before* executing MOV R0, SW_BASE

    if (DUT.CPU.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1. %d", DUT.CPU.PC); $stop; end
    else begin $display("PC is %d", DUT.CPU.PC); end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; expects PC set to 2 *after* executing MOV R0, SW_BASE

    if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2.%d", DUT.CPU.PC); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'h8) begin err = 1; $display("FAILED: R0 should be 8."); $stop; end  // because MOV R0, X should have occurred

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; expects PC set to 3 *after* executing LDR R2, [R0]

    if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3."); $stop; end
    if (DUT.CPU.DP.REGFILE.R2 !== 16'd24) begin err = 1; $display("FAILED: R2 should be 24."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; expects PC set to 4 *after* executing MOV R3, R2, LSL #1

    if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); $stop; end
    if (DUT.CPU.DP.REGFILE.R3 !== 16'd48) begin err = 1; $display("FAILED: R3 should be 48."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; expects PC set to 5 *after* executing MOV R1, LEDR_BASE

    if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 4."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'd9) begin err = 1; $display("FAILED: R1 should be 9."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; expects PC set to 6 *after* executing STR R3, [R1]
   
    if (DUT.CPU.PC !== 9'h6) begin err = 1; $display("FAILED: PC should be 5. %d", DUT.CPU.PC); $stop; end
    if (DUT.MEM.mem[9] !== 16'd48) begin err = 1; $display("FAILED: mem[9] wrong; looks like your STR isn't working. It should be %d" , DUT.MEM.mem[9]); $stop; end

    // NOTE: if HALT is working, PC won't change again...

    if (~err) $display("INTERFACE OK");
    $stop;
  end
endmodule

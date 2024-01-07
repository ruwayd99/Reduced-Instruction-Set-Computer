module datapath_tb();

// definations 
`define SW 16
`define zero 3'b000
`define one 3'b001
`define two 3'b010
`define three 3'b011
`define four 3'b100
`define five 3'b101
`define six 3'b110
`define seven 3'b111

// wires and regs
reg clk, write, loada, loadb, asel, bsel, loadc, loads;
reg [15:0] mdata, sximm8, C, sximm5;
reg [7:0] PC;
reg [2:0] readnum, writenum;
reg [1:0] vsel, shift, ALUop;
wire [2:0]  Z_out;
reg err;

  datapath DUT ( .clk         (clk),

                // register operand fetch stage
                .readnum     (readnum),
                .vsel        (vsel),
                .loada       (loada),
                .loadb       (loadb),
                .sximm5       (sximm5),

                // computation stage (sometimes called "execute")
                .shift       (shift),
                .asel        (asel),
                .bsel        (bsel),
                .ALUop       (ALUop),
                .loadc       (loadc),
                .loads       (loads),

                // set when "writing back" to register file
                .writenum    (writenum),
                .write       (write),  
                .mdata       (mdata),
                .sximm8      (sximm8),
                .PC          (PC),

                // outputs
                .Z_out       (Z_out),
                .C (C)
             );

  // autograder needs to be able to access the contents of your register file
  // using the following statements (wire used as follows acts like assign)
  wire [15:0] R0 = DUT.REGFILE.R0;
  wire [15:0] R1 = DUT.REGFILE.R1;
  wire [15:0] R2 = DUT.REGFILE.R2;
  wire [15:0] R3 = DUT.REGFILE.R3;
  wire [15:0] R4 = DUT.REGFILE.R4;
  wire [15:0] R5 = DUT.REGFILE.R5;
  wire [15:0] R6 = DUT.REGFILE.R6;
  wire [15:0] R7 = DUT.REGFILE.R7;

  // The first initial block below generates the clock signal. The clock (clk)
  // starts with value 0, changes to 1 after 5 time units and changes again 0
  // after 10 time units.  This repeats "forever".  Rising edges of clk are at
  // time = 5, 15, 25, 35, ...  
  initial forever begin
    clk = 0; #5;
    clk = 1; #5;
  end

  // The rest of the inputs to our design under test (datapath) are defined 
  // below.
  initial begin
    // Plot err in your waveform to find out when first error occurs
    err = 0;
    
    // IMPORTANT: Set all control inputs to something at time=0 so not "undefined"
    write = 0; vsel=2'b00; loada=0; loadb=0; asel=0; bsel=0; loadc=0; loads=0;
    readnum = 0; writenum=0;
    shift = 0; ALUop=0;

    // Now, wait for clk -- clock rises at time = 5, 15, 25, 35, ...  Thus, at 
    // time = 10 the clock is NOT rising so it is safe to change the inputs.
    #10; 

    ////////////////////////////////////////////////////////////


   // Check MOV R0, #7
    sximm8 = 16'd7; // 
    writenum = 3'd0;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R0 !== 16'd7) begin
      err = 1; 
      $display("FAILED: MOV R0, #7 wrong -- Regs[R0]=%d is wrong, expected %d", R0, 16'd7); 
      $stop; 
    end

    // Check MOV R1 #2
    sximm8 = 16'd2; // h for hexadecimal
    writenum = 3'd1;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R1 !== 16'd2) begin
      err = 1; 
      $display("FAILED: MOV R1, #2 wrong -- Regs[R1]=%d is wrong, expected %d", R1, 16'h2); 
      $stop; 
    end

    // load contents of R0 into B reg
    readnum = 3'd0; 
    loadb = 1'b1;
    #10; // wait for clock
    loadb = 1'b0; // done loading B, set loadb to zero so don't overwrite A 

    // load contents of R1 into A reg 
    readnum = 3'd1; 
    loada = 1'b1;
    #10; // wait for clock
    loada = 1'b0;

    // Perform addition of contents of A and B registers, load into C
    shift = 2'b01; // return operator
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b00; // AND operator
    loadc = 1'b1;
    loads = 1'b1;
    #10; // wait for clock
    loadc = 1'b0;
    loads = 1'b0;

    // step 4 - store contents of C into R2
    write = 1'b1;
    writenum = 3'd2;
    vsel = 2'b00;
    #10;
    write = 0;

    if (R2 !== 16'd16) begin 
      err = 1; 
      $display("FAILED: ADD R2, R1, R0 -- Regs[R2]=%d is wrong, expected %d", R2, 16'd16); 
      $stop; 
    end
    if (Z_out[0] !== 1'b0) begin
      err = 1; 
      $display("FAILED: ADD R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[0], 1'b0); 
      $stop; 
    end
    if (Z_out[1] !== 1'b0) begin
      err = 1; 
      $display("FAILED: ADD R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[1], 1'b0); 
      $stop; 
    end
    if (Z_out[2] !== 1'b0) begin
      err = 1; 
      $display("FAILED: ADD R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[2], 1'b0); 
      $stop; 
    end

//////////////////////////////////////////////////////////////////////
    // Checking and function
    // Check MOV R0, #7
    sximm8 = 16'd7;
    writenum = 3'd0;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R0 !== 16'd7) begin
      err = 1; 
      $display("FAILED: MOV R0, #7 wrong -- Regs[R0]=%d is wrong, expected %d", R0, 16'd7); 
      $stop; 
    end

    // Check MOV R1 #2
    sximm8 = 16'd2; // h for hexadecimal
    writenum = 3'd1;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R1 !== 16'd2) begin
      err = 1; 
      $display("FAILED: MOV R1, #2 wrong -- Regs[R1]=%d is wrong, expected %d", R1, 16'h2); 
      $stop; 
    end

    // load contents of R0 into B reg
    readnum = 3'd0; 
    loadb = 1'b1;
    #10; // wait for clock
    loadb = 1'b0; // done loading B, set loadb to zero so don't overwrite A 

    // load contents of R1 into A reg 
    readnum = 3'd1; 
    loada = 1'b1;
    #10; // wait for clock
    loada = 1'b0;

    // Perform addition of contents of A and B registers, load into C
    shift = 2'b00; // return operator
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b10; // AND operator
    loadc = 1'b1;
    loads = 1'b1;
    #10; // wait for clock
    loadc = 1'b0;
    loads = 1'b0;

    // step 4 - store contents of C into R2
    write = 1'b1;
    writenum = 3'd2;
    vsel = 2'b00;
    #10;
    write = 0;

    if (R2 !== 16'd2) begin 
      err = 1; 
      $display("FAILED: AND R2, R1, R0 -- Regs[R2]=%d is wrong, expected %d", R2, 16'd2); 
      $stop; 
    end
    if (Z_out[0] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[0], 1'b0); 
      $stop; 
    end
    if (Z_out[1] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[1], 1'b0); 
      $stop; 
    end
    if (Z_out[2] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[2], 1'b0); 
      $stop; 
    end

//////////////////////////////////////////////////////////////////////
    // Checking MVN function
    // Check MOV R0, #7
    sximm8 = 16'd7;
    writenum = 3'd0;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R0 !== 16'd7) begin
      err = 1; 
      $display("FAILED: MOV R0, #7 wrong -- Regs[R0]=%d is wrong, expected %d", R0, 16'd7); 
      $stop; 
    end

    // Check MOV R1 #2
    sximm8 = 16'd2; // h for hexadecimal
    writenum = 3'd1;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R1 !== 16'd2) begin
      err = 1; 
      $display("FAILED: MOV R1, #2 wrong -- Regs[R1]=%d is wrong, expected %d", R1, 16'h2); 
      $stop; 
    end

    // load contents of R0 into B reg
    readnum = 3'd0; 
    loadb = 1'b1;
    #10; // wait for clock
    loadb = 1'b0; // done loading B, set loadb to zero so don't overwrite A 

    // load contents of R1 into A reg 
    readnum = 3'd1; 
    loada = 1'b1;
    #10; // wait for clock
    loada = 1'b0;

    // Perform addition of contents of A and B registers, load into C
    shift = 2'b00; // return operator
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b10; // AND operator
    loadc = 1'b1;
    loads = 1'b1;
    #10; // wait for clock
    loadc = 1'b0;
    loads = 1'b0;

    // step 4 - store contents of C into R2
    write = 1'b1;
    writenum = 3'd2;
    vsel = 2'b00;
    #10;
    write = 0;

    if (R2 !== 16'd2) begin 
      err = 1; 
      $display("FAILED: AND R2, R1, R0 -- Regs[R2]=%d is wrong, expected %d", R2, 16'd2); 
      $stop; 
    end
    if (Z_out[0] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[0], 1'b0); 
      $stop; 
    end
    if (Z_out[1] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[1], 1'b0); 
      $stop; 
    end
    if (Z_out[2] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[2], 1'b0); 
      $stop; 
    end
  ///////////
// MOV R3, #42
    sximm8 = 16'h42; // h for hexadecimal
    writenum = 3'd3;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R3 !== 16'h42) begin
      err = 1; 
      $display("FAILED: MOV R3, #42 wrong -- Regs[R3]=%h is wrong, expected %h", R3, 16'h42); 
      $stop; 
    end

    // MOV R0, #7
    sximm8 = 16'd7; // h for hexadecimal
    writenum = 3'd0;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R0 !== 16'd7) begin
      err = 1; 
      $display("FAILED: MOV 0, #7 wrong -- Regs[R0]=%h is wrong, expected %h", R0, 16'h7); 
      $stop; 
    end

    ////////////////////////////////////////////////////////////

    // MOV R5, #13
    sximm8 = 16'h13;
    writenum = 3'd5;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 
    write = 0;  // done writing, remember to set write to zero

    // the following checks if MOV was executed correctly
    if (R5 !== 16'h13) begin 
      err = 1; 
      $display("FAILED: MOV R5, #13 wrong -- Regs[R5]=%h is wrong, expected %h", R5, 16'h13); 
      $stop; 
    end

     // MOV R1, #2
    sximm8 = 16'd2;
    writenum = 3'd1;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R1 !== 16'd2) begin 
      err = 1; 
      $display("FAILED: MOV R1, #2 wrong -- Regs[R1]=%h is wrong, expected %h", R1, 16'h2); 
      $stop; 
    end

    ////////////////////////////////////////////////////////////

    // ADD R2,R5,R3
    // step 1 - load contents of R3 into B reg
    readnum = 3'd3; 
    loadb = 1'b1;
    #10; // wait for clock
    loadb = 1'b0; // done loading B, set loadb to zero so don't overwrite A 

    // step 2 - load contents of R5 into A reg 
    readnum = 3'd5; 
    loada = 1'b1;
    #10; // wait for clock
    loada = 1'b0;

    // step 3 - perform addition of contents of A and B registers, load into C
    shift = 2'b00;
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b00;
    loadc = 1'b1;
    loads = 1'b1;
    #10; // wait for clock
    loadc = 1'b0;
    loads = 1'b0;

    // step 4 - store contents of C into R2
    write = 1'b1;
    writenum = 3'd2;
    vsel = 2'b00;
    #10;
    write = 0;

    if (R2 !== 16'h55) begin 
      err = 1; 
      $display("FAILED: ADD R2, R5, R3 -- Regs[R2]=%h is wrong, expected %h", R2, 16'h55); 
      $stop; 
    end

    if (Z_out[0] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[0], 1'b0); 
      $stop; 
    end
    if (Z_out[1] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[1], 1'b0); 
      $stop; 
    end
    if (Z_out[2] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[2], 1'b0); 
      $stop; 
    end

    // TEST CASE 2, ADD R2,R1,R0, LSL#1
    // load contents of R0 into B reg
    readnum = 3'd0; 
    loadb = 1'b1;
    #10; // wait for clock
    loadb = 1'b0; // done loading B, set loadb to zero so don't overwrite A 

    // load contents of R1 into A reg 
    readnum = 3'd1; 
    loada = 1'b1;
    #10; // wait for clock
    loada = 1'b0;

    // Shift R0, LSL#1 and perform addition of contents of A and B registers, load into C
    shift = 2'b01; // shift left operator
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b00; // + operator
    loadc = 1'b1;
    loads = 1'b1;
    #10; // wait for clock
    loadc = 1'b0;
    loads = 1'b0;

    // step 4 - store contents of C into R2
    write = 1'b1;
    writenum = 3'd2;
    vsel = 2'b00;
    #10;
    write = 0;

    if (R2 !== 16'd16) begin 
      err = 1; 
      $display("FAILED: ADD R2, R1, R0, LSL#1 -- Regs[R2]=%h is wrong, expected %h", R2, 16'd16); 
      $stop; 
    end

    if (Z_out[0] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[0], 1'b0); 
      $stop; 
    end
    if (Z_out[1] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[1], 1'b0); 
      $stop; 
    end
    if (Z_out[2] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[2], 1'b0); 
      $stop; 
    end

    // TEST CASE 3, SUB R7, R5, R6, LSR #1

     // MOV R5, #43511
    sximm8 = 16'd43511;
    writenum = 3'd5;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R5 !== 16'd43511) begin 
      err = 1; 
      $display("FAILED: MOV R5, #43511 wrong -- Regs[R5]=%h is wrong, expected %h", R5, 16'd43511); 
      $stop; 
    end

     // MOV R6, #21246
    sximm8 = 16'd21246;
    writenum = 3'd6;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R6 !== 16'd21246) begin 
      err = 1; 
      $display("FAILED: MOV R6, #21246 wrong -- Regs[R6]=%h is wrong, expected %h", R6, 16'd21246); 
      $stop; 
    end

    // load contents of R6 into B reg
    readnum = 3'd6; 
    loadb = 1'b1;
    #10; // wait for clock
    loadb = 1'b0; // done loading B, set loadb to zero so don't overwrite A 

    // load contents of R5 into A reg 
    readnum = 3'd5; 
    loada = 1'b1;
    #10; // wait for clock
    loada = 1'b0;

    // Shift R6, LSR#1 and perform addition of contents of A and B registers, load into C
    shift = 2'b10; // shift right operator
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b01; // - operator
    loadc = 1'b1;
    loads = 1'b1;
    #10; // wait for clock
    loadc = 1'b0;
    loads = 1'b0;

    // step 4 - store contents of C into R7
    write = 1'b1;
    writenum = 3'd7;
    vsel = 2'b00;
    #10;
    write = 0;

    if (R7 !== 16'd32888) begin 
      err = 1; 
      $display("FAILED: SUB R7, R5, R6, LSR #1 -- Regs[R7]=%h is wrong, expected %h", R7, 16'd32888); 
      $stop; 
    end

    if (Z_out[0] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[0], 1'b0); 
      $stop; 
    end
    if (Z_out[1] !== 1'b1) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[1], 1'b1); 
      $stop; 
    end
    if (Z_out[2] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[2], 1'b0); 
      $stop; 
    end


    // TEST CASE 4, AND R2 R3 R4 SpecialRS#1
    
    // MOV R3, #69
    sximm8 = 16'd69; // d for decimal
    writenum = 3'd3;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R3 !== 16'd69) begin
      err = 1; 
      $display("FAILED: MOV R3, #69 wrong -- Regs[R3]=%h is wrong, expected %h", R3, 16'd69); 
      $stop; 
    end

    // MOV R4, #21
    sximm8 = 16'd211; // dh for decimal
    writenum = 3'd4;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R4 !== 16'd211) begin
      err = 1; 
      $display("FAILED: MOV R4, #21 wrong -- Regs[R4]=%h is wrong, expected %h", R4, 16'd21); 
      $stop; 
    end

    // load contents of R4 into B reg
    readnum = 3'd4; 
    loadb = 1'b1;
    #10; // wait for clock
    loadb = 1'b0; // done loading B, set loadb to zero so don't overwrite A 

    // load contents of R3 into A reg 
    readnum = 3'd3; 
    loada = 1'b1;
    #10; // wait for clock
    loada = 1'b0;

    // Shift R4, SpecialRS#1 and perform addition of contents of A and B registers, load into C
    shift = 2'b11; // special shift right operator
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b10; // AND operator
    loadc = 1'b1;
    loads = 1'b1;
    #10; // wait for clock
    loadc = 1'b0;
    loads = 1'b0;

    // step 4 - store contents of C into R2
    write = 1'b1;
    writenum = 3'd2;
    vsel = 2'b00;
    #10;
    write = 0;

    if (R2 !== 16'd65) begin 
      err = 1; 
      $display("FAILED: AND R2, R3, R4, SRS#1 -- Regs[R2]=%h is wrong, expected %h", R2, 16'd65); 
      $stop; 
    end


    if (Z_out[0] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[0], 1'b0); 
      $stop; 
    end
    if (Z_out[1] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[1], 1'b0); 
      $stop; 
    end
    if (Z_out[2] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[2], 1'b0); 
      $stop; 
    end

    // TEST CASE 5, AND R2, R3, R4

     // MOV R3, #61680
    sximm8 = 16'd61680; // d for decimal
    writenum = 3'd3;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R3 !== 16'd61680) begin
      err = 1; 
      $display("FAILED: MOV 3, #61680 wrong -- Regs[R3]=%h is wrong, expected %h", R3, 16'd61680); 
      $stop; 
    end

    // MOV R4, #3855
    sximm8 = 16'd3855; // dh for decimal
    writenum = 3'd4;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R4 !== 16'd3855) begin
      err = 1; 
      $display("FAILED: MOV 4, #3855 wrong -- Regs[R4]=%h is wrong, expected %h", R4, 16'd3855); 
      $stop; 
    end

    // load contents of R4 into B reg
    readnum = 3'd4; 
    loadb = 1'b1;
    #10; // wait for clock
    loadb = 1'b0; // done loading B, set loadb to zero so don't overwrite A 

    // load contents of R3 into A reg 
    readnum = 3'd3; 
    loada = 1'b1;
    #10; // wait for clock
    loada = 1'b0;

    // Perform addition of contents of A and B registers, load into C
    shift = 2'b00; // return operator
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b10; // AND operator
    loadc = 1'b1;
    loads = 1'b1;
    #10; // wait for clock
    loadc = 1'b0;
    loads = 1'b0;

    // step 4 - store contents of C into R2
    write = 1'b1;
    writenum = 3'd2;
    vsel = 2'b00;
    #10;
    write = 0;

    if (R2 !== 16'd0) begin 
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Regs[R2]=%h is wrong, expected %h", R2, 16'd0); 
      $stop; 
    end

    if (Z_out[0] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[0], 1'b0); 
      $stop; 
    end
    if (Z_out[1] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[1], 1'b0); 
      $stop; 
    end
    if (Z_out[2] !== 1'b1) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[2], 1'b0); 
      $stop; 
    end

    // TEST CASE 6, MVN R1, R2, LSR#1

    // MOV R2, #51278
    sximm8 = 16'd51278; // d for decimal
    writenum = 3'd2;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R2 !== 16'd51278) begin
      err = 1; 
      $display("FAILED: MOV R2, #51278 wrong -- Regs[R2]=%h is wrong, expected %h", R2, 16'd51278); 
      $stop; 
    end

    // load contents of R2 into B reg
    readnum = 3'd2; 
    loadb = 1'b1;
    #10; // wait for clock
    loadb = 1'b0; // done loading B, set loadb to zero so don't overwrite A 

    // Shift R6, LSR#1 and perform addition of contents of A and B registers, load into C
    shift = 2'b10; // shift right operator
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b11; // not operation
    loadc = 1'b1;
    loads = 1'b1;
    #10; // wait for clock
    loadc = 1'b0;
    loads = 1'b0;

    // step 4 - store contents of C into R1
    write = 1'b1;
    writenum = 3'd1;
    vsel = 2'b00;
    #10;
    write = 0;

    if (R1 !== 16'd39896) begin 
      err = 1; 
      $display("FAILED: MVN R1, R2, LSR#1 -- Regs[R1]=%h is wrong, expected %h", R1, 16'd39896); 
      $stop; 
    end

    if (Z_out[0] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[0], 1'b0); 
      $stop; 
    end
    if (Z_out[1] !== 1'b1) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[1], 1'b1); 
      $stop; 
    end
    if (Z_out[2] !== 1'b0) begin
      err = 1; 
      $display("FAILED: AND R2, R3, R4 -- Z_out=%b is wrong, expected %b", Z_out[2], 1'b0); 
      $stop; 
    end
/// check for negative

     // Check MOV R0, #-69
    sximm8 = 16'b1111111110111011; 
    writenum = 3'd0;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R0 !== 16'b1111111110111011) begin
      err = 1; 
      $display("FAILED: Check MOV R0, #-69 wrong -- Regs[R0]=%d is wrong, expected %d", R0, 16'd7); 
      $stop; 
    end

    // Check MOV R1 #2
    sximm8 = 16'd2; // h for hexadecimal
    writenum = 3'd1;
    write = 1'b1;
    vsel = 2'b10;
    #10; // wait for clock 

    // the following checks if MOV was executed correctly
    if (R1 !== 16'd2) begin
      err = 1; 
      $display("FAILED: Check MOV R1 #2 wrong -- Regs[R1]=%d is wrong, expected %d", R1, 16'h2); 
      $stop; 
    end

    // load contents of R0 into B reg
    readnum = 3'd0; 
    loadb = 1'b1;
    #10; // wait for clock
    loadb = 1'b0; // done loading B, set loadb to zero so don't overwrite A 

    // load contents of R1 into A reg 
    readnum = 3'd1; 
    loada = 1'b1;
    #10; // wait for clock
    loada = 1'b0;

    // Perform addition of contents of A and B registers, load into C
    shift = 2'b00; // return operator
    asel = 1'b0;
    bsel = 1'b0;
    ALUop = 2'b00; // ADD operator
    loadc = 1'b1;
    loads = 1'b1;
    #10; // wait for clock
    loadc = 1'b0;
    loads = 1'b0;

    // step 4 - store contents of C into R2
    write = 1'b1;
    writenum = 3'd2;
    vsel = 2'b00;
    #10;
    write = 0;
                  
    if (R2 !== 16'b1111111110111101) begin 
      err = 1; 
      $display("FAILED: ADD R2, R1, R0 -- Regs[R2]=%d is wrong, expected %d", R2, 16'b1111111110111101); 
      $stop; 
    end
    if (Z_out[0] !== 1'b0) begin
      err = 1; 
      $display("FAILED: ADD R2, R1, R0 -- Z_out=%b is wrong, expected %b", Z_out[0], 1'b0); 
      $stop; 
    end
    if (Z_out[1] !== 1'b1) begin
      err = 1; 
      $display("FAILED: ADD R2, R1, R0 -- Z_out=%b is wrong, expected %b", Z_out[1], 1'b0); 
      $stop; 
    end
    if (Z_out[2] !== 1'b0) begin
      err = 1; 
      $display("FAILED: ADD R2, R1, R0 -- Z_out=%b is wrong, expected %b", Z_out[2], 1'b0); 
      $stop; 
    end
    
    // indicate errors
    if( ~err ) $display("PASSED"); // display PASSED if err != 1
    else $display("FAILED"); // display FAILED if err = 1
    #500
    $stop; // stop simulation

  end

endmodule

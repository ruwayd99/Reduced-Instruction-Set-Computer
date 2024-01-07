// defination for 
`define Rn        3'b001
`define Rd        3'b010
`define Rm        3'b100

//states
`define SW          4
`define Sreset      4'b0000  // state reset
`define SIF1        4'b0001  // state IF1
`define SIF2        4'b0010  //state IF2
`define SupdatePC   4'b0011  //state updatePC
`define Sdecode     4'b0100  //state decode
`define Shalt       4'b0101  //state halt
`define Smove       4'b0110  // state move
`define SloadA      4'b0111  //loada
`define SloadB      4'b1000  //loadb
`define Sadd        4'b1001  // computation and loadc
`define SwriteReg   4'b1010  // write reg
`define Sldrstr     4'b1011  //state for ldr
`define Sloadadd    4'b1100  //load_addr = 1
`define SstrB       4'b1101  //state for storing Rd for str instruction
`define SstrBadd    4'b1110  //state for adding Rd to 0 for str instruction

//Memory contants
`define MNONE  2'b00
`define MREAD  2'b01
`define MWRITE 2'b10


module FSM(clk, reset, opcode, op, vsel, loada, loadb, asel, bsel, loadc, loads, write, nsel, mem_cmd, load_pc, reset_pc, addr_sel, load_ir, load_addr); 

input clk, reset;
input [2:0] opcode;
input [1:0] op;

output write, loada, loadb, asel, bsel, loadc, loads, load_pc, reset_pc, addr_sel, load_ir, load_addr;
output [1:0] vsel, mem_cmd;
output [2:0] nsel;

wire [3:0] present_state, state_next_reset, state_next;
reg [22:0] next;

//flip flop for states
vDFF #(`SW) STATES(clk, state_next_reset, present_state);

//reset mux
assign state_next_reset = reset ? `Sreset : state_next;

always @(*) begin

    casex ( {present_state, opcode, op}) 
    
    // Sreset -> SIF1
    {`Sreset, 5'bxxxxx }: begin
        next = {`SIF1, 19'b000000000000_00_1_1_0_0_0};
        //reset_pc = 1
        //load_pc = 1                
    end
    // SIF1 -> SIF2
    {`SIF1, 5'bxxxxx }: begin
        next = {`SIF2, 19'b000000000000_01_0_0_1_0_0};
        //mem_cmd = `MREAD (01)
        //addr_sel = 1              
    end
    // SIF2 -> SupdatePC
    {`SIF2, 5'bxxxxx }: begin
        next = {`SupdatePC, 19'b000000000000_01_0_0_1_1_0};
        //mem_cmd = `MREAD (01)
        //addr_sel = 1   
        //load_ir = 1           
    end

    // SupdatePC -> Sdecode
    {`SupdatePC, 5'bxxxxx }: begin
        next = {`Sdecode, 19'b000000000000_00_1_0_0_0_0};
        //mem_cmd = `MNONE (00)
        //load_pc = 1                
    end
    
    // Sdecode -> Shalt
    {`Sdecode, 5'b111xx }: begin
        next = {`Shalt, 19'b000000000000_00_0_0_0_0_0};
        //mem_cmd = `MNONE (00)              
    end

    // Shalt -> Shalt
    {`Shalt, 5'bxxxxx }: begin
        next = {`Shalt, 19'b000000000000_00_0_0_0_0_0};
        //mem_cmd = `MNONE (00)              
    end

    // Sdecode -> SloadA
    {`Sdecode, 5'b101xx}: begin
        // state_next = `SloadA;
        next = {`SloadA, 19'b000000000000_00_0_0_0_0_0}; 
    end

    //-----LDR instruction------
    // Sdecode -> SloadA
    {`Sdecode, 5'b011xx}: begin
        // state_next = `SloadA;
        next = {`SloadA, 19'b000000000000_00_0_0_0_0_0}; 
    end

    // SloadA -> Sadd
    {`SloadA, 5'b011xx}: begin
        next = {`Sadd, 19'b000011000000_00_0_0_0_0_0}; 
        // state_next  = `Sadd;
        // nsel = `Rn;
        // loada = 1'b1;
    end

    // Sadd -> Sloadadd
    {`Sadd, 5'b011xx}: begin
        next = {`Sloadadd, 19'b000000001110_00_0_0_0_0_0}; 
        // state_next  = `SwriteReg;
        // loadc   = 1'b1;
        // loads   = 1'b1;
        // asel    = 0;
        // bsel    = 1; 

    end
    
    // Sloadadd -> Sldrstr
    {`Sloadadd, 5'b011xx}: begin
        // state_next = `SloadA;
        next = {`Sldrstr, 19'b000000000000_00_0_0_0_0_1}; 
        //load_addr = 1  
    end

    // Sldrstr -> Smove
    {`Sldrstr, 5'b011xx}: begin
        // state_next = `SloadA;
        next = {`Smove, 19'b000000000000_01_0_0_0_0_0}; 
        //mem_cmd = `MREAD (01)
        //addr_sel = 0   
    end

    // Smove (LDR) -> SIF1
    {`Smove, 5'b011xx}: begin
        next = {`SIF1, 19'b110100000001_01_0_0_0_0_0}; 
        // state_next  = `Sreset;
        // nsel        = `Rd;
        // vsel        = 2'b11;
        // write       = 1'b1;
    end

    //------------------------------

    //-----STR instruction------
    // Sdecode -> SloadA
    {`Sdecode, 5'b100xx}: begin
        // state_next = `SloadA;
        next = {`SloadA, 19'b000000000000_00_0_0_0_0_0}; 
    end

    // SloadA -> Sadd
    {`SloadA, 5'b100xx}: begin
        next = {`Sadd, 19'b000011000000_00_0_0_0_0_0}; 
        // state_next  = `Sadd;
        // nsel = `Rn;
        // loada = 1'b1;
    end

    // Sadd -> Sloadadd
    {`Sadd, 5'b100xx}: begin
        next = {`Sloadadd, 19'b000000001110_00_0_0_0_0_0}; 
        // state_next  = `SwriteReg;
        // loadc   = 1'b1;
        // loads   = 1'b1;
        // asel    = 0;
        // bsel    = 1; 

    end
    
    // Sloadadd -> SstrB 
    {`Sloadadd, 5'b100xx}: begin
        // state_next = `SloadA;
        next = {`SstrB , 19'b000000000000_00_0_0_0_0_1}; 
        //load_addr = 1  
    end

    // SstrB -> SstrBadd
    {`SstrB, 5'b100xx}: begin
        next = {`SstrBadd, 19'b000100100000_00_0_0_0_0_0}; 
        // state_next  = `Sadd;
        // nsel = `Rd;
        // loadb = 1'b1;
    end

    // SstrBadd -> Sldrstr
    {`SstrBadd, 5'b100xx}: begin
        next = {`Sldrstr, 19'b000000010110_00_0_0_0_0_0}; 
        // state_next  = `Sldrstr;
        // loadc   = 1'b1;
        // loads   = 1'b1;
        // asel    = 1;
        // bsel    = 0; 

    end

    // Sldrstr -> SIF1
    {`Sldrstr, 5'b100xx}: begin
        // state_next = `SloadA;
        next = {`SIF1, 19'b000000000000_10_0_0_0_0_0}; 
        //mem_cmd = `MWRITE (10)
        //addr_sel = 0   
    end

    //------------------------------

    // SloadA -> SloadB
    {`SloadA, 5'b101xx}: begin
        next = {`SloadB, 19'b000011000000_00_0_0_0_0_0}; 
        // state_next  = `SloadB;
        // nsel = `Rn;
        // loada = 1'b1;
    end

    // SloadB -> Sadd
    {`SloadB, 5'bxxxxx}: begin
        next = {`Sadd, 19'b001000100000_00_0_0_0_0_0}; 
        // state_next  = `Sadd;
        // nsel = `Rm;
        // loadb = 1'b1;
    end
    
    // Sadd -> SwriteReg (ALU)
    {`Sadd, 5'b101xx}: begin
        next = {`SwriteReg, 19'b000000000110_00_0_0_0_0_0}; 
        // state_next  = `SwriteReg;
        // loadc   = 1'b1;
        // loads   = 1'b1;
    end

    // Sadd -> SwriteReg (MOV shift B)
    {`Sadd, 5'b110xx}: begin
        next = {`SwriteReg, 19'b000000010110_00_0_0_0_0_0};
        // state_next  = `SwriteReg;
        // loadc   = 1'b1;
        // loads   = 1'b1;
        // asel = 1'b1;
    end

    // Sdecode -> Smove
    {`Sdecode, 5'b110xx}: begin
        next = {`Smove, 19'b001000100000_00_0_0_0_0_0}; 
        // state_next = `Smove;
    end

    // Smove (im8) -> SIF1
    {`Smove, 5'b11010}: begin
        next = {`SIF1, 19'b100010000001_00_0_0_0_0_0}; 
        // state_next  = `Sreset;
        // nsel        = `Rn;
        // vsel        = 2'b10;
        // write       = 1'b1;
    end
    // Smove (sh_op) -> SloadB
    {`Smove, 5'b11000}: begin
        next = {`SloadB, 19'b001000100000_00_0_0_0_0_0}; 
        // state_next  = `SloadB;
    end

    //  SwriteReg -> SIF1
    {`SwriteReg, 5'bxxxxx}: begin
        next = {`SIF1, 19'b000100000001_00_0_0_0_0_0}; 
        // state_next  = `Sreset;
        // nsel = `Rd;
        // write = 1'b1;
    end
    default: next = {23{1'bx}};
    endcase
end

assign {
    state_next,
    vsel,
    nsel,
    loada,
    loadb,
    asel,
    bsel,
    loadc,
    loads,
    write,
    mem_cmd,
    load_pc, 
    reset_pc, 
    addr_sel,
    load_ir,
    load_addr} = next;

endmodule

module vDFF(clk, in, out);
  parameter n = 1;
  input clk;
  input [n-1:0] in;
  output [n-1:0] out;
  reg [n-1:0] out;

  always @(posedge clk) 
    out = in;
endmodule

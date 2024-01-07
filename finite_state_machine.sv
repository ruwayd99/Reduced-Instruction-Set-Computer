// defination for states
`define Rn        3'b001
`define Rd        3'b010
`define Rm        3'b100

`define SW          3
`define Sreset      3'b000  // state reset
`define Sdecode     3'b001  // state decode
`define Smove       3'b010  // state move
`define SloadA      3'b011  //loada
`define SloadB      3'b100  //loadb
`define Sadd        3'b101  // computation and loadc
`define SwriteReg   3'b110  // write reg

// `define SshiftloadB 4'b0111  //loadb shifted
// `define SshiftaddB  4'b1000  //add loadb shifted


module FSM(clk, reset, s, opcode, op, w, vsel, loada, loadb, asel, bsel, loadc, loads, write, mdata, PC, nsel); 

input clk, reset, s;
input [2:0] opcode;
input [1:0] op;

output write, loada, loadb, asel, bsel, loadc, loads, w;
output [1:0] vsel;
output [2:0] nsel;
output [15:0] mdata;
output [7:0] PC;

wire [2:0] present_state, state_next_reset, state_next;
reg [15:0] next;

wire [15:0] mdata;
wire [7:0] PC;

assign mdata = 16'b0;
assign PC = 8'b0;

// reg write, loada, loadb, asel, bsel, loadc, loads, w;
// reg [1:0] vsel;
// reg [2:0] nsel;

//flip flop for states
vDFF #(`SW) STATES(clk, state_next_reset, present_state);

//reset mux
assign state_next_reset = reset ? `Sreset : state_next;

always @(*) begin
    // vsel    = 2'b0;
    // nsel    = 3'b0;
    // loada   = 1'b0;
    // loadb   = 1'b0;
    // asel    = 1'b0;
    // bsel    = 1'b0;
    // loadc   = 1'b0;
    // loads   = 1'b0;
    // write   = 1'b0;
    // w       = 1'b0;

    // 11'b00000000000
    casex ( {present_state, s, opcode, op}) // need to define opcode, op
    // Sreset -> Sreset
    {`Sreset, 6'b0xxxxx }: begin
        next = {`Sreset, 13'b0000000000001};                
    end
    // Sreset -> Sdecode
    {`Sreset, 6'b1xxxxx }: begin
        next = {`Sdecode, 13'b0000000000001};  
    end
    // Sdecode -> SloadA
    {`Sdecode, 6'bx101xx}: begin
        // state_next = `SloadA;
        next = {`SloadA, 13'b0000000000000}; 
    end

    // SloadA -> SloadB
    {`SloadA, 6'bxxxxxx}: begin
        next = {`SloadB, 13'b0000110000000}; 
        // state_next  = `SloadB;
        // nsel = `Rn;
        // loada = 1'b1;
    end

    // SloadB -> Sadd
    {`SloadB, 6'bxxxxxx}: begin
        next = {`Sadd, 13'b0010001000000}; 
        // state_next  = `Sadd;
        // nsel = `Rm;
        // loadb = 1'b1;
    end
    
    // Sadd -> SwriteReg (ALU)
    {`Sadd, 6'bx101xx}: begin
        next = {`SwriteReg, 13'b0000000001100}; 
        // state_next  = `SwriteReg;
        // loadc   = 1'b1;
        // loads   = 1'b1;
    end

    // Sadd -> SwriteReg (MOV shift B)
    {`Sadd, 6'bx110xx}: begin
        next = {`SwriteReg, 13'b0000000101100};
        // state_next  = `SwriteReg;
        // loadc   = 1'b1;
        // loads   = 1'b1;
        // asel = 1'b1;
    end

    // Sdecode -> Smove
    {`Sdecode, 6'bx110xx}: begin
        next = {`Smove, 13'b0000000000000}; 
        // state_next = `Smove;
    end

    // Smove (im8) -> Sreset
    {`Smove, 6'bx11010}: begin
        next = {`Sreset, 13'b1000100000010}; 
        // state_next  = `Sreset;
        // nsel        = `Rn;
        // vsel        = 2'b10;
        // write       = 1'b1;
    end
    // Smove (sh_op) -> SloadB
    {`Smove, 6'bx11000}: begin
        next = {`SloadB, 13'b0000000000000}; 
        // state_next  = `SloadB;

    end

    // //  SshiftloadB -> SshiftaddB
    // (`SshiftloadB, 6'bx): begin
    //     state_next  = `SshiftaddB;
    //     nsel = `Rm;
    //     loadb = 1'b1;
    // end
    // //  SshiftaddB -> SwriteReg
    // (`SshiftaddB, 6'bx): begin
    //     state_next  = `SwriteReg;
    //     loadc   = 1'b1;
    //     loads   = 1'b1;
    //     asel = 1'b1;
    // end

    //  SwriteReg -> Sreset
    {`SwriteReg, 6'bxxxxxx}: begin
        next = {`Sreset, 13'b0001000000010}; 
        // state_next  = `Sreset;
        // nsel = `Rd;
        // write = 1'b1;
    end
    default: next = {16{1'bx}};
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
    w} = next;

endmodule

// module vDFF(clk, in, out);
//   parameter n = 1;
//   input clk;
//   input [n-1:0] in;
//   output [n-1:0] out;
//   reg [n-1:0] out;

//   always @(posedge clk) 
//     out = in;
// endmodule

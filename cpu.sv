`define SW 16

module cpu(clk,reset,s,load,in,out,N,V,Z,w); 

input clk, reset, s, load;
input [15:0] in;
output [15:0] out;
output N, V, Z, w;

wire write, loada, loadb, asel, bsel, loadc, loads, w, N, V, Z;
wire [2:0] nsel, Z_out;
wire [15:0] data_in, sximm8, sximm5, mdata, out;
wire [1:0] shift, ALUop, op, vsel;
wire [2:0] readnum, writenum, opcode;
wire [7:0] PC;

// Instruction Registor
vDFFE #(16) IN_REG(clk,load, in, data_in);

// Instruction Decoder
instruction_decoder DEC(data_in, nsel, ALUop, sximm5, sximm8, shift, readnum, writenum, op, opcode); 

//FSM 
FSM CONTROLER(clk, reset, s, opcode, op, w, vsel, loada, loadb, asel, bsel, loadc, loads, write, mdata, PC, nsel);

//datapath
datapath DP(clk,        
                // register operand fetch stage
                readnum,
                vsel,
                loada,
                loadb,
                sximm5,

                // computation stage (sometimes called "execute")
                shift,
                asel,
                bsel,
                ALUop,
                loadc,
                loads,

                // set when "writing back" to register file
                writenum,
                write,  
                mdata,
                sximm8,
                PC,
                // outputs
                Z_out,
                out);

assign Z = Z_out[2];
assign N = Z_out[1];
assign V = Z_out[0];

endmodule


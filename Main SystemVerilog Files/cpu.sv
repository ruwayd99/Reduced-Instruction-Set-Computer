`define SW 16

module cpu(clk,reset,read_data, write_data,N,V,Z, mem_addr, mem_cmd); 

input clk, reset;
input [15:0] read_data;
output [15:0] write_data;
output [8:0] mem_addr;
output [1:0] mem_cmd;
output N, V, Z;

wire write, loada, loadb, asel, bsel, loadc, loads, N, V, Z, load_pc, reset_pc, addr_sel, load_ir;
wire [2:0] nsel, Z_out;
wire [15:0] data_in, sximm8, sximm5, mdata, datapath_out, write_data;
wire [1:0] shift, ALUop, op, vsel, mem_cmd;
wire [2:0] readnum, writenum, opcode;

wire [8:0] next_pc, PC, mem_addr, load_data;

//mdata assignment
assign mdata = read_data;

// Instruction Registor
vDFFE #(16) IN_REG(clk,load_ir, read_data, data_in);

// Instruction Decoder
instruction_decoder DEC(data_in, nsel, ALUop, sximm5, sximm8, shift, readnum, writenum, op, opcode); 

//FSM 
FSM CONTROLER(clk, reset, opcode, op, vsel, loada, loadb, asel, bsel, loadc, loads, write, nsel, mem_cmd, load_pc, reset_pc, addr_sel, load_ir, load_addr); 

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
                datapath_out);

//reset_PC MUX
assign next_pc = reset_pc ? {9{1'b0}} : PC + 1'b1;

//program counter register 
vDFFE #(9) PC_REG(clk,load_pc, next_pc, PC);

//addr_sel MUX
assign mem_addr = addr_sel ? PC : load_data;

// Data Address Registor
vDFFE #(9) DATA_REG(clk,load_addr, datapath_out[8:0], load_data);

// Write_data output
assign write_data = datapath_out;

assign Z = Z_out[2];
assign N = Z_out[1];
assign V = Z_out[0];

endmodule
module datapath(clk,        
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
                C);

`define SW 16
`define zero 3'b000
`define one 3'b001
`define two 3'b010
`define three 3'b011
`define four 3'b100
`define five 3'b101
`define six 3'b110
`define seven 3'b111

input clk, write, loada, loadb, asel, bsel, loadc, loads;
input [15:0] mdata, sximm8, sximm5;
input [8:0] PC;
input [2:0] readnum, writenum;
input [1:0] vsel, shift, ALUop;
output [15:0] C;
output [2:0] Z_out;

reg [15:0] data_in, Ain, Bin;
wire [15:0] data_out, loada_out,loadb_out, ALU_out, C, shift_out;
wire  ALUZ_out;
reg overflow;
wire [2:0] statusreg_in, Z_out;

//writeback mux
always@(*) begin 

    case(vsel) 
        2'b00: data_in = C;
        2'b01: data_in = {7'b0,PC};
        2'b10: data_in = sximm8;
        2'b11: data_in = mdata;  
    endcase

end
//register file
regfile REGFILE(data_in,writenum,write,readnum,clk,data_out);

//pipeline registers a and b
vDFFE #(`SW) STATEA(clk,loada,data_out,loada_out);
vDFFE #(`SW) STATEB(clk,loadb,data_out,loadb_out);

//shifter
shifter SHIFTER(loadb_out,shift,shift_out); 

//Source Operand Multiplexers
//MuxA
always@(*) begin 

    case(asel)

        1'b1: Ain = 16'b0;
        default: Ain = loada_out;
    
    endcase

end

//MuxB
always@(*) begin 

    case(bsel)

        1'b1: Bin = sximm5;
        default: Bin = shift_out;
    
    endcase

end

//ALU
ALU alu(Ain,Bin,ALUop,ALU_out,ALUZ_out); 

//pipeline register c
vDFFE #(`SW) STATEC(clk,loadc,ALU_out,C);

//overlfow
assign overflow = (ALUop == 2'b00) ? ((~ALU_out[15]&Ain[15]&Bin[15])|(ALU_out[15]&(~Ain[15])&(~Bin[15]))) :
                     (ALUop == 2'b01) ? (~ALU_out[15]&Ain[15]&(~Bin[15])) : 1'b0;


//final status register input
assign statusreg_in = {ALUZ_out,ALU_out[15], overflow};

//status register
vDFFE #(3) STATUS(clk,loads,statusreg_in,Z_out);

endmodule
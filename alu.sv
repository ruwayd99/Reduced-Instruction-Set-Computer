module ALU(Ain,Bin,ALUop,out,Z); 

// inputs and outputs
input [15:0] Ain, Bin;
input [1:0] ALUop;
output [15:0] out;
output Z;

//definitions for operators and values
`define plus 2'b00
`define minus 2'b01
`define and 2'b10 
`define not 2'b11 
`define zero 16'b0000000000000000
`define zone 1'b1
`define zzero 1'b0

// wire and regs
reg [1:0] ALUop;
reg [15:0] Ain, Bin;
reg [15:0] out;
reg Z;

// detects operators and perform calculation for both out and Z
always @(*) begin
    // calculattes out from change in operator ALUop
	case(ALUop)
        `plus: out = Ain + Bin;     // plus operator outputs
        `minus: out = Ain - Bin;    // minus operator outputs
        `and: out = Ain & Bin;      // and operator outputs
        `not: out = ~Bin;           // not operator outputs

		default: out = `zero;       // default out set to zero
	endcase

    // Calculates Z from changes in out
    case(out)
        `zero: Z = `zone;           // Z = 1 when out = 0

        default: Z = `zzero;        // Z = 0 when out != 0
    endcase
end

endmodule

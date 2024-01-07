module instruction_decoder(data_in, nsel, ALUop, sximm5, sximm8, shift, readnum, writenum, op, opcode); 

input [15:0] data_in;
input [2:0] nsel;
output [15:0] sximm8, sximm5;
output [1:0] shift, ALUop, op;
output [2:0] readnum, writenum, opcode;

// Define constants 
`define Rn        3'b001
`define Rd        3'b010
`define Rm        3'b100

// Declare registers for read and write numbers
reg [2:0] readnum, writenum;

always@(*) begin 
    // Case statement for register selection based on nsel
    case(nsel) 
        `Rn: begin 
            readnum = data_in[10:8];
            writenum = data_in[10:8];
        end
        `Rd: begin 
            readnum = data_in[7:5];
            writenum = data_in[7:5];
        end
        `Rm: begin 
            readnum = data_in[2:0];
            writenum = data_in[2:0];
        end
    endcase
end

// Assign ALU operation based on data_in
assign ALUop = data_in[12:11];

// Assign signed extended values
assign sximm5 = {{11{data_in[4]}}, data_in[4:0]}; 
assign sximm8 = {{8{data_in[7]}}, data_in[7:0]}; 

// Assign shift value
assign shift = data_in[4:3]; 

// Assign operation and opcode
assign op = data_in[12:11];
assign opcode = data_in[15:13];

endmodule 
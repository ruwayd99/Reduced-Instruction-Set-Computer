module regfile(data_in,writenum,write,readnum,clk,data_out);
input [15:0] data_in;
input [2:0] writenum, readnum;
input write, clk;
output [15:0] data_out;

`define SW 16
`define zero 3'b000
`define one 3'b001
`define two 3'b010
`define three 3'b011
`define four 3'b100
`define five 3'b101
`define six 3'b110
`define seven 3'b111

//3:8 decoder
// reg [7:0] decoder_out;
// always_comb begin 
//     case(writenum) 
    
//         `zero: decoder_out = 8'b00000001;
//         `one: decoder_out = 8'b00000010;
//         `two: decoder_out = 8'b00000100;
//         `three: decoder_out = 8'b00001000;
//         `four: decoder_out = 8'b00010000;
//         `five: decoder_out = 8'b00100000;
//         `six: decoder_out = 8'b01000000;
//         `seven: decoder_out = 8'b10000000;
//         default: decoder_out = 8'b00000000;  
    
//     endcase
// end

reg en0, en1, en2, en3, en4, en5, en6, en7;

always_comb begin
    en0 = 1'b0;
    en1 = 1'b0;
    en2 = 1'b0;
    en3 = 1'b0;
    en4 = 1'b0;
    en5 = 1'b0;
    en6 = 1'b0;
    en7 = 1'b0;
    
    case (writenum)
        `zero: en0 = write ? 1'b1 : 1'b0; 
        `one: en1 = write ? 1'b1 : 1'b0;
        `two: en2 = write ? 1'b1 : 1'b0;
        `three: en3 = write ? 1'b1 : 1'b0;
        `four: en4 = write ? 1'b1 : 1'b0;
        `five: en5 = write ? 1'b1 : 1'b0;
        `six: en6 = write ? 1'b1 : 1'b0;
        `seven: en7 = write ? 1'b1 : 1'b0;
    endcase
end


//and block for write and the decoder_out
// wire [7:0] enable;
// assign enable = decoder_out & write;

wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
// wire [15:0] data_in;

//load enable registers 
vDFFE #(`SW) STATE0(clk,en0,data_in,R0);
vDFFE #(`SW) STATE1(clk,en1,data_in,R1);
vDFFE #(`SW) STATE2(clk,en2,data_in,R2);
vDFFE #(`SW) STATE3(clk,en3,data_in,R3);
vDFFE #(`SW) STATE4(clk,en4,data_in,R4);
vDFFE #(`SW) STATE5(clk,en5,data_in,R5);
vDFFE #(`SW) STATE6(clk,en6,data_in,R6);
vDFFE #(`SW) STATE7(clk,en7,data_in,R7);

// fill out the rest


//reg-file mux
reg [15:0] data_out;
always_comb begin 
    case(readnum) 
    
        `zero: data_out = R0;
        `one: data_out = R1;
        `two: data_out = R2;
        `three: data_out = R3;
        `four: data_out = R4;
        `five: data_out = R5;
        `six: data_out = R6;
        `seven: data_out = R7;
        default: data_out = 16'bxxxxxxxxxxxxxxxx;

    endcase
end
endmodule

//module for load enable
module vDFFE(clk,en,in,out);

    parameter n = 1;
    input clk,en;
    input [n-1:0] in;
    output [n-1:0] out;
    reg [n-1:0] out;
    wire [n-1:0] next_out;
    //if enable is 1, then we can write to the register
    assign next_out = en ? in : out;

    always_ff @(posedge clk)
        out = next_out;
endmodule
module shifter(in,shift,sout); 

// input and output
input [15:0] in;    
input [1:0] shift;
output [15:0] sout;

// define operators 
`define return 2'b00
`define left 2'b01
`define right 2'b10
`define cright 2'b11

// wire and reg
reg [15:0] in;
reg [1:0] shift;
reg [15:0] sout;

// checks the state of shift and returns output sout
always @(*) begin
    case(shift)
        `return: sout = in;                     // when sout returns in
        `left:  sout = in << 1;                 // when sout shifts left by 1 bit
        `right: sout = in >> 1;                 // when sout shift right by 1 bit
        `cright:  sout = {in[15], in[15:1]};    // when sout shift right by 1 bit and the MSB is copied

        default: sout = 16'bxxxxxxxxxxxxxxxx;   // default sout
    endcase
end
endmodule
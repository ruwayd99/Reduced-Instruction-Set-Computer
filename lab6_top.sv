// DE1-SOC INTERFACE SPECIFICATION in this file:
//
// clk input to datpath has rising edge when KEY0 is *pressed* 
//
// HEX5 contains the status register output on the top (Z), middle (N) and
// bottom (V) segment.
//
// HEX3, HEX2, HEX1, HEX0 are wired to out which should show the contents
// of your register C.
//
// When SW[9] is set to 0, SW[7:0] changes the lower 8 bits of the 16-bit 
// input "in". LEDR[8:0] will show the upper 8-bits of 16-bit input "in".
//
// When SW[9] is set to 1, SW[7:0] changes the upper 8 bits of the 16-bit
// input "in". LEDR[8:0] will show the lower 8-bits of 16-bit input "in".
//
// The rising edge of clk occurs at the moment when you press KEY0.
// The input reset is 1 as long as you press (and hold) KEY1.
// The input s is 1 as long as you press (and hold) KEY2.
// The input load is 1 as long as you press (and hold) KEY3.

module lab6_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);
  input [3:0] KEY;
  input [9:0] SW;
  output [9:0] LEDR; 
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  input CLOCK_50;

  wire [15:0] out, ir;
  input_iface IN(CLOCK_50, SW, ir, LEDR[7:0]);

  wire Z, N, V;
  cpu U( .clk   (~KEY[0]), // recall from Lab 4 that KEY0 is 1 when NOT pushed
         .reset (~KEY[1]), 
         .s     (~KEY[2]),
         .load  (~KEY[3]),
         .in    (ir),
         .out   (out),
         .Z     (Z),
         .N     (N),
         .V     (V),
         .w     (LEDR[9]) );

  assign HEX5[0] = ~Z;
  assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;

  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(out[3:0],   HEX0);
  sseg H1(out[7:4],   HEX1);
  sseg H2(out[11:8],  HEX2);
  sseg H3(out[15:12], HEX3);
  assign HEX4 = 7'b1111111;
  assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
  assign LEDR[8] = 1'b0;
endmodule

module input_iface(clk, SW, ir, LEDR);
  input clk;
  input [9:0] SW;
  output [15:0] ir;
  output [7:0] LEDR;
  wire sel_sw = SW[9];  
  wire [15:0] ir_next = sel_sw ? {SW[7:0],ir[7:0]} : {ir[15:8],SW[7:0]};
  vDFF #(16) REG(clk,ir_next,ir);
  assign LEDR = sel_sw ? ir[7:0] : ir[15:8];  
endmodule         

module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;
  always @(posedge clk)
    Q <= D;
endmodule

// The sseg module below is used to display the value of datpath_out on
// the hex LEDS the input is a 4-bit value representing numbers between 0 and
// 15 the output is a 7-bit value that will print a hexadecimal digit. 

module sseg(in,segs);
  input [3:0] in;
  output [6:0] segs;

  `define zero    4'b0000
  `define one     4'b0001
  `define two     4'b0010
  `define three   4'b0011
  `define four    4'b0100
  `define five    4'b0101
  `define six     4'b0110
  `define seven   4'b0111
  `define eight   4'b1000
  `define nine    4'b1001
  `define A       4'b1010
  `define B       4'b1011
  `define C       4'b1100 
  `define D       4'b1101 
  `define E       4'b1110 
  `define F       4'b1111 

  `define off     7'b1111111
  `define d_zero  7'b1000000
  `define d_one   7'b1111001 
  `define d_two   7'b0100100
  `define d_three 7'b0110000
  `define d_four  7'b0011001
  `define d_five  7'b0010010
  `define d_six   7'b0000010
  `define d_seven 7'b1111000
  `define d_eight 7'b0000000
  `define d_nine  7'b0010000
  `define d_A     7'b0001000
  `define d_b     7'b0000011
  `define d_c     7'b0100111
  `define d_d     7'b0100001
  `define d_E     7'b0000110
  `define d_F     7'b0001110
  
  // NOTE: The code for sseg below is not complete: You can use your code from
  // Lab4 to fill this in or code from someone else's Lab4.  
  //
  // IMPORTANT:  If you *do* use someone else's Lab4 code for the seven
  // segment display you *need* to state the following three things in
  // a file README.txt that you submit with handin along with this code: 
  //
  //   1.  First and last name of student providing code
  //   2.  Student number of student providing code
  //   3.  Date and time that student provided you their code
  //
  // You must also (obviously!) have the other student's permission to use
  // their code.
  //
  // To do otherwise is considered plagiarism.
  //
  // One bit per segment. On the DE1-SoC a HEX segment is illuminated when
  // the input bit is 0. Bits 6543210 correspond to:
  //
  //    0000
  //   5    1
  //   5    1
  //    6666
  //   4    2
  //   4    2
  //    3333
  //
  // Decimal value | Hexadecimal symbol to render on (one) HEX display
  //             0 | 0
  //             1 | 1
  //             2 | 2
  //             3 | 3
  //             4 | 4
  //             5 | 5
  //             6 | 6
  //             7 | 7
  //             8 | 8
  //             9 | 9
  //            10 | A
  //            11 | b
  //            12 | C
  //            13 | d
  //            14 | E
  //            15 | F
  reg [6:0] segs;

  always_comb begin 
    case(in) 
      `zero: segs = `d_zero;
      `one: segs = `d_one;
      `two: segs = `d_two;
      `three: segs = `d_three;
      `four: segs = `d_four;
      `five: segs = `d_five;
      `six: segs = `d_six;
      `seven: segs = `d_seven;
      `eight: segs = `d_eight;
      `nine: segs = `d_nine;
      `A: segs = `d_A;
      `B: segs = `d_b;
      `C: segs = `d_c;
      `D: segs = `d_d;
      `E: segs = `d_E;
      `F: segs = `d_F;
      default: segs = `off;
    
    endcase
  end
  // assign segs = 7'b0001110;  // this will output "F" 

endmodule

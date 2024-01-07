//Memory contants
`define MNONE  2'b00
`define MREAD  2'b01
`define MWRITE 2'b10

`define off 7'b1111111

module RISC_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
// input and output
input [3:0] KEY;
input [9:0] SW;
output [9:0] LEDR;
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

// wire for HEX
wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

// turn HEX off
assign HEX0 = `off;
assign HEX1 = `off;
assign HEX2 = `off;
assign HEX3 = `off;
assign HEX4 = `off;
assign HEX5 = `off;

//wires and regs
wire msel, mred, clk, reset, N,V,Z, write, mwritewire;
reg tri_enable, load_reg;
wire[1:0] mem_cmd;
wire [8:0] mem_addr;
wire [7:0] read_address, write_address;
wire [15:0] read_data, write_data, dout, din, dout_data;

//clk
assign clk = ~KEY[0];

//reset 
assign reset = ~KEY[1];

//cpu module
cpu CPU(clk,reset,read_data, write_data,N,V,Z, mem_addr, mem_cmd);

//assignments RAM
assign read_address = mem_addr[7:0];
assign write_address = mem_addr[7:0];
assign din = write_data;

//mwritewire assignment
assign mwritewire = mem_cmd == `MWRITE ? 1'b1 : 1'b0;
assign write = mwritewire & msel ? 1'b1 : 1'b0;

//mred assignment
assign mred = mem_cmd == `MREAD ? 1'b1 : 1'b0;

//msel assignment (check if address is valid)
assign msel = mem_addr[8] == 1'b0 ? 1'b1 : 1'b0;

//tri state driver
assign dout_data = msel & mred ? dout : {16{1'bz}};
assign read_data = dout_data;

//RAM module
RAM MEM(clk, read_address, write_address, write, din, dout);

// Tri state SW
assign read_data[7:0] = tri_enable ? SW[7:0] : {8{1'bz}};
assign read_data[15:8] = tri_enable ? 8'h00 : {8{1'bz}};

// Register LEDR
vDFFE #(8) LEDR_Reg(clk,load_reg, write_data[7:0], LEDR[7:0]);

// function block
always @(*) begin
    case(mem_addr) 
        9'h140: begin // checks if mem_addr = 9'h140
            if (mem_cmd == `MREAD) begin // if mem_cmd = `MREAD enable to tri_enable
                tri_enable = 1'b1;
                load_reg = 1'b0;
            end
            else begin 
                load_reg = 1'b0;
                tri_enable = 1'b0;
            end
        end
        9'h100: begin // checks if mem_addr = 9'h100
            if (mem_cmd == `MWRITE) begin
                load_reg = 1'b1; // if mem_cmd = `MWRITE enable to load register
                tri_enable = 1'b0;
            end
            else begin 
                load_reg = 1'b0;
                tri_enable = 1'b0;
            end
        end
        default: begin
             tri_enable = 1'b0; // set tri_enable to zero if the two conditions are not satisfied 
             load_reg = 1'b0; // set load register to zero if the two conditions are not satisfied 
        end
    endcase
end

endmodule

//RAM module from silde set 11
module RAM(clk, read_address, write_address, write, din, dout);

    // Changing paramter to correct data_width and address_width
    parameter data_width = 16;
    parameter address_width = 8;
    parameter filename = "data.txt";

    // input and output
    input clk;
    input [address_width-1:0] read_address, write_address;
    input write;
    input [data_width -1:0] din;
    output [data_width-1:0] dout;

    // reg
    reg [data_width-1:0] dout;
    reg [data_width-1:0] mem [2**address_width-1:0];

    // initial
    initial $readmemb(filename, mem);

    // always block
    always @ (posedge clk) begin 
    
        if(write)
            mem[write_address] <= din;

        dout <= mem[read_address]; 

    end
endmodule
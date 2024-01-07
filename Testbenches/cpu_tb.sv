module cpu_tb();

reg clk, reset, s, load;
reg [15:0] in;
wire [15:0] out;
wire N,V,Z,w;

reg err;

cpu DUT(clk,reset,s,load,in,out,N,V,Z,w);


  
  // time = 5, 15, 25, 35, ...  
initial begin
    clk = 0; #5;
    forever begin
      clk = 1; #5;
      clk = 0; #5;
    end
end

  // The rest of the inputs to our design under test (cpu_tb) are defined 
  // below.
initial begin
    // Plot err in your waveform to find out when first error occurs
    err = 0;
    
    // IMPORTANT: Set all control inputs to something at time=0 so not "undefined"
    reset = 1; s = 0; load = 0; in = 16'b0;

    // Now, wait for clk -- clock rises at time = 5, 15, 25, 35, ...  Thus, at 
    // time = 10 the clock is NOT rising so it is safe to change the inputs.
    #10; 
    reset = 0; 
    ////////////////////////////////////////////////////////////

    // Checking ADD function //

    // Check MOV R0, #7
    in = 16'b1101000000000111;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'h7) begin
      err = 1;
      $display("FAILED: MOV R0, #7");
      $stop;
    end

    // Check MOV R1 #2
    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1101000100000010;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'h2) begin
      err = 1;
      $display("FAILED: MOV R1, #2");
      $stop;
    end

    // Check ADD R2, R1, R0, LSL#1

    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1010000101001000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'h10) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0, LSL#1"); // check output
      $stop;
    end
    if (cpu_tb.DUT.Z !== 1'b0) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0, LSL#1 (Z_out)"); // check Z
      $stop;
    end
    if (cpu_tb.DUT.N !== 1'b0) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0, LSL#1 (N)"); // check N
      $stop;
    end
    if (cpu_tb.DUT.V !== 1'b0) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0, LSL#1(V) "); // check V
      $stop;
    end

//////////////////////////////////////////////////////////////////////

    // Checking AND function overflow //
        // Check MOV R0, # negative max val
    in = 16'b1101000011111111;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'b1111111111111111) begin
      err = 1;
      $display("FAILED: MOV R0, #-32768");
      $stop;
    end

    // Check MOV R1, R0(10)
    in = 16'b1100000000110000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'b0111111111111111) begin
      err = 1;
      $display("FAILED: MOV R1, R0(01)");
      $stop;
    end

    // Check MOV R0, R0(10)
    in = 16'b1100000000010000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'b0111111111111111) begin
      err = 1;
      $display("FAILED: MOV R0, R0(01)");
      $stop;
    end

    // Check ADD R2, R1, R0,

    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1010000101000000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'b1111111111111110) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0"); // check output
      $stop;
    end
    if (cpu_tb.DUT.Z !== 1'b0) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0, LSL#1 (Z_out)"); // check Z
      $stop;
    end
    if (cpu_tb.DUT.N !== 1'b1) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0 (N)"); // check N
      $stop;
    end
    if (cpu_tb.DUT.V !== 1'b1) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0 (V)"); // check V
      $stop;
    end

    /////////////////////////////////////////////////////////////////////////////////////////////

    // Checking AND function //
    // Check MOV R0, #7
    in = 16'b1101000000000111;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'h7) begin
      err = 1;
      $display("FAILED: MOV R0, #7");
      $stop;
    end

    // Check MOV R1 #2
    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1101000100000010;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'h2) begin
      err = 1;
      $display("FAILED: MOV R1, #2");
      $stop;
    end

    // Check MOV R2, R0<00>
    in = 16'b1100000001000000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'h7) begin
      err = 1;
      $display("FAILED: MOV R2, R0(7)<00> %d", cpu_tb.DUT.DP.REGFILE.R2);
      $stop;
    end

    // Check MOV R3, R1<01>
    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1100000001101001;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R3 !== 16'h4) begin
      err = 1;
      $display("FAILED: MOV R3, R1(2)<01>");
      $stop;
    end

    // Check AND R4, R2, R3, LSR#1
    
    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1011001010010011;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R4 !== 16'h2) begin
      err = 1;
      $display("FAILED: AND R4, R2, R3, LSR#1");
      $stop;
    end
    if (cpu_tb.DUT.Z !== 1'b0) begin
      err = 1;
      $display("FAILED: AND R4, R2, R3, LSR#1 (Z_out)"); // check Z
      $stop;
    end
    if (cpu_tb.DUT.N !== 1'b0) begin
      err = 1;
      $display("FAILED: AND R4, R2, R3, LSR#1 (N)"); // check N
      $stop;
    end
    if (cpu_tb.DUT.V !== 1'b0) begin
      err = 1;
      $display("FAILED: AND R4, R2, R3, LSR#1(V) "); // check V
      $stop;
    end

///////////////////////////////////////////////////////////////////////

    // Checking MVN function //

    // Check MOV R5, #85>
    in = 16'b1101010101010101;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R5 !== 16'd85) begin
      err = 1;
      $display("FAILED: MOV R5, #85, %d", cpu_tb.DUT.DP.REGFILE.R5);
      $stop;
    end

    // Check MOV R6, R5<11>
    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1100000011011101;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R6 !== 16'd42) begin
      err = 1;
      $display("FAILED: MOV R6, R5<11>");
      $stop;
    end

    // Check MVN R7, R6
    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1011100011100110;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R7 !== 16'b1111111111010101) begin
      err = 1;
      $display("FAILED: MVN R7, R6");
      $stop;
    end
    if (cpu_tb.DUT.Z !== 1'b0) begin
      err = 1;
      $display("FAILED: MVN R7, R6 (Z_out)"); // check Z
      $stop;
    end
    if (cpu_tb.DUT.N !== 1'b1) begin
      err = 1;
      $display("FAILED: MVN R7, R6 (N)"); // check N
      $stop;
    end
    if (cpu_tb.DUT.V !== 1'b0) begin
      err = 1;
      $display("FAILED: MVN R7, R6 (V) "); // check V
      $stop;
    end

    ///////////////////////////////////////////////////////////////////////

    // Checking CMP function //

    // Check MOV R5, #69>
    in = 16'b1101010101000101;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R5 !== 16'd69) begin
      err = 1;
      $display("FAILED: MOV R5, #69");
      $stop;
    end

    // Check MOV R6, #69>
    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1101011001000101;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R6 !== 16'd69) begin
      err = 1;
      $display("FAILED: MOV R6, #69");
      $stop;
    end

    // Check CMP R6, R5
    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1010111000000101;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.Z !== 1'b1) begin
      err = 1;
      $display("FAILED: CMP R6, R5 (Z_out)"); // check Z
      $stop;
    end
    if (cpu_tb.DUT.N !== 1'b0) begin
      err = 1;
      $display("FAILED: CMP R6, R5 (N)"); // check N
      $stop;
    end
    if (cpu_tb.DUT.V !== 1'b0) begin
      err = 1;
      $display("FAILED: CMP R6, R5 (V) "); // check V
      $stop;
    end

    ///////////////////////////////////////////////////////////////////////

      // Checking CMP function //

    // Check MOV R5, #-69>
    in = 16'b1101010110111011;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R5 !== 16'b1111111110111011) begin
      err = 1;
      $display("FAILED: MOV R5, #-69 %d",cpu_tb.DUT.DP.REGFILE.R5);
      $stop;
    end

    // Check MOV R6,R5<11>
    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1100000011011101;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R6 !== 16'b1111111111011101) begin
      err = 1;
      $display("FAILED: MOV R6,R5<11>");
      $stop;
    end

    // Check CMP R6, R5
    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1010111000000101;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.Z !== 1'b0) begin
      err = 1;
      $display("FAILED: CMP R6, R5 (Z_out)"); // check Z
      $stop;
    end
    if (cpu_tb.DUT.N !== 1'b0) begin
      err = 1;
      $display("FAILED: CMP R6, R5 (N)"); // check N
      $stop;
    end
    if (cpu_tb.DUT.V !== 1'b0) begin
      err = 1;
      $display("FAILED: CMP R6, R5 (V) "); // check V
      $stop;
    end

    // indicate errors
    if( ~err ) $display("PASSED"); // display PASSED if err != 1
    else $display("FAILED"); // display FAILED if err = 1
    #500
    $stop; // stop simulation

  end

endmodule

/*


Author Diego Charles 709758

This module is capable to send the signal of a 7 segment display

Decodes a raw 4 bit input value into 7 segment coded value.
Expected decode input goes from 0 to F
Expected decode output goes from 0 to 9 and A to F.

TODO: Make this implementation support 4 bits instead 3 
      and decode oputput for A to F. 
*/

module decoder7seg #(
    parameter WIDTH = 3,
	parameter DISPLAYSEGMENTS = 7
)(
    input  wire [WIDTH-1:0] i_SW3b,   // Switches 
    output wire [DISPLAYSEGMENTS-1:0] o_leds7b  // 
);
 
    
	
	/*
	 assign a = (~A & ~C) | B | (A & C);
    assign b = ~A | (~B & ~C) | (B & C);
    assign c = A | ~B | C;
    assign d = (~A & C) | (~A & B) | (A & ~B & C) | (B & ~C);
	 
    assign e = (B & ~C) | (~A & ~C);
    assign f = (~B & ~C) | (A & ~B) | (A & ~C);
    assign g = (~A & B) | (A & ~C) | (A & ~B)
	*/
	
	//a

	assign  o_leds7b[0]= ~( ((~i_SW3b[2])*(~ i_SW3b[0]) )|  (i_SW3b[1]) | ( i_SW3b[2]* i_SW3b[0])  );
    assign o_leds7b[1] =~  (~i_SW3b[2] | (~i_SW3b[1] & ~i_SW3b[0]) | (i_SW3b[1] & i_SW3b[0]));
    assign o_leds7b[2] = ~(i_SW3b[2] | ~i_SW3b[1] | i_SW3b[0]);
    assign  o_leds7b[3] =~ ((~i_SW3b[2] & ~i_SW3b[0]) | (~i_SW3b[2] & i_SW3b[1]) | (i_SW3b[2] & ~i_SW3b[1] & i_SW3b[0]) | (i_SW3b[1] & ~i_SW3b[0]));
	 
    assign  o_leds7b[4] =~ ((i_SW3b[1] & ~i_SW3b[0]) | (~i_SW3b[2] & ~i_SW3b[0]));
    assign   o_leds7b[5]=~ ((~i_SW3b[1] & ~i_SW3b[0]) | (i_SW3b[2] & ~i_SW3b[1]) | (i_SW3b[2] & ~i_SW3b[0]));
    assign   o_leds7b[6]=~ ((~i_SW3b[2] & i_SW3b[1]) | (i_SW3b[2] & ~i_SW3b[0]) | (i_SW3b[2] & ~i_SW3b[1]));
 
endmodule
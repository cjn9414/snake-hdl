// --------------------------------------------------------------------------
// File : lfsr.v
// 
// Module : lfsr
// Author : Carter Nesbitt
// Created : 15 September 2019
// Modified : 15 September 2019
// 
// Language : Verilog 
// Description : Linear-Feedback Shift Register implementation with
//					asynchronous reset and parallel output.
// --------------------------------------------------------------------------

module lfsr
	(
        i_Clk,
		i_Rst,
        o_Data
	);
    	
	parameter DEPTH = 12;
	parameter TAP1 = 4;
	parameter TAP2 = 7;
	parameter INIT = 1;
	input wire i_Clk;
	input wire i_Rst;
    output reg [DEPTH-1:0] o_Data;
	
	integer idx;
	
	always @ (posedge(i_Clk) or posedge(i_Rst))
		if (i_Rst) begin
			o_Data <= INIT;
		end else begin
			o_Data[0] <= o_Data[TAP1] ^ o_Data[TAP2];
			for (idx = 1; idx < DEPTH; idx = idx + 1) begin
				o_Data[idx] <= o_Data[idx-1];
			end
		end
endmodule
	
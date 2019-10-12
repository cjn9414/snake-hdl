// --------------------------------------------------------------------------
// File : Basys3_button_debouncer.v
// 
// Module : Basys3_button_debouncer
// Author : Carter Nesbitt
// Created : 12 October 2019
// Modified : 12 October 2019
// 
// Language : Verilog 
// Description : Filters the signals received
//				 from the push buttons to alleviate bouncing
//				 and maintain signal integrity.
// --------------------------------------------------------------------------

module Basys3_button_debouncer 
	(
		input wire i_Clk,
		input wire [3:0] i_Buttons,
		output wire [3:0] o_Buttons
	);
	
	// Target clock frequency
	parameter c_CLK_FREQ = 106470000;
	
	// Time that signal must be stable in microseconds
	parameter c_FILTER_MICRO = 5000;
	
	// Number of cycles to wait to consider signal stable
	localparam c_FILTER_CYCLES = c_CLK_FREQ * c_FILTER_MICRO / 1000000;
	
	// Counts clock cycles that button input is stable
	integer ValidCount = 0;
	
	// Register button input and compare to future inputs
	reg [3:0] r_UnstableButtons = 0;
	
	// Register to hold the most previous signal, feed to output
	reg [3:0] r_Buttons = 0;
	
	always @(posedge(i_Clk)) begin
		if (i_Buttons == r_UnstableButtons) begin
			// Signal remains stable
			if (ValidCount < c_FILTER_CYCLES) begin
				// Hasn't reached full stability
				ValidCount <= ValidCount + 1;
			end else begin
				// Signal has held its value for long enough
				ValidCount <= 0;
				r_Buttons <= i_Buttons;
			end
		end else begin
			// Signal changed value
			ValidCount <= 0;
			r_UnstableButtons <= i_Buttons;
		end
	end
	
	assign o_Buttons = r_Buttons;
	
endmodule
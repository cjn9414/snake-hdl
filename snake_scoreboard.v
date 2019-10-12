// --------------------------------------------------------------------------
// File : snake_scoreboard.v
// 
// Module : snake_scoreboard
// Author : Carter Nesbitt
// Created : 15 September 2019
// Modified : 15 September 2019
// 
// Language : Verilog 
// Description : Component that maps a score to a set of four seven-segment
//					display modules.
// --------------------------------------------------------------------------

module snake_scoreboard 
	(
		input wire i_Clk,
		input wire i_Score,
		output reg [6:0] o_ScoreDisplay
	);
	
	parameter SCORE_WIDTH = 14;
	
	wire [27:0] w_Segments;
	reg [3:0] r_SegmentSelect = 0;
	integer r_Score;
	integer idx;
	
	
	always @ (posedge(i_Clk)) begin
		r_Score <= i_Score;
		r_SegmentSelect[3] <= r_SegmentSelect[2];
		r_SegmentSelect[2] <= r_SegmentSelect[1];
		r_SegmentSelect[1] <= r_SegmentSelect[0];
		r_SegmentSelect[0] <= r_SegmentSelect[3];
	end
	
	assign w_Segments[27:21] = r_Score / 1000;
	assign w_Segments[20:14] = r_Score / 100;
	assign w_Segments[13:7] = r_Score / 10;
	assign w_Segments[6:0] = r_Score % 10;
	
	always @* begin
		if (r_SegmentSelect[3]) begin
			o_ScoreDisplay <= w_Segments[27:21];
		end else if (r_SegmentSelect[2]) begin
			o_ScoreDisplay <= w_Segments[20:14];
		end else if (r_SegmentSelect[1]) begin
			o_ScoreDisplay <= w_Segments[13:7];
		end else begin
			o_ScoreDisplay <= w_Segments[6:0];
		end
	end
endmodule
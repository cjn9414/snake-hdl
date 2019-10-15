// --------------------------------------------------------------------------
// File : snake_scoreboard.v
// 
// Module : snake_scoreboard
// Author : Carter Nesbitt
// Created : 15 September 2019
// Modified : 12 October 2019
// 
// Language : Verilog 
// Description : Component that maps a score to a set of four seven-segment
//					display modules.
// --------------------------------------------------------------------------

module snake_scoreboard 
	(
		i_Clk,
		i_Score,
		o_ScoreDisplay,
		o_SegmentSelect
	);
	
	// Four BCD digits
	parameter SCORE_WIDTH = 16;
	
	input wire i_Clk;
	input wire [SCORE_WIDTH-1:0] i_Score;
	output reg [7:0] o_ScoreDisplay;
	output reg [3:0] o_SegmentSelect;

	localparam c_RESET_SR = 4'b1110;
	
	reg [3:0] r_Selected_Segment; // Selected digit
	reg [3:0] r_SegmentSelect = c_RESET_SR;
	integer r_Score;
	
	localparam SS_0 = 8'b00000011;
	localparam SS_1 = 8'b10011111;
	localparam SS_2 = 8'b00100101;
	localparam SS_3 = 8'b00001101;
	localparam SS_4 = 8'b10011001;
	localparam SS_5 = 8'b01001001;
	localparam SS_6 = 8'b01000001;
	localparam SS_7 = 8'b00011111;
	localparam SS_8 = 8'b00000001;
	localparam SS_9 = 8'b00001001;

	
	always @ (posedge(i_Clk)) begin
		r_SegmentSelect[3] <= r_SegmentSelect[2];
		r_SegmentSelect[2] <= r_SegmentSelect[1];
		r_SegmentSelect[1] <= r_SegmentSelect[0];
		r_SegmentSelect[0] <= r_SegmentSelect[3];
	end
	
	always @* begin // Select digit to display
		if (r_SegmentSelect[3] == 1'b0) begin
			r_Selected_Segment = i_Score[15:12];
		end else if (r_SegmentSelect[2] == 1'b0) begin
			r_Selected_Segment = i_Score[11:8];
		end else if (r_SegmentSelect[1] == 1'b0) begin
			r_Selected_Segment = i_Score[7:4];
		end else begin
			r_Selected_Segment = i_Score[3:0];
		end
	end
	
	always @* begin // Select 7-Segment pin assertions 
		case (r_Selected_Segment)
			4'd0: o_ScoreDisplay = SS_0;
			4'd1: o_ScoreDisplay = SS_1;
			4'd2: o_ScoreDisplay = SS_2;
			4'd3: o_ScoreDisplay = SS_3;
			4'd4: o_ScoreDisplay = SS_4;
			4'd5: o_ScoreDisplay = SS_5;
			4'd6: o_ScoreDisplay = SS_6;
			4'd7: o_ScoreDisplay = SS_7;
			4'd8: o_ScoreDisplay = SS_8;
			default: o_ScoreDisplay = SS_9;
		 endcase
	end
	
	always @* begin
		o_SegmentSelect <= r_SegmentSelect;
	end
endmodule
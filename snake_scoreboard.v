// --------------------------------------------------------------------------
// File : snake_scoreboard.v
// 
// Module : snake_scoreboard
// Author : Carter Nesbitt
// Created : 15 September 2019
// Modified : 15 October 2019
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
	output reg [6:0] o_ScoreDisplay;
	output reg [3:0] o_SegmentSelect;

	localparam c_RESET_SR = 4'b1110;
	
	reg [3:0] r_Selected_Segment = 4'b0000; // Selected digit
	reg [1:0] r_SegCounter = 2'b00;
	integer r_Score;
	
	localparam SS_0 = 7'b0000001;
	localparam SS_1 = 7'b1001111;
	localparam SS_2 = 7'b0010010;
	localparam SS_3 = 7'b0000110;
	localparam SS_4 = 7'b1001100;
	localparam SS_5 = 7'b0100100;
	localparam SS_6 = 7'b0100000;
	localparam SS_7 = 7'b0001111;
	localparam SS_8 = 7'b0000000;
	localparam SS_9 = 7'b0000100;

	
	always @ (posedge(i_Clk)) begin
		r_SegCounter <= r_SegCounter + 1;
	end
	
	always @* begin // Select digit to display
		case (r_SegCounter)
			2'b11 : begin
				r_Selected_Segment <= i_Score[15:12];
				o_SegmentSelect <= 4'b0111;
				end
			2'b10 : begin
				r_Selected_Segment <= i_Score[11:8];
				o_SegmentSelect <= 4'b1011;
				end
			2'b01 : begin
				r_Selected_Segment <= i_Score[7:4];
				o_SegmentSelect <= 4'b1101;
				end
			default : begin
				r_Selected_Segment <= i_Score[3:0];
				o_SegmentSelect <= 4'b1110;
				end
		endcase
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
endmodule
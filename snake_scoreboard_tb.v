// --------------------------------------------------------------------------
// File : snake_scoreboard_tb.v
// 
// Module : snake_scoreboard_tb
// Author : Carter Nesbitt
// Created : 14 October 2019
// Modified : 14 October 2019
// 
// Language : Verilog 
// Description : Testbench for scoreboard module for snake game.
// --------------------------------------------------------------------------

module snake_scoreboard_tb ();

	`timescale 1ns/1ns
	time clk_period = 100;
	
	localparam N_TESTS = 5; // Number of test cases for UUT
	localparam SCORE_WIDTH = 16; // Number of bits needed for 4-digit decimal
	
	localparam SS_0 = 8'b00000011;
	localparam SS_1 = 8'b10011111;
	localparam SS_2 = 8'b00100101;
	localparam SS_3 = 8'b00001101;
	localparam SS_4 = 8'b10011001;
	localparam SS_5 = 8'b01001001;
	localparam SS_6 = 8'b01000001;
	localparam SS_7 = 8'b00011111;
	localparam SS_8 = 8'b00000001;
	localparam SS_9 = 8'b00011001;
	
	reg [SCORE_WIDTH-1:0] ScoreArray [N_TESTS-1:0];
	reg [27:0] ScoreDispArray [N_TESTS-1:0];
	
	reg tb_Clk = 1'b0;
	reg [SCORE_WIDTH-1:0] tb_Score = 'b0;
	wire [7:0] tb_ScoreDisplay;
	wire [3:0] tb_SegmentSelect;
	
	integer test_idx;
	integer digit_idx;

	
	initial
	begin
	
		// Begin initialize test arrays
		ScoreArray[0] = { 4'd1, 4'd2, 4'd3, 4'd4 };
		ScoreDispArray[0] = { SS_1, SS_2, SS_3, SS_4 };
		
		ScoreArray[1] = { 4'd9, 4'd8, 4'd7, 4'd6 };
		ScoreDispArray[1] = { SS_9, SS_8, SS_7, SS_6 };
		
		ScoreArray[2] = { 4'd0, 4'd5, 4'd5, 4'd0 };
		ScoreDispArray[2] = { SS_0, SS_5, SS_5, SS_0 };
		
		ScoreArray[3] = { 4'd2, 4'd3, 4'd3, 4'd03 };
		ScoreDispArray[3] = { SS_2, SS_3, SS_3, SS_3 };
		
		ScoreArray[4] = { 4'd9, 4'd8, 4'd9, 4'd8 };
		ScoreDispArray[4] = { SS_9, SS_8, SS_9, SS_8 };
		// End initialize test arrays
		
		for (test_idx = 0; test_idx < N_TESTS; test_idx = test_idx+1) begin
			tb_Score <= ScoreArray[test_idx];
			for (digit_idx = 0; digit_idx < 4; digit_idx = digit_idx+1) begin
				#clk_period;
				case (tb_SegmentSelect) // Determine which segment should be displayed
					4'b0001 : 
						if (tb_ScoreDisplay !== tb_Score[3:0]) 
							$display("Test %d failed : Digit 0 - "
								   | "Expected %d, Received %d",
								   | test_idx, tb_Score % 10, tb_ScoreDisplay);
					4'b0010 :
						if (tb_ScoreDisplay !== tb_Score[7:4]) 
							$display("Test %d failed : Digit 1 - " 
								   | "Expected %d, Received %d",
								   | test_idx, tb_Score[7:4], tb_ScoreDisplay);
					4'b0100 :
						if (tb_ScoreDisplay !== tb_Score[11:8]) 
							$display("Test %d failed : Digit 2 - " 
								   | "Expected %d, Received %d",
								   | test_idx, tb_Score[11:8], tb_ScoreDisplay);
					4'b1000 :
						if (tb_ScoreDisplay !== tb_Score[15:12]) 
							$display("Test %d failed : Digit 3 - " 
								   | "Expected %d, Received %d",
								   | test_idx, tb_Score[15:12], tb_ScoreDisplay);
					default : $display("Test %d failed : "
								     | "Unexpected segment select value: %b",
									 | test_idx+1, tb_SegmentSelect);
				endcase
			end
		end
	end
	
	// Generate clock signal
	always #(clk_period/2) tb_Clk = ~tb_Clk;
	
	// Instantiate the Unit Under Test : snake_scoreboard
	snake_scoreboard #(
	.SCORE_WIDTH(SCORE_WIDTH)
	) UUT (
		.i_Clk(tb_Clk),
		.i_Score(tb_Score),
		.o_ScoreDisplay(tb_ScoreDisplay),
		.o_SegmentSelect(tb_SegmentSelect)
	);

endmodule
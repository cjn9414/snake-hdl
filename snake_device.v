// --------------------------------------------------------------------------
// File : snake_device.v
// 
// Module : snake_device
// Author : Carter Nesbitt
// Created : 15 September 2019
// Modified : 12 October 2019
// 
// Language : Verilog 
// Description : High level module for the classic snake game
//					re-imagined in hardware.
// --------------------------------------------------------------------------

module snake_device (
	input i_Clk,
	input i_Rst,
	input [3:0] i_Direction,
	output wire [6:0] o_ScoreDisplay,
	output wire [3:0] o_Red,
	output wire [3:0] o_Green,
	output wire [3:0] o_Blue,
	output wire o_HSync,
	output wire o_VSync,
	output wire [3:0] o_SegmentSelect
);
	parameter CLK_FREQ = 106470000;
	parameter REFRESH_RATE = 20;
	parameter SCOREBOARD_CLK_FREQ = 4096;
	parameter DISPLAY_WIDTH = 1440;
	parameter DISPLAY_HEIGHT = 900;
	parameter CELLS_WIDTH = 32;
	parameter CELLS_HEIGHT = 32;
	parameter LFSR_DEPTH = $clog2(CELLS_WIDTH*CELLS_HEIGHT);
	parameter LFSR_INIT = 12'hC75;
	parameter MAX_7SEG = 16;
	
	wire w_SnakeClk;
	wire w_ScoreClk;
	wire w_GameOver;
	wire [MAX_7SEG-1:0] w_Score;

	wire [LFSR_DEPTH-1:0] w_Food;
	wire [LFSR_DEPTH-1:0] w_RNG;
	wire [(CELLS_WIDTH+1) * (CELLS_HEIGHT+1)-1:0] w_SnakeGrid;
	wire [3:0] w_Direction;
	
	localparam TEST_7SEG = { 4'd8, 4'd1, 4'd7, 4'd0 };
		
	clock_divider
	#(
		.DIV(CLK_FREQ / REFRESH_RATE)
	) clk_to_snake (
		.i_clk(i_Clk),
		.o_clk(w_SnakeClk)
	);
			
	clock_divider
	#(
		.DIV(CLK_FREQ / SCOREBOARD_CLK_FREQ)
	) clk_to_scoreboard (
		.i_clk(i_Clk),
		.o_clk(w_ScoreClk)
	);
	
	
	snake_game
	#(
		.c_GRID_IDX_SZ(LFSR_DEPTH),
		.c_WIDTH(CELLS_WIDTH),
		.c_HEIGHT(CELLS_HEIGHT)
	) game_logic (
		.i_Clk(w_SnakeClk),
		.i_Rst(i_Rst),
		.i_Direction(w_Direction),
		.i_FoodLocation(w_RNG),
		.o_Kill(w_GameOver),
		.o_SnakeGrid(w_SnakeGrid),
		.o_Food(w_Food),
		.o_Score(w_Score)
	);
	
	lfsr
	#(
		.DEPTH(LFSR_DEPTH),
		.INIT(LFSR_INIT)
	) random_cell_generator (
		.i_Clk(i_Clk),
		.i_Rst(i_Rst),
		.o_Data(w_RNG)
	);
	
	snake_to_vga
	#(
		.c_WIDTH(CELLS_WIDTH),
		.c_HEIGHT(CELLS_HEIGHT),
		.c_GRID_IDX_SZ(LFSR_DEPTH),
		.c_SCREEN_WIDTH(DISPLAY_WIDTH),
		.c_SCREEN_HEIGHT(DISPLAY_HEIGHT)
	) vga_wrapper (
		.i_Clk(i_Clk),
		.i_Rst(i_Rst),
		.i_GameOver(w_GameOver),
		.i_SnakeGrid(w_SnakeGrid),
		.i_Food(w_Food),
		.o_Red(o_Red),
		.o_Green(o_Green),
		.o_Blue(o_Blue),
		.o_HSync(o_HSync),
		.o_VSync(o_VSync)
	);
	
	snake_scoreboard
	#(
	   .SCORE_WIDTH(MAX_7SEG)
	) score_wrapper (
		.i_Clk(w_ScoreClk),
		.i_Score(TEST_7SEG),
		.o_ScoreDisplay(o_ScoreDisplay),
		.o_SegmentSelect(o_SegmentSelect)
	);
	
	Basys3_button_debouncer
	#(
	) direction_debouncer (
		.i_Clk(i_Clk),
		.i_Buttons(i_Direction),
		.o_Buttons(w_Direction)
	);
	
endmodule
	
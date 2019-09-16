// --------------------------------------------------------------------------
// File : snake_device.v
// 
// Module : snake_device
// Author : Carter Nesbitt
// Created : 15 September 2019
// Modified : 15 September 2019
// 
// Language : Verilog 
// Description : High level module for the classic snake game
//					re-imagined in hardware.
// --------------------------------------------------------------------------

module snake_device (
	input wire i_Clk,
	input wire i_Rst,
	input [3:0] i_Direction,
	output wire [23:0] o_ScoreDisplay,
	output wire [3:0] o_Red,
	output wire [3:0] o_Green,
	output wire [3:0] o_Blue,
	output wire o_HSync,
	output wire o_VSync
);
	parameter CLK_FREQ = 106470000;
	parameter REFRESH_RATE = 20;
	parameter DISPLAY_WIDTH = 1440;
	parameter DISPLAY_HEIGHT = 900;
	parameter VGA_POLARITY = 1'b0;
	parameter CELLS_WIDTH = 32;
	parameter CELLS_HEIGHT = 32;
	parameter LFSR_DEPTH = $clog2(CELLS_WIDTH*CELLS_HEIGHT);
	parameter LFSR_INIT = 3'hC75;
	parameter MAX_7SEG = $clog2(9999);
	
	wire w_SnakeClk;
	
	reg [LFSR_DEPTH-1:0] r_Food;
	reg r_GameOver;
	reg [LFSR_DEPTH-1:0] r_RNG;
	reg [(CELLS_WIDTH+1 * CELLS_HEIGHT+1)-1:0] r_SnakeGrid;
	reg [MAX_7SEG:0] r_Score;
	
	signal_generator
	#( 
		.pol(VGA_POLARITY)
	) vga_signal (
		.i_clk(i_Clk),
		.i_rst(i_Rst),
		.o_h_sync(o_HSync),
		.o_v_sync(o_VSync)
	);
	
	snake_game
	#(
	) game_logic (
		.i_Clk(i_Clk),
		.i_Rst(i_Rst),
		.i_SnakeClk(w_SnakeClk),
		.i_Direction(i_Direction),
		.o_Kill(r_GameOver),
		.o_Grid(r_SnakeGrid),
		.o_Food(r_Food),
		.o_Score(r_Score)
	);
	
	lfsr
	#(
		.DEPTH(LFSR_DEPTH)
		.INIT(
	) random_cell_generator (
		.i_Clk(i_Clk),
		.i_Rst(i_Rst),
		.o_Data(r_RNG)
	);
	
	clock_divider
	#(
		.DIV(CLK_FREQ / REFRESH_RATE)
	) clk_to_snake (
		.i_clk(i_Clk),
		.o_clk(w_SnakeClk)
	);
	
	snake_to_vga
	#(
		.WIDTH(DISPLAY_WIDTH),
		.HEIGHT(DISPLAY_HEIGHT),
		.VGA_POLARITY(VGA_POLARITY)
	) vga_wrapper (
		.i_Clk(i_Clk),
		.i_Rst(i_Rst),
		.i_GameOver(r_GameOver),
		.i_SnakeGrid(r_SnakeGrid),
		.i_Food(r_Food),
		.o_Red(o_Red),
		.o_Green(o_Green),
		.o_Blue(o_Blue),
		.o_HSync(o_HSync),
		.o_VSync(o_VSync)
	);
	
	snake_scoreboard
	#() score_wrapper (
		.i_Score(r_Score),
		.o_ScoreDisplay(o_ScoreDisplay)
	)
	
endmodule
	
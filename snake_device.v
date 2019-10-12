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
	input wire [3:0] i_Direction,
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
	parameter LFSR_INIT = 12'hC75;
	parameter MAX_7SEG = $clog2(9999);
	
	wire w_SnakeClk;
	
	reg [LFSR_DEPTH-1:0] r_Food = 0;
	reg r_GameOver = 0;
	reg [LFSR_DEPTH-1:0] r_RNG = 0;
	reg [(CELLS_WIDTH+1 * CELLS_HEIGHT+1)-1:0] r_SnakeGrid = 0;
	reg [MAX_7SEG:0] r_Score = 0;
	reg [3:0] r_Direction = 0;
	
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
		.c_GRID_IDX_SIZE(LFSR_DEPTH),
		.c_WIDTH(CELLS_WIDTH),
		.c_HEIGHT(CELLS_HEIGHT)
	) game_logic (
		.i_Clk(i_Clk),
		.i_Rst(i_Rst),
		.i_SnakeClk(w_SnakeClk),
		.i_Direction(r_Direction),
		.i_FoodLocation(r_RNG),
		.o_Kill(r_GameOver),
		.o_Grid(r_SnakeGrid),
		.o_Food(r_Food),
		.o_Score(r_Score)
	);
	
	lfsr
	#(
		.DEPTH(LFSR_DEPTH),
		.INIT(LFSR_INIT)
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
		.c_WIDTH(DISPLAY_WIDTH),
		.c_HEIGHT(DISPLAY_HEIGHT),
		.c_VGA_POLARITY(VGA_POLARITY)
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
	#(
	   .SCORE_WIDTH(MAX_7SEG)
	) score_wrapper (
		.i_Score(r_Score),
		.o_ScoreDisplay(o_ScoreDisplay)
	);
	
	Basys3_button_debouncer
	#(
	) direction_debouncer (
		.i_Switches(i_Direction),
		.o_Switches(r_Direction)
	);
	
endmodule
	
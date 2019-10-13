// --------------------------------------------------------------------------
// File : snake_to_vga.v
// 
// Module : snake_to_vga
// Author : Carter Nesbitt
// Created : 12 October 2019
// Modified : 12 October 2019
// 
// Language : Verilog 
// Description : Converts the structured output of the snake game
//				 logic module to a VGA signal.
// --------------------------------------------------------------------------

module snake_to_vga
	(
		i_Clk,
		i_Rst,
		i_GameOver,
		i_SnakeGrid,
		i_Food,
		o_Red,
		o_Green,
		o_Blue,
		o_HSync,
		o_VSync
	);
	
	parameter c_WIDTH = 32;
	parameter c_HEIGHT = 32;
	parameter c_GRID_IDX_SZ = 10;
	parameter c_SCREEN_WIDTH = 1440;
	parameter c_SCREEN_HEIGHT = 900;

	// Eventually change to params to make application more generic.
	localparam c_VGA_POLARITY_X = 1'b0;
	localparam c_VGA_POLARITY_Y = 1'b1;
	localparam c_FRONT_PORCH_END_H = 1520;
	localparam c_SYNC_PULSE_END_H = 1672;
	localparam c_BACK_PORCH_END_H = 1904;
	localparam c_FRONT_PORCH_END_V = 901;
	localparam c_SYNC_PULSE_END_V = 904;
	localparam c_BACK_PORCH_END_V = 932;
	
	// Max value to VGA DAC = 16, currently set to half for testing
	localparam c_COLOR_HIGH = 4'd8;
	localparam c_COLOR_LOW = 4'd0;
	
	// Each pixel is x^2 (= 16 pixels) wide
	localparam c_SQUARE_PIXEL_SHIFT = 4;
	localparam c_GAME_PIXEL_WIDTH = c_WIDTH * (2**c_SQUARE_PIXEL_SHIFT);
	localparam c_GAME_PIXEL_HEIGHT = c_HEIGHT * (2**c_SQUARE_PIXEL_SHIFT);
	
	localparam c_PIXEL_TO_CELL_SHIFT = $clog2(c_WIDTH);
	localparam c_X_PIXEL_IDX_SZ = $clog2(c_SCREEN_WIDTH)-1;
	localparam c_Y_PIXEL_IDX_SZ = $clog2(c_SCREEN_HEIGHT);
	// Input / Output list
	input i_Clk;
	input i_Rst;
	input i_GameOver;
	input [(c_WIDTH+1)*(c_HEIGHT+1)-1:0] i_SnakeGrid;
	input [c_GRID_IDX_SZ-1:0] i_Food;
	output reg [3:0] o_Red;
	output reg [3:0] o_Green;
	output reg [3:0] o_Blue;
	output o_HSync;
	output o_VSync;
	
	// Current display location for VGA
	wire [c_X_PIXEL_IDX_SZ:0] w_Pixel_X = 0;
	wire [c_Y_PIXEL_IDX_SZ:0] w_Pixel_Y = 0;
	
	always @(posedge(i_Clk) or posedge(i_Rst)) begin
		if (i_Rst == 1'b1) begin
			o_Red <= c_COLOR_LOW;
			o_Green <= c_COLOR_LOW;
			o_Blue <= c_COLOR_HIGH;
		end else if (w_Pixel_X > c_GAME_PIXEL_WIDTH ||
				w_Pixel_Y > c_GAME_PIXEL_HEIGHT) begin
			o_Red <= c_COLOR_LOW;
			o_Green <= c_COLOR_LOW;
			o_Blue <= c_COLOR_HIGH;				
		end else if (i_GameOver == 1'b1) begin
			o_Red <= c_COLOR_LOW;
			o_Green <= c_COLOR_LOW;
			o_Blue <= c_COLOR_LOW;
		end else if (w_Pixel_X[c_X_PIXEL_IDX_SZ:c_SQUARE_PIXEL_SHIFT] == 'b0 ||
					 w_Pixel_X[c_X_PIXEL_IDX_SZ:c_SQUARE_PIXEL_SHIFT] == c_WIDTH || 
					 w_Pixel_Y[c_Y_PIXEL_IDX_SZ:c_SQUARE_PIXEL_SHIFT] == 'b0 ||
					 w_Pixel_Y[c_Y_PIXEL_IDX_SZ:c_SQUARE_PIXEL_SHIFT] == c_HEIGHT) begin
			o_Red <= c_COLOR_HIGH;
			o_Green <= c_COLOR_LOW;
			o_Blue <= c_COLOR_LOW;
		end else if (w_Pixel_X[c_X_PIXEL_IDX_SZ:c_SQUARE_PIXEL_SHIFT] == i_Food) begin
			o_Red <= c_COLOR_HIGH;
			o_Green <= c_COLOR_LOW;
			o_Blue <= c_COLOR_LOW;
		end else if ( i_SnakeGrid[ { w_Pixel_Y[c_Y_PIXEL_IDX_SZ:c_SQUARE_PIXEL_SHIFT], c_PIXEL_TO_CELL_SHIFT }
					 + w_Pixel_X[c_X_PIXEL_IDX_SZ:c_SQUARE_PIXEL_SHIFT] ] == 1'b1) begin
			o_Red <= c_COLOR_LOW;
			o_Green <= c_COLOR_HIGH;
			o_Blue <= c_COLOR_HIGH;
		end else begin
			o_Red <= c_COLOR_LOW;
			o_Green <= c_COLOR_LOW;
			o_Blue <= c_COLOR_LOW;
		end
	end	

	
	signal_generator_coords
	#( 
		.pol_x(c_VGA_POLARITY_X),
		.pol_y(c_VGA_POLARITY_Y),
		.h_visible_area_end(c_SCREEN_WIDTH),
		.h_front_porch_end(c_FRONT_PORCH_END_H),
		.h_sync_pulse_end(c_SYNC_PULSE_END_H),
		.h_back_porch_end(c_BACK_PORCH_END_H),
		.v_visible_area_end(c_SCREEN_HEIGHT),
		.v_front_porch_end(c_FRONT_PORCH_END_V),
		.v_sync_pulse_end(c_SYNC_PULSE_END_V),
		.v_back_porch_end(c_BACK_PORCH_END_V)
	) vga_signal (
		.i_clk(i_Clk),
		.i_rst(i_Rst),
		.o_h_sync(o_HSync),
		.o_v_sync(o_VSync),
		.o_x(w_Pixel_X),
		.o_y(w_Pixel_Y)
	);

endmodule
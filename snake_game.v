// --------------------------------------------------------------------------
// File : snake_game.v
// 
// Module : snake_game
// Author : Carter Nesbitt
// Created : 12 October 2019
// Modified : 12 October 2019
// 
// Language : Verilog 
// Description : Maintains the logic for the snake game in Verilog.
// --------------------------------------------------------------------------

module snake_game 
	(
		i_Clk,
		i_Rst,
		i_SnakeClk,
		i_Direction,
		i_FoodLocation,
		o_Kill,
		o_Grid,
		o_Food,
		o_Score
	);
	
	// Size of indexing for accessing locations on game grid.
	parameter c_GRID_IDX_SZ = 10;
	
	// Cell width and height of the snake game.
	parameter c_WIDTH = 32;
	parameter c_HEIGHT = 32;
	
	// Specified list on inputs and outputs
	input [c_GRID_IDX_SZ-1:0] i_FoodLocation;
	input i_Clk;
	input i_Rst;
	input i_SnakeClk;
	input [3:0] i_Direction;
	output reg o_Kill;
	output reg o_Grid;
	output reg o_Food;
	output reg o_Score;
	
	localparam [3:0] RIGHT = 4'b0001;
	localparam [3:0] LEFT = 4'b0010;
	localparam [3:0] UP = 4'b0100;
	localparam [3:0] DOWN = 4'b1000;
	
	integer IdxH = 0;
	integer IdxV = 0;
	
	// Counter representing the number of nodes to add to the snake.
	reg [1:0] r_FoodCount = 0;
	reg [c_GRID_IDX_SZ-1:0] r_FoodLocation = 0;
	
	// Center starting snake cell
	reg [c_GRID_IDX_SZ-1:0] r_Head = (c_WIDTH*c_HEIGHT)/2 + c_WIDTH/2;
	reg [c_GRID_IDX_SZ-1:0] r_Tail = (c_WIDTH*c_HEIGHT)/2 + c_WIDTH/2;
	
	// Binary grid representing snake locations
	reg [(c_WIDTH+1)*(c_HEIGHT+1)-1:0] r_SnakeGrid = 0;
	
	// Update the snake grid by moving the tail
	// to the head. Leave the tail if food was recently
	// collected.
	always @(posedge(i_Clk)) begin
		case (i_Direction)
			RIGHT : begin
				r_SnakeGrid[r_Head + 1] <= 1'b1; 		// right
				r_Head <= r_Head + 1;
				end
			LEFT : begin
				r_SnakeGrid[r_Head - 1] <= 1'b1; 		// left
				r_Head <= r_Head - 1;
				end
			UP : begin
				r_SnakeGrid[r_Head + c_WIDTH] <= 1'b1; 	// up
				r_Head <= r_Head + c_WIDTH;
				end
			DOWN : begin
				r_SnakeGrid[r_Head - c_WIDTH] <= 1'b1; 	// down
				r_Head <= r_Head + - c_WIDTH;
				end
			default :
				r_Head <= r_Head; 						// still
		endcase
		
		if (r_FoodCount == 0) begin
			r_SnakeGrid[r_Tail] = 1'b0;
		end else begin
			r_SnakeGrid[r_Tail] = 1'b1;
			r_FoodCount <= r_FoodCount - 1;
			r_Tail <= r_Tail;
		end
		// This will not work effectively
		// TODO: FIFO of direction changes with counter
		// for each entry to remove from FIFO. Represents
		// direction to change the tail of the snake.
		if (r_SnakeGrid[r_Tail + 1] == 1'b1) begin
			r_Tail <= r_Tail + 1;
		end else if (r_SnakeGrid[r_Tail - 1] == 1'b1) begin
			r_Tail <= r_Tail - 1;
		end else if (r_SnakeGrid[r_Tail + c_WIDTH] == 1'b1) begin
			r_Tail <= r_Tail + c_WIDTH;
		end else begin
			r_Tail <= r_Tail - c_WIDTH;
		end
	end


	// Check for snake out of bounds
	// Check for snake overlapping food
	always @* begin
		o_Kill <= 1'b0;
		for (IdxH = 0; IdxH < c_WIDTH; IdxH = IdxH + 1) begin
			if (r_SnakeGrid[IdxH] == 1'b1) begin
				o_Kill <= 1'b1;
			end else if (r_SnakeGrid[c_WIDTH*(c_HEIGHT-1)+IdxH] == 1'b1) begin
				o_Kill <= 1'b1;
			end
		end
		
		for (IdxV = 1; IdxV < c_HEIGHT; IdxV = IdxV + 1) begin
			if (r_SnakeGrid[c_WIDTH*IdxV] == 1'b1) begin
				o_Kill = 1'b1;
			end else if (r_SnakeGrid[(c_WIDTH+1)*IdxV-1] == 1'b1) begin
				o_Kill = 1'b1;
			end
		end
		
		if (r_FoodLocation == r_Head) begin
			r_FoodCount = 'd3;
			r_FoodLocation = i_FoodLocation;
		end
	end
endmodule
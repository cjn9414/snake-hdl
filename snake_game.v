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
		o_SnakeGrid,
		o_Food,
		o_Score
	);
	
	// Size of indexing for accessing locations on game grid.
	parameter c_GRID_IDX_SZ = 10;
	
	// Cell width and height of the snake game.
	parameter c_WIDTH = 32;
	parameter c_HEIGHT = 32;
	parameter SCORE_WIDTH = 14;
	
	// Specified list on inputs and outputs
	input [c_GRID_IDX_SZ-1:0] i_FoodLocation;
	input i_Clk;
	input i_Rst;
	input i_SnakeClk;
	input [3:0] i_Direction;
	output reg o_Kill;
	output reg [(c_WIDTH+1)*(c_HEIGHT+1)-1:0] o_SnakeGrid = 0;
	output reg [c_GRID_IDX_SZ-1:0] o_Food = 0;
	output reg [SCORE_WIDTH-1:0] o_Score = 0;
	
	localparam [3:0] RIGHT = 4'b0001;
	localparam [3:0] LEFT = 4'b0010;
	localparam [3:0] UP = 4'b0100;
	localparam [3:0] DOWN = 4'b1000;
	
	// Indices to check for snake out of bounds
	integer IdxH = 0;
	integer IdxV = 0;
	
	// Counter representing the number of nodes to add to the snake.
	reg [1:0] r_FoodCount = 0;
	
	// Center starting snake cell
	reg [c_GRID_IDX_SZ-1:0] r_Head = (c_WIDTH*c_HEIGHT)/2 + c_WIDTH/2;
	reg [c_GRID_IDX_SZ-1:0] r_Tail = (c_WIDTH*c_HEIGHT)/2 + c_WIDTH/2;
		
	// Update the snake grid by moving the tail
	// to the head. Leave the tail if food was recently
	// collected.
	always @(posedge(i_Clk) or posedge(i_Rst)) begin
		if (i_Rst == 1'b1) begin
			o_SnakeGrid <= 'b0;
			o_Score <= 'b0;
		end else begin
			case (i_Direction)
				RIGHT : begin
					o_SnakeGrid[r_Head + 1] <= 1'b1; 		// right
					r_Head <= r_Head + 1;
					end
				LEFT : begin
					o_SnakeGrid[r_Head - 1] <= 1'b1; 		// left
					r_Head <= r_Head - 1;
					end
				UP : begin
					o_SnakeGrid[r_Head + c_WIDTH] <= 1'b1; 	// up
					r_Head <= r_Head + c_WIDTH;
					end
				DOWN : begin
					o_SnakeGrid[r_Head - c_WIDTH] <= 1'b1; 	// down
					r_Head <= r_Head + - c_WIDTH;
					end
				default :
					r_Head <= r_Head; 						// still
			endcase
			
			if (r_FoodCount == 0) begin
				o_SnakeGrid[r_Tail] <= 1'b0;
			end else begin
				o_SnakeGrid[r_Tail] <= 1'b1;
				r_FoodCount <= r_FoodCount - 1;
			end
			// This will not work effectively
			// TODO: FIFO of direction changes with counter
			// for each entry to remove from FIFO. Represents
			// direction to change the tail of the snake.
			if (o_SnakeGrid[r_Tail + 1] == 1'b1) begin
				r_Tail <= r_Tail + 1;
			end else if (o_SnakeGrid[r_Tail - 1] == 1'b1) begin
				r_Tail <= r_Tail - 1;
			end else if (o_SnakeGrid[r_Tail + c_WIDTH] == 1'b1) begin
				r_Tail <= r_Tail + c_WIDTH;
			end else begin
				r_Tail <= r_Tail - c_WIDTH;
			end
			
			// Check for snake overlapping food
			if (o_Food == r_Head) begin
				o_Score <= o_Score + 1;
				r_FoodCount <= 'd3;
				o_Food <= i_FoodLocation;
			end
		end
	end


	// Check for snake out of bounds
	always @* begin
		o_Kill <= 1'b0;
		for (IdxH = 0; IdxH < c_WIDTH; IdxH = IdxH + 1) begin
			if (o_SnakeGrid[IdxH] == 1'b1) begin
				o_Kill <= 1'b1;
			end else if (o_SnakeGrid[c_WIDTH*(c_HEIGHT-1)+IdxH] == 1'b1) begin
				o_Kill <= 1'b1;
			end
		end
		
		for (IdxV = 1; IdxV < c_HEIGHT; IdxV = IdxV + 1) begin
			if (o_SnakeGrid[c_WIDTH*IdxV] == 1'b1) begin
				o_Kill <= 1'b1;
			end else if (o_SnakeGrid[(c_WIDTH+1)*IdxV-1] == 1'b1) begin
				o_Kill <= 1'b1;
			end
		end
	end
endmodule
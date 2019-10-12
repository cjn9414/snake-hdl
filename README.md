# Snake - Reimagined in VHDL/Verilog

## About
Snake is a classic game existing on a multitude of gaming platforms since its inception in 1976. Since then it has become a very common game to replicate, especially to those who are new to programming. However, this reproduction is generally performed in software. The question I am hoping to answer myself: how easy would Snake be to replicate in hardware?

## Technical Elaboration
The reimagination of Snake in hardware will be performed using a mix of Verilog and VHDL. This is mainly because I want to become more proficient in Verilog, but already have existing modules written in VHDL that will aid in the development of this project.

I have a rough idea going in to this project of how it will be implemented. Here is a quick rundown of some important concepts:

* Assuming a 32x32 grid, create an array of size 33, with each element containing a vector of 33 bits. This block represents a bit for each cell, which may or may not contain a piece of the snake. There is an extra grid around the 32x32 grid which represents the "kill" zone. That is, if any surrounding register gets asserted, then the game is over. Additionally, the game is also over whenever the bit representing the head of the snake attempts to feed into a register which is already asserted. That is, the snake collides with itself.

* Create a dedicated vector of size ten used to represent the cell on the board in which the "food" is stored. This location can be cross referenced with the array of vectors to determine if the snake collides with a food piece.

* Although redundant, create a dedicated vector to represent the tail of the snake. This way, when the snake eats a piece of food, the register storing the tail of the snake can be held high for five steps in order to extend the snake.

* User will use buttons stored on the FPGA board (I am using the Basys-3) to change the direction of the snake.

* VGA monitor will be used to display the snake game. The VGA component has already been developed in VHDL.

* The input clock will align with the required clock speed of the VGA display. This clock speed will then be dropped using an internal counter to create an update clock for the snake game. This clock frequency will be approximately 10Hz.

* Use an LFSR with a width of ten bits that updates with the input clock speed. This will be used to randomly select the location of the next food piece.

* The seven-segment display on the FPGA board will be used to maintain the score of the user.

## Status
This project is just getting started. I can't be sure when I will kick this project into full gear, as I have many active projects. I mainly wanted the notes above documented so that when I get around to pursuing this project I know what can be done. I don't anticipate this project being too much of a time commitment. I would expect it to be operational in maybe a weekend or two of work. This timeframe may change depending on how competent I am with Verilog at the time of start.

## Future
As of right now, I don't expect to continue this project much further than the imagined end result. This is more of a quick and fun project!



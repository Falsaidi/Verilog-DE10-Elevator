// Displays the floor number
module display(num,out);
	input [1:0] num;
	output reg [6:0] out;
	
	always @(num)
	begin
	// Outputs the floor number + 1 to have floors from 1-4
	case(num)
		0: out='b1001111;
		1: out='b0010010;
		2: out='b0000110;
		3: out='b1001100;
	endcase
	end
	
endmodule

// Displays the direction that the elevator is moving
module displaydir(clear,dir,ssd1,ssd0);
	input clear,dir;
	output reg [6:0] ssd1,ssd0;
	
	always @(clear,dir)
	begin
		// Clears the output (used when the elevator isn't moving)
		if(clear) begin
			ssd1 = 'b1111111;
			ssd0 = 'b1111111;
		end
		// If the direction is up, display "up" on the SSDs
		else if(dir) begin
			ssd1 = 'b1000001;
			ssd0 = 'b0011000;
		end
		// If the direction is down, display "dn" on the SSDs
		else begin
			ssd1 = 'b1000010;
			ssd0 = 'b1101010;
		end
	end
endmodule

// Displays the current state of the elevator doors
module displaydoor(open,door1,door0);
	input open;
	output reg [6:0] door1,door0;
	
	always @(open)
	begin
		// If the door is open, display the doors as apart
		if(open) begin
			door1 = 'b1111001;
			door0 = 'b1001111;
		end
		// If the door is closed, display the doors as together
		else begin
			door1 = 'b1001111;
			door0 = 'b1111001;
		end
	end
endmodule

// Generates a clock that ticks every second
module slowclock(clkin,slowclk);
	input clkin;
	output reg slowclk;
	
	// Number of ticks needed from the 50MHz clock to generate a second-long clock
	integer second = 25_000_000;
	
	integer counter;
	
	always @(posedge clkin)
	begin
		// Resets the counter if it reaches 25 million and ticks the slow clock
		if(counter == second) begin
			slowclk = ~slowclk;
			counter <= 0;
		end
		// For long as the counter is less than 25 million, increase it by one every tick
		else counter <= counter + 1;
	end
endmodule

module project(currFloor,displayFloor,newFloor,displayNewFloor,move,clk,direction1,direction0,door1,door0);
	// On-board inputs
	input move,clk;
	input [1:0] newFloor;
	
	// Output for the current floor
	output reg [1:0] currFloor;
	
	// SSD Outputs
	output [6:0] displayFloor;
	output [6:0] displayNewFloor;
	output [6:0] direction1;
	output [6:0] direction0;
	output [6:0] door1;
	output [6:0] door0;
	
	// Internal variables (neither inputs nor outputs)
	reg [1:0] tempFloor;  // Stores the floor to be moved to (so the elevator is locked in to move to that floor once the button is pressed)
	reg direction,clear,open;
	wire slowclk;
	
	// Generates the clock movement
	slowclock clock(clk,slowclk);
	
	// Displays the direction of the elevator (if it's moving)
	// and displays the doors to show them open/closed
	displaydir(clear,direction,direction1,direction0);
	displaydoor(open,door1,door0);
	
	// Displays the current floor and the floor to move to
	display show1(currFloor,displayFloor);
	display show2(newFloor,displayNewFloor);
	
	// When the button is pressed to move the elevator, lock in the new floor
	always @(posedge move)
	begin
		tempFloor = newFloor;
	end
	
	always @(posedge slowclk)
	begin
		// Checks to see if the floor to move to is different from the current floor
		if(tempFloor != currFloor) begin
			open = 0;  // Closes the doors
			
			// If the new floor is higher than the current floor,
			// display the direction as "up" and increase the current floor
			if(tempFloor > currFloor) begin
				currFloor = currFloor + 1;
				direction = 1;
				clear = 0;
			end
			
			// If the new floor is lower than the current floor,
			// display the direction as "dn" (for down) and decrease the current floor
			else begin
				currFloor = currFloor - 1;
				direction = 0;
				clear = 0;
			end
		end
		
		// Clears the signal for moving the elevator and opens the door
		// (Only runs when the elevator reached its new floor)
		else begin
			clear = 1;
			open = 1;
		end
	end
endmodule
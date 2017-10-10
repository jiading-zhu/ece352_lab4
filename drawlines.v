/* drawlines.v
 *
 * Top level entity for the drawlines circuits.
 * Inputs:
 * - SW[8:0] - a value for X or Y coordinate. Should be between 0 and 319 for X and 0 to 239 for Y.
 * - SW[9] 	 - specify if X or Y is beign entered (0 for X and 1 for Y)
 * - KEY[2]  - press to signal that the new point is now ready (GO).
 * - KEY[1]  - press to store the X or Y coordinate of the new point.
 * - KEY[0]  - asynchronous reset. Press the button to reset the system.
 * Outputs:
 * - lines display on a monitor
 * - LEDR[9] is lit up when new point can be entered.
 */

module drawlines(
			SW,
			CLOCK_50,
			LEDR,
			KEY,
			VGA_R,
			VGA_G,
			VGA_B,
			VGA_HS,
			VGA_VS,
			VGA_BLANK,
			VGA_SYNC,
			VGA_CLK);
	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
	output [9:0] LEDR;
	output [9:0] VGA_R;
	output [9:0] VGA_G;
	output [9:0] VGA_B;
	output	VGA_HS,
			VGA_VS,
			VGA_BLANK,
			VGA_SYNC,
			VGA_CLK;		
			
	/* Local wires to connect modules together */
	//INPUTS
	wire       resetN, go;
	wire       XorY_sel, XorY_store;
	wire [8:0] XorY_val;
	wire [2:0] colour;
	assign resetN     = KEY[0];
	assign XorY_store = KEY[1];
	assign go         = KEY[2];
	assign XorY_val   = SW[8:0];
	assign XorY_sel   = SW[9];
	assign colour     = 3'b101;
	//UI <--> LDA
	wire       line_go, line_done;
	wire [8:0] X_0, X_1;
	wire [7:0] Y_0, Y_1;
	//LDA <--> VGA
	wire [8:0] to_VGA_x;
	wire [7:0] to_VGA_y;
	wire       to_VGA_plot;
	
	vga_adapter VGA(
				.resetn(resetN),
				.clock(CLOCK_50),
				.colour(colour),
				.x(to_VGA_x),
				.y(to_VGA_y),
				.plot(to_VGA_plot),
				.VGA_R(VGA_R),
				.VGA_G(VGA_G),
				.VGA_B(VGA_B),
				.VGA_HS(VGA_HS),
				.VGA_VS(VGA_VS),
				.VGA_BLANK(VGA_BLANK),
				.VGA_SYNC(VGA_SYNC),
				.VGA_CLK(VGA_CLK));
			defparam VGA.RESOLUTION = "320x240";				
			defparam VGA.MONOCHROME = "FALSE";
			defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;	
			defparam VGA.BACKGROUND_IMAGE = "background.mif";

	/* Line algorithm FSM */
	
	LDA system_lda (x_0, x_1, y_0, y_1, CLOCK_50, line_go, line_done);
	
	
	
	/* User interface */
	
	ui system_ui (CLOCK_50, resetN, XorY_store, go, line_done,
					  XorY_sel, XorY_val, x_0, y_0, x_1, y_1, line_go, LEDR[0]);
	

	/* Circuit outputs. */
	
	
endmodule
		

module ui(CLOCK_50,
			 aresetN,
			 store,
			 update,
			 lda_ready,
			 x_or_y,
			 number_in,
			 x_start,
			 y_start,
			 x_end,
			 y_end,
			 start,
			 ready_led
			 );
			 
	input CLOCK_50;
	input aresetN;
	input store;
	input update;
	input lda_ready;
	input x_or_y;
	input number_in;
	output [8:0] x_start, x_end;
	output [7:0] y_start, y_end;
	output start, ready_led;

	reg [5:0] ui_state;
	reg start_r;
	reg led_r;
	
	reg [8:0] xs_r, xe_r;
	reg [7:0] ys_r, ye_r;
	
	parameter 
				 STRT    = 6'b000000,
				 STORE_X = 6'b000001,
				 STORE_Y = 6'b000010,
				 IDLE    = 6'b000100,
				 UPDATE_V= 6'b001000,
				 MOV_STRT= 6'b010000;
				
	always @ (posedge CLOCK_50 or negedge aresetN) begin	
	
		if (!aresetN) begin
			ui_state <= STRT;
			xs_r <= 9'b000000000;
			xe_r <= 9'b000000000;
			ys_r <= 8'b00000000;
			ye_r <= 8'b00000000;
			end
		else begin
			case (ui_state)
			
				STRT: begin
					xs_r <= 9'b000000000;
					xe_r <= 9'b000000000;
					ys_r <= 8'b00000000;
					ye_r <= 8'b00000000;
					
					if (store && ~x_or_y) begin
						ui_state <= STORE_X; end
					if (store && x_or_y) begin
						ui_state <= STORE_Y; end
					else begin
						ui_state <= STRT;end 
						end
				
				STORE_X: begin
					xe_r <= number_in;
					ui_state <= IDLE;
					end
				
				STORE_Y: begin
					ye_r <= number_in;
					ui_state <= IDLE; end
					
				IDLE:begin
					if (store && ~x_or_y) begin
						ui_state <= STORE_X; end
					if (store && x_or_y) begin
						ui_state <= STORE_Y; end
						
					if (~store && update) begin
						ui_state <= UPDATE_V; end
					else begin
						ui_state <= IDLE;end  end
						
				UPDATE_V:begin 
					if (lda_ready) begin
						ui_state <= MOV_STRT; end
					else begin
						ui_state <= UPDATE_V; end
						end
				
				MOV_STRT: begin
					xs_r <= xe_r;
					ys_r <= ye_r;
					ui_state <= IDLE;
							end
				endcase
				
			end
						
			
	
	end
	
	
	always @ (*) begin
	
		case(ui_state)
		
			STRT:begin
				led_r = 1;
				start_r = 0; end
			STORE_Y:begin
				led_r = 0;
				start_r = 0;end
			STORE_X:begin
				led_r = 0;
				start_r = 0;end
			IDLE:begin
				led_r = 1;
				start_r = 0;end
			UPDATE_V: begin
				start_r = 1;
				led_r = 0;end
			MOV_STRT: begin
				start_r = 0;
				led_r = 0;end
				
		
		endcase
	
	end
	
	assign x_start = xs_r;
	assign x_end = xe_r;
	assign y_start = ys_r;
	assign y_end = ye_r;
	assign ready_led = led_r;
	assign start = start_r;
	
endmodule 
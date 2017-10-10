module LDA(input1,input2,input3,input4,clk,colour,start,done,to_VGA_plot,to_VGA_x,to_VGA_y);
	input [8:0] input1, input3;
	input [7:0] input2, input4;
	input clk;
	input colour;
	input start;
	output done, to_VGA_plot;
	output [8:0] to_VGA_x;
	output [7:0] to_VGA_y;
	
	reg [8:0] X0, X1, x, x_plot;
	reg [7:0] Y0, Y1;
	reg [8:0] error, deltax;
	reg [7:0] deltay, y, y_plot;
	reg [1:0] steep, ystep;
	reg [3:0] cur_st, next_st;
	
	initial begin
	
		X0 = input1;
		Y0 = input2;
		X1 = input3;
		Y1 = input4;
		deltay = ((Y1-Y0)<8'b0)?(Y0-Y1):(Y1-Y0);
		deltax = ((X1-X0)<9'b0)?(X0-X1):(X1-X0);
		steep = (deltay>deltax)?1:0;
	
		deltax = X1 - X0;
		error = deltax >> 1;
		y = Y0;
		ystep = (Y0<Y1)?1:(-1);
		x = X0;
	
	end
	
	parameter A=4'b0000, B=4'b0001, C=4'b0010, D=4'b0011, E=4'b0100, F=4'b0101, G=4'b0110, H=4'b0111, I=4'b1000, J=4'b1001;
	
	always@ (cur_st)
	begin
		case(cur_st)
			A: begin
				if (steep == 1)
				begin
					X0<=Y0;
					Y0<=X0;
					X1<=Y1;
					Y1<=X1;
				end
				else
					X0<=X0;
				next_st = B;
			end
			
			B:	begin
				if (X0>X1)
				begin
					X0<=X1;
					X1<=X0;
					Y0<=Y1;
					Y1<=Y0;
				end
				else
					X0<=X0;
				next_st = C;
			end
			
			C: if (x<=X1)
					next_st = E;
				else
					next_st = D;
					
			D: next_st = D;
			
			E: if (steep == 1)
					next_st = F;
				else
					next_st = G;
			
			F:	begin
					next_st = H;
				end
				
			G:	begin
					next_st = H;
				end
			
			H:	begin
				error <= error + deltay;
				if (error>0)
					next_st = I;
				else
					next_st = J;
			end
			
			I:	begin
				y <= y + ystep;
				error <= error - deltax;
				next_st = J;
			end
			
			J: begin
				x <= x+1;
				next_st = C;
			end
			
			default: next_st = A;
		endcase
	end
	
	always@(posedge clk)
		if (!start)
			cur_st <=A;
		else
			cur_st <=next_st;
			
	assign done = (cur_st == D);
	assign to_VGA_x = (cur_st == F)?(y):(x);
	assign to_VGA_y = (cur_st == F)?(x):(y);
	assign to_VGA_plot = ((cur_st == F)|(cur_st == G))?1:0;
		
endmodule

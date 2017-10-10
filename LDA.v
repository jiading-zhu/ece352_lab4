module LDA(X0,Y0,X1,Y1,clk,colour,start,done);
	input [8:0] X0, X1;
	input [7:0] Y0, Y1;
	input clk;
	input colour;
	input start;
	output done;
	
	wire steep;
	wire [8:0] error, deltax, deltax1;
	wire [7:0] deltay, y;
	wire [1:0] ystep;
	
	assign deltay = ((Y1-Y0)<8'b0)?(Y0-Y1):(Y1-Y0);
	assign deltax = ((X1-X0)<9'b0)?(X0-X1):(X1-X0);
	assign steep = (deltay>deltax)?1:0;
	
	assign deltax1 = X1 - X0;
	assign error = deltax1 >> 1;
	assign y = Y0;
	assign ystep = (Y0<Y1)?1:(-1);
	
	always@ (posedge start)
	begin
		if (steep == 1)
		begin
			X0<=Y0;
			Y0<=X0;
			X1<=Y1;
			Y1<=X1;
		end
		
		if (X0>X1)
		begin
			X0<=X1;
			X1<=X0;
			Y0<=Y1;
			Y1<=Y0;
		end
	end
	
	generate
	genvar x;
	
	for (x=X0; x<=X1; x = x+1)	begin: test
		always @(posedge start)
		begin
			if (steep == 1)
				vga_adapter vga(1,clk,colour,y,x,1,1,0,1,1,1,1,1,1);	//I have no idea what I'm doing
			else
				vga_adapter vga(1,clk,colour,x,y,1,1,0,1,1,1,1,1,1);
				
			error <= error + deltay;
			
			if (error>0)
			begin
				y <= y + ystep;
				error <= error - deltax1;
			end
			if (x == X1)
				done <= 1;
			else
				done <= 0;
		end
	end
	endgenerate
		
endmodule
	
	
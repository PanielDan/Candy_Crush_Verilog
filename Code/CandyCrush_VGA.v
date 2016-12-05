`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Mackenzie Collins/Danny Pan
//////////////////////////////////////////////////////////////////////////////////
module CandyCrush_VGA(ClkPort, vga_h_sync, vga_v_sync, red, green, blue, Sw0, Sw1,
	btnU, btnD, btnC, btnL, btnR,
	St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7);
	
	input ClkPort, Sw0, btnU, btnD, btnC, btnL, btnR, Sw0, Sw1;
	//input reg [3:0] color;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	output reg [2:0] red, green;
	output reg [1:0] blue;
	wire BtnU_Pulse, BtnD_Pulse, BtnC_Pulse, BtnL_Pulse, BtnR_Pulse;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*  LOCAL SIGNALS */
	wire	reset, start, ClkPort, board_clk, clk, button_clk;
	
	BUF BUF1 (board_clk, ClkPort); 	
	BUF BUF2 (reset, Sw0);
	BUF BUF3 (start, Sw1);
	
	reg [27:0]	DIV_CLK;
	always @ (posedge board_clk, posedge reset)  
	begin : CLOCK_DIVIDER
      if (reset)
			DIV_CLK <= 0;
      else
			DIV_CLK <= DIV_CLK + 1'b1;
	end	

	assign	button_clk = DIV_CLK[18];
	assign	clk = DIV_CLK[1];
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b11111};
	
	
	ee201_debouncer #(.N_dc(28)) ee201_debouncer_L 
        (.CLK(board_clk), .RESET(reset), .PB(btnL), .DPB( ), 
		.SCEN(BtnL_Pulse), .MCEN( ), .CCEN( ));
	
	ee201_debouncer #(.N_dc(28)) ee201_debouncer_R 
        (.CLK(board_clk), .RESET(reset), .PB(btnR), .DPB( ), 
		.SCEN(BtnR_Pulse), .MCEN( ), .CCEN( ));
		
	ee201_debouncer #(.N_dc(28)) ee201_debouncer_C 
        (.CLK(board_clk), .RESET(reset), .PB(btnC), .DPB( ), 
		.SCEN(BtnC_Pulse), .MCEN( ), .CCEN( ));
		
	ee201_debouncer #(.N_dc(28)) ee201_debouncer_U 
        (.CLK(board_clk), .RESET(reset), .PB(btnU), .DPB( ), 
		.SCEN(BtnU_Pulse), .MCEN( ), .CCEN( ));
	
	ee201_debouncer #(.N_dc(28)) ee201_debouncer_D 
        (.CLK(board_clk), .RESET(reset), .PB(btnD), .DPB( ), 
		.SCEN(BtnD_Pulse), .MCEN( ), .CCEN( ));
	
	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [9:0] CounterY;

	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
			
	wire marker = (((CounterX >= ((50*(X+1))+ 12) ) && (CounterX < ((50*(X+1))+ 38))) &&
						((CounterY >= ((50*(Y+1))+ 12) ) && (CounterY < ((50*(Y+1))+ 38))));
	//wire Ax, Bx, Cx, Dx, Ex, Fx, Gx, Hx, Ay, By, Cy, Dy, Ey, Fy, Gy, Hy;
	wire xArray[7:0];	
	assign xArray[0] = CounterX>=51 && CounterX<101;
	assign xArray[1] = CounterX>=101 && CounterX<151;
	assign xArray[2] = CounterX>=151 &&	CounterX<201;
	assign xArray[3] = CounterX>=201 && CounterX<251;
	assign xArray[4] = CounterX>=251 && CounterX<301;
	assign xArray[5] = CounterX>=301 && CounterX<351;
	assign xArray[6] = CounterX>=351 && CounterX<401;
	assign xArray[7] = CounterX>=401 && CounterX<451;
	
	wire yArray [7:0];
	assign yArray[0] = CounterY>=51 && CounterY<101;
	assign yArray[1] = CounterY>=101 && CounterY<151;
	assign yArray[2] = CounterY>=151 && CounterY<201;
	assign yArray[3] = CounterY>=201 && CounterY<251;
	assign yArray[4] = CounterY>=251 && CounterY<301;
	assign yArray[5] = CounterY>=301 && CounterY<351;
	assign yArray[6] = CounterY>=351 && CounterY<401;
	assign yArray[7] = CounterY>=401 && CounterY<451;
	
	reg[7:0] color[8:0];

	initial
	begin: intializeColors
		color[0] = 8'b10000000; // black
		color[1] = 8'b10011101; // green
		color[2] = 8'b11100100; // burnt orange
		color[3] = 8'b11110111; // lavender/pink
		color[4] = 8'b01000010; // purple
		color[5] = 8'b11101100;	// organge
		color[6] = 8'b00011111; // cyan
		color[7] = 8'b00000111; // blue
		color[8] = 8'b11101001; // salmon
	end
	
	//	RGB CHART
//		r2	r1	r0	g2	g1	g0	b1	b0
//	A	1	0	0	1	1	1	0	1	green
//	B	1	1	1	0	0	1	0	0	burnt orange
//	C	1	1	1	1	0	1	1	1	lavender
//	D	0	1	0	0	0	0	1	0	purple
//	E	1	1	1	0	1	1	0	0	orange
//	F	0	0	0	1	1	1	1	1	cyan
//	G	0	0	0	0	0	1	1	1	blue
//	H	1	1	1	0	1	0	0	1	salmon
	
	//Game Board Variables
	reg displayFlag;
	
	//Color Display Loop
	always @(posedge board_clk)
	begin
		//display colors
		if (reset)
		begin
			red[0] = 0;
			red[1] = 0;
			red[2] = 0;
			green[0] = 0;
			green[1] = 0;
			green[2] = 0;
			blue[1] = 0;
			blue[0] = 0;
		end
		else if(displayFlag)
		begin
			//Gotta hard code 512 Statements

			red[0] =  (
			(color[Grid[0][0]][7] & xArray[0] & yArray[0]) | 
			(color[Grid[0][1]][7] & xArray[0] & yArray[1]) | 
			(color[Grid[0][2]][7] & xArray[0] & yArray[2]) |
			(color[Grid[0][3]][7] & xArray[0] & yArray[3]) |
			(color[Grid[0][4]][7] & xArray[0] & yArray[4]) |
			(color[Grid[0][5]][7] & xArray[0] & yArray[5]) |
			(color[Grid[0][6]][7] & xArray[0] & yArray[6]) |
			(color[Grid[0][7]][7] & xArray[0] & yArray[7]) |
			(color[Grid[1][0]][7] & xArray[1] & yArray[0]) |
			(color[Grid[1][1]][7] & xArray[1] & yArray[1]) |
			(color[Grid[1][2]][7] & xArray[1] & yArray[2]) |
			(color[Grid[1][3]][7] & xArray[1] & yArray[3]) |
			(color[Grid[1][4]][7] & xArray[1] & yArray[4]) |
			(color[Grid[1][5]][7] & xArray[1] & yArray[5]) |
			(color[Grid[1][6]][7] & xArray[1] & yArray[6]) |
			(color[Grid[1][7]][7] & xArray[1] & yArray[7]) |
			(color[Grid[2][0]][7] & xArray[2] & yArray[0]) |
			(color[Grid[2][1]][7] & xArray[2] & yArray[1]) |
			(color[Grid[2][2]][7] & xArray[2] & yArray[2]) |
			(color[Grid[2][3]][7] & xArray[2] & yArray[3]) |
			(color[Grid[2][4]][7] & xArray[2] & yArray[4]) |
			(color[Grid[2][5]][7] & xArray[2] & yArray[5]) |
			(color[Grid[2][6]][7] & xArray[2] & yArray[6]) |
			(color[Grid[2][7]][7] & xArray[2] & yArray[7]) |
			(color[Grid[3][0]][7] & xArray[3] & yArray[0]) |
			(color[Grid[3][1]][7] & xArray[3] & yArray[1]) |
			(color[Grid[3][2]][7] & xArray[3] & yArray[2]) |
			(color[Grid[3][3]][7] & xArray[3] & yArray[3]) |
			(color[Grid[3][4]][7] & xArray[3] & yArray[4]) |
			(color[Grid[3][5]][7] & xArray[3] & yArray[5]) |
			(color[Grid[3][6]][7] & xArray[3] & yArray[6]) |
			(color[Grid[3][7]][7] & xArray[3] & yArray[7]) |
			(color[Grid[4][0]][7] & xArray[4] & yArray[0]) | 
			(color[Grid[4][1]][7] & xArray[4] & yArray[1]) |
			(color[Grid[4][2]][7] & xArray[4] & yArray[2]) |
			(color[Grid[4][3]][7] & xArray[4] & yArray[3]) |
			(color[Grid[4][4]][7] & xArray[4] & yArray[4]) |
			(color[Grid[4][5]][7] & xArray[4] & yArray[5]) |
			(color[Grid[4][6]][7] & xArray[4] & yArray[6]) |
			(color[Grid[4][7]][7] & xArray[4] & yArray[7]) |
			(color[Grid[5][0]][7] & xArray[5] & yArray[0]) | 
			(color[Grid[5][1]][7] & xArray[5] & yArray[1]) |
			(color[Grid[5][2]][7] & xArray[5] & yArray[2]) |
			(color[Grid[5][3]][7] & xArray[5] & yArray[3]) |
			(color[Grid[5][4]][7] & xArray[5] & yArray[4]) |
			(color[Grid[5][5]][7] & xArray[5] & yArray[5]) |
			(color[Grid[5][6]][7] & xArray[5] & yArray[6]) |
			(color[Grid[5][7]][7] & xArray[5] & yArray[7]) |
			(color[Grid[6][0]][7] & xArray[6] & yArray[0]) | 
			(color[Grid[6][1]][7] & xArray[6] & yArray[1]) |
			(color[Grid[6][2]][7] & xArray[6] & yArray[2]) |
			(color[Grid[6][3]][7] & xArray[6] & yArray[3]) |
			(color[Grid[6][4]][7] & xArray[6] & yArray[4]) |
			(color[Grid[6][5]][7] & xArray[6] & yArray[5]) |
			(color[Grid[6][6]][7] & xArray[6] & yArray[6]) |
			(color[Grid[6][7]][7] & xArray[6] & yArray[7]) |
			(color[Grid[7][0]][7] & xArray[7] & yArray[0]) | 
			(color[Grid[7][1]][7] & xArray[7] & yArray[1]) |
			(color[Grid[7][2]][7] & xArray[7] & yArray[2]) |
			(color[Grid[7][3]][7] & xArray[7] & yArray[3]) |
			(color[Grid[7][4]][7] & xArray[7] & yArray[4]) |
			(color[Grid[7][5]][7] & xArray[7] & yArray[5]) |
			(color[Grid[7][6]][7] & xArray[7] & yArray[6]) |
			(color[Grid[7][7]][7] & xArray[7] & yArray[7]) 
			) & inDisplayArea & !marker;
			
			red[1] = (
			(color[Grid[0][0]][6] & xArray[0] & yArray[0]) | 
			(color[Grid[0][1]][6] & xArray[0] & yArray[1]) |
			(color[Grid[0][2]][6] & xArray[0] & yArray[2]) |
			(color[Grid[0][3]][6] & xArray[0] & yArray[3]) |
			(color[Grid[0][4]][6] & xArray[0] & yArray[4]) |
			(color[Grid[0][5]][6] & xArray[0] & yArray[5]) |
			(color[Grid[0][6]][6] & xArray[0] & yArray[6]) |
			(color[Grid[0][7]][6] & xArray[0] & yArray[7]) |
			(color[Grid[1][0]][6] & xArray[1] & yArray[0]) |
			(color[Grid[1][1]][6] & xArray[1] & yArray[1]) |
			(color[Grid[1][2]][6] & xArray[1] & yArray[2]) |
			(color[Grid[1][3]][6] & xArray[1] & yArray[3]) |
			(color[Grid[1][4]][6] & xArray[1] & yArray[4]) |
			(color[Grid[1][5]][6] & xArray[1] & yArray[5]) |
			(color[Grid[1][6]][6] & xArray[1] & yArray[6]) |
			(color[Grid[1][7]][6] & xArray[1] & yArray[7]) |
			(color[Grid[2][0]][6] & xArray[2] & yArray[0]) |
			(color[Grid[2][1]][6] & xArray[2] & yArray[1]) |
			(color[Grid[2][2]][6] & xArray[2] & yArray[2]) |
			(color[Grid[2][3]][6] & xArray[2] & yArray[3]) |
			(color[Grid[2][4]][6] & xArray[2] & yArray[4]) |
			(color[Grid[2][5]][6] & xArray[2] & yArray[5]) |
			(color[Grid[2][6]][6] & xArray[2] & yArray[6]) |
			(color[Grid[2][7]][6] & xArray[2] & yArray[7]) |
			(color[Grid[3][0]][6] & xArray[3] & yArray[0]) |
			(color[Grid[3][1]][6] & xArray[3] & yArray[1]) |
			(color[Grid[3][2]][6] & xArray[3] & yArray[2]) |
			(color[Grid[3][3]][6] & xArray[3] & yArray[3]) |
			(color[Grid[3][4]][6] & xArray[3] & yArray[4]) |
			(color[Grid[3][5]][6] & xArray[3] & yArray[5]) |
			(color[Grid[3][6]][6] & xArray[3] & yArray[6]) |
			(color[Grid[3][7]][6] & xArray[3] & yArray[7]) |
			(color[Grid[4][0]][6] & xArray[4] & yArray[0]) | 
			(color[Grid[4][1]][6] & xArray[4] & yArray[1]) |
			(color[Grid[4][2]][6] & xArray[4] & yArray[2]) |
			(color[Grid[4][3]][6] & xArray[4] & yArray[3]) |
			(color[Grid[4][4]][6] & xArray[4] & yArray[4]) |
			(color[Grid[4][5]][6] & xArray[4] & yArray[5]) |
			(color[Grid[4][6]][6] & xArray[4] & yArray[6]) |
			(color[Grid[4][7]][6] & xArray[4] & yArray[7]) |
			(color[Grid[5][0]][6] & xArray[5] & yArray[0]) | 
			(color[Grid[5][1]][6] & xArray[5] & yArray[1]) |
			(color[Grid[5][2]][6] & xArray[5] & yArray[2]) |
			(color[Grid[5][3]][6] & xArray[5] & yArray[3]) |
			(color[Grid[5][4]][6] & xArray[5] & yArray[4]) |
			(color[Grid[5][5]][6] & xArray[5] & yArray[5]) |
			(color[Grid[5][6]][6] & xArray[5] & yArray[6]) |
			(color[Grid[5][7]][6] & xArray[5] & yArray[7]) |
			(color[Grid[6][0]][6] & xArray[6] & yArray[0]) | 
			(color[Grid[6][1]][6] & xArray[6] & yArray[1]) |
			(color[Grid[6][2]][6] & xArray[6] & yArray[2]) |
			(color[Grid[6][3]][6] & xArray[6] & yArray[3]) |
			(color[Grid[6][4]][6] & xArray[6] & yArray[4]) |
			(color[Grid[6][5]][6] & xArray[6] & yArray[5]) |
			(color[Grid[6][6]][6] & xArray[6] & yArray[6]) |
			(color[Grid[6][7]][6] & xArray[6] & yArray[7]) |
			(color[Grid[7][0]][6] & xArray[7] & yArray[0]) | 
			(color[Grid[7][1]][6] & xArray[7] & yArray[1]) |
			(color[Grid[7][2]][6] & xArray[7] & yArray[2]) |
			(color[Grid[7][3]][6] & xArray[7] & yArray[3]) |
			(color[Grid[7][4]][6] & xArray[7] & yArray[4]) |
			(color[Grid[7][5]][6] & xArray[7] & yArray[5]) |
			(color[Grid[7][6]][6] & xArray[7] & yArray[6]) |
			(color[Grid[7][7]][6] & xArray[7] & yArray[7]) 
			) & inDisplayArea & !marker;
			
			red[2] = (
			(color[Grid[0][0]][5] & xArray[0] & yArray[0]) | 
			(color[Grid[0][1]][5] & xArray[0] & yArray[1]) |
			(color[Grid[0][2]][5] & xArray[0] & yArray[2]) |
			(color[Grid[0][3]][5] & xArray[0] & yArray[3]) |
			(color[Grid[0][4]][5] & xArray[0] & yArray[4]) |
			(color[Grid[0][5]][5] & xArray[0] & yArray[5]) |
			(color[Grid[0][6]][5] & xArray[0] & yArray[6]) |
			(color[Grid[0][7]][5] & xArray[0] & yArray[7]) |
			(color[Grid[1][0]][5] & xArray[1] & yArray[0]) |
			(color[Grid[1][1]][5] & xArray[1] & yArray[1]) |
			(color[Grid[1][2]][5] & xArray[1] & yArray[2]) |
			(color[Grid[1][3]][5] & xArray[1] & yArray[3]) |
			(color[Grid[1][4]][5] & xArray[1] & yArray[4]) |
			(color[Grid[1][5]][5] & xArray[1] & yArray[5]) |
			(color[Grid[1][6]][5] & xArray[1] & yArray[6]) |
			(color[Grid[1][7]][5] & xArray[1] & yArray[7]) |
			(color[Grid[2][0]][5] & xArray[2] & yArray[0]) |
			(color[Grid[2][1]][5] & xArray[2] & yArray[1]) |
			(color[Grid[2][2]][5] & xArray[2] & yArray[2]) |
			(color[Grid[2][3]][5] & xArray[2] & yArray[3]) |
			(color[Grid[2][4]][5] & xArray[2] & yArray[4]) |
			(color[Grid[2][5]][5] & xArray[2] & yArray[5]) |
			(color[Grid[2][6]][5] & xArray[2] & yArray[6]) |
			(color[Grid[2][7]][5] & xArray[2] & yArray[7]) |
			(color[Grid[3][0]][5] & xArray[3] & yArray[0]) |
			(color[Grid[3][1]][5] & xArray[3] & yArray[1]) |
			(color[Grid[3][2]][5] & xArray[3] & yArray[2]) |
			(color[Grid[3][3]][5] & xArray[3] & yArray[3]) |
			(color[Grid[3][4]][5] & xArray[3] & yArray[4]) |
			(color[Grid[3][5]][5] & xArray[3] & yArray[5]) |
			(color[Grid[3][6]][5] & xArray[3] & yArray[6]) |
			(color[Grid[3][7]][5] & xArray[3] & yArray[7]) |
			(color[Grid[4][0]][5] & xArray[4] & yArray[0]) | 
			(color[Grid[4][1]][5] & xArray[4] & yArray[1]) |
			(color[Grid[4][2]][5] & xArray[4] & yArray[2]) |
			(color[Grid[4][3]][5] & xArray[4] & yArray[3]) |
			(color[Grid[4][4]][5] & xArray[4] & yArray[4]) |
			(color[Grid[4][5]][5] & xArray[4] & yArray[5]) |
			(color[Grid[4][6]][5] & xArray[4] & yArray[6]) |
			(color[Grid[4][7]][5] & xArray[4] & yArray[7]) |
			(color[Grid[5][0]][5] & xArray[5] & yArray[0]) | 
			(color[Grid[5][1]][5] & xArray[5] & yArray[1]) |
			(color[Grid[5][2]][5] & xArray[5] & yArray[2]) |
			(color[Grid[5][3]][5] & xArray[5] & yArray[3]) |
			(color[Grid[5][4]][5] & xArray[5] & yArray[4]) |
			(color[Grid[5][5]][5] & xArray[5] & yArray[5]) |
			(color[Grid[5][6]][5] & xArray[5] & yArray[6]) |
			(color[Grid[5][7]][5] & xArray[5] & yArray[7]) |
			(color[Grid[6][0]][5] & xArray[6] & yArray[0]) | 
			(color[Grid[6][1]][5] & xArray[6] & yArray[1]) |
			(color[Grid[6][2]][5] & xArray[6] & yArray[2]) |
			(color[Grid[6][3]][5] & xArray[6] & yArray[3]) |
			(color[Grid[6][4]][5] & xArray[6] & yArray[4]) |
			(color[Grid[6][5]][5] & xArray[6] & yArray[5]) |
			(color[Grid[6][6]][5] & xArray[6] & yArray[6]) |
			(color[Grid[6][7]][5] & xArray[6] & yArray[7]) |
			(color[Grid[7][0]][5] & xArray[7] & yArray[0]) | 
			(color[Grid[7][1]][5] & xArray[7] & yArray[1]) |
			(color[Grid[7][2]][5] & xArray[7] & yArray[2]) |
			(color[Grid[7][3]][5] & xArray[7] & yArray[3]) |
			(color[Grid[7][4]][5] & xArray[7] & yArray[4]) |
			(color[Grid[7][5]][5] & xArray[7] & yArray[5]) |
			(color[Grid[7][6]][5] & xArray[7] & yArray[6]) |
			(color[Grid[7][7]][5] & xArray[7] & yArray[7]) 
			) & inDisplayArea  & !marker;
			
			green[0] = (
			(color[Grid[0][0]][4] & xArray[0] & yArray[0]) | 
			(color[Grid[0][1]][4] & xArray[0] & yArray[1]) |
			(color[Grid[0][2]][4] & xArray[0] & yArray[2]) |
			(color[Grid[0][3]][4] & xArray[0] & yArray[3]) |
			(color[Grid[0][4]][4] & xArray[0] & yArray[4]) |
			(color[Grid[0][5]][4] & xArray[0] & yArray[5]) |
			(color[Grid[0][6]][4] & xArray[0] & yArray[6]) |
			(color[Grid[0][7]][4] & xArray[0] & yArray[7]) |
			(color[Grid[1][0]][4] & xArray[1] & yArray[0]) |
			(color[Grid[1][1]][4] & xArray[1] & yArray[1]) |
			(color[Grid[1][2]][4] & xArray[1] & yArray[2]) |
			(color[Grid[1][3]][4] & xArray[1] & yArray[3]) |
			(color[Grid[1][4]][4] & xArray[1] & yArray[4]) |
			(color[Grid[1][5]][4] & xArray[1] & yArray[5]) |
			(color[Grid[1][6]][4] & xArray[1] & yArray[6]) |
			(color[Grid[1][7]][4] & xArray[1] & yArray[7]) |
			(color[Grid[2][0]][4] & xArray[2] & yArray[0]) |
			(color[Grid[2][1]][4] & xArray[2] & yArray[1]) |
			(color[Grid[2][2]][4] & xArray[2] & yArray[2]) |
			(color[Grid[2][3]][4] & xArray[2] & yArray[3]) |
			(color[Grid[2][4]][4] & xArray[2] & yArray[4]) |
			(color[Grid[2][5]][4] & xArray[2] & yArray[5]) |
			(color[Grid[2][6]][4] & xArray[2] & yArray[6]) |
			(color[Grid[2][7]][4] & xArray[2] & yArray[7]) |
			(color[Grid[3][0]][4] & xArray[3] & yArray[0]) |
			(color[Grid[3][1]][4] & xArray[3] & yArray[1]) |
			(color[Grid[3][2]][4] & xArray[3] & yArray[2]) |
			(color[Grid[3][3]][4] & xArray[3] & yArray[3]) |
			(color[Grid[3][4]][4] & xArray[3] & yArray[4]) |
			(color[Grid[3][5]][4] & xArray[3] & yArray[5]) |
			(color[Grid[3][6]][4] & xArray[3] & yArray[6]) |
			(color[Grid[3][7]][4] & xArray[3] & yArray[7]) |
			(color[Grid[4][0]][4] & xArray[4] & yArray[0]) | 
			(color[Grid[4][1]][4] & xArray[4] & yArray[1]) |
			(color[Grid[4][2]][4] & xArray[4] & yArray[2]) |
			(color[Grid[4][3]][4] & xArray[4] & yArray[3]) |
			(color[Grid[4][4]][4] & xArray[4] & yArray[4]) |
			(color[Grid[4][5]][4] & xArray[4] & yArray[5]) |
			(color[Grid[4][6]][4] & xArray[4] & yArray[6]) |
			(color[Grid[4][7]][4] & xArray[4] & yArray[7]) |
			(color[Grid[5][0]][4] & xArray[5] & yArray[0]) | 
			(color[Grid[5][1]][4] & xArray[5] & yArray[1]) |
			(color[Grid[5][2]][4] & xArray[5] & yArray[2]) |
			(color[Grid[5][3]][4] & xArray[5] & yArray[3]) |
			(color[Grid[5][4]][4] & xArray[5] & yArray[4]) |
			(color[Grid[5][5]][4] & xArray[5] & yArray[5]) |
			(color[Grid[5][6]][4] & xArray[5] & yArray[6]) |
			(color[Grid[5][7]][4] & xArray[5] & yArray[7]) |
			(color[Grid[6][0]][4] & xArray[6] & yArray[0]) | 
			(color[Grid[6][1]][4] & xArray[6] & yArray[1]) |
			(color[Grid[6][2]][4] & xArray[6] & yArray[2]) |
			(color[Grid[6][3]][4] & xArray[6] & yArray[3]) |
			(color[Grid[6][4]][4] & xArray[6] & yArray[4]) |
			(color[Grid[6][5]][4] & xArray[6] & yArray[5]) |
			(color[Grid[6][6]][4] & xArray[6] & yArray[6]) |
			(color[Grid[6][7]][4] & xArray[6] & yArray[7]) |
			(color[Grid[7][0]][4] & xArray[7] & yArray[0]) | 
			(color[Grid[7][1]][4] & xArray[7] & yArray[1]) |
			(color[Grid[7][2]][4] & xArray[7] & yArray[2]) |
			(color[Grid[7][3]][4] & xArray[7] & yArray[3]) |
			(color[Grid[7][4]][4] & xArray[7] & yArray[4]) |
			(color[Grid[7][5]][4] & xArray[7] & yArray[5]) |
			(color[Grid[7][6]][4] & xArray[7] & yArray[6]) |
			(color[Grid[7][7]][4] & xArray[7] & yArray[7]) 
			) & inDisplayArea  & !marker;
			
			green[1] = (
			(color[Grid[0][0]][3] & xArray[0] & yArray[0]) | 
			(color[Grid[0][1]][3] & xArray[0] & yArray[1]) |
			(color[Grid[0][2]][3] & xArray[0] & yArray[2]) |
			(color[Grid[0][3]][3] & xArray[0] & yArray[3]) |
			(color[Grid[0][4]][3] & xArray[0] & yArray[4]) |
			(color[Grid[0][5]][3] & xArray[0] & yArray[5]) |
			(color[Grid[0][6]][3] & xArray[0] & yArray[6]) |
			(color[Grid[0][7]][3] & xArray[0] & yArray[7]) |
			(color[Grid[1][0]][3] & xArray[1] & yArray[0]) |
			(color[Grid[1][1]][3] & xArray[1] & yArray[1]) |
			(color[Grid[1][2]][3] & xArray[1] & yArray[2]) |
			(color[Grid[1][3]][3] & xArray[1] & yArray[3]) |
			(color[Grid[1][4]][3] & xArray[1] & yArray[4]) |
			(color[Grid[1][5]][3] & xArray[1] & yArray[5]) |
			(color[Grid[1][6]][3] & xArray[1] & yArray[6]) |
			(color[Grid[1][7]][3] & xArray[1] & yArray[7]) |
			(color[Grid[2][0]][3] & xArray[2] & yArray[0]) |
			(color[Grid[2][1]][3] & xArray[2] & yArray[1]) |
			(color[Grid[2][2]][3] & xArray[2] & yArray[2]) |
			(color[Grid[2][3]][3] & xArray[2] & yArray[3]) |
			(color[Grid[2][4]][3] & xArray[2] & yArray[4]) |
			(color[Grid[2][5]][3] & xArray[2] & yArray[5]) |
			(color[Grid[2][6]][3] & xArray[2] & yArray[6]) |
			(color[Grid[2][7]][3] & xArray[2] & yArray[7]) |
			(color[Grid[3][0]][3] & xArray[3] & yArray[0]) |
			(color[Grid[3][1]][3] & xArray[3] & yArray[1]) |
			(color[Grid[3][2]][3] & xArray[3] & yArray[2]) |
			(color[Grid[3][3]][3] & xArray[3] & yArray[3]) |
			(color[Grid[3][4]][3] & xArray[3] & yArray[4]) |
			(color[Grid[3][5]][3] & xArray[3] & yArray[5]) |
			(color[Grid[3][6]][3] & xArray[3] & yArray[6]) |
			(color[Grid[3][7]][3] & xArray[3] & yArray[7]) |
			(color[Grid[4][0]][3] & xArray[4] & yArray[0]) | 
			(color[Grid[4][1]][3] & xArray[4] & yArray[1]) |
			(color[Grid[4][2]][3] & xArray[4] & yArray[2]) |
			(color[Grid[4][3]][3] & xArray[4] & yArray[3]) |
			(color[Grid[4][4]][3] & xArray[4] & yArray[4]) |
			(color[Grid[4][5]][3] & xArray[4] & yArray[5]) |
			(color[Grid[4][6]][3] & xArray[4] & yArray[6]) |
			(color[Grid[4][7]][3] & xArray[4] & yArray[7]) |
			(color[Grid[5][0]][3] & xArray[5] & yArray[0]) | 
			(color[Grid[5][1]][3] & xArray[5] & yArray[1]) |
			(color[Grid[5][2]][3] & xArray[5] & yArray[2]) |
			(color[Grid[5][3]][3] & xArray[5] & yArray[3]) |
			(color[Grid[5][4]][3] & xArray[5] & yArray[4]) |
			(color[Grid[5][5]][3] & xArray[5] & yArray[5]) |
			(color[Grid[5][6]][3] & xArray[5] & yArray[6]) |
			(color[Grid[5][7]][3] & xArray[5] & yArray[7]) |
			(color[Grid[6][0]][3] & xArray[6] & yArray[0]) | 
			(color[Grid[6][1]][3] & xArray[6] & yArray[1]) |
			(color[Grid[6][2]][3] & xArray[6] & yArray[2]) |
			(color[Grid[6][3]][3] & xArray[6] & yArray[3]) |
			(color[Grid[6][4]][3] & xArray[6] & yArray[4]) |
			(color[Grid[6][5]][3] & xArray[6] & yArray[5]) |
			(color[Grid[6][6]][3] & xArray[6] & yArray[6]) |
			(color[Grid[6][7]][3] & xArray[6] & yArray[7]) |
			(color[Grid[7][0]][3] & xArray[7] & yArray[0]) | 
			(color[Grid[7][1]][3] & xArray[7] & yArray[1]) |
			(color[Grid[7][2]][3] & xArray[7] & yArray[2]) |
			(color[Grid[7][3]][3] & xArray[7] & yArray[3]) |
			(color[Grid[7][4]][3] & xArray[7] & yArray[4]) |
			(color[Grid[7][5]][3] & xArray[7] & yArray[5]) |
			(color[Grid[7][6]][3] & xArray[7] & yArray[6]) |
			(color[Grid[7][7]][3] & xArray[7] & yArray[7]) 
			) & inDisplayArea  & !marker;
			
			green[2] = (
			(color[Grid[0][0]][2] & xArray[0] & yArray[0]) | 
			(color[Grid[0][1]][2] & xArray[0] & yArray[1]) |
			(color[Grid[0][2]][2] & xArray[0] & yArray[2]) |
			(color[Grid[0][3]][2] & xArray[0] & yArray[3]) |
			(color[Grid[0][4]][2] & xArray[0] & yArray[4]) |
			(color[Grid[0][5]][2] & xArray[0] & yArray[5]) |
			(color[Grid[0][6]][2] & xArray[0] & yArray[6]) |
			(color[Grid[0][7]][2] & xArray[0] & yArray[7]) |
			(color[Grid[1][0]][2] & xArray[1] & yArray[0]) |
			(color[Grid[1][1]][2] & xArray[1] & yArray[1]) |
			(color[Grid[1][2]][2] & xArray[1] & yArray[2]) |
			(color[Grid[1][3]][2] & xArray[1] & yArray[3]) |
			(color[Grid[1][4]][2] & xArray[1] & yArray[4]) |
			(color[Grid[1][5]][2] & xArray[1] & yArray[5]) |
			(color[Grid[1][6]][2] & xArray[1] & yArray[6]) |
			(color[Grid[1][7]][2] & xArray[1] & yArray[7]) |
			(color[Grid[2][0]][2] & xArray[2] & yArray[0]) |
			(color[Grid[2][1]][2] & xArray[2] & yArray[1]) |
			(color[Grid[2][2]][2] & xArray[2] & yArray[2]) |
			(color[Grid[2][3]][2] & xArray[2] & yArray[3]) |
			(color[Grid[2][4]][2] & xArray[2] & yArray[4]) |
			(color[Grid[2][5]][2] & xArray[2] & yArray[5]) |
			(color[Grid[2][6]][2] & xArray[2] & yArray[6]) |
			(color[Grid[2][7]][2] & xArray[2] & yArray[7]) |
			(color[Grid[3][0]][2] & xArray[3] & yArray[0]) |
			(color[Grid[3][1]][2] & xArray[3] & yArray[1]) |
			(color[Grid[3][2]][2] & xArray[3] & yArray[2]) |
			(color[Grid[3][3]][2] & xArray[3] & yArray[3]) |
			(color[Grid[3][4]][2] & xArray[3] & yArray[4]) |
			(color[Grid[3][5]][2] & xArray[3] & yArray[5]) |
			(color[Grid[3][6]][2] & xArray[3] & yArray[6]) |
			(color[Grid[3][7]][2] & xArray[3] & yArray[7]) |
			(color[Grid[4][0]][2] & xArray[4] & yArray[0]) | 
			(color[Grid[4][1]][2] & xArray[4] & yArray[1]) |
			(color[Grid[4][2]][2] & xArray[4] & yArray[2]) |
			(color[Grid[4][3]][2] & xArray[4] & yArray[3]) |
			(color[Grid[4][4]][2] & xArray[4] & yArray[4]) |
			(color[Grid[4][5]][2] & xArray[4] & yArray[5]) |
			(color[Grid[4][6]][2] & xArray[4] & yArray[6]) |
			(color[Grid[4][7]][2] & xArray[4] & yArray[7]) |
			(color[Grid[5][0]][2] & xArray[5] & yArray[0]) | 
			(color[Grid[5][1]][2] & xArray[5] & yArray[1]) |
			(color[Grid[5][2]][2] & xArray[5] & yArray[2]) |
			(color[Grid[5][3]][2] & xArray[5] & yArray[3]) |
			(color[Grid[5][4]][2] & xArray[5] & yArray[4]) |
			(color[Grid[5][5]][2] & xArray[5] & yArray[5]) |
			(color[Grid[5][6]][2] & xArray[5] & yArray[6]) |
			(color[Grid[5][7]][2] & xArray[5] & yArray[7]) |
			(color[Grid[6][0]][2] & xArray[6] & yArray[0]) | 
			(color[Grid[6][1]][2] & xArray[6] & yArray[1]) |
			(color[Grid[6][2]][2] & xArray[6] & yArray[2]) |
			(color[Grid[6][3]][2] & xArray[6] & yArray[3]) |
			(color[Grid[6][4]][2] & xArray[6] & yArray[4]) |
			(color[Grid[6][5]][2] & xArray[6] & yArray[5]) |
			(color[Grid[6][6]][2] & xArray[6] & yArray[6]) |
			(color[Grid[6][7]][2] & xArray[6] & yArray[7]) |
			(color[Grid[7][0]][2] & xArray[7] & yArray[0]) | 
			(color[Grid[7][1]][2] & xArray[7] & yArray[1]) |
			(color[Grid[7][2]][2] & xArray[7] & yArray[2]) |
			(color[Grid[7][3]][2] & xArray[7] & yArray[3]) |
			(color[Grid[7][4]][2] & xArray[7] & yArray[4]) |
			(color[Grid[7][5]][2] & xArray[7] & yArray[5]) |
			(color[Grid[7][6]][2] & xArray[7] & yArray[6]) |
			(color[Grid[7][7]][2] & xArray[7] & yArray[7]) 
			) & inDisplayArea  & !marker;
			
			blue[1] = (
			(color[Grid[0][0]][1] & xArray[0] & yArray[0]) | 
			(color[Grid[0][1]][1] & xArray[0] & yArray[1]) |
			(color[Grid[0][2]][1] & xArray[0] & yArray[2]) |
			(color[Grid[0][3]][1] & xArray[0] & yArray[3]) |
			(color[Grid[0][4]][1] & xArray[0] & yArray[4]) |
			(color[Grid[0][5]][1] & xArray[0] & yArray[5]) |
			(color[Grid[0][6]][1] & xArray[0] & yArray[6]) |
			(color[Grid[0][7]][1] & xArray[0] & yArray[7]) |
			(color[Grid[1][0]][1] & xArray[1] & yArray[0]) |
			(color[Grid[1][1]][1] & xArray[1] & yArray[1]) |
			(color[Grid[1][2]][1] & xArray[1] & yArray[2]) |
			(color[Grid[1][3]][1] & xArray[1] & yArray[3]) |
			(color[Grid[1][4]][1] & xArray[1] & yArray[4]) |
			(color[Grid[1][5]][1] & xArray[1] & yArray[5]) |
			(color[Grid[1][6]][1] & xArray[1] & yArray[6]) |
			(color[Grid[1][7]][1] & xArray[1] & yArray[7]) |
			(color[Grid[2][0]][1] & xArray[2] & yArray[0]) |
			(color[Grid[2][1]][1] & xArray[2] & yArray[1]) |
			(color[Grid[2][2]][1] & xArray[2] & yArray[2]) |
			(color[Grid[2][3]][1] & xArray[2] & yArray[3]) |
			(color[Grid[2][4]][1] & xArray[2] & yArray[4]) |
			(color[Grid[2][5]][1] & xArray[2] & yArray[5]) |
			(color[Grid[2][6]][1] & xArray[2] & yArray[6]) |
			(color[Grid[2][7]][1] & xArray[2] & yArray[7]) |
			(color[Grid[3][0]][1] & xArray[3] & yArray[0]) |
			(color[Grid[3][1]][1] & xArray[3] & yArray[1]) |
			(color[Grid[3][2]][1] & xArray[3] & yArray[2]) |
			(color[Grid[3][3]][1] & xArray[3] & yArray[3]) |
			(color[Grid[3][4]][1] & xArray[3] & yArray[4]) |
			(color[Grid[3][5]][1] & xArray[3] & yArray[5]) |
			(color[Grid[3][6]][1] & xArray[3] & yArray[6]) |
			(color[Grid[3][7]][1] & xArray[3] & yArray[7]) |
			(color[Grid[4][0]][1] & xArray[4] & yArray[0]) |
			(color[Grid[4][1]][1] & xArray[4] & yArray[1]) |
			(color[Grid[4][2]][1] & xArray[4] & yArray[2]) |
			(color[Grid[4][3]][1] & xArray[4] & yArray[3]) |
			(color[Grid[4][4]][1] & xArray[4] & yArray[4]) |
			(color[Grid[4][5]][1] & xArray[4] & yArray[5]) |
			(color[Grid[4][6]][1] & xArray[4] & yArray[6]) |
			(color[Grid[4][7]][1] & xArray[4] & yArray[7]) |
			(color[Grid[5][0]][1] & xArray[5] & yArray[0]) |
			(color[Grid[5][1]][1] & xArray[5] & yArray[1]) |
			(color[Grid[5][2]][1] & xArray[5] & yArray[2]) |
			(color[Grid[5][3]][1] & xArray[5] & yArray[3]) |
			(color[Grid[5][4]][1] & xArray[5] & yArray[4]) |
			(color[Grid[5][5]][1] & xArray[5] & yArray[5]) |
			(color[Grid[5][6]][1] & xArray[5] & yArray[6]) |
			(color[Grid[5][7]][1] & xArray[5] & yArray[7]) |
			(color[Grid[6][0]][1] & xArray[6] & yArray[0]) |
			(color[Grid[6][1]][1] & xArray[6] & yArray[1]) |
			(color[Grid[6][2]][1] & xArray[6] & yArray[2]) |
			(color[Grid[6][3]][1] & xArray[6] & yArray[3]) |
			(color[Grid[6][4]][1] & xArray[6] & yArray[4]) |
			(color[Grid[6][5]][1] & xArray[6] & yArray[5]) |
			(color[Grid[6][6]][1] & xArray[6] & yArray[6]) |
			(color[Grid[6][7]][1] & xArray[6] & yArray[7]) |
			(color[Grid[7][0]][1] & xArray[7] & yArray[0]) |
			(color[Grid[7][1]][1] & xArray[7] & yArray[1]) |
			(color[Grid[7][2]][1] & xArray[7] & yArray[2]) |
			(color[Grid[7][3]][1] & xArray[7] & yArray[3]) |
			(color[Grid[7][4]][1] & xArray[7] & yArray[4]) |
			(color[Grid[7][5]][1] & xArray[7] & yArray[5]) |
			(color[Grid[7][6]][1] & xArray[7] & yArray[6]) |
			(color[Grid[7][7]][1] & xArray[7] & yArray[7]) 
			) & inDisplayArea  & !marker;
			
			blue[0] = (
			(color[Grid[0][0]][0] & xArray[0] & yArray[0]) | 
			(color[Grid[0][1]][0] & xArray[0] & yArray[1]) |
			(color[Grid[0][2]][0] & xArray[0] & yArray[2]) |
			(color[Grid[0][3]][0] & xArray[0] & yArray[3]) |
			(color[Grid[0][4]][0] & xArray[0] & yArray[4]) |
			(color[Grid[0][5]][0] & xArray[0] & yArray[5]) |
			(color[Grid[0][6]][0] & xArray[0] & yArray[6]) |
			(color[Grid[0][7]][0] & xArray[0] & yArray[7]) |
			(color[Grid[1][0]][0] & xArray[1] & yArray[0]) |
			(color[Grid[1][1]][0] & xArray[1] & yArray[1]) |
			(color[Grid[1][2]][0] & xArray[1] & yArray[2]) |
			(color[Grid[1][3]][0] & xArray[1] & yArray[3]) |
			(color[Grid[1][4]][0] & xArray[1] & yArray[4]) |
			(color[Grid[1][5]][0] & xArray[1] & yArray[5]) |
			(color[Grid[1][6]][0] & xArray[1] & yArray[6]) |
			(color[Grid[1][7]][0] & xArray[1] & yArray[7]) |
			(color[Grid[2][0]][0] & xArray[2] & yArray[0]) |
			(color[Grid[2][1]][0] & xArray[2] & yArray[1]) |
			(color[Grid[2][2]][0] & xArray[2] & yArray[2]) |
			(color[Grid[2][3]][0] & xArray[2] & yArray[3]) |
			(color[Grid[2][4]][0] & xArray[2] & yArray[4]) |
			(color[Grid[2][5]][0] & xArray[2] & yArray[5]) |
			(color[Grid[2][6]][0] & xArray[2] & yArray[6]) |
			(color[Grid[2][7]][0] & xArray[2] & yArray[7]) |
			(color[Grid[3][0]][0] & xArray[3] & yArray[0]) |
			(color[Grid[3][1]][0] & xArray[3] & yArray[1]) |
			(color[Grid[3][2]][0] & xArray[3] & yArray[2]) |
			(color[Grid[3][3]][0] & xArray[3] & yArray[3]) |
			(color[Grid[3][4]][0] & xArray[3] & yArray[4]) |
			(color[Grid[3][5]][0] & xArray[3] & yArray[5]) |
			(color[Grid[3][6]][0] & xArray[3] & yArray[6]) |
			(color[Grid[3][7]][0] & xArray[3] & yArray[7]) |
			(color[Grid[4][0]][0] & xArray[4] & yArray[0]) |
			(color[Grid[4][1]][0] & xArray[4] & yArray[1]) |
			(color[Grid[4][2]][0] & xArray[4] & yArray[2]) |
			(color[Grid[4][3]][0] & xArray[4] & yArray[3]) |
			(color[Grid[4][4]][0] & xArray[4] & yArray[4]) |
			(color[Grid[4][5]][0] & xArray[4] & yArray[5]) |
			(color[Grid[4][6]][0] & xArray[4] & yArray[6]) |
			(color[Grid[4][7]][0] & xArray[4] & yArray[7]) |
			(color[Grid[5][0]][0] & xArray[5] & yArray[0]) |
			(color[Grid[5][1]][0] & xArray[5] & yArray[1]) |
			(color[Grid[5][2]][0] & xArray[5] & yArray[2]) |
			(color[Grid[5][3]][0] & xArray[5] & yArray[3]) |
			(color[Grid[5][4]][0] & xArray[5] & yArray[4]) |
			(color[Grid[5][5]][0] & xArray[5] & yArray[5]) |
			(color[Grid[5][6]][0] & xArray[5] & yArray[6]) |
			(color[Grid[5][7]][0] & xArray[5] & yArray[7]) |
			(color[Grid[6][0]][0] & xArray[6] & yArray[0]) |
			(color[Grid[6][1]][0] & xArray[6] & yArray[1]) |
			(color[Grid[6][2]][0] & xArray[6] & yArray[2]) |
			(color[Grid[6][3]][0] & xArray[6] & yArray[3]) |
			(color[Grid[6][4]][0] & xArray[6] & yArray[4]) |
			(color[Grid[6][5]][0] & xArray[6] & yArray[5]) |
			(color[Grid[6][6]][0] & xArray[6] & yArray[6]) |
			(color[Grid[6][7]][0] & xArray[6] & yArray[7]) |
			(color[Grid[7][0]][0] & xArray[7] & yArray[0]) |
			(color[Grid[7][1]][0] & xArray[7] & yArray[1]) |
			(color[Grid[7][2]][0] & xArray[7] & yArray[2]) |
			(color[Grid[7][3]][0] & xArray[7] & yArray[3]) |
			(color[Grid[7][4]][0] & xArray[7] & yArray[4]) |
			(color[Grid[7][5]][0] & xArray[7] & yArray[5]) |
			(color[Grid[7][6]][0] & xArray[7] & yArray[6]) |
			(color[Grid[7][7]][0] & xArray[7] & yArray[7]) 
			) & inDisplayArea  & !marker;
			
		end
		/*
		red[0] <= (xArray[1] | xArray[2] | xArray[4] | xArray[7] ) & yArray[0] & inDisplayArea;
		red[1] <= (xArray[1] | xArray[2] | xArray[3] | xArray[4]| xArray[7]) & yArray[0] & inDisplayArea;
		red[2] <= (xArray[0] | xArray[1] | xArray[2] | xArray[4] | xArray[7]) & yArray[0] & inDisplayArea;
		green[0] <= (xArray[0] | xArray[1] | xArray[2] | xArray[4] | xArray[5] | xArray[6]) & yArray[0] & inDisplayArea;
		green[1] <= (xArray[0] | xArray[4] | xArray[5] | xArray[7] ) & yArray[0] & inDisplayArea;
		green[2] <= (xArray[0] | xArray[2] | xArray[5]) & yArray[0] & inDisplayArea;
		blue[1] <= (xArray[2] | xArray[3] | xArray[5] | xArray[6]) & yArray[0] & inDisplayArea;
		blue[0] <= (xArray[0] | xArray[2] | xArray[5] | xArray[6] | xArray[7]) & yArray[0] & inDisplayArea;
		*/
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  VGA control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	

	/*			GAME VARIABLE INITIALIZATION 		*/
	reg[3:0] Grid[7:0][7:0];
	integer loadI, loadJ;
	wire[12:0] LFSR;
	reg enableLFSR, enableCandyCrush;
	wire[2:0] randomNum;
	reg dataLoadingFlag;
	wire[2:0] X, Y, writeX, writeY;
	wire[2:0] swapX, swapY;
	wire SwapFlag, writeBlackFlag, writeRandomFlag;
	wire[3:0] stateNum;

	CandyCrush CCFSM (board_clk, reset, enableCandyCrush, BtnU_Pulse, BtnD_Pulse, BtnC_Pulse,
					BtnL_Pulse, BtnR_Pulse, Grid[X][Y], X, Y, swapX, swapY, writeX, writeY,
					SwapFlag, writeBlackFlag, writeRandomFlag, stateNum);
					
	
	
	
	assign randomNum = {LFSR[2], LFSR[1], LFSR[0]};	
	
	lfsr LFSR_Module (LFSR, enableLFSR, board_clk, reset);

	initial
	begin: initialize_flags
		loadI = 0;
		loadJ = 0;
		dataLoadingFlag = 1;
		enableLFSR = 1;
		displayFlag = 0;
		enableCandyCrush = 0;
	end

	always @ (posedge board_clk)
	begin: Grid_Data_Operations
		if (dataLoadingFlag & !reset)
		begin
			Grid[loadI][loadJ] <= randomNum + 1;
			
			if (loadI == 7 && loadJ == 7)
			begin
				dataLoadingFlag <= 0;
				displayFlag <= 1;
				enableCandyCrush <= 1;
			end
			else if (loadI == 7)
			begin
				loadI = 0;
				loadJ = loadJ + 1;
			end
			else
				loadI = loadI + 1;
		end
		if(SwapFlag)
		begin
			Grid[X][Y] <= Grid[swapX][swapY];
			Grid[swapX][swapY] <= Grid[X][Y];
		end
		if(writeBlackFlag)
		begin
			Grid[writeX][writeY] <= 0;
		end
		if(writeRandomFlag)
		begin
			Grid[writeX][writeY] <= randomNum + 1;
		end
	end
	
	
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	`define QI 			2'b00
	`define QGAME_1 	2'b01
	`define QGAME_2 	2'b10
	`define QDONE 		2'b11
	
	reg [3:0] p2_score;
	reg [3:0] p1_score;
	reg [1:0] state;
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	assign LD0 = (p1_score == 4'b1010);
	assign LD1 = (p2_score == 4'b1010);
	
	assign LD2 = start;
	assign LD4 = reset;
	
	assign LD3 = (state == `QI);
	assign LD5 = (state == `QGAME_1);	
	assign LD6 = (state == `QGAME_2);
	assign LD7 = (state == `QDONE);
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	reg 	[3:0]	SSD;
	wire 	[3:0]	SSD0, SSD1, SSD2, SSD3;
	wire 	[1:0] ssdscan_clk;
	
	assign SSD3 = stateNum[3:0];
	assign SSD2 = 4'b1111;
	assign SSD1 = {0, X[2],X[1],X[0]};
	assign SSD0 = {0, Y[2],Y[1],Y[0]};
	
	// need a scan clk for the seven segment display 
	// 191Hz (50MHz / 2^18) works well
	assign ssdscan_clk = DIV_CLK[19:18];	
	assign An0	= !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	assign An1	= !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
	assign An2	= !( (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
	assign An3	= !( (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
			2'b00:
					SSD = SSD0;
			2'b01:
					SSD = SSD1;
			2'b10:
					SSD = SSD2;
			2'b11:
					SSD = SSD3;
		endcase 
	end	

	// and finally convert SSD_num to ssd
	reg [6:0]  SSD_CATHODES;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES, 1'b1};
	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD)		
			4'b1111: SSD_CATHODES = 7'b1111111 ; //Nothing 
			4'b0000: SSD_CATHODES = 7'b0000001 ; //0
			4'b0001: SSD_CATHODES = 7'b1001111 ; //1
			4'b0010: SSD_CATHODES = 7'b0010010 ; //2
			4'b0011: SSD_CATHODES = 7'b0000110 ; //3
			4'b0100: SSD_CATHODES = 7'b1001100 ; //4
			4'b0101: SSD_CATHODES = 7'b0100100 ; //5
			4'b0110: SSD_CATHODES = 7'b0100000 ; //6
			4'b0111: SSD_CATHODES = 7'b0001111 ; //7
			4'b1000: SSD_CATHODES = 7'b0000000 ; //8
			4'b1001: SSD_CATHODES = 7'b0000100 ; //9
			4'b1010: SSD_CATHODES = 7'b0001000 ; //10 or A
			default: SSD_CATHODES = 7'bXXXXXXX ; // default is not needed as we covered all cases
		endcase
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
endmodule

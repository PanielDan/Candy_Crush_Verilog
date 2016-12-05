/*
Author: Danny Pan
Candy Crush state machine

*/


module CandyCrush(
	Clk, Reset, Enable,
	BtnU, BtnD, BtnC, BtnL, BtnR,
	Grid,
	//Outputs
	X, Y, swapX, swapY, writeX, writeY,
	SwapFlag, writeBlackFlag, writeRandomFlag, stateNum
);
	//Signals are declared here
	input BtnU, BtnD, BtnC, BtnL, BtnR, Clk, Reset, Enable;
	input [3:0] Grid;
	output reg [2:0] X, Y, writeX, writeY;
	output reg [2:0] swapX, swapY;
	output reg SwapFlag, writeBlackFlag, writeRandomFlag;
	output reg [3:0] stateNum;
	reg columnCheck[7:0];
	reg writeOriginalFlag, repopFlag, eraseFlag, blackGapFlag;
	reg [2:0] repopX, repopY, originalX, originalY;
	reg [12:0] state;
	reg NFlag, SFlag, WFlag, EFlag;
	reg [3:0] selectedColor, indexCounter;
	
	
	localparam 	
	InitializeVariables = 	13'b0000000000001, 	//1
	CursorMove = 			13'b0000000000010, 	//2
	SwapSelect = 			13'b0000000000100,	//4
	Swap = 					13'b0000000001000,	//8
	SetColor = 				13'b0000000010000,	//16
	NeighborCheck = 		13'b0000000100000,	//32
	NorthCheck = 			13'b0000001000000,	//64
	EastCheck = 			13'b0000010000000,	//128
	SouthCheck = 			13'b0000100000000,	//256
	WestCheck = 			13'b0001000000000,	//512
	RepopulateCheck = 		13'b0010000000000,	//1024
	RepopulateColumn = 		13'b0100000000000,	//2048
	ResetValues = 			13'b1000000000000,	//4096
	Unknown = 				13'bXXXXXXXXXXXXX;	//8192
	
	always @(posedge Clk)
	begin
		case (state)
			InitializeVariables: stateNum = 4'b0001;
			CursorMove:				stateNum = 4'b0010;
			SwapSelect:				stateNum = 4'b0011;
			Swap:						stateNum = 4'b0100;
			SetColor:				stateNum = 4'b0101;
			NeighborCheck:			stateNum = 4'b0110;
			NorthCheck:				stateNum = 4'b0111;
			EastCheck:				stateNum = 4'b1000;
			SouthCheck: 			stateNum = 4'b1001;
			WestCheck:				stateNum = 4'b1010;
			RepopulateCheck:		stateNum = 4'b1011;
			RepopulateColumn:		stateNum = 4'b1100;
			ResetValues:			stateNum = 4'b1101;
		endcase
	end

	
	always @(posedge Clk)
	begin
		if (Reset)
		begin
			state <= InitializeVariables;
			X <= 4'b0000;
			Y <= 4'b0000;
			SwapFlag <= 0;
			writeBlackFlag <= 0;
			writeRandomFlag <= 0;
			writeOriginalFlag <= 0;
			blackGapFlag <= 0;
			repopFlag <= 0;
			originalX <= 4'b0000;
			originalY <= 4'b0000;
			repopX <= 4'b0000;
			repopY <= 4'b0000;
			writeX <= 4'b0000;
			writeY <= 4'b0000;
			swapX <= 4'b0000;
			swapY <= 4'b0000;
			NFlag <= 0;
			SFlag <= 0;
			WFlag <= 0;
			EFlag <= 0;
			eraseFlag <= 0;
			selectedColor <= 4'b0000;
			indexCounter <= 4'b0000;
		end	
		else if (Enable)
			case(state)
				InitializeVariables:
				begin
					state <= CursorMove;
					X <= 3;
					Y <= 3;
					columnCheck[0] <= 0;
					columnCheck[1] <= 0;
					columnCheck[2] <= 0;
					columnCheck[3] <= 0;
					columnCheck[4] <= 0;
					columnCheck[5] <= 0;
					columnCheck[6] <= 0;
					columnCheck[7] <= 0;
				end
				CursorMove:
				begin
					if(BtnC)
					begin
						originalX <= X;
						originalY <= Y;
						state <= SwapSelect;
						//Need to add cursor color change
					end
					else if(BtnU)
					begin
						if(Y > 0)
							Y <= Y - 1;
					end
					else if(BtnD)
					begin
						if(Y < 7)
							Y <= Y + 1;
					end
					else if(BtnL)
					begin
						if (X > 0)
							X <= X - 1;
					end
					else if(BtnR)
					begin
						if (X < 7)
							X <= X + 1;
					end
				end
				SwapSelect:
				begin
					//State Change
					if(BtnC)
					begin
						state <= Swap;
						swapX <= originalX;
						swapY <= originalY;
						SwapFlag <= 1;
						//Need to add cursor color change
					end
					else if(BtnU)
					begin
						if( (Y > 0) && (Y > (originalY - 1)) )
							Y <= originalY - 1;
							X <= originalX;
					end
					else if(BtnD)
					begin
						if( (Y < 7) && (Y < (originalY + 1)) )
							Y <= originalY + 1;
							X <= originalX;
					end
					else if(BtnL)
					begin
						if ( (X > 0) && (X > (originalX - 1)) )
							X <= originalX - 1;
							Y <= originalY;
					end
					else if(BtnR)
					begin
						if ( (X < 7) && (X < (originalX + 1)) )
							X <= originalX + 1;
							Y <= originalY;
					end				
				end
				Swap:
				begin
					state <= SetColor;
					X <= originalX;
					Y <= originalY;
					SwapFlag <= 0;
				end
				SetColor:
				begin
					state <= NeighborCheck;
					selectedColor <= Grid;
				end
				NeighborCheck:
				begin
					if(!NFlag)
					begin
						NFlag <= 1;
						if (Y > 0)
							begin
							state <= NorthCheck;
							Y <= Y - 1;
							end
					end
					else if (!SFlag)
					begin
						writeBlackFlag <= 0;
						SFlag <= 1;
						if (Y < 7)
							begin
							state <= SouthCheck;
							Y <= Y + 1;
							end
					end
					else if (!WFlag)
					begin
						writeBlackFlag <= 0;
						WFlag <= 1;
						if (X > 0)
							begin
							state <= WestCheck;
							X <= X - 1;
							end
					end					
					else if (!EFlag)
					begin
						EFlag <= 1;
						writeBlackFlag <= 0;
						if (X < 7)
							begin
							state <= EastCheck;
							X <= X + 1;
							end
					end
					else
					begin
						if(writeOriginalFlag)
						begin
							writeBlackFlag <= 1;
							writeX <= originalX;
							writeY <= originalY;
							columnCheck[originalX] <= 1;

						end
						state <= RepopulateCheck;
					end
				end
				NorthCheck:
				begin
					if(Grid == selectedColor)
					begin
						columnCheck[X] <= 1;
						writeOriginalFlag <= 1;
						writeBlackFlag <= 1;
						writeX <= X;
						writeY <= Y;
						if (Y > 0)
							Y <= Y - 1;
						else
						begin
							state <= NeighborCheck;
							Y <= originalY;
						end
					end
					else
					begin
						state <= NeighborCheck;
						Y <= originalY;
					end
				end
				EastCheck:
				begin
					if(Grid == selectedColor)
					begin
						columnCheck[X] <= 1;
						writeOriginalFlag <= 1;
						writeBlackFlag <= 1;
						writeX <= X;
						writeY <= Y;
						if (X < 7)
							X <= X + 1;
						else
						begin
							state <= NeighborCheck;
							X <= originalX;
						end
					end
					else
					begin
						state <= NeighborCheck;
						X <= originalX;
					end
				end
				SouthCheck:
				begin
					if(Grid == selectedColor)
					begin
						columnCheck[X] <= 1;
						writeOriginalFlag <= 1;
						writeBlackFlag <= 1;
						writeX <= X;
						writeY <= Y;
						if (Y < 7)
							Y <= Y + 1;
						else
						begin
							state <= NeighborCheck;
							Y <= originalY;
						end
					end
					else
					begin
						state <= NeighborCheck;
						Y <= originalY;
					end
				end
				WestCheck:
				begin
					if(Grid == selectedColor)
					begin
						columnCheck[X] <= 1;
						writeOriginalFlag <= 1;
						writeBlackFlag <= 1;
						writeX <= X;
						writeY <= Y;
						if (X > 0)
							X <= X - 1;
						else
						begin
							state <= NeighborCheck;
							X <= originalX;
						end
					end
					else
					begin
						state <= NeighborCheck;
						X <= originalX;
					end
				end
				RepopulateCheck:
				begin
					writeBlackFlag <= 0;
					writeOriginalFlag <= 0;
					writeRandomFlag <= 0;
					if(indexCounter == 8)
						state <= ResetValues;
					else
					begin
						if(columnCheck[indexCounter] == 1)
						begin
							state <= RepopulateColumn;
							X <= indexCounter;
							Y <= 7;
							repopX <= indexCounter;
							repopY <= 7;
						end
						else
							indexCounter <= indexCounter + 1;
					end
				end
				RepopulateColumn:
				begin
					if(repopY == 7 && Y == 0)
					begin
						if (Grid == 0)
						begin
							writeX <= repopX;
							writeY <= Y;
							writeRandomFlag <= 1;
						end
						state <= RepopulateCheck;
						repopFlag <= 0;
						indexCounter <= indexCounter + 1;
					end
					else if(repopY == 0 && repopFlag)
					begin
						state <= RepopulateCheck;
						repopFlag <= 0;
						writeRandomFlag <= 1;
						writeX <= repopX;
						writeY <= repopY;
						indexCounter <= indexCounter + 1;
					end
					else if(Grid == 0 && !repopFlag)
					begin
						repopY <= Y;
						Y <= Y - 1;
						repopFlag <= 1;
					end
					else if (Grid != 0 && repopFlag)
					begin
						swapX <= repopX;
						swapY <= repopY;
						SwapFlag <= 1;
						repopY <= repopY - 1;
						if (Y > 0)
								Y <= Y - 1;
					end
					else if (Grid == 0 && repopFlag)
					begin
						SwapFlag <= 0;
						if (Y == repopY)
						begin
							writeX <= repopX;
							writeY <= repopY;
							writeRandomFlag <= 1;
							Y <= Y - 1;
							repopY <= repopY - 1;
						end
						else if (Y == 0)
							Y <= repopY;
						else if(Y > 0 )
							Y <= Y - 1;
					end
					else if (Grid != 0 && !repopFlag)
						if (Y > 0)
							Y <= Y-1;
				end
				ResetValues:
				begin
					state <= CursorMove;
					X <= originalX;
					Y <= originalY;
					
					SwapFlag <= 0;
					writeBlackFlag <= 0;
					writeRandomFlag <= 0;
					writeOriginalFlag <= 0;
					repopFlag <= 0;
					originalX <= 4'b0000;
					originalY <= 4'b0000;
					repopX <= 4'b0000;
					repopY <= 4'b0000;
					writeX <= 4'b0000;
					writeY <= 4'b0000;
					swapX <= 4'b0000;
					swapY <= 4'b0000;
					NFlag <= 0;
					SFlag <= 0;
					WFlag <= 0;
					EFlag <= 0;
					eraseFlag <= 0;
					selectedColor <= 4'b0000;
					indexCounter <= 4'b0000;
					columnCheck[0] <= 0;
					columnCheck[1] <= 0;
					columnCheck[2] <= 0;
					columnCheck[3] <= 0;
					columnCheck[4] <= 0;
					columnCheck[5] <= 0;
					columnCheck[6] <= 0;
					columnCheck[7] <= 0;
					blackGapFlag <= 0;
				end
			endcase
	end
	
endmodule
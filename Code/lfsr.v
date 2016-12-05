//LFSR Code

module lfsr    (
out             ,  // Output of the counter
enable          ,  // Enable  for counter
clk             ,  // clock input
reset              // reset input
);

	output [12:0] out;
	input enable, clk, reset;
	reg [12:0] out;
	wire        linear_feedback1, linear_feedback2, linear_feedback3;

	assign linear_feedback1 = !(out[7] ^ out[3]);
	assign linear_feedback2 = !(out[4] ^ out[0]);
	assign linear_feedback3 = !(linear_feedback2 ^ out[2]);
	
	always @(posedge clk)
	begin
		if (reset)
		out <= 8'b0 ;
		else if (enable) 
		begin
			out <= {out[10],out[9], out[8],
				out[7], out[6],
				out[5], out[4], out[3], out[2],
				out[0], linear_feedback3, linear_feedback2};
		end 
	end
endmodule // End Of Module counter

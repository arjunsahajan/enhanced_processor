module cntr
(
	input clk,
	input load,
	input reset_n,
	input [15: 0] D,
	
	output [15: 0] Q
);

	reg [15: 0] Q_reg;
	
	always @(clk)
	begin
		if(!load)
			Q_reg <= D;
		else if(!reset_n)
			Q_reg <= 0;
		else
			Q_reg <= Q_reg + 1;
	end
	
	assign Q = Q_reg;
	
endmodule


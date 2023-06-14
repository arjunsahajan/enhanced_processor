module cntr
(
	input clk,
	input en,
	input load,
	input reset_n,
	input [15: 0] D,
	
	output [15: 0] Q
);

	reg [15: 0] Q_reg;
	
	always @(posedge clk)
	begin
		if(!reset_n)
			Q_reg <= 0;
		else if(!load)
			Q_reg <= D;
		else if(en)
			Q_reg <= Q_reg + 1;
	end
	
	assign Q = Q_reg;
	
endmodule


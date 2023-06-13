module cntr
(
	input clk,
	input en,
	input load,
	input reset_n,
	input [15: 0] D,
	
	output [15: 0] Q
);

	reg [15: 0] Q_reg, Q_nxt;
	
	always @(posedge clk)
	begin
		Q_reg <= Q_nxt;
	end
	
	always @(*)
	begin
		if(!reset_n)
			Q_nxt <= 0;
		else if(!load)
			Q_nxt <= D;
		else if(en)
			Q_nxt <= Q_nxt + 1;
	end
	
	assign Q = Q_reg;
	
endmodule


module stack_ptr
(
	input clk,
	input load,
	input reset_n,
	input [15: 0] D,
	input sp_incr,
	input sp_decr,
	
	output [15: 0] Q
);

	reg [15: 0] Q_reg;

	always @(posedge clk)
	begin
		if(sp_incr)
			Q_reg <= Q_reg + 1;
		else if(sp_decr)
			Q_reg <= Q_reg - 1;
		else if(!load)
			Q_reg <= D;
		else if(!reset_n)
			Q_reg <= 0;
	end

	assign Q = Q_reg;
	
endmodule

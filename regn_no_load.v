module regn_no_load
# (parameter N = 8)
(
	input clk,	
	input clear,
	input [N - 1: 0] D,
	
	output [N - 1: 0] Q
);

	reg [N - 1: 0] Q_reg;

	always @(posedge clk)
	begin
	  if (!clear)
			Q_reg <= 0;
	  else
			Q_reg <= D;
	end

	assign Q = Q_reg;
	
endmodule

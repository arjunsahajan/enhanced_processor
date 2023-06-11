module addr_cntr
(
	input clk,
	input reset_n,
	
	output [4: 0] addr
); 

	reg [4: 0] addr_reg;

	always @(posedge clk)
	begin
		if(!reset_n)
			addr_reg <= 0;
		else
			addr_reg <= addr_reg + 1;
	end

	assign addr = addr_reg;
	
endmodule


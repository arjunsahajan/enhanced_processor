module mux
(
	input [15: 0] inp0, inp1, inp2, inp3, inp4, inp5, inp6, inp7, inp8, inp9, inp10,
	input [3: 0] sel,
	
	output [15: 0] mux_out
);

	parameter MV = 3'b000;
	parameter MVT = 3'b001;
	
	reg [15: 0] mux_out_reg;

	always @(sel)
	begin
		case(sel)
			4'b0000: mux_out_reg <= inp0;
			
			4'b0001: mux_out_reg <= inp1;
			
			4'b0010: mux_out_reg <= inp2;
			
			4'b0011: mux_out_reg <= inp3;
			
			4'b0100: mux_out_reg <= inp4;
			
			4'b0101: mux_out_reg <= inp5;
			
			4'b0110: mux_out_reg <= inp6;
			
			4'b0111: mux_out_reg <= inp7;
			
			4'b1000: 
			begin
				if(inp8[15: 13] == MVT)
					mux_out_reg <= {inp8[7: 0], 8'b0};
				else
					mux_out_reg <= {{7{inp8[8]}}, inp8[8: 0]};
			end
			
			4'b1001: mux_out_reg <= inp9;
			
			4'b1010: mux_out_reg <= inp10;
		endcase
	end

	assign mux_out = mux_out_reg;
	
endmodule

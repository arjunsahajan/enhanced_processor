module arithmetic_logic_unit 
#(parameter n = 8)
(
	input [n - 1: 0] x, y,
	input cin, 
	input add_sub_control,
	input [1: 0] op,
	
	output [n - 1: 0] alu_out,
	output cout
);
	
	parameter ADD_SUB = 2'b00;
	parameter LOGICAL_AND = 2'b01;

	wire [n - 1: 0] sum;
	wire [n - 1: 0] logical_and;
	wire [n - 1: 0] y_xor;
	wire [n: 0] c;
	
	reg [n: 0] alu_out_reg;
	
	assign c[0] = cin;
	assign cout = c[n];
	
	generate
	
		genvar j;
		
		for(j = 0; j < n; j = j + 1)
		begin: y_xored
		
			assign y_xor[j] = y[j] ^ add_sub_control;
		
		end
	
	endgenerate
	
	
	generate
	
		genvar k;
		
		for(k = 0; k < n; k = k + 1)
		begin: stage
		
			FullAdderUsingHalf FA(.a(x[k]), .b(y_xor[k]), .cin(c[k]), .sum(sum[k]), .cout(c[k + 1]));
		
		end
		
	endgenerate
	
	assign logical_and = x & y;
	
	always @(op)
	begin
		case(op)
			ADD_SUB: 
			begin
				alu_out_reg <= sum;
			end
			
			LOGICAL_AND:
			begin
				alu_out_reg <= logical_and;
			end
		endcase
	end
	
	assign alu_out = alu_out_reg;
	
endmodule 


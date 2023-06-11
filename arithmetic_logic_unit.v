module arithmetic_logic_unit 
#(parameter n = 8)
(
	input [n - 1: 0] x, y,
	input cin, add_sub_control,
	
	output [n - 1: 0] sum,
	output cout,
	output over_flow
);

	wire [n: 0] c;
	assign c[0] = cin;
	assign cout = c[n];
	
	wire [n - 1: 0] y_xor;
	
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
	
	assign over_flow = cout ^ c[7];
	
endmodule 


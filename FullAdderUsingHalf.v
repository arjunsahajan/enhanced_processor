module FullAdderUsingHalf 
(
	input a, b, cin,
	
	output sum, cout
);

	wire a1, b1, c1;

	HalfAdder HA0(a, b, a1, b1);
	HalfAdder HA1(a1, cin, sum, c1);

	assign cout = c1 | b1;

endmodule
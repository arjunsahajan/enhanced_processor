module arithmetic_logic_unit 
#(parameter n = 8)
(
	input [n - 1: 0] x, y,
	input cin, 
	input add_sub_control,
	input [1: 0] op,
	input [1: 0] shift_rot_type,
	
	output [n - 1: 0] alu_out,
	output cout,
	output z_flag
);
	
	parameter OP_ADD_SUB = 2'b00;
	parameter OP_LOGICAL_AND = 2'b01;
	parameter OP_SHFT_ROT = 2'b10;
	
	parameter LSL = 2'b00;
	parameter LSR = 2'b01;
	parameter ASR = 2'b10;
	parameter ROR = 2'b11;

	wire [n - 1: 0] sum;
	wire [n - 1: 0] logical_and;
	wire [n - 1: 0] y_xor;
	wire [n: 0] c;
	
	reg [n - 1: 0] alu_out_reg;
	reg z_flag_reg;
	reg [n - 1: 0] shift_rot_out_reg;
	
	// adder
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
	
	// barrel shifter
	always @(shift_rot_type)
	begin
		case(shift_rot_type)
			LSL:
			begin
				shift_rot_out_reg <= x << y;
			end
			
			LSR:
			begin
				shift_rot_out_reg <= x >> y;
			end
			
			ASR:
			begin
				shift_rot_out_reg <= {{n{x[n - 1]}}, x} >> y;
			end	
			
			ROR:
			begin
				shift_rot_out_reg <= (x >> y) | (x << (n - y));
			end
		endcase
	end
	
	// output select based on op
	always @(op)
	begin
		case(op)
			OP_ADD_SUB: 
				alu_out_reg <= sum;
			
			OP_LOGICAL_AND:
				alu_out_reg <= logical_and;
				
			OP_SHFT_ROT:
				alu_out_reg <= shift_rot_out_reg;
			
			default:
				alu_out_reg <= 16'bxxxx_xxxx_xxxx_xxxx;
		endcase
	end
	
	// nor implementation
	always @(alu_out)
	begin
		if(alu_out)
			z_flag_reg = 1'b0;
		else
			z_flag_reg = 1'b1;
	end
	
	assign c[0] = cin;
	assign cout = c[n];
	assign z_flag = z_flag_reg;
	assign alu_out = alu_out_reg;
	assign logical_and = x & y;
	
endmodule 


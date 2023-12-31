module control_unit_fsm
(
	input clk,
	input run,
	input reset_n,
	input [15: 0] IR_out,
	input [2: 0] flag_out,

	output reg sp_incr,
	output reg sp_decr,
	output reg flag_in,
	output reg pc_incr,
	output reg W_inp,
	output reg [1: 0] op,
	output reg add_sub_ctrl,
	output reg [3: 0] sel,
	output reg IR_in, G_in, A_in, ADDR_in, DOUT_in,
	output reg [7: 0] RX_in,
	output reg [1: 0] shift_rot_type,
	output reg done,
	output reg degub_sig
);
	
	parameter SEL_IR_REG = 4'b1000;
	parameter SEL_G_REG = 4'b1001;
	parameter SEL_PC_REG = 4'b0111;
	parameter SEL_DIN = 4'b1010;
	
	parameter OP_ADD_SUB = 2'b00;
	parameter OP_LOGICAL_AND = 2'b01;
	parameter OP_SHFT_ROT = 2'b10;

	parameter T0 = 3'b000;
	parameter T1 = 3'b001;
	parameter T2 = 3'b010;
	parameter T3 = 3'b011;
	parameter T4 = 3'b100;
	parameter T5 = 3'b101;
	parameter IDLE = 3'b110;

	parameter MV = 3'b000;
	parameter MVT_BRN = 3'b001;
	parameter ADD = 3'b010;
	parameter SUB = 3'b011;
	parameter LD_POP = 3'b100;
	parameter ST_PUSH = 3'b101;
	parameter AND = 3'b110;
	parameter CMP_SHFT_ROT = 3'b111;
	
	parameter AB = 3'b000;
	parameter EQ = 3'b001;
	parameter NE = 3'b010;
	parameter CC = 3'b011;
	parameter CS = 3'b100;
	parameter PL = 3'b101;
	parameter MI = 3'b110;
	parameter BL = 3'b111;
	
	parameter PC_in = 7;
	parameter LINK_in = 6;
	
	reg [2: 0] state, nxt_state;
		
	wire [2: 0] inst;
	wire [2: 0] RX;
	wire [2: 0] RY;
	wire imm_flag;
	wire cout, n_flag, z_flag;
	wire cmp_or_shft_rot;
	wire imm_flag_shft_rot;
	
	always @(state)
	begin
		// default values
		pc_incr <= 1'b0;
		sp_incr <= 1'b0;
		sp_decr <= 1'b0;
		IR_in <= 1'b1;
		G_in <= 1'b1;
		A_in <= 1'b1;
		flag_in <= 1'b1;
		RX_in <= 8'b11111111;
		ADDR_in <= 1'b1;
		DOUT_in <= 1'b1;
		W_inp <= 1'b0;
		done <= 1'b0;
		sel <= 4'bxxxx;
		op <= 2'bxx;
		shift_rot_type <= 2'bxx;
		degub_sig <= 1'b0;
		
		case(state)
			T0: // T0 clock cycle
			begin
				sel <= SEL_PC_REG;
				ADDR_in <= 1'b0;
				pc_incr <= 1'b1;
				
				nxt_state <= T1;
			end
		
			T1: // T1 clock cycle
			begin
				nxt_state <= T2;
			end
		
			T2: // T2 clock cycle
			begin
				IR_in <= 1'b0;
				nxt_state <= T3;
			end
				
			T3: // T3 clock cycle																																																		
			begin
				case(inst)
					MV: 
					begin
						if(imm_flag)
						begin
							sel <= SEL_IR_REG;
						end
						else
						begin
							sel <= RY;
						end
						
						RX_in[RX] <= 1'b0;
						done <= 1'b1;
					end
					
					ADD, SUB, AND:
					begin
						sel <= RX;
						A_in <= 1'b0;
					end
					
					LD_POP:
					begin
						if(imm_flag) // pop
						begin
							sel <= RY;
							ADDR_in <= 1'b0;
							sp_incr <= 1'b1;
						end
						else // ld
						begin
							sel <= RY;
							ADDR_in <= 1'b0;
						end
					end
					
					ST_PUSH:
					begin
						if(imm_flag) // push
						begin
							sp_decr <= 1'b1;
						end
						else // st
						begin
							sel <= RY;
							ADDR_in <= 1'b0;
						end
					end
					
					CMP_SHFT_ROT:
					begin
						sel <= RX;
						A_in <= 1'b0;
					end
					
					MVT_BRN:
					begin
						if(imm_flag)
						begin
							sel <= SEL_IR_REG;
							RX_in[RX] <= 1'b0;
							
							done <= 1'b1;
						end
						else
						begin
							sel <= SEL_PC_REG;
							A_in <= 1'b0;
							
							case(RX)
								AB:
								begin
									// always branch
									degub_sig <= 1'b1;
								end
								
								EQ:
								begin
									if(!z_flag)
									begin
										done <= 1'b1;
									end
								end
								
								NE:
								begin
									if(z_flag)
									begin
										done <= 1'b1;
									end
								end
								
								CC:
								begin
									if(cout)
									begin
										done <= 1'b1;
									end
								end
								
								CS:
								begin
									if(!cout)
									begin
										done <= 1'b1;
									end
								end
								
								PL:
								begin
									if(n_flag)
									begin
										done <= 1'b1;
									end
								end
								
								MI:
								begin
									if(!n_flag)
									begin
										done <= 1'b1;
									end
								end
								
								default:
								begin
									done <= 1'b1;
								end
								
								BL:
								begin
									sel <= SEL_PC_REG;
									A_in <= 1'b0;
									RX_in[LINK_in] <= 1'b0;
								end
							endcase
						end
					end
				endcase
				
				nxt_state <= T4;
			end
			
			T4: // T4 clock cycle
			begin
				case(inst)
					ADD:
					begin
						if(imm_flag)
						begin
							sel <= SEL_IR_REG;
						end
						else
						begin
							sel <= RY;
						end
						
						add_sub_ctrl <= 1'b0;
						G_in <= 1'b0;
						flag_in <= 1'b0;
					end	
					
					SUB:
					begin
						if(imm_flag)
						begin
							sel <= SEL_IR_REG;
						end
						else
						begin
							sel <= RY;
						end
						
						add_sub_ctrl <= 1'b1;
						G_in <= 1'b0;
						flag_in <= 1'b0;
					end
					
					AND:
					begin
						if(imm_flag)
						begin
							sel <= SEL_IR_REG;
						end
						else
						begin
							sel <= RY;
						end
						
						G_in <= 1'b0;
						flag_in <= 1'b0;
					end
					
					ST_PUSH:
					begin
						if(imm_flag) // push
						begin
							sel <= RY;
							ADDR_in <= 1'b0;
						end
						else // st
						begin
							sel <= RX;
							DOUT_in <= 1'b0;
							W_inp <= 1'b1;
							
							done <= 1'b1;
						end
					end
					
					CMP_SHFT_ROT:
					begin
						if(imm_flag) // cmp with immediate
						begin
							sel <= SEL_IR_REG;
							add_sub_ctrl <= 1'b1;
							op <= OP_ADD_SUB;
							flag_in <= 1'b0;
							
							done <= 1'b1;
						end
						else
						begin
							if(cmp_or_shft_rot) // shift or rotate
							begin
								shift_rot_type <= IR_out[6: 5];
							
								if(imm_flag_shft_rot)
								begin
									sel <= SEL_IR_REG;
								end
								else
								begin
									sel <= RY;
								end
								
								op <= OP_SHFT_ROT;
								G_in <= 1'b0;
								flag_in <= 1'b0;
							end
							else // cmp with register
							begin 
								sel <= RY;
								add_sub_ctrl <= 1'b1;
								op <= OP_ADD_SUB;
								flag_in <= 1'b0;
								
								done <= 1'b1;
							end
						end
					end
					
					MVT_BRN:
					begin
						sel <= SEL_IR_REG;
						G_in <= 1'b0;
						add_sub_ctrl <= 1'b0;
						op <= OP_ADD_SUB;
					end
				endcase
			
				nxt_state <= T5;
			end
			
			T5: // T5 clock cycle
			begin
				case(inst)
					ADD, SUB:
					begin
						sel <= SEL_G_REG;
						RX_in[RX] <= 1'b0;
						op <= OP_ADD_SUB;
						
						done <= 1'b1;
					end
					
					AND:
					begin
						sel <= SEL_G_REG;
						RX_in[RX] <= 1'b0;
						op <= OP_LOGICAL_AND;
						
						done <= 1'b1;
					end
					
					LD_POP:
					begin
						if(imm_flag) //pop
						begin
							sel <= SEL_DIN;
							RX_in[RX] <= 1'b0;
							
							done <= 1'b1;
						end
						else // ld
						begin
							sel <= SEL_DIN;
							RX_in[RX] <= 1'b0;
							
							done <= 1'b1;
						end
					end
					
					ST_PUSH:
					begin
						if(imm_flag) // push
						begin
							sel <= RX;
							DOUT_in <= 1'b0;
							W_inp <= 1'b1;
							
							done <= 1'b1;
						end
					end
					
					MVT_BRN:
					begin
						sel <= SEL_G_REG;
						RX_in[PC_in] <= 1'b0;
						
						done <= 1'b1;
					end
					
					CMP_SHFT_ROT:
					begin
						sel <= SEL_G_REG;
						RX_in[RX] = 1'b0;
						
						done <= 1'b1;
					end
				endcase
			end
			
			IDLE:
				nxt_state <= IDLE;
		endcase
	end
	
	always @(posedge clk)
	begin
	
		if(!reset_n)
			state <= IDLE;
		else if(!run || done)
			state <= T0;
		else
			state <= nxt_state;
	end
	
	assign inst = IR_out[15: 13];
	assign RX = IR_out[11: 9];
	assign RY = IR_out[2: 0];
	assign imm_flag = IR_out[12];
	assign imm_flag_shft_rot = IR_out[7];
	assign cmp_or_shft_rot = IR_out[8];
	
	assign cout = flag_out[2];
	assign n_flag = flag_out[1];
	assign z_flag = flag_out[0];
endmodule

module control_unit_fsm
(
	input clk,
	input run,
	input reset_n,
	input [15: 0] IR_out,

	output reg pc_incr,
	output reg W_inp,
	output reg [1: 0] op,
	output reg add_sub_ctrl,
	output reg [3: 0] sel,
	output reg IR_in, G_in, A_in, ADDR_in, PC_in, DOUT_in,
	output reg [7: 0] RX_in,
	output reg done
);
	
	parameter SEL_IR_REG = 4'b1000;
	parameter SEL_G_REG = 4'b1001;
	parameter SEL_PC_REG = 4'b0111;
	parameter SEL_DIN = 4'b1010;
	
	parameter ADD_SUB = 2'b00;
	parameter LOGICAL_AND = 2'b01;

	parameter T0 = 3'b000;
	parameter T1 = 3'b001;
	parameter T2 = 3'b010;
	parameter T3 = 3'b011;
	parameter T4 = 3'b100;
	parameter T5 = 3'b101;
	parameter IDLE = 3'b110;

	parameter MV = 3'b000;
	parameter MVT = 3'b001;
	parameter ADD = 3'b010;
	parameter SUB = 3'b011;
	parameter LD = 3'b100;
	parameter ST = 3'b101;
	parameter AND = 3'b110;
	
	reg [2: 0] state, nxt_state;
		
	wire [2: 0] inst;
	wire [2: 0] RX;
	wire [2: 0] RY;
	wire imm_flag;
	
	always @(state)
	begin
		// default values
		pc_incr <= 1'b0;
		IR_in <= 1'b1;
		G_in <= 1'b1;
		A_in <= 1'b1;
		RX_in <= 8'b11111111;
		ADDR_in <= 1'b1;
		DOUT_in <= 1'b1;
		PC_in <= 1'b1;
		W_inp <= 1'b0;
		done <= 1'b0;
		sel <= 4'bxxxx;
		op <= 2'bxx;
		
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
					
					MVT:
					begin
						sel <= SEL_IR_REG;
						RX_in[RX] <= 1'b0;
						
						done <= 1'b1;
					end
					
					ADD, SUB, AND:
					begin
						sel <= RX;
						A_in <= 1'b0;
					end
					
					LD, ST:
					begin
						sel <= RY;
						ADDR_in <= 1'b0;
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
					end
					
					ST:
					begin
						sel <= RX;
						DOUT_in <= 1'b0;
						W_inp <= 1'b1;
						
						done <= 1'b1;
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
						op <= ADD_SUB;
						
						done <= 1'b1;
					end
					
					AND:
					begin
						sel <= SEL_G_REG;
						RX_in[RX] <= 1'b0;
						op <= LOGICAL_AND;
						
						done <= 1'b1;
					end
					
					LD:
					begin
						sel <= SEL_DIN;
						RX_in[RX] <= 1'b0;
						
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
	
		if(!reset_n || done)
			state <= IDLE;
		else if(!run)
			state <= T0;
		else
			state <= nxt_state;
		
	end
	
	assign inst = IR_out[15: 13];
	assign RX = IR_out[11: 9];
	assign RY = IR_out[2: 0];
	assign imm_flag = IR_out[12];
	
endmodule

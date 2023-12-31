module enhanced_processor
(
	input clk_50MHz,
	input run,
	input reset_n,
	
	output [15: 0] IR_out, R0_out, R1_out, R2_out, R3_out, R4_out, SP_out, LINK_out, PC_out, G_out, A_out, DOUT_out,
	output [7: 0] ADDR_out,
	output [2: 0] flag_out,
	output W_out, W_inp,
	output [15: 0] mux_out,
	output [15: 0] alu_out,
	output add_sub_ctrl,
	output cout, z_flag,
	output [3: 0] sel,
	output IR_in, G_in, A_in, ADDR_in, DOUT_in, flag_in,
	output [7: 0] RX_in,
	output [15: 0] DIN,
	output pc_incr,
	output sp_incr,
	output sp_decr,
	output [1: 0] op,
	output [1: 0] shift_rot_type,
	output done,
	output degub_sig
);
	
	inst_mem IM
	(
		.clock(clk_50MHz),
		.address(ADDR_out),
		.wren(W_out),
		.data(DOUT_out),
		
		.q(DIN)
	);
	
	// Instruction register
	regn #(.N(16)) IR
	(
		.clk(clk_50MHz),
		.D(DIN),
		.load(IR_in),
		.clear(reset_n),
		
		.Q(IR_out)
	);
	
	control_unit_fsm CUF
	(
		.clk(clk_50MHz),
		.IR_out(IR_out),
		.run(run),
		.reset_n(reset_n),
		.flag_out(flag_out),
		
		.sp_incr(sp_incr),
		.sp_decr(sp_decr),
		.degub_sig(degub_sig),
		.flag_in(flag_in),
		.DOUT_in(DOUT_in),
		.ADDR_in(ADDR_in),
		.pc_incr(pc_incr),
		.W_inp(W_inp),
		.add_sub_ctrl(add_sub_ctrl),
		.op(op),
		.sel(sel),
		.IR_in(IR_in),
		.G_in(G_in), 
		.A_in(A_in),
		.RX_in(RX_in),
		.shift_rot_type(shift_rot_type),
		.done(done)
	);
	
	// 16-bit general purpose registers R0 - R6
	regn #(.N(16)) R0
	(
		.clk(clk_50MHz),
		.D(mux_out),
		.load(RX_in[0]),
		.clear(reset_n),
		
		.Q(R0_out)
	);
	
	regn #(.N(16)) R1
	(
		.clk(clk_50MHz),
		.D(mux_out),
		.load(RX_in[1]),
		.clear(reset_n),
		
		.Q(R1_out)
	);
	
	regn #(.N(16)) R2
	(
		.clk(clk_50MHz),
		.D(mux_out),
		.load(RX_in[2]),
		.clear(reset_n),
		
		.Q(R2_out)
	);
	
	regn #(.N(16)) R3
	(
		.clk(clk_50MHz),
		.D(mux_out),
		.load(RX_in[3]),
		.clear(reset_n),
		
		.Q(R3_out)
	);
	
	regn #(.N(16)) R4
	(
		.clk(clk_50MHz),
		.D(mux_out),
		.load(RX_in[4]),
		.clear(reset_n),
		
		.Q(R4_out)
	);
	
	// Stack pointer
	stack_ptr SP
	(
		.clk(clk_50MHz),
		.D(mux_out),
		.load(RX_in[5]),
		.reset_n(reset_n),
		.sp_incr(sp_incr),
		.sp_decr(sp_decr),
		
		.Q(SP_out)
	);
	
	// Link register
	regn #(.N(16)) LINK
	(
		.clk(clk_50MHz),
		.D(mux_out),
		.load(RX_in[6]),
		.clear(reset_n),
		
		.Q(LINK_out)
	);
	
	// Program counter
	cntr PC
	(
		.clk(clk_50MHz),
		.en(pc_incr),
		.D(mux_out),
		.load(RX_in[7]),
		.reset_n(reset_n),
		
		.Q(PC_out)
	);
	
	// Output register
	regn #(.N(16)) G
	(
		.clk(clk_50MHz),
		.D(alu_out),
		.load(G_in),
		.clear(reset_n),
		
		.Q(G_out)
	);

	// Accumulator
	regn #(.N(16)) A
	(
		.clk(clk_50MHz),
		.D(mux_out),
		.load(A_in),
		.clear(reset_n),
		
		.Q(A_out)
	);
	
	// Address register
	regn #(.N(16)) ADDR
	(
		.clk(clk_50MHz),
		.D(mux_out),
		.load(ADDR_in),
		.clear(reset_n),
		
		.Q(ADDR_out)
	);
	
	// Data out register
	regn #(.N(16)) DOUT
	(
		.clk(clk_50MHz),
		.D(mux_out),
		.load(DOUT_in),
		.clear(reset_n),
		
		.Q(DOUT_out)
	);
	
	// Write enable register
	regn_no_load #(.N(1)) WD
	(
		.clk(clk_50MHz),
		.D(W_inp),
		.clear(reset_n),
		
		.Q(W_out)
	);
	
	// Flag register
	regn #(.N(3)) flag
	(
		.clk(clk_50MHz),
		.D({cout, alu_out[15], z_flag}),
		.load(flag_in),
		.clear(reset_n),
		
		.Q(flag_out)
	);
	
	mux MX
	(
		.inp0(R0_out),
		.inp1(R1_out),
		.inp2(R2_out),
		.inp3(R3_out),
		.inp4(R4_out),
		.inp5(SP_out),
		.inp6(LINK_out),
		.inp7(PC_out),
		.inp8(IR_out),
		.inp9(G_out),
		.inp10(DIN),
		.sel(sel),
		
		.mux_out(mux_out)
	);
	
	arithmetic_logic_unit #(.n(16)) ALU
	(
		.x(A_out), 
		.y(mux_out), 
		.cin(add_sub_ctrl), 
		.add_sub_control(add_sub_ctrl),
		.op(op),
		.shift_rot_type(shift_rot_type),
		
		.alu_out(alu_out),
		.cout(cout),
		.z_flag(z_flag)
	);
	
endmodule

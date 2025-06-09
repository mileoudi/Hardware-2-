package rounding_pkg; 

typedef enum logic [2:0] {
    IEEE_near,
    IEEE_zero,
    IEEE_pinf,
    IEEE_ninf,
    near_up,
	away_zero
} round_mode_t;

endpackage

import rounding_pkg::*;

module fp_mult (
	input  logic [31:0] a,
	input  logic [31:0] b,
	input  logic [2:0] rnd,

	output logic [31:0] z,
	output logic [7:0] status,
	input logic clk, rst
);

logic sign;
logic [9:0] exp_sum;      
logic [47:0] mant_prod;    

logic [22:0] mant_norm;
logic [9:0]  exp_norm;

logic guard, sticky;
logic overflow=1'b0;
logic underflow=1'b0;

logic [22:0] mant_pipe;
logic [9:0]  exp_pipe;  
logic sign_pipe;
logic [31:0] a_pipe, b_pipe;
logic guard_pipe, sticky_pipe;
logic [2:0] round_mode_pipe;

logic [23:0] mantissa_round_input;
logic [24:0] mant_round;
logic round_sign;
logic [2:0] round_mode;
logic inexact;

logic [9:0]  status_flags;

logic [31:0] z_calc;
logic zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f;

assign sign = a[31] ^ b[31];
assign exp_sum = (a[30:23]+b[30:23])-10'd127;
assign mant_prod = {1'b1, a[22:0]}*{1'b1, b[22:0]};

assign round_mode = rnd;

normalize_mult norm(
	.P(mant_prod),
	.S(exp_sum),
	.guard(guard),
	.sticky(sticky),
	.norm_exponent(exp_norm),
	.norm_mantissa(mant_norm)
);

always_ff @(posedge clk or negedge rst) begin
	if(!rst) begin
		sign_pipe<=1'b0;
		exp_pipe<=10'b0;
		mant_pipe<=23'b0;
		a_pipe<=32'b0;
		b_pipe<=32'b0;
		guard_pipe<=1'b0;
		sticky_pipe<=1'b0;
		round_mode_pipe<=3'b0;
		mantissa_round_input<=24'b0;
	end 
	else begin
		sign_pipe<=a[31]^b[31];
		exp_pipe<=exp_norm;
		mant_pipe<=mant_norm;
		a_pipe<=a;
		b_pipe<=b;
		mantissa_round_input <= {1'b1, mant_norm}; 
		guard_pipe<=guard;
		sticky_pipe<=sticky;
		round_mode_pipe<=round_mode;
	end
end

round_mult round(
    	.mantissa_round_input(mantissa_round_input),
	.pipe_sign(sign_pipe),
    	.pipe_guard(guard_pipe),
    	.pipe_sticky(sticky_pipe),
    	.round_mode(round_mode_pipe),

    	.round_mantissa(mant_round),
	.round_sign(round_sign),
    	.inexact(inexact)
);

logic [24:0] post_mantissa;
logic [9:0] post_exponent;
always_comb begin
  if (mant_round[24] == 1'b1) begin 
	post_mantissa = mant_round >> 1; 
	post_exponent = exp_pipe + 1;
	end
  else begin
	post_mantissa = mant_round;
	post_exponent = exp_pipe;
	end
end

assign z_calc = {sign_pipe,post_exponent[7:0],post_mantissa[22:0]};

always_comb begin
  if (post_exponent >= 10'd255)
    overflow = 1;
  else
    overflow = 0;

  if (post_exponent <= 10'd0)
    underflow = 1;
  else
    underflow = 0;
end

exception_mult exception_handler(
        .a(a_pipe),
        .b(b_pipe),
        .z_calc(z_calc),
        .overflow(overflow),
        .underflow(underflow),
        .inexact(inexact),
        .round_mode(round_mode_pipe),

        .z(z),
        .zero_f(zero_f),
        .inf_f(inf_f),
        .nan_f(nan_f),
        .tiny_f(tiny_f),
        .huge_f(huge_f),
        .inexact_f(inexact_f)
);
assign status_flags = {1'b0, 1'b0, inexact_f, huge_f, tiny_f, nan_f, inf_f, zero_f};
assign status = status_flags;

endmodule 
package rounding_pkg;

typedef enum logic [2:0] {
    IEEE_near = 3'b000,
    IEEE_zero = 3'b001,
    IEEE_pinf = 3'b010,
    IEEE_ninf = 3'b011,
    near_up = 3'b100,
	away_zero = 3'b101
} round_mode_t;

endpackage

import rounding_pkg::*;

module fp_mult (
	input logic clk,
	input logic rst_n,
	input  logic [31:0] a,
	input  logic [31:0] b,
    input  logic [2:0]  rnd,
    
	output logic [31:0] z,
    output logic [7:0]  status
);

logic sign;
logic [9:0] exp_add; 
logic [47:0] mantissa_mult;

logic [9:0] norm_exponent;
logic [22:0] norm_mantissa;
logic guard, sticky;

logic pipe_sign;
logic [9:0] pipe_exponent;
logic [22:0] pipe_mantissa;
logic pipe_guard, pipe_sticky; 

logic [2:0] round_mode;
always_comb begin
    round_mode = rnd;
end
logic round_sign;
logic [9:0] round_exponent;
logic [22:0] round_mantissa;
logic round_guard, round_sticky;

logic overflow = 1'b0;
logic underflow= 1'b0;

logic [31:0] z_calc;
logic [31:0] k;
logic zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f;

assign sign = a[31] ^ b[31];
assign exp_add = ({2'b00, a[30:23]}+{2'b00, b[30:23]})-10'd127;
assign mantissa_mult = {1'b1, a[22:0]}*{1'b1, b[22:0]};

normalize_mult norm(
	.P(mantissa_mult),
	.S(exp_add),
	.guard(guard),
	.sticky(sticky),
	.norm_exponent(norm_exponent),
	.norm_mantissa(norm_mantissa)
);

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		pipe_sign<=1'b0;
		pipe_exponent<=10'b0;
		pipe_mantissa<=23'b0;
		pipe_guard<=1'b0;
		pipe_sticky<=1'b0;
	end 
	else begin
		pipe_sign<=sign;
		pipe_exponent<=norm_exponent;
		pipe_mantissa<=norm_mantissa;
		pipe_guard<=guard;
		pipe_sticky<=sticky;
	end
end

round_mult round(
    	.pipe_sign(pipe_sign),
    	.pipe_exponent(pipe_exponent),
    	.pipe_mantissa(pipe_mantissa),
    	.pipe_guard(pipe_guard),
    	.pipe_sticky(pipe_sticky),
    	.round_mode(round_mode),

    	.round_sign(round_sign),
    	.round_exponent(round_exponent),
    	.round_mantissa(round_mantissa),
    	.round_guard(round_guard),
    	.round_sticky(round_sticky),
	.z_calc(z_calc),
    	.inexact(inexact)
);

always_comb begin

    if (round_exponent[7:0] == 8'b1111_1111) 
		overflow = 1; 
    else 
		overflow = 0;
	    
    if (round_exponent[7:0] == 8'b0000_0000)
		underflow = 1; 
    else 
		underflow = 0;
end

exception_mult exception_handler(
        .a(a),
        .b(b),
        .z_calc(z_calc),
        .overflow(overflow),
        .underflow(underflow),
        .inexact(inexact),
        .round_mode(round_mode),
        .z(z),
		.k(k),
        .zero_f(zero_f),
        .inf_f(inf_f),
        .nan_f(nan_f),
        .tiny_f(tiny_f),
        .huge_f(huge_f),
        .inexact_f(inexact_f)
);

endmodule
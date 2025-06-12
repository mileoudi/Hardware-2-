import rounding_pkg::*;

module exception_mult (
    input logic [31:0] a, b,
    input logic [31:0] z_calc,
    input logic underflow, overflow,
    input logic inexact,
    input logic [2:0] round_mode,

    output logic [31:0] z,
    output logic zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f
);

typedef enum logic [2:0] {
    ZERO,
    INF,
    NORM,
    MIN_NORM,
    MAX_NORM
} interp_t;

function interp_t num_interp(logic [31:0] signal);

case(signal[30:23])
  8'b1111_1111: return INF; 
  8'b0000_0000: return ZERO; 
  default: return NORM; 
endcase

endfunction

function logic [30:0] z_num(interp_t interp);

case(interp)
  ZERO:     return 31'b00000000_00000000000000000000000; 
  INF:      return 31'b11111111_00000000000000000000000;
  MIN_NORM: return 31'b00000001_00000000000000000000000;
  MAX_NORM: return 31'b11111110_11111111111111111111111;
  default: return 31'b0;
endcase 

endfunction

always_comb begin
    zero_f = 0;
    inf_f = 0;
    nan_f = 0;
    tiny_f = 0;
    huge_f = 0;
    inexact_f = 0;

    case ({num_interp(a),num_interp(b)})
        // Zero * Zero, Zero * Norm, Norm * Zero => Zero result
        {ZERO, ZERO}, {ZERO, NORM}, {NORM, ZERO}: begin
            zero_f = 1;
            z = {z_calc[31], z_num(ZERO)};
        end

        // Zero * Inf (or NaN) => treat as Inf
        {ZERO, INF}, {INF, ZERO}: begin
            inf_f = 1;
            nan_f = 1; 
            z = {1'b0, z_num(INF)}; // Always +INF
        end

        // Inf * Inf, Inf * Norm, Norm * Inf => Inf result
        {INF, INF}, {INF, NORM}, {NORM, INF}: begin
            inf_f = 1;
            z = {z_calc[31], z_num(INF)};
        end

        // Normal * Normal => check overflow / underflow
        {NORM, NORM}: begin
            if (overflow) begin
                huge_f = 1;
                inexact_f = 1;
                case (round_mode)
                    IEEE_near, away_zero: begin
                        z = {z_calc[31], z_num(INF)};
                        inf_f = 1;
                    end
                    IEEE_zero: begin
                        z = {z_calc[31], z_num(MAX_NORM)};
                    end
                    IEEE_pinf, near_up: begin
                        if (!(z_calc[31])) begin 
                            z = {z_calc[31], z_num(INF)};
                            inf_f = 1;
                        end else begin 
                            z = {z_calc[31], z_num(MAX_NORM)};
                        end
                    end
                    IEEE_ninf: begin
                        if (!(z_calc[31])) begin
                            z = {z_calc[31], z_num(MAX_NORM)};
                        end else begin
                            z = {z_calc[31], z_num(INF)};
                            inf_f = 1;
                        end
                    end
                endcase
            end
            else if (underflow) begin
                tiny_f = 1;
                inexact_f = 1;
                case (round_mode)
                    IEEE_near, away_zero: begin
                        z = {z_calc[31], z_num(MIN_NORM)};
                    end
                    IEEE_zero: begin
                        z = {z_calc[31], z_num(ZERO)};
                        zero_f = 1;
                    end
                    IEEE_pinf, near_up: begin
                        if (!(z_calc[31])) begin
                            z = {z_calc[31], z_num(MIN_NORM)};
                        end else begin
                            z = {z_calc[31], z_num(ZERO)};
                            zero_f = 1;
                        end
                    end
                    IEEE_ninf: begin
                        if (!(z_calc[31])) begin
                            z = {z_calc[31], z_num(ZERO)};
                            zero_f = 1;
                        end else begin
                            z = {z_calc[31], z_num(MIN_NORM)};
                        end
                    end
                endcase
            end
            else begin
                z = z_calc;
                inexact_f = inexact;
            end
        end

	default: 
	    begin
                z = {z_calc[31], 31'b0};
                zero_f = 1'b1;
            end
        endcase
end

endmodule	

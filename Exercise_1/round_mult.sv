import rounding_pkg::*;

module round_mult (
    input logic [23:0] mantissa_round_input, 
    input logic pipe_guard,
    input logic pipe_sticky,
    input logic pipe_sign,
    input logic [2:0] round_mode,

    output logic [24:0] round_mantissa,
	output logic round_sign,
    output logic inexact
);

logic [24:0] mantissa_extended; 


always_comb begin 
    mantissa_extended={1'b0, mantissa_round_input}; // 25 bits for rounding
    inexact=(pipe_guard|pipe_sticky);
    
    case (round_mode)
        IEEE_near: begin
            if (pipe_guard && (pipe_sticky || mantissa_extended[0])) begin
                mantissa_extended=mantissa_extended+1;
            end
        end

        IEEE_zero: begin
    	// No rounding: result is mantissa_extended as is.
        end
        
        IEEE_pinf: begin
            if(!pipe_sign && inexact) begin
                mantissa_extended=mantissa_extended+1;
            end
        end

        IEEE_ninf: begin
            if(pipe_sign && inexact) begin
                mantissa_extended=mantissa_extended+1;
            end
        end

        near_up: begin
            if(pipe_guard && (pipe_sticky || mantissa_extended[0])) begin
                mantissa_extended=mantissa_extended+1;
            end
        end

        away_zero: begin 
            if(inexact) begin
                mantissa_extended=mantissa_extended+1;
            end
        end

        default: begin
            if(pipe_guard && (pipe_sticky || mantissa_extended[0])) begin
                mantissa_extended=mantissa_extended+1;
            end
        end
    endcase
    round_mantissa=mantissa_extended;   
	round_sign=pipe_sign;
end
endmodule
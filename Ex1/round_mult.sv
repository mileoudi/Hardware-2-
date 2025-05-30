import rounding_pkg::*;

module round_mult (
    input logic pipe_sign,
    input logic [9:0] pipe_exponent,
    input logic [22:0] pipe_mantissa,
    input logic pipe_guard, pipe_sticky, 
    input logic [2:0] round_mode,

    output logic round_sign,
    output logic [9:0] round_exponent,
    output logic [22:0] round_mantissa,
    output logic round_guard, round_sticky,
    output logic [31:0] z_calc,
    output logic inexact
);

logic [24:0] mantissa_extended; 


always_comb begin 
    mantissa_extended = {1'b0, pipe_mantissa}; 
    inexact=(pipe_guard|pipe_sticky);
    
    case (round_mode)
        IEEE_near: begin
            if (pipe_guard && (pipe_sticky || mantissa_extended[0])) begin
                mantissa_extended=mantissa_extended+1;
            end
        end

        IEEE_zero: begin
    
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
            if(pipe_guard&&(pipe_sticky||mantissa_extended[0])) begin
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
	if (mantissa_extended[24] == 1'b1) begin
            round_mantissa = mantissa_extended>>1; 
            round_exponent = pipe_exponent + 1;  
    end 
    else begin
            round_mantissa = mantissa_extended;   
            round_exponent = pipe_exponent; 
    end
    
    round_sign = pipe_sign;
	round_guard = pipe_guard;
    round_sticky = pipe_sticky;   
    z_calc = {round_sign, round_exponent[7:0], round_mantissa[22:0]};

end
endmodule
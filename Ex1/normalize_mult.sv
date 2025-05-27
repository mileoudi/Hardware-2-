module normalize_mult (
	input logic [47:0] P,
	input logic [8:0] S,

	output logic [9:0] norm_exponent,
	output logic [22:0] norm_mantissa,
	output logic sticky, guard
);

always @(*) 
begin
	norm_exponent=S;
	if (P[47]) begin
		norm_mantissa=P[46:23];
		guard=P[22];
		sticky=|P[21:0];
		norm_exponent=S+1;
	end 
	else begin
		norm_mantissa=P[45:22];
		guard=P[21];
		sticky=|P[20:0];
	end	
end

endmodule
module Cond_Unit(
	input[3:0] NZCV_in,
	input[3:0] ALUFlags,
	input SvalueE,
	output reg[3:0] NZCV_out
	);
	
	
	always @ (*)
	begin
		NZCV_out = (SvalueE == 1'b1) ? ALUFlags : NZCV_in;	
	end
	
endmodule

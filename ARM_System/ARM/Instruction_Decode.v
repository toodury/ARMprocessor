module Instruction_Decode(
	input[31:0] inst,
	output reg[3:0] ReadAddr1,
	output reg[3:0] ReadAddr2,
	output reg[3:0] WriteAddr
	);
	

	always @ (*)
	begin
		ReadAddr1 = inst[19:16];
		ReadAddr2 = inst[3:0];
		WriteAddr = inst[15:12];
	end

endmodule

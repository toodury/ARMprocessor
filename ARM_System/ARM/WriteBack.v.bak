module WriteBack(
	input[31:0] ReadDataW,
	input[31:0] ALUOutW,
	input MemtoRegW,
	output reg[31:0] ResultW
	);
	
	always @ (*)
	begin
		if (MemtoRegW == 1'b1) ResultW = ReadDataW;
		else ResultW = ALUOutW;
	end

endmodule

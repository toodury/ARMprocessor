module MEM(
	input[31:0] ALUResult,
	input[31:0] WriteDataM,
	input MemWriteM,
	output reg[31:0] memaddr,
	output reg[31:0] writedata,
	output reg memwrite,
	output reg memread);

	always @ (*)
	begin
		memaddr = ALUResult;
		writedata = WriteDataM;
		memwrite = MemWriteM;
		memread = 1'b1;
	end

endmodule

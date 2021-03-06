module MEMWB_Register(
	input clk,
	input reset,
	input RegWriteM,
	input MemtoRegM,
	input[31:0] readdata,
	input[31:0] ALUResultM,
	input[3:0] WriteAddrM,
	input StoreM,
	input CmpM,
	input PCSrcM,
	input BranchM,
	input LoadM,
	output reg LoadW,
	output reg BranchW,
	output reg PCSrcW,
	output reg CmpW,
	output reg StoreW,
	output reg RegWriteW,
	output reg MemtoRegW,
	output reg[31:0] ReadDataW,
	output reg[31:0] ALUOutW,
	output reg[3:0] WriteAddrW);
	

	always @ (negedge clk)
	begin
	if (reset)
	begin
		RegWriteW <= 1'b0;
		MemtoRegW <= 1'b0;
		ReadDataW <= 'h00000000;
		ALUOutW <= 'h00000000;
		WriteAddrW <= 4'b0000;
		StoreW <= 1'b0;
		CmpW <= 1'b0;
		PCSrcW <= 1'b0;
		BranchW <= 1'b0;
		LoadW <= 1'b0;
	end
	else
	begin
		RegWriteW <= RegWriteM;
		MemtoRegW <= MemtoRegM;
		ReadDataW <= readdata;
		ALUOutW <= ALUResultM;
		WriteAddrW <= WriteAddrM;
		StoreW <= StoreM;
		CmpW <= CmpM;
		PCSrcW <= PCSrcM;
		BranchW <= BranchM;
		LoadW <= LoadM;
	end
	end

endmodule

module EXMEM_Register(
	input clk,
	input reset,
	input RegWriteE,
	input MemtoRegE,
	input MemWriteE,
	input[3:0] WriteAddrE,
	input[31:0] WriteDataE,
	input[31:0] ALUResultE,
	input StoreE,
	input CmpE,
	input PCSrcE,
	input BranchE,
	input LoadE,
	output reg LoadM,
	output reg BranchM,
	output reg PCSrcM,
	output reg CmpM,
	output reg StoreM,
	output reg RegWriteM,
	output reg MemtoRegM,
	output reg MemWriteM,
	output reg[3:0] WriteAddrM,
	output reg[31:0] WriteDataM,
	output reg[31:0] ALUResultM);

	always @ (negedge clk)
	begin
	if (reset)
	begin
		RegWriteM <= 1'b0;
		MemtoRegM <= 1'b0;
		MemWriteM <= 1'b0;
		WriteAddrM <= 4'b0000;
		WriteDataM <= 'h00000000;
		ALUResultM <= 'h00000000;
		StoreM <= 1'b0;
		CmpM <= 1'b0;
		PCSrcM <= 1'b0;
		BranchM <= 1'b0;
		LoadM <= 1'b0;
	end
	else
	begin
		RegWriteM <= RegWriteE;
		MemtoRegM <= MemtoRegE;
		MemWriteM <= MemWriteE;
		WriteAddrM <= WriteAddrE;
		WriteDataM <= WriteDataE;
		ALUResultM <= ALUResultE;
		StoreM <= StoreE;
		CmpM <= CmpE;
		PCSrcM <= PCSrcE;
		BranchM <= BranchE;
		LoadM <= LoadE;
	end
	end

endmodule

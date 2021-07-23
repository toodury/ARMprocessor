module IDEX_Register(
	input clk,
	input reset,
	input IDEXWrite,
	input PCSrcD,
	input RegWriteD,
	input MemWriteD,
	input MemtoRegD,
	input ALUSrcD,
	input SvalueD,
	input BranchD,
	input[3:0] ALUOpD,
	input[31:0] ExtImmD,
	input[3:0] WriteAddrD,
	input[3:0] NZCV_out,
	input StoreD,
	input[3:0] ReadAddr1,
	input[3:0] ReadAddr2,
	input LoadD,
	input[1:0] opD,
	input CmpD,
	output reg CmpE,
	output reg[1:0] opE,
	output reg LoadE,
	output reg[3:0] ReadAddr1E,
	output reg[3:0] ReadAddr2E,
	output reg StoreE,
	output reg[3:0] NZCV_in,
	output reg[3:0] WriteAddrE,
	output reg[31:0] ExtImmE,
	output reg[3:0] ALUOpE,
	output reg PCSrcE,
	output reg RegWriteE,
	output reg MemWriteE,
	output reg MemtoRegE,
	output reg ALUSrcE,
	output reg SvalueE,
	output reg BranchE);
	
	
	always @ (negedge clk)
	begin
	if (reset == 1'b1 || IDEXWrite == 1'b0)
	begin
		ALUOpE <= 1'b0;
		PCSrcE <= 1'b0;
		RegWriteE <= 1'b0;
		MemWriteE <= 1'b0;
		MemtoRegE <= 1'b0;
		ALUSrcE <= 1'b0;
		SvalueE <= 1'b0;
		BranchE <= 1'b0;
		WriteAddrE <= 4'b0000;
		ExtImmE <= 'h000000000;
		NZCV_in <= 4'b0000;
		StoreE <= 1'b0;
		ReadAddr1E <= 4'b0000;
		ReadAddr2E <= 4'b0000;
		LoadE <= 1'b0;
		opE <= 2'b00;
		CmpE <= 1'b0;
	end
	else
	begin
		ALUOpE <= ALUOpD;
		PCSrcE <= PCSrcD;
		RegWriteE <= RegWriteD;
		MemWriteE <= MemWriteD;
		MemtoRegE <= MemtoRegD;
		ALUSrcE <= ALUSrcD;
		SvalueE <= SvalueD;
		BranchE <= BranchD;
		WriteAddrE <= WriteAddrD;
		ExtImmE <= ExtImmD;
		NZCV_in <= NZCV_out;
		StoreE <= StoreD;
		ReadAddr1E <= ReadAddr1;
		ReadAddr2E <= ReadAddr2;
		LoadE <= LoadD;
		opE <= opD;
		CmpE <= CmpD;
	end
	end
	

endmodule

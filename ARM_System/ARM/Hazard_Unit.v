module Hazard_Unit(
	input[3:0] WriteAddrD,
	input[3:0] WriteAddrE,
	input[3:0] WriteAddrM,
	input[3:0] WriteAddrW,
	input StoreD,
	input StoreE,
	input[3:0] ReadAddr1,
	input[3:0] ReadAddr2,
	input[3:0] ReadAddr1E,
	input[3:0] ReadAddr2E,
	input[31:0] ReadData3E,
	input[31:0] ALUResultM,
	input[31:0] ResultW,
	input[31:0] readdata,
	input LoadE,
	input LoadM,
	input LoadW,
	input BranchD,
	input BranchE,
	input BranchM,
	input BranchW,
	input[1:0] opD,
	input[1:0] opE,
	input PCSrcD,
	input PCSrcM,
	input PCSrcW,
	input RegWriteD,
	input RegWriteE,
	input RegWriteM,
	input RegWriteW,
	output reg nop,
	output reg[1:0] ForwardA,
	output reg[1:0] ForwardB,
	output reg PCWrite,			// PC update X for stall
	output reg InstWrite,		// InstD : nop for stall
	output reg IDEXWrite,
	output reg[31:0] WriteDataE
	);
	
	always @ (*)		// Forward A, B
	begin
		ForwardA = 2'b00;
		ForwardB = 2'b00;
		if (RegWriteW == 1'b1)
		begin
			if (WriteAddrW == ReadAddr1E)
				ForwardA = 2'b01;
			if (WriteAddrW == ReadAddr2E)
				ForwardB = 2'b01;
		end
		
		if (RegWriteM == 1'b1)
		begin
			if (~(LoadW == 1'b1 && WriteAddrW == ReadAddr1E))		// M : Stall
				begin
					if (WriteAddrM == ReadAddr1E)
						ForwardA = 2'b10;
				end
			if (~(LoadW == 1'b1 && WriteAddrW == ReadAddr2E))
				begin
					if (WriteAddrM == ReadAddr2E)
						ForwardB = 2'b10;
				end
		end
		
		if (StoreE == 1'b1)
		begin
			WriteDataE = ReadData3E;
			if (RegWriteW == 1'b1)
			begin
				if (WriteAddrW == WriteAddrE)
					WriteDataE = ResultW;
			end
			if (RegWriteM == 1'b1)
			begin
				if (LoadM == 1'b1)
				begin
					if (WriteAddrM == WriteAddrE)
						WriteDataE = readdata;
				end
				else
				begin
					if (WriteAddrM == WriteAddrE)
						WriteDataE = ALUResultM;				
				end
			end
		end
	end
	
	always @ (*)	// Load + Data Dependency -> Stall
	begin
		PCWrite = 1'b1;
		InstWrite = 1'b1;
		IDEXWrite = 1'b1;
		nop = 1'b0;
		if (LoadE == 1'b1 && RegWriteE == 1'b1)
		begin
			if (WriteAddrE == ReadAddr1 || WriteAddrE == ReadAddr2 || (WriteAddrE == WriteAddrD && StoreD == 1'b1))
			begin
				PCWrite = 1'b0;
				InstWrite = 1'b0;
				IDEXWrite = 1'b0;
			end
		end
		
		if (PCSrcD == 1'b1 || (WriteAddrD == 4'b1111 && RegWriteD == 1'b1))		// Branch taken -> stall
		begin
			InstWrite = 1'b0;
			nop = 1'b1;
		end
		
		if (WriteAddrE == 4'b1111 && RegWriteE == 1'b1)
		begin
			nop = 1'b1;
			InstWrite = 1'b0;
		end
	end


endmodule

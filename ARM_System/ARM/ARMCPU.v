module ExtendMUX(			// for extension of immediate value
	 input[23:0] in,
	 input[1:0] ImmSrc,
	 output reg[31:0] ExtImm
	 );
 
	integer i;
	always @ (*)
	begin
		case(ImmSrc)
		2'b00:				// singed extension 8-bit
		begin
			ExtImm[7:0] = in[7:0];
			for(i=8;i<32;i=i+1)
				ExtImm[i] = in[7];
		end
		2'b01:				// unsigned extension 12-bit
		begin
			ExtImm[11:0] = in[11:0];
			for(i=12;i<32;i=i+1)
				ExtImm[i] = 'b0;
		end
		2'b10:				// (signed extension 24-bit) X 4
		begin
			ExtImm[1:0] = 2'b00;
			ExtImm[25:2] = in[23:0];
			for(i=26;i<32;i=i+1)
				ExtImm[i] = in[23];
		end
		default:
			ExtImm = 'h00000000;
		endcase
	end
endmodule

module RegisterFile(
	input clk,
	input reset,
	input we,
	input[1:0] RegSrc,
	input[3:0] addr1,
	input[3:0] addr2,
	input[3:0] addr3,
	input[3:0] waddr,
	input[31:0] wdata,
	input[31:0] pcin,
	output reg[31:0] data1,
	output reg[31:0] data2,
	output reg[31:0] data3,
	output[31:0] pcout
	);
	
	reg[31:0] tmpPC;
	reg[31:0] registers[15:0];
	reg[3:0] tmpaddr1;
	reg[3:0] tmpaddr2;
	reg[3:0] tmpaddr3;
	reg[3:0] tmpwaddr;
	integer idx;
	
	assign pcout = pcin;
		
	// write to register file			// first half
	always @ (negedge clk)
	begin
		if (reset)		// register reset
		begin
			for(idx=0; idx<=15; idx=idx+1) begin
				registers[idx] = 'h00000000;
			end
		end
		else
		begin
			if(we)		// write enable
				registers[waddr] <= wdata;				// register WB
				
			if(RegSrc[0] == 1'b1)
				registers[14] <= registers[15] + 'd4;		// BL, lr = pc + 4
				
			
			registers[15] <= pcin;
			tmpPC <= registers[15] + 32'd8;
		end
		
		tmpaddr1 = addr1;
		tmpaddr2 = addr2;
		tmpaddr3 = addr3;
		tmpwaddr = waddr;
	end
	
	// read from register file			// second half
	always @ (posedge clk)
	begin
		if (reset)		// dataOut1, 2 reset
		begin
			data1 = 'h00000000;
			data2 = 'h00000000;
			data3 = 'h00000000;
		end
		else
		begin
			if (tmpaddr1 == 15) begin		// $15 : PC, so PC + 80
				data1 = tmpPC;
			end
			else begin
				data1 = registers[tmpaddr1];	// dataOut1 = value of $addr1
			end
			
			if (tmpaddr2 == 15) begin
				data2 = tmpPC;
			end
			else
			begin
				// RegSrc MUX
				if (RegSrc[1] == 1'b0)
					data2 = registers[tmpaddr2];		// dataOut2 = value of $addr2
				else
					data2 = registers[tmpwaddr];		// dataOut2 = value of $waddr
			end
			
			if (tmpaddr3 == 15) begin
				data3 = tmpPC;
			end
			else begin
				data3 = registers[tmpaddr3];
			end
		end
	end

endmodule

module armreduced(
	input clk,
	input reset,
	output[31:0] pc,
	input[31:0] inst,
	input nIRQ,
	output[3:0] be,
	output[31:0] memaddr,
	output memwrite,
	output memread,
	output[31:0] writedata,
	input[31:0] readdata
	);
	
	
	wire[3:0] ReadAddr1, ReadAddr2, ReadAddr1E, ReadAddr2E, WriteAddrD, WriteAddrE, WriteAddrM, WriteAddrW;
	wire[31:0] ReadData1E, ReadData2E, ReadData3E, ReadDataW;
	wire[31:0] WriteDataE, WriteDataM;
	wire[31:0] ExtImmD, ExtImmE, SrcA, SrcB, pctmp;
	wire[31:0] ALUResultE, ALUResultM, ResultW, ALUOutW;
	wire[3:0] ALUOpD, ALUOpE, ALUFlags, NZCV_out, NZCV_in;
	wire[1:0] RegSrc, ImmSrc, opE;
	wire[1:0] ForwardA, ForwardB;
	wire PCSrcD, PCSrcE, PCSrcM, PCSrcW, RegWriteD, RegWriteE, RegWriteM, RegWriteW, MemWriteD, MemWriteE, MemWriteM;
	wire MemtoRegD, MemtoRegE, MemtoRegM, MemtoRegW, ALUSrcD, ALUSrcE, SvalueD, SvalueE, BranchD, BranchE, BranchM, BranchW;
	wire StoreD, StoreE, LoadD, LoadE, LoadM;
	wire PCWrite, InstWrite, IDEXWrite, nop;
	wire[31:0] NextPC;
	wire[31:0] instD;
	
	assign pc = pctmp;
	assign be = 4'b1111;
	
	
	Instruction_Fetch _Instruction_Fetch(.clk(clk), .reset(reset), .PCWrite(PCWrite), .PCSrc(PCSrcD), .pc(pctmp), .pc_out(NextPC),
										 .inst(inst), .InstWrite(InstWrite), .nop(nop), .ExtImm(ExtImmD), .WriteAddrE(WriteAddrE),
										 .RegWriteE(RegWriteE), .ALUResultE(ALUResultE), .instD(instD));
	
	ctrlSig _ctrlSig(
			.NZCV(NZCV_out), .cond(instD[31:28]), .op(instD[27:26]), .funct(instD[25:20]), .ALUOp(ALUOpD), .ImmSrc(ImmSrc), 
			.RegSrc(RegSrc), .PCSrc(PCSrcD), .RegWrite(RegWriteD), .MemWrite(MemWriteD), .MemtoReg(MemtoRegD), .ALUSrc(ALUSrcD), 
			.Svalue(SvalueD), .Branch(BranchD), .Store(StoreD), .Load(LoadD));
	
	Instruction_Decode _Instruction_Decode(.inst(instD), .ReadAddr1(ReadAddr1), .ReadAddr2(ReadAddr2), .WriteAddr(WriteAddrD));
										
	Hazard_Unit _Hazard_Unit(.WriteAddrD(WriteAddrD), .WriteAddrE(WriteAddrE), .WriteAddrM(WriteAddrM), .WriteAddrW(WriteAddrW), 
							.StoreD(StoreD), .StoreE(StoreE), .ReadAddr1(ReadAddr1), .ReadAddr2(ReadAddr2), .ReadAddr1E(ReadAddr1E),
							.ReadAddr2E(ReadAddr2E), .ReadData3E(ReadData3E), .ALUResultM(ALUResultM), .ResultW(ResultW),
							.readdata(readdata), .LoadE(LoadE), .LoadM(LoadM), .LoadW(LoadW), .BranchD(BranchD), .BranchE(BranchE), 
							.BranchM(BranchM), .BranchW(BranchW),.opD(instD[27:26]), .opE(opE), .PCSrcD(PCSrcD), .PCSrcM(PCSrcM),
							.PCSrcW(PCSrcW), .RegWriteD(RegWriteD), .RegWriteE(RegWriteE), .RegWriteM(RegWriteM), 
							.RegWriteW(RegWriteW), .nop(nop), .ForwardA(ForwardA), .ForwardB(ForwardB), .PCWrite(PCWrite), 
							.InstWrite(InstWrite), .IDEXWrite(IDEXWrite), .WriteDataE(WriteDataE));
	
	
	ExtendMUX _ExtendMUX( .in(instD[23:0]), .ImmSrc(ImmSrc), .ExtImm(ExtImmD) );
	
	RegisterFile _RegisterFile( .clk(clk), .reset(reset), .we(RegWriteW), .RegSrc(RegSrc), .addr1(ReadAddr1), .addr2(ReadAddr2), 
								.addr3(WriteAddrD), .waddr(WriteAddrW), .wdata(ResultW), .pcin(NextPC), .data1(ReadData1E), 
								.data2(ReadData2E), .data3(ReadData3E), .pcout(pctmp));
								
	
	IDEX_Register(.clk(clk), .reset(reset), .IDEXWrite(IDEXWrite), .PCSrcD(PCSrcD), .RegWriteD(RegWriteD), .MemWriteD(MemWriteD), 
				.MemtoRegD(MemtoRegD), .ALUSrcD(ALUSrcD), .SvalueD(SvalueD), .BranchD(BranchD), .ALUOpD(ALUOpD), .ExtImmD(ExtImmD), 
				.WriteAddrD(WriteAddrD), .NZCV_out(NZCV_out), .StoreD(StoreD), .ReadAddr1(ReadAddr1), .ReadAddr2(ReadAddr2), 
				.LoadD(LoadD), .opD(instD[27:26]), .opE(opE), .LoadE(LoadE), .ReadAddr1E(ReadAddr1E), .ReadAddr2E(ReadAddr2E),
				.StoreE(StoreE), .NZCV_in(NZCV_in), .WriteAddrE(WriteAddrE), .ExtImmE(ExtImmE), .ALUOpE(ALUOpE), .PCSrcE(PCSrcE),
				.RegWriteE(RegWriteE), .MemWriteE(MemWriteE), .MemtoRegE(MemtoRegE), .ALUSrcE(ALUSrcE), .SvalueE(SvalueE), 
				.BranchE(BranchE));
				
	ALU_MUX _ALU_MUX(.ForwardA(ForwardA), .ForwardB(ForwardB), .ALUSrcE(ALUSrcE), .ExtImmE(ExtImmE), .ReadData1E(ReadData1E),
					.ReadData2E(ReadData2E), .ALUResultM(ALUResultM), .ResultW(ResultW), .SrcA(SrcA), .SrcB(SrcB));
				
	ALU32bit _ALU32bit( .SrcA(SrcA), .SrcB(SrcB), .ALUOp(ALUOpE), .ALUFlags(ALUFlags), .ALUResult(ALUResultE) );
	
	Cond_Unit _Cond_Unit(.NZCV_in(NZCV_in), .ALUFlags(ALUFlags), .SvalueE(SvalueE), .NZCV_out(NZCV_out));

				
	EXMEM_Register(.clk(clk), .reset(reset), .RegWriteE(RegWriteE), .MemtoRegE(MemtoRegE), .MemWriteE(MemWriteE), 
					.WriteAddrE(WriteAddrE), .WriteDataE(WriteDataE), .ALUResultE(ALUResultE), .PCSrcE(PCSrcE), .BranchE(BranchE), 
					.LoadE(LoadE), .LoadM(LoadM), .BranchM(BranchM), .PCSrcM(PCSrcM), .RegWriteM(RegWriteM), .MemtoRegM(MemtoRegM),
					.MemWriteM(MemWriteM), .WriteAddrM(WriteAddrM), .WriteDataM(WriteDataM), .ALUResultM(ALUResultM));
					
	MEM _MEM(.ALUResult(ALUResultM), .WriteDataM(WriteDataM), .MemWriteM(MemWriteM), .memaddr(memaddr), .writedata(writedata), 
				.memwrite(memwrite), .memread(memread));
			
				
					
	MEMWB_Register _MEMWB_Register(.clk(clk), .reset(reset), .RegWriteM(RegWriteM), .MemtoRegM(MemtoRegM), .readdata(readdata), 
								.ALUResultM(ALUResultM), .WriteAddrM(WriteAddrM), .PCSrcM(PCSrcM), .BranchM(BranchM), .LoadM(LoadM), 
								.LoadW(LoadW), .BranchW(BranchW), .PCSrcW(PCSrcW), .RegWriteW(RegWriteW), .MemtoRegW(MemtoRegW), 
								.ReadDataW(ReadDataW), .ALUOutW(ALUOutW), .WriteAddrW(WriteAddrW));
								
	WriteBack _WriteBack(.ReadDataW(ReadDataW), .ALUOutW(ALUOutW), .MemtoRegW(MemtoRegW), .ResultW(ResultW));
								

endmodule


module ALU_MUX(
	input[1:0] ForwardA,
	input[1:0] ForwardB,
	input ALUSrcE,
	input[31:0] ExtImmE,
	input[31:0] ReadData1E,
	input[31:0] ReadData2E,
	input[31:0] ALUResultM,
	input[31:0] ResultW,
	output reg[31:0] SrcA,
	output reg[31:0] SrcB);
	
	always @ (*)
	begin
		case(ForwardA)
		2'b00:
		begin
			SrcA = ReadData1E;
		end
		2'b01:
		begin
			SrcA = ResultW;
		end
		2'b10:
		begin
			SrcA = ALUResultM;
		end
		default:
			SrcA = 'h00000000;
		endcase
	end
	
	always @ (*)
	begin
		if (ALUSrcE == 1'b1)
			SrcB = ExtImmE;
		else
		begin
			case(ForwardB)
			2'b00:
			begin
				SrcB = ReadData2E;
			end
			2'b01:
			begin
				SrcB = ResultW;
			end
			2'b10:
			begin
				SrcB = ALUResultM;
			end
			default:
				SrcB = 'h00000000;
			endcase
		end
	end

endmodule

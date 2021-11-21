module maindec(input clk, reset,
	       input [5:0] op,
	       output PCWrite, MemWrite, IRWrite,
	       output RegWrite, ALUSrcA, Branch, IorD,
	       output MemtoReg, RegDst,
	       output [1:0] ALUSrcB, PCSrc, ALUOp);

  reg [14:0] controls;
  reg [3:0] state, nextState;
  assign {PCWrite, MemWrite, IRWrite, RegWrite, ALUSrcA, Branch,
	  IorD, MemtoReg, RegDst, ALUSrcB, PCSrc, ALUOp} = controls;

  always@(posedge clk or posedge reset) begin
    if(reset) state <= 4'h5010;
    else state <= nextState;
  end
  
  always@(*) begin
    case(state)
	4'h5010: nextState <= 4'h0030;			// State 0: Fetch
	4'h0030: case(op)				// State 1: Decode
			6'b000000: nextState <= 4'h0402;		// R-Type
			6'b100011: nextState <= 4'h0420;		// lw
			6'b101011: nextState <= 4'h0420;		// sw
			6'b000100: nextState <= 4'h0605;		// beq
			6'b001000: nextState <= 4'h0420;		// addi
			6'b000010: nextState <= 4'h4008;		// j
			default: nextState <= 4'hxxxx;			// Should never happen
			endcase
	4'h0420: case(op)				// State 2: MemAdr
			6'b100011: nextState <= 4'h0100;		// lw
			6'b101011: nextState <= 4'h2100;		// sw
			default: nextState <= 4'hxxxx;			// Should never happen
			endcase
	4'h0100: nextState <= 4'h0880;			// State 3: MemRead
	4'h0880: nextState <= 4'h5010;			// State 4: MemWriteback
	4'h2100: nextState <= 4'h5010;			// State 5: MemWrite
	4'h0402: nextState <= 4'h0840;			// State 6: Execute
	4'h0840: nextState <= 4'h5010;			// State 7: ALUWriteback
	4'h0605: nextState <= 4'h5010;			// State 8: Branch
	4'h0420: nextState <= 4'h0800;			// State 9: ADDIExecute
	4'h0800: nextState <= 4'h5010;			// State 10: ADDIWriteback
	4'h4008: nextState <= 4'h5010;			// State 11: Jump
	default: nextState <= 4'hxxxx;			// Should never happen
    endcase
  end

  always@(*) begin
    case(state)
	4'h5010: controls <= 15'b101000000010000;	// Fetch
	4'h0030: controls <= 15'b000000000110000;	// Decode
	4'h0420: controls <= 15'b000010000100000;	// MemAdr and AddiEx
	4'h0100: controls <= 15'b000000100000000;	// MemRd
	4'h0880: controls <= 15'b000100010000000;	// MemWb
	4'h2100: controls <= 15'b010000100000000;	// MemWr
	4'h0402: controls <= 15'b000010000000010;	// RtypeEx
	4'h0840: controls <= 15'b000100001000000;	// RtypeWb
	4'h0605: controls <= 15'b000011000000101;	// BeqEx
	4'h0800: controls <= 15'b000100000000000;       // AddiWB
	4'h4008: controls <= 15'b100000000001000;	// JEx
	default: controls <= 15'bxxxxxxxxxxxxxxx;	// Should never happen
    endcase
  end
endmodule

module aludec(input [5:0] funct,
	      input [1:0] aluop,
	      output reg [2:0] alucontrol);
  
  always@(*) begin
    case(aluop)
	2'b00: alucontrol <= 3'b010;
	2'b01: alucontrol <= 3'b110;
	default: case(funct)
		6'b100000: alucontrol <= 3'b010; // add
        	6'b100010: alucontrol <= 3'b110; // sub
        	6'b100100: alucontrol <= 3'b000; // and
        	6'b100101: alucontrol <= 3'b001; // or
        	6'b101010: alucontrol <= 3'b111; // slt
		default: alucontrol <= 3'bxxx; // n/a
	endcase
    endcase
  end
endmodule
	

			
	
module maindec(input clk, reset,
	       input [5:0] op,
	       output PCWrite, MemWrite, IRWrite,
	       output RegWrite, ALUSrcA, Branch, IorD,
	       output MemtoReg, RegDst,
	       output [1:0] ALUSrcB, PCSrc, ALUOp);

  reg [16:0] controls;
  reg [4:0] state, nextState;

  always @(posedge clk or posedge reset) begin
    if(reset) state <= 5'b00000;
    else state <= nextState;
  end
  
  always@(*) begin
    case(state)
	5'b00000: nextState <= 5'b00001;			// State 0: Fetch
	5'b00001: case(op)				// State 1: Decode
			6'b000000: nextState <= 5'b00110;		// R-Type
			6'b100011: nextState <= 5'b00010;		// lw
			6'b101011: nextState <= 5'b00010;		// sw
			6'b000100: nextState <= 5'b01000;		// beq
			6'b001000: nextState <= 5'b01001;		// addi
			6'b000010: nextState <= 5'b01011;		// j
			default: nextState <= 5'bxxxxx;			// Should never happen
			endcase
	5'b00010: case(op)				// State 2: MemAdr
			6'b100011: nextState <= 5'b00011;		// lw
			6'b101011: nextState <= 5'b00101;		// sw
			default: nextState <= 5'bxxxxx;			// Should never happen
			endcase
	5'b00011: nextState <= 5'b00100;			// State 3: MemRead
	5'b00100: nextState <= 5'b00000;			// State 4: MemWriteback
	5'b00101: nextState <= 5'b00000;			// State 5: MemWrite
	5'b00110: nextState <= 5'b00111;			// State 6: Execute
	5'b00111: nextState <= 5'b00000;			// State 7: ALUWriteback
	5'b01000: nextState <= 5'b00000;			// State 8: Branch
	5'b01001: nextState <= 5'b01010;			// State 9: ADDIExecute
	5'b01010: nextState <= 5'b00000;			// State 10: ADDIWriteback
	5'b01011: nextState <= 5'b00000;			// State 11: Jump
	default: nextState <= 5'b00000;			// Should never happen
    endcase
  end

  assign {PCWrite, MemWrite, IRWrite, RegWrite, ALUSrcA, Branch,
	  IorD, MemtoReg, RegDst, ALUSrcB, PCSrc, ALUOp} = controls;

  always@(*) begin
    case(state)
	5'b00000: controls <= 15'b101000000010000;	// Fetch
	5'b00001: controls <= 15'b000000000110000;	// Decode
	5'b00010: controls <= 15'b000010000100000;	// MemAdr
	5'b00011: controls <= 15'b000000100000000;	// MemRd
	5'b00100: controls <= 15'b000100010000000;	// MemWb
	5'b00101: controls <= 15'b010000100000000;	// MemWr
	5'b00110: controls <= 15'b000010000000010;	// RtypeEx
	5'b00111: controls <= 15'b000100001000000;	// RtypeWb
	5'b01000: controls <= 15'b000011000000101;	// BeqEx
	5'b01001: controls <= 15'b000010000100000;	// AddiEx
	5'b01010: controls <= 15'b000100000000000;      // AddiWB
	5'b01011: controls <= 15'b100000000001000;	// JEx
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
			
	
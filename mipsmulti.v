//-------------------------------------------------------
// Multicycle MIPS processor
//------------------------------------------------

module mips(input        clk, reset,
            output [31:0] adr, writedata,
            output        memwrite,
            input [31:0] readdata);

  wire        zero, pcen, irwrite, regwrite,
               alusrca, iord, memtoreg, regdst;
  wire [1:0]  alusrcb, pcsrc;
  wire [2:0]  alucontrol;
  wire [5:0]  op, funct;

  controller c(clk, reset, op, funct, zero,
               pcen, memwrite, irwrite, regwrite,
               alusrca, iord, memtoreg, regdst, 
               alusrcb, pcsrc, alucontrol);
  datapath dp(clk, reset, 
              pcen, irwrite, regwrite,
              alusrca, iord, memtoreg, regdst,
              alusrcb, pcsrc, alucontrol,
              op, funct, zero,
              adr, writedata, readdata);
endmodule

// Todo: Implement controller module
module controller(input       clk, reset,
                  input [5:0] op, funct,
                  input       zero,
                  output       pcen, memwrite, irwrite, regwrite,
                  output       alusrca, iord, memtoreg, regdst,
                  output [1:0] alusrcb, pcsrc,
                  output [2:0] alucontrol);

// **PUT YOUR CODE HERE**
  wire [1:0] aluop;
  wire branch, pcwrite;

  // Instantiates main decoder and ALU decoder, assigns appropriate inputs/outputs
  maindec md(clk, reset, op, pcwrite, memwrite, irwrite, regwrite, alusrca, branch, iord,
	     memtoreg, regdst, alusrcb, pcsrc, aluop);
  aludec ad(funct, aluop, alucontrol);

  // Determines pcen based on the values of pcwrite, branch, and zero. 
  assign pcen = pcwrite | (branch & zero);
 
endmodule

// Todo: Implement datapath
module datapath(input        clk, reset,
                input        pcen, irwrite, regwrite,
                input        alusrca, iord, memtoreg, regdst,
                input [1:0]  alusrcb, pcsrc, 
                input [2:0]  alucontrol,
                output [5:0]  op, funct,
                output        zero,
                output [31:0] adr, writedata, 
                input [31:0] readdata);

// **PUT YOUR CODE HERE** 
  wire [4:0] writereg;
  wire [31:0] pcnext, pc;
  wire [31:0] instr, data, srca, srcb;
  wire [31:0] a;
  wire [31:0] aluresult, aluout;
  wire [31:0] signimm;
  wire [31:0] signimmsh;
  wire [31:0] wd3, rd1, rd2;

  // Assigns op to the 6 most significant bits of instr
  assign op = instr[31:26];
  // Assigns funct to the 6 least significant bits of instr
  assign funct = instr[5:0];

  // Instantiation of PC register, with width of 32
  flopenr #(32) pcreg(clk, reset, pcen, pcnext, pc);
  // Instantiation of 2:1 MUX that determines whether to get new instructino from PC 
  // or continues instruction from the previous cycle
  mux2 #(32) adrmux(pc, aluout, iord, adr);
  // Instantiation of both instruction and data registers
  flopenr #(32) instrreg(clk, reset, irwrite, readdata, instr);
  flopr #(32) datareg(clk, reset, readdata, data);
  
  // Instantiation of 2:1 MUX which connects to A3 of register file, parses instr
  // to get two instruction inputs
  mux2 #(5) regdstmux(instr[20:16], instr[15:11], regdst, writereg);
  // Instantiation of 2:1 MUX which connects to WD3 of register file, input determined by MemtoReg
  mux2 #(32) wdmux(aluout, data, memtoreg, wd3);
  // Instantiation of Register file
  regfile rf(clk, regwrite, instr[25:21], instr[20:16], writereg,
	     wd3, rd1, rd2);
  // Instantiation of sign extension module, used if instruction uses immediates
  signext se(instr[15:0], signimm);
  // Instantiation of shift left module, shifts sign extended number to the left 2
  sl2 immsh(signimm, signimmsh);
  // Instantiation of flip flop for both the output RD1 and RD2 of the register file	
  flopr #(32) areg(clk, reset, rd1, a);
  flopr #(32) breg(clk, reset, rd2, writedata);
  // Instantiation of 2:1 MUX for output A from the register file flip flop, outputs to ALU
  mux2 #(32) srcamux(pc, a, alusrca, srca);
  // Instantiation of 4:1 MUX for output B from the register file flip flop, also takes immediate inputs
  // and outputs to ALU
  mux4 #(32) srcbmux(writedata, 32'b100, signimm, signimmsh, alusrcb, srcb);
  
  // Instantiation of ALU, takes SrcA and SrcB as inputs. Function determined by input of ALUControl
  ALU alu(srca, srcb, alucontrol, aluresult, zero);
  
  // Instantiation of flip flop connected to output of ALU
  flopr #(32) alureg(clk, reset, aluresult, aluout);
  // Instantiation of 3:1 MUX, outputs to beginning of datapath of processor
  mux3 #(32) pcmux(aluresult, aluout, {pc[31:28], instr[25:0], 2'b00}, pcsrc, pcnext);

endmodule

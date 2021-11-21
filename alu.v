module ALU (input [31:0] a, b, input [2:0] f, output reg [31:0] y, output zero) ;
  always @(*)begin
    case (f[1:0]) 
      3'b000: y <= a & b;
      3'b001: y <= a | b;
      3'b010: y <= a + b;
      3'b011: y <= a & ~b;
      3'b101: y <= a + ~b;
      3'b110: y <= a- b;
      3'b111: y <= a < b ? 1:0;
      default: y <= 0;
    endcase
  end 
  
  assign zero = (y == 32'b0) ;
   
 endmodule

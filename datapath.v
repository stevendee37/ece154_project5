module regfile(input clk, 
	       input we3, 
	       input [4:0] ra1, ra2, wa3,
	       input [31:0] wd3,
	       output [31:0] rd1, rd2);
  
  reg [31:0] rf[31:0];
  always@(posedge clk)
    if (we3) rf[wa3] <= wd3;
  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

module sl2(input [31:0] a,
	   output [31:0] y);
  assign y = {a[29:0], 2'b00};
endmodule 

module signext(input [15:0] a,
	       output [31:0] y);
  assign y = {{16{a[15]}}, a};
endmodule

module flopr #(parameter WIDTH=8)
	   (input clk, reset,
	    input [WIDTH-1:0] d,
	    output reg [WIDTH-1:0] q);
  always@(posedge clk, posedge reset)
    if(reset) q <= 0;
    else      q <= d;
endmodule

module flopenr #(parameter WIDTH=8)
		(input clk, reset,
	   	 input en, 	
		 input [WIDTH-1:0] d,
		 output reg [WIDTH-1:0] q);
  always@(posedge clk, posedge reset)
    if(reset) q <= 0;
    else if (en) q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
	     (input [WIDTH-1:0] d0, d1,
	      input s,
	      output [WIDTH-1:0] y);
  assign y = s ? d1 : d0;
endmodule

module mux3 #(parameter WIDTH = 8)
	     (input [WIDTH-1:0] d0, d1, d2,
	      input [1:0] s,
	      output [WIDTH-1:0] y);
  assign #1 y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule;

module mux4 #(parameter WIDTH = 8)
	     (input [WIDTH-1:0] d0, d1, d2, d3, 
	      input [1:0] s,
	      output reg [WIDTH - 1:0] y);
  always@(*)
    case(s)
      2'b00: y <= d0;
      2'b01: y <= d1;
      2'b10: y <= d2;
      2'b11: y <= d3;
    endcase
endmodule


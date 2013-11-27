module GraphicCard (
  input clk, rst,
  input [175:0] registerVGA,
  input [15:0] IfPC, IfIR,
  input [3:0] registerS, registerM, registerT,
  input [15:0] calResult,
  output hs, vs,
  output [2:0] r, g, b
);

wire [10:0] x, y;
reg clk25M;

always @ (negedge clk, negedge rst)
begin
  if (!rst)
    clk25M = 0;
  else
    clk25M = ~ clk25M;
end

VGAEngine VGAEngineM (
  clk25M,
  rst,
  hs, vs,
  x, y
);

Renderer RendererM (
  x, y,
  registerVGA,
  IfPC, IfIR,
  registerS, registerM, registerT,
  calResult,
  r, g, b
);

endmodule


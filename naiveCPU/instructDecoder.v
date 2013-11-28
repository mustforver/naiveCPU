module instructionDecoder (
  input clk, rst,
  input [15:0] instruction,
  output reg [15:0] instructionTemp,
  output reg [3:0] registerS, registerM, registerT,
  output reg [1:0] memControl
);

always @ (negedge clk or negedge rst)
  if (!rst)
    instructionTemp = 16'b0000100000000000; // nop
  else
    instructionTemp = instruction;

always @ (posedge clk or negedge rst)
begin
  registerS = 0;
  registerM = 0;
  registerT = 0;
  memControl = 2'b00; // IDLE
  if (!rst) // the negedge of rst
  begin
    registerS = 0;
    registerM = 0;
    registerT = 0;
    memControl = 2'b00; // IDLE
  end
  else
  begin
    case (instructionTemp[15:11])
      5'b00000:                         // addsp3
      begin
        registerS = 4'b1001;            // sp
        registerT = instructionTemp[10:8];
      end
      //5'b00001:                         // nop
      //5'b00010:                         // b
      5'b00100:                         // beqz
        registerS = instructionTemp[10:8];
      5'b00101:                         // bnez
        registerS = instructionTemp[10:8];
      5'b00110:                         // sll, srl, sra
      begin
        registerS = instructionTemp[7:5];
        registerT = instructionTemp[10:8];
      end
      5'b01000:                         // addiu3
      begin
        registerS = instructionTemp[10:8];
        registerT = instructionTemp[7:5];
      end
      5'b01001:                         // addiu
      begin
        registerS = instructionTemp[10:8];
        registerT = instructionTemp[10:8];
      end
      5'b01010:                         // slti
        registerS = instructionTemp[10:8];
      5'b01100:                         // addsp, bteqz, btnez, mtsp, sw_rs
        case (instructionTemp[10:8])
          //3'b000:                       // bteqz
          //3'b001:                       // btnez
          3'b010:                       // sw_rs
          begin
            registerS = 4'b1010;
            registerM = 4'b1001;
          end
          3'b011:                       // addsp
          begin
            registerS = 4'b1001;        // sp
            registerT = 4'b1001;        // sp
          end
          3'b100:                       // mtsp
          begin
            registerS = instructionTemp[7:5];
            registerT = 4'b1001;        // sp
          end
        endcase
      5'b01011:                         // sltui
        registerS = instructionTemp[10:8];
      5'b01101:                         // li
        registerT = instructionTemp[10:8];
      5'b01110:                         // cmpi
        registerS = instructionTemp[10:8];
      5'b01111:                         // move
      begin
        registerS = instructionTemp[7:5];
        registerT = instructionTemp[10:8];
      end
      5'b10010:                         // lw_sp
      begin
        registerS = 4'b1001;            // sp
        registerT = instructionTemp[10:8];
        memControl = 2'b10; // read
      end
      5'b10011:                         // lw
      begin
        registerS = instructionTemp[10:8];
        registerT = instructionTemp[7:5];
        memControl = 2'b10; // read
      end
      5'b11010:                         // sw_sp
      begin
        registerS = 4'b1001;            // sp
        registerM = instructionTemp[10:8];
        memControl = 2'b01; // write
      end
      5'b11011:                         // sw
      begin
        registerS = instructionTemp[7:5];
        registerM = instructionTemp[10:8];
        memControl = 2'b10; // write
      end
      5'b11100:                         // addu, subu
      begin
        registerS = instructionTemp[10:8];
        registerM = instructionTemp[7:5];
        registerT = instructionTemp[4:2];
      end
      5'b11101:                         // jalr, jr, jrra, mfpc, sllv, srav, slt, sltu, srlv, cmp, neg, and, or, xor, not
        case (instructionTemp[4:0])
          5'b00000:                     // jalr, jr, jrra, mfpc
            case (instructionTemp[7:5])
              3'b000:                   // jr
                registerS = instructionTemp[10:8];
              //3'b001:                   // jrra
              3'b010:                   // mfpc
                registerT = instructionTemp[10:8];
              3'b110:                   // jalr
              begin
                registerS = instructionTemp[10:8];
                registerT = 4'b1010;    // ra
              end
            endcase
          5'b00010:                     // slt
          begin
            registerS = instructionTemp[10:8];
            registerM = instructionTemp[7:5];
          end
          5'b00011:                     // sltu
          begin
            registerS = instructionTemp[10:8];
            registerM = instructionTemp[7:5];
          end
          5'b00100:                     // sllv
          begin
            registerS = instructionTemp[7:5];
            registerM = instructionTemp[10:8];
            registerT = instructionTemp[7:5];
          end
          5'b00110:                     // srlv
          begin
            registerS = instructionTemp[7:5];
            registerM = instructionTemp[10:8];
            registerT = instructionTemp[7:5];
          end
          5'b00111:                     // srav
          begin
            registerS = instructionTemp[7:5];
            registerM = instructionTemp[10:8];
            registerT = instructionTemp[7:5];
          end
          5'b01010:                     // cmp
          begin
            registerS = instructionTemp[7:5];
            registerM = instructionTemp[10:8];
          end
          5'b01011:                     // neg
          begin
            registerS = instructionTemp[7:5];
            registerT = instructionTemp[10:8];
          end
          5'b01100:                     // and
          begin
            registerS = instructionTemp[7:5];
            registerM = instructionTemp[10:8];
            registerT = instructionTemp[10:8];
          end
          5'b01101:                     // or
          begin
            registerS = instructionTemp[7:5];
            registerM = instructionTemp[10:8];
            registerT = instructionTemp[10:8];
          end
          5'b01110:                     // xor
          begin
            registerS = instructionTemp[7:5];
            registerM = instructionTemp[10:8];
            registerT = instructionTemp[10:8];
          end
          5'b01111:                     // not
          begin
            registerS = instructionTemp[7:5];
            registerT = instructionTemp[10:8];
          end
        endcase
      5'b11110:                         // mfih, mtih
        case (instructionTemp[0])
          1'b0:                         // mfih
          begin
            registerS = 4'b1000;        // ih
            registerT = instructionTemp[10:8];
          end
          1'b1:                         // mtih
          begin
            registerS = instructionTemp[10:8];
            registerT = 4'b1000;        // ih
          end
        endcase
      //5'b11111:                         // int
		default:
		begin
        registerS = 0;
        registerM = 0;
        registerT = 0;
        memControl = 2'b00; // IDLE
		end
    endcase
  end
end

endmodule


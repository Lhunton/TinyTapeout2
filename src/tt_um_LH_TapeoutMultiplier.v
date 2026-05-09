`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:17:03 04/14/2026 
// Design Name: 
// Module Name:    TapeoutMultiplier 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module TapeoutMultiplier(
	input wire [7:0] ui_in,
	input wire [7:0] uio_in,
	output reg [7:0] uo_out,
	output wire [7:0] uio_out,
	output wire [7:0] uio_oe,
	input wire ena,
	input wire clk,
	input wire rst_n
    );
	 
	 //internal regs
	 reg signed [7:0] A_reg;
	 reg signed [7:0] B_reg;
	 reg Output_select;
	 
	 wire [15:0] Product;
	 wire Valid;
	 reg Start;
	 
	 //control logic
	 always@(posedge clk or negedge rst_n) begin
		 if(!rst_n) begin
			A_reg <= 0;
			B_reg <= 0;
			Start <= 0;
			Output_select <= 0;
		end else begin
			Start <= 0;
			
			case (ui_in[7:6])
				2'b00: A_reg <= $signed(ui_in[5:0]);
				2'b01: B_reg <= $signed(ui_in[5:0]);
				2'b10: Start <= 1;
			endcase
		end
	end
	 
	 //outputs
	 always@(posedge ) begin
		if(Valid) begin
			if(Output_select == 0)
				uo_out <= Product [7:0];
		end
	end

	assign uio_out = Valid ? Product[15:8] : 8'b0;
	assign uio_oe = 8'HFF;
	 
	 
	//multiplier
	wire [7:0] partialProducts [7:0]; //makes 8 partial products each 8 bits long

	genvar i, j;
	generate
		for (i = 0; i < 8; i = i + 1) begin : PartialProductRow
			for (j = 0; j < 8; j = j + 1) begin : PartialProductCol
				if (i == 7 && j < 7) begin
					assign partialProducts[i][j] = ~(A_reg[7] & B_reg[j]); //last row except last bit
				end
				else if (i < 7 && j == 7) begin
					assign partialProducts[i][j] = ~(A_reg[i] & B_reg[7]); //last COL except last bit
				end
				else if (i == 7 && j == 7) begin
					assign partialProducts[i][j] = (A_reg[i] & B_reg[j]); //Bottom corner  of array
				end
				else begin
					assign partialProducts[i][j] = (A_reg[i] & B_reg[j]); //nominal position AND
				end
			end
		end
	endgenerate

	wire [15:0] Shifted [7:0];

	generate
		 for (i = 0; i < 8; i = i + 1) begin : ShiftedRows
			  wire [7:0] row;
			  for (j = 0; j < 8; j = j + 1) begin : AssignBits
					assign row[j] = partialProducts[i][j];
			  end
			  assign Shifted[i] = {8'b0, row} << i;
		 end
	endgenerate

	wire signed [15:0] intermediaryOne [3:0];
	wire signed [15:0] intermediaryTwo [1:0];
	wire signed [15:0] intermediaryThree;

	assign intermediaryOne[0] = Shifted[0] + Shifted[1];
	assign intermediaryOne[1] = Shifted[2] + Shifted[3];
	assign intermediaryOne[2] = Shifted[4] + Shifted[5];
	assign intermediaryOne[3] = Shifted[6] + Shifted[7];

	assign intermediaryTwo[0] = intermediaryOne[0] + intermediaryOne[1];
	assign intermediaryTwo[1] = intermediaryOne[2] + intermediaryOne[3];

	assign intermediaryThree = intermediaryTwo[0] + intermediaryTwo[1];

	wire [15:0] correctionBit = 16'b1000000100000000;
	wire signed [15:0] ProductWire = intermediaryThree + correctionBit;

	reg Valid_reg;
	
	always @(posedge clk) begin
		if(Start) begin
			Valid_reg <= 1'b1;
		end else begin
			Valid_reg <= 1'b0;
		end
	end
	
	assign Product = ProductWire;
	assign Valid = Valid_reg;

endmodule

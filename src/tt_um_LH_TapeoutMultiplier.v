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
module tt_um_LH_TapeoutMultiplier(
    input wire [7:0] ui_in,
    input wire [7:0] uio_in,
    output wire [7:0] uo_out,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input wire ena,
    input wire clk,
    input wire rst_n
);

    wire signed [7:0] A = ui_in;
    wire signed [7:0] B = uio_in;
    wire [15:0] Product;

    // Partial products
    wire [7:0] partialProducts [7:0];
    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : PartialProductRow
            for (j = 0; j < 8; j = j + 1) begin : PartialProductCol
                if (i == 7 && j < 7)
                    assign partialProducts[i][j] = ~(A[7] & B[j]);
                else if (i < 7 && j == 7)
                    assign partialProducts[i][j] = ~(A[i] & B[7]);
                else if (i == 7 && j == 7)
                    assign partialProducts[i][j] =  (A[i] & B[j]);
                else
                    assign partialProducts[i][j] =  (A[i] & B[j]);
            end
        end
    endgenerate

    // Shift partial products
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

    // Tree reduction
    wire signed [15:0] intermediaryOne [3:0];
    wire signed [15:0] intermediaryTwo [1:0];
    wire signed [15:0] intermediaryThree;

    assign intermediaryOne[0] = Shifted[0] + Shifted[1];
    assign intermediaryOne[1] = Shifted[2] + Shifted[3];
    assign intermediaryOne[2] = Shifted[4] + Shifted[5];
    assign intermediaryOne[3] = Shifted[6] + Shifted[7];
    assign intermediaryTwo[0]  = intermediaryOne[0] + intermediaryOne[1];
    assign intermediaryTwo[1]  = intermediaryOne[2] + intermediaryOne[3];
    assign intermediaryThree   = intermediaryTwo[0] + intermediaryTwo[1];

    wire [15:0] correctionBit = 16'b1000000100000000;
    assign Product = intermediaryThree + correctionBit;

    // Outputs
    assign uo_out  = Product[7:0];
    assign uio_out = Product[15:8];
    assign uio_oe  = 8'hFF;

endmodule

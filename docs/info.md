<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

A full adder is constructed from XOR, AND and OR logic gates. Outputs of the full adder and a 4th input, for graphical purposes, are connected to a 7seg display that show the letter L when all pins are driven. 

## How to test

The goal of the circuit is simply to display the letter L on the 7 seg. If the L does not show when all 4 inputs are set to 1, it is broken :(
Bottom 2 segments of the 3 required to make an L are controlled by the full adder. 

A  B  O  C
0  0  0  0 
0  1  1  0
1  0  1  0
1  1  1  1

## External hardware

Switch, 2 buttons, 7 segment display 

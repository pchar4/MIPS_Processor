`timescale 1ns/1ns

`define NOP 4'b0000
`define ARITH_2OP 4'b0001
`define ARITH_1OP 4'b0010
`define MOVI 4'b0011
`define ADDI 4'b0100
`define SUBI 4'b0101
`define LOAD 4'b0110
`define STOR 4'b0111
`define BEQ 4'b1000
`define BGE 4'b1001
`define BLE 4'b1010
`define BC 4'b1011
`define J 4'b1100
`define CONTROL 4'b1111

`define ADD 3'b000
`define ADDC 3'b001
`define SUB 3'b010
`define SUBB 3'b011
`define AND 3'b100
`define OR 3'b101
`define XOR 3'b110
`define XNOR 3'b111

`define NOT 3'b000
`define SHIFTL 3'b001
`define SHIFTR 3'b010
`define CP 3'b011

`define STC    12'b000000000001
`define STB    12'b000000000010
`define RESET  12'b101010101010
`define HALT   12'b111111111111




/*
 * Module: alu
 * Description: Arithmetic Logic Unit
 *              This unit contains the math/logical units for the processor, and is used for the following functions:
 *              - 2 Operand Arithmetic
 *                  Add, Add with Carry, Subtract, Subtract with Borrow, bitwise AND/OR/XOR/XNOR
 *              - 1 Operand Arithmetic
 *                  Bitwise NOT, Shift Left, Shift Right, Register Copy
 *              - Add immediate (no carry bit)
 *              - Subtract immediate (no borrow bit)
 *              - Load and Store (Address addition - effectively the same to the ALU as Add immediate)
 *              This module does not contain the adder for the Program Counter, nor does it have the comparator logic for branches
 */
module alu (
	input 	      arith_1op_pi,
	input 	      arith_2op_pi,
	input [2:0]   alu_func_pi,
	input 	      addi_pi,
	input 	      subi_pi,
	input 	      load_or_store_pi,
	input [15:0]  reg1_data_pi, // Register operand 1
	input [15:0]  reg2_data_pi, // Register operand 2
	input [5:0]   immediate_pi, // Immediate operand
	input 	      stc_cmd_pi, // STC instruction must set carry_out
	input 	      stb_cmd_pi, // STB instruction must set borrow_out
	input 	      carry_in_pi, // Use for ADDC
	input 	      borrow_in_pi, // Use for SUBB
	
	output [15:0] alu_result_po,// The 16-bit result disregarding carry out or borrow
	output 	      carry_out_po, // Propagate carry_in unless an arithmetic/STC instruction generates a new carry 
	output 	      borrow_out_po // Propagate borrow_in unless an arithmetic/STB instruction generates a new borrow
);
	// all the control signals we will need to determine all in one
	wire [7:0] instr_onehot_and_func = {arith_1op_pi, arith_2op_pi, addi_pi, subi_pi, load_or_store_pi, alu_func_pi};
	
	reg[15:0] alu_out_reg;

	reg carry_out_reg;
	reg borrow_out_reg;

	always @(*) begin
		carry_out_reg = carry_in_pi;
		borrow_out_reg = borrow_in_pi;
		casez (instr_onehot_and_func)
		// arith 1 ops
			// NOT
			8'b10000000: alu_out_reg = ~reg1_data_pi;
			// SHIFTL
			8'b10000001: alu_out_reg = reg1_data_pi << 1;
			// SHIFTR
			8'b10000010: alu_out_reg = reg1_data_pi >> 1;
			// CP
			8'b10000011: alu_out_reg = reg1_data_pi;
		// arith 2 ops
			// ADD
			8'b01000000: {carry_out_reg, alu_out_reg} = reg1_data_pi + reg2_data_pi;
			// ADDC
			8'b01000001: {carry_out_reg, alu_out_reg} = reg1_data_pi + reg2_data_pi + carry_in_pi;
			// SUB
			8'b01000010: begin
				borrow_out_reg = reg1_data_pi < reg2_data_pi;
				alu_out_reg = reg1_data_pi - reg2_data_pi;
			end
			// SUBB
			8'b01000011: begin
				alu_out_reg =  reg1_data_pi - reg2_data_pi - borrow_in_pi;
				borrow_out_reg = reg1_data_pi < (reg2_data_pi + borrow_in_pi);
			end
			// AND
			8'b01000100: alu_out_reg = reg1_data_pi & reg2_data_pi;
			// OR
			8'b01000101: alu_out_reg = reg1_data_pi | reg2_data_pi;
			// XOR
			8'b01000110: alu_out_reg = reg1_data_pi ^ reg2_data_pi;
			// XNOR
			8'b01000111: alu_out_reg = ~(reg1_data_pi ^ reg2_data_pi);
		
		// addi
			8'b00100???: {carry_out_reg, alu_out_reg} = reg1_data_pi + immediate_pi;
		// subi
			8'b00010???: begin
				borrow_out_reg = reg1_data_pi < immediate_pi;
				alu_out_reg = reg1_data_pi - immediate_pi;
			end
		// LD OR ST -- basically addi without the carry?
			8'b00001???: alu_out_reg = reg1_data_pi + immediate_pi;

			default: alu_out_reg = 0;
		endcase
	end

	assign alu_result_po = alu_out_reg;
	assign carry_out_po = stc_cmd_pi | (carry_out_reg === 1);
	assign borrow_out_po = stb_cmd_pi | (borrow_out_reg ===1);
   


endmodule // alu

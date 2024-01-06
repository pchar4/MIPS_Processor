/*
 * Module: program_counter
 * Description: Program counter.
 *              Synchronously clear the program counter when "reset" and "clk_en" are asserted at a positive clock edge.
 *              Default action: increment the program counter by 2 (size of an instruction in bytes) every cycle unless halted.
 *              If a taken branch or jump is asserted: update the  program counter to the target address instead 
 *                                                    Target Address is PC + 2 + Sign-extended immediate value 
 *              Return the updated PC value in the output port signal "pc_po".
 * 
 */

module program_counter (
		input 	      clk_pi,
		input 	      clk_en_pi,
		input 	      reset_pi,
		
		input 	      branch_taken_pi,
		input [5:0]   branch_immediate_pi, // Needs to be sign extended		
		input 	      jump_taken_pi,
		input [11:0]  jump_immediate_pi, // Needs to be sign extended
			
		output [15:0] pc_po
		);

   	reg [15:0] 		      PC;  // Program Counter   
	assign pc_po = PC;
	initial
	PC <= 16'hFFFF;  // Do not remove. Assumed by the Testbench.

	wire[15:0] signextended_branch = branch_immediate_pi[5] ? {10'b1111111111, branch_immediate_pi} : {10'b0, branch_immediate_pi};
	wire[15:0] signextended_jump = jump_immediate_pi[11] ? {4'b1111, jump_immediate_pi} : {4'b0, jump_immediate_pi};
	always @(posedge clk_pi ) begin
		if (reset_pi) begin
			PC <= 0;
		end else begin
			if (clk_en_pi) begin
				if (branch_taken_pi) begin
					PC <= PC + signextended_branch + 2;
				end else if (jump_taken_pi) begin
					PC <= PC + signextended_jump + 2;
				end else
					PC <= PC + 2;
			end
		end
	end
   

endmodule




`timescale 1ns/1ns

/*
 * Module: processor
 * Description: The top module of this lab 
 */
module processor (
	input CLK_pi,
	input CPU_RESET_pi
); 
 

// Declare wires to interconnect the ports of the modules to implement the processor


   
   


   wire cpu_clk_en = 1'b1; // Used to slow down CLK in FPGA implementation
   wire reset, clock_enable;
   wire [15:0] curr_inst;
   
   // PC Wires
   wire br_taken;
   wire [15:0] pc;

   // Decoder Wires
   wire [2:0] alu_func, destination_reg, source_reg1, source_reg2;
   wire [11:0] immediate;
   wire arith_1op, arith_2op, movi_lower, movi_higher, addi, subi, load, store, 
   branch_eq, branch_ge, branch_le, branch_carry, jump, stc_cmd, stb_cmd, halt_cmd, rst_cmd;

   // ALU extra wires
   wire alu_carry_in, alu_borrow_in, alu_carry_out, alu_borrow_out;
   wire [15:0] reg1_data, reg2_data, alu_result; 

   // Regfile wire
   wire [15:0] dest_result_data, regD_data;
   wire wr_destination_reg, current_carry, current_borrow;
   assign wr_destination_reg = arith_2op | arith_1op | movi_lower | movi_higher | addi | subi | load;

   // mem_data wire
   wire [15:0] data_mem_data;
   // Write an "assign" statement for the "reset" signal
   assign reset = CPU_RESET_pi || (curr_inst == rst_cmd); // FIX THIS ONE

   // Write an "assign" statement for the  "clock_enable" signal
   assign clock_enable = cpu_clk_en & (~halt_cmd); // FIX THIS ONE TOO!


   // Add the input-output ports of each module instantiated below
   
decoder myDecoder(
.instruction_pi(curr_inst),
.alu_func_po(alu_func),
.destination_reg_po(destination_reg),
.source_reg1_po(source_reg1),
.source_reg2_po(source_reg2),
.immediate_po(immediate),
.arith_2op_po(arith_2op),
.arith_1op_po(arith_1op),
.movi_lower_po(movi_lower),
.movi_higher_po(movi_higher),
.addi_po(addi),
.subi_po(subi),
.load_po(load),
.store_po(store),
.branch_eq_po(branch_eq),
.branch_ge_po(branch_ge),
.branch_le_po(branch_le),
.branch_carry_po(branch_carry),
.jump_po(jump),
.stc_cmd_po(stc_cmd),
.stb_cmd_po(stb_cmd),
.halt_cmd_po(halt_cmd),
.rst_cmd_po(rst_cmd)
); 

alu  myALU(
.arith_1op_pi(arith_1op),
.arith_2op_pi(arith_2op),
.alu_func_pi(alu_func),
.addi_pi(addi),
.subi_pi(subi),
.load_or_store_pi(load | store),
.reg1_data_pi(reg1_data),
.reg2_data_pi(reg2_data),
.immediate_pi(immediate[5:0]),
.stc_cmd_pi(stc_cmd),
.stb_cmd_pi(stb_cmd),
.carry_in_pi(alu_carry_in),
.borrow_in_pi(alu_borrow_in),
.alu_result_po(alu_result),
.carry_out_po(alu_carry_out),
.borrow_out_po(alu_borrow_out)
);

branch  myBranch( 
.branch_eq_pi(branch_eq), 
.branch_ge_pi(branch_ge),
.branch_le_pi(branch_le),
.branch_carry_pi(branch_carry), 
.reg1_data_pi(reg1_data), 
.reg2_data_pi(reg2_data), 
.alu_carry_bit_pi(alu_carry_in), 
.is_branch_taken_po(br_taken)
);

regfile   myRegfile(
.clk_pi(CLK_pi),
.clk_en_pi(clock_enable),
.reset_pi(reset),
.source_reg1_pi(source_reg1),
.source_reg2_pi(source_reg2),
.destination_reg_pi(destination_reg),
.wr_destination_reg_pi(arith_2op | arith_1op | movi_lower | movi_higher | addi | subi | load),
.dest_result_data_pi(load ? data_mem_data : alu_result),
.movi_lower_pi(movi_lower),
.movi_higher_pi(movi_higher),
.immediate_pi(immediate[7:0]),
.new_carry_pi(alu_carry_out),
.new_borrow_pi(alu_borrow_out),

.reg1_data_po(reg1_data),
.reg2_data_po(reg2_data),
.regD_data_po(regD_data),
.current_carry_po(alu_carry_in),
.current_borrow_po(alu_borrow_in)
);

program_counter myProgram_counter( 
.clk_pi(CLK_pi), 
.clk_en_pi(clock_enable), 
.reset_pi(reset), 
.branch_taken_pi(br_taken), 
.branch_immediate_pi(immediate[5:0]), 
.jump_taken_pi(jump), 
.jump_immediate_pi(immediate), 
.pc_po(pc)
);

			  
instruction_mem myInstruction_mem( pc, curr_inst
);

data_mem  myData_mem(CLK_pi, clock_enable, reset, store, regD_data, alu_result, data_mem_data);
// assign foo = curr_inst;
// always @(posedge CLK_pi ) begin
//    if (curr_inst == 16'h4241) begin
//    #1;
//     $display("ALU_RESULT: %x\tREG1_DATA: %x\tIMMEDIATE[5:0]: %x", alu_result, reg1_data, immediate[5:0]);
//     $display("BR_Taken: %b\tJumpTaken: %x\tIMMEDIATE[5:0]: %x", {branch_eq, branch_ge, branch_le, branch_carry, alu_carry_in}, jump, immediate[5:0]);
//     $display("BR_Taken: %b\tJumpTaken: %x\tIMMEDIATE[5:0]: %x\tIMMEDIATE[5:0]%x\tpc: %x\tinst: %b", br_taken, jump, immediate[5:0], immediate, pc, curr_inst);
//   end
// end  
endmodule 



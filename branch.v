`timescale 1ns/1ns

module branch (
input        branch_eq_pi,
input        branch_ge_pi,
input        branch_le_pi,
input        branch_carry_pi,
input [15:0] reg1_data_pi,
input [15:0] reg2_data_pi,
input        alu_carry_bit_pi,

output  is_branch_taken_po)
;

// combining all input signals into 1 so that we can have a very parallel case statement
wire [3:0] instrs = {branch_eq_pi, branch_ge_pi, branch_le_pi, branch_carry_pi};
reg branchval = 0;
assign is_branch_taken_po = branchval;
always @(*) begin
    // instructions are a onehot vector
    // $display("instrs %b", {instrs, alu_carry_bit_pi});
    case (instrs)
        4'b1000: branchval = reg1_data_pi == reg2_data_pi;
        4'b0100: branchval = reg1_data_pi >= reg2_data_pi;
        4'b0010: branchval = reg1_data_pi <= reg2_data_pi;
        4'b0001: branchval = alu_carry_bit_pi;
        default: branchval = 0;

    endcase
    // $display("isbranchtaken %b", is_branch_taken_po);
end

endmodule // branch_comparator

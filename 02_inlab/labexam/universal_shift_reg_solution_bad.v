module universal_shift_reg (
    input clk,
    input rst,
    input [1:0] mode,
    input serial_in,
    input [3:0] parallel_in,
    output [3:0] q
);
    // TODO: Implement the universal shift register.
    reg q_reg [3:0];
    assign q = q_reg;

    always @(posedge clk) begin
        if(rst)
            q_reg <= 4'd0000;
        
        case(mode)
            00: q_reg <= q_reg;
            01: q_reg <= {serial_in, q_reg[2:0]};
            10: q_reg <= {q_reg[3:1],serial_in};
            11: q_reg <= parallel_in;
            default: q_reg <= q_reg;
        endcase
        
    end
endmodule

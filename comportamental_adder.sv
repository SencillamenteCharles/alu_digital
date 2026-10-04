
/**
This module is parametric.
Detectects aritmetic operation carry and overflow.

*/
module comportamental_adder  #(parameter LENGTH = 5)(
    input  wire signed [LENGTH-1:0] i_op_a_param,       // 
    input  wire signed [LENGTH-1:0] i_op_b_param,       // 
	 input  wire w_sum_substract, // true for sum, false for substract
    output reg  signed [LENGTH-1:0] o_param_result,  
    output reg               f_carry,   
    output reg               f_overflow 
);

    //extended register, to hold the carry.
    reg [LENGTH:0] ext_result;

    always @(*) begin
        if (w_sum_substract ==0) begin
            
				// result is in a extra bit , so operands.
				
            ext_result = {i_op_a_param[LENGTH-1], i_op_a_param} - {i_op_b_param[LENGTH-1], i_op_b_param};
				
        end else begin
            // Suma: A + B
            ext_result = {i_op_a_param[LENGTH-1], i_op_a_param} + {i_op_b_param[LENGTH-1], i_op_b_param};
        end

       
        o_param_result = ext_result[LENGTH-1:0];

        // El Carry se refleja en el bit 5 (desbordamiento aritmético sin signo o préstamo)
        f_carry = ext_result[LENGTH];

        // Detección de Overflow para números con signo:
        // Ocurre si los operandos tienen el mismo signo y el resultado tiene un signo distinto.
        // En una suma: (A y B positivos y Resultado negativo) o (A y B negativos y Resultado positivo)
        if (w_sum_substract) begin
            f_overflow = (i_op_a_param[LENGTH-1] == i_op_b_param[LENGTH-1]) && (o_param_result[LENGTH-1] != i_op_a_param[LENGTH-1]);
        end else begin
            // En una resta: (A y B tienen signos opuestos y el resultado tiene signo diferente a A)
            f_overflow = (i_op_a_param[LENGTH-1] != i_op_b_param[LENGTH-1]) && (o_param_result[LENGTH-1] != i_op_a_param[LENGTH-1]);
        end
    end

endmodule
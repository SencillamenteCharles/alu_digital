module ALU_PARAM #(parameter LENGTH = 5) ( 
    input i_clk,  
	 
	//Control
    input i_rst,
    input i_enable, 	
	
    //inputs	
    input signed  [LENGTH-1:0] i_porta,          
    input signed [LENGTH-1:0] i_portb,          
    input         [3:0]       i_control,
	 
	 //flags
	 output reg  f_carry,   
    output reg  f_overflow ,
    output reg f_zero,    //detect true logic operation zeros
	 
	 // outputs
    output reg  signed [LENGTH-1:0] o_result_low,    
	 output reg  [LENGTH-1:0] o_result_high //used only to store high part of multiplication.   
);

//registros para las entradas
reg signed [LENGTH-1:0] i_porta_reg;
reg signed [LENGTH-1:0] i_portb_reg;
reg  [LENGTH-1:0] w_temporal_result_low;
reg  [LENGTH-1:0] w_temporal_result_high;
reg signed [LENGTH-1:0] o_result_low_reg;
reg  [LENGTH-1:0] o_result_high_reg;
//hold whole multiplication
reg signed [(LENGTH *2 )-1:0] w_multiplication_result;
reg signed [(LENGTH *2 )-1:0] w_expected_multiplication_result;

/** import modules
**
**
**
*/
//regs for  imported  modules.
reg signed [LENGTH-1:0] w_adder_output;
reg f_w_sum_substract;// true for tell adder to do sum, false to do substraction
reg f_overflow_adder;
comportamental_adder #(.LENGTH(LENGTH)) adder_subtracter
(
    .i_op_a_param     (i_porta_reg),       // 
    .i_op_b_param     (i_portb_reg),       // 
	 . w_sum_substract (f_w_sum_substract), // true for sum, false for substract
    .o_param_result   (w_adder_output),  
    .f_carry          (f_carry),   // Bandera de Carry / Préstamo
    .f_overflow       (f_overflow_adder) 
);


reg signed [LENGTH-1:0] w_negative_output;
reg f_overflow_negative;
omportamental_negative_param #(.LENGTH(LENGTH)) negative
(

    .i_op_b_param    (i_portb_reg),       // 
    .o_param_result (w_negative_output),   
    .f_overflow( f_overflow_negative) 
);


multiplier_signed_param #(.LENGTH(LENGTH)) multiplier
(
    .i_a (i_porta_reg),
    .i_b(i_porta_reg),
    .o_y (w_multiplication_result)
);


// do enable storage, and zeroize registers in posedge
always@( posedge i_clk) begin

  //highest priority signal
   if(i_rst)begin
	
	//clear registers
		i_porta_reg <= {LENGTH{1'b0}};
		i_portb_reg <= {LENGTH{1'b0}};
		o_result_low_reg<= {LENGTH{1'b0}};
		o_result_high_reg<= {LENGTH{1'b0}};
		
	//clear outputs

    //clear flags	
		
	end 
	// storage input and output into registers
  else if( i_enable) begin
  
  // make registers read inputs
	  i_porta_reg <= i_porta;
	  i_portb_reg <= i_portb;
	  
	  
	o_result_low_reg <= w_temporal_result_low;
	o_result_high_reg <= w_temporal_result_high;
	;
	end
	
  else begin
  // when not enable registers hold their value
     i_porta_reg <= i_porta_reg;
	  i_portb_reg <= i_portb_reg;
	  o_result_low_reg<= o_result_low_reg;
	  o_result_high_reg<= o_result_high_reg;
  
  end

end

// make outputs copy registers
assign  o_result_low = o_result_low_reg;	 
assign o_result_high = o_result_high_reg;


    always @(*) begin
	 
		 //o_result_high= {LENGTH{1'b0}};
		 f_w_sum_substract=0;
		 w_temporal_result_low= {LENGTH{1'b0}};
		 
        case (i_control)
            4'd0: begin //do sum
					f_w_sum_substract= 1;
					//load output from the adder into the output low register
				    w_temporal_result_low=  w_adder_output;
					//load overflow adder flag to alu overflow flag
					f_overflow = f_overflow_adder;
				       end
			 4'd1: begin //do substraction
					f_w_sum_substract= 0;
					//load output from the adder into the output low register
				     w_temporal_result_low=  w_adder_output;
					 //load overflow adder flag to alu overflow flag
					f_overflow = f_overflow_adder;
				    end	
			 4'd2:begin //do negative of b
			        w_temporal_result_low = w_negative_output;
					//load overflow negaive flag to alu overflow flag
					f_overflow = f_overflow_negative;
			 end
             4'd3: begin //do multiply
				w_temporal_result_high = w_multiplication_result[(LENGTH *2 )-1:LENGTH];
				w_temporal_result_low =w_multiplication_result[LENGTH -1:0]; 
			 end	

			4'd4: w_temporal_result_low = unsigned'(i_porta_reg) & unsigned'(i_portb_reg);                // Operación lógica AND
            4'd5: w_temporal_result_low = unsigned'(i_porta_reg) | unsigned'(i_portb_reg);                // Operación lógica OR
            4'd6: w_temporal_result_low = ~ (unsigned'(i_porta_reg));                   // Negación lógica/bit a bit de A
            4'd7: w_temporal_result_low = unsigned'(i_porta_reg) ^ unsigned'(i_portb_reg);                // Operación lógica XOR
            4'd8: w_temporal_result_low = unsigned'(i_porta_reg) << unsigned'(i_portb_reg[3:0]) ;          // Corrimiento de bits a la izquierda
            4'd9: w_temporal_result_low = unsigned'(i_porta_reg) >> unsigned'(i_portb_reg[3:0]);          // Corrimiento de bits a la derecha		

            default: w_temporal_result_low = {LENGTH{1'b0}};     // 
        endcase
    end

	 
	 
/*zero flag processing	
 
 if aritmetic operation is true, it means control carries an aritmetic operation
 if aritmetic operation is zero, it means control carries an logic operation
with aritmetic operations we can detect a true zero.
*/
assign f_aritmetic_operation = (~i_control[3]) & (~i_control[2])  ; 
assign f_logic_operation = (~f_aritmetic_operation)  ; 

 always @(*) begin
   if ((f_logic_operation ==1 ) && (o_result_low == {LENGTH, 1'b0}) )begin
	     
		 f_zero <= 1 ;//,means that logic operation in  the ALU is zero. 
	end
	else begin 
	      f_zero <= 0;
	end
    
 end

 /*
 overflow flag processing
 */
 

endmodule



module omportamental_negative_param  #(parameter LENGTH = 5)(
    input  wire signed [LENGTH-1:0] i_op_b_param,       // 
    output reg  signed [LENGTH-1:0] o_param_result,   
    output reg               f_overflow 
);

    //extended register, to hold the carry.
    reg [LENGTH:0] ext_result;

    always @(*) begin

     //ext_result = { {LENGTH-1 {1'b0}}, 1} + (~ i_op_b_param);
   ext_result=-i_op_b_param;
   o_param_result= ext_result[LENGTH-1:0];
     //find if the number is the least negative value

    if( i_op_b_param[LENGTH-1] && ( i_op_b_param[LENGTH-2:0 ]== {LENGTH-2{1'b1}}))
    f_overflow = 1'b1;
    else
       f_overflow = 1'b0;
       
    end

endmodule

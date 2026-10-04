
// mutiplicador comportamental parametrico en complemento a dosh.
module multiplier_signed_param #(parameter LENGTH = 5)  // Ancho paramétrico de las entradas y salida x2
(
    input signed [LENGTH-1:0] i_a,
    input signed [LENGTH-1:0] i_b,
    

    output signed [(LENGTH*2)-1:0] o_y 
);


    assign o_y = i_a * i_b;

endmodule
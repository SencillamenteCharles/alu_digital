
`timescale 1ns/1ps


`define TEST_ADD       //good
//`define TEST_SUB         // good
//`define TEST_NEG_B       // needs overflow fix
`define TEST_MULT

`define TEST_AND      //good
`define TEST_OR       //good
`define TEST_NEG_LOG    //good
`define TEST_XOR         //good
`define TEST_SHIFT_LEFT    //good
`define TEST_SHIFT_RIGTH

module tb();

    // Parameters
    parameter LENGTH = 5;

    // Testbench Inputs
    reg i_clk;
    reg i_rst;
    reg i_enable;
    reg signed [LENGTH-1:0] i_porta;
    reg signed [LENGTH-1:0] i_portb;
    reg [3:0] i_control;

    // Testbench Outputs
	 reg f_evauluation_debug;
    wire f_zero;
    wire f_carry;  
    wire f_overflow;
    wire signed [LENGTH-1:0] o_result_low;
    wire signed [LENGTH-1:0] o_result_high;


    // Instantiate the Unit Under Test (UUT)
    ALU_PARAM #(.LENGTH(LENGTH)) uut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_enable(i_enable),
        .i_porta(i_porta),
        .i_portb(i_portb),
        .i_control(i_control),
        .f_carry(f_carry),   
        .f_overflow(f_overflow) ,
        .f_zero(f_zero),
        .o_result_low(o_result_low),
        .o_result_high(o_result_high)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 i_clk = ~i_clk;

	 
reg signed [LENGTH:0]i;
reg signed [LENGTH:0]j;
logic [32:0]u_i;
logic [32:0] u_j;
reg signed [LENGTH:0]expected_tb_o_result_low;
reg  [31:0]failed_operations_counter;
reg  [31:0]overflow_operations_counter;
reg  [31:0]operations_executed;

/* initial values and setup
 *
*/
    initial begin
        // Initialize Signals
        i_clk = 0;
        i_rst = 1;
        i_enable = 0;//active high enable
        i_porta = 0;
        i_portb = 0;
        f_evauluation_debug=0;	
		  
		  //release  reset an enable ALU
		  #20 
		   i_rst = 0;           
		   i_enable = 1;
		  
        $display(" starting complete ALU test bench ");
        $display(" ");

/*  Begin of adder tb, op0 ***************************************************************************************************************
**
*/	
`ifdef TEST_ADD
		i_control = 4'd0; // Set control code to 0 for AdditioN   
         operations_executed= 0;
         failed_operations_counter=0;
         overflow_operations_counter=0;

        for (i = -(2**(LENGTH-1)); i <= (2**(LENGTH-1))-1; i = i + 1) begin
        
            for (j = -(2**(LENGTH-1)); j <= (2**(LENGTH-1))-1; j = j + 1) begin   
                operations_executed++;
                i_porta = i ; // Tomamos el bit menos significativo como ejemplo
                i_portb =  j;   
				expected_tb_o_result_low = i + j;	  	
                #20;// let some time for the registers capture inputs

				f_evauluation_debug=1;//used to know when the test bench is evaluating the output
                if( (expected_tb_o_result_low != o_result_low) && (f_overflow ==0 )	)begin
						failed_operations_counter++;		
						$display("ADDER ERROR %d + %d != %d , expecting %d", i_porta, i_portb,  o_result_low ,expected_tb_o_result_low);			
				end
                if( (expected_tb_o_result_low != o_result_low) && (f_overflow ==1 )	)begin
						overflow_operations_counter++;		
						//$display(" ADDER OVERFLOW at operation # %d : %d + %d != %d , expecting %d",operations_executed,  i_porta, i_portb,  o_result_low ,expected_tb_o_result_low);		
				end
			    #5;
				 f_evauluation_debug=0;
			    #10;
            end
		end
        $display(" adder verification results for %d operations executed",operations_executed );
        $display(" Ops failed %d ", failed_operations_counter );
        $display(" Ops overflowed %d ",overflow_operations_counter );
        if( failed_operations_counter ==0)
             $display(" operation with control %d PASSED", i_control) ;
        else
        $display(" operation with control %d FAILED!", i_control );
        $display(" ");
`endif
/*  Begin of adder sub tb op1 ***************************************************************************************************************
**
*/
`ifdef TEST_SUB	
		i_control = 4'd1; // do substraction with adder
        operations_executed= 0;
        failed_operations_counter=0;
        overflow_operations_counter=0;
        for (i = -(2**(LENGTH-1)); i <= (2**(LENGTH-1))-1; i = i + 1) begin
            for (j = -(2**(LENGTH-1)); j <= (2**(LENGTH-1))-1; j = j + 1) begin   
                operations_executed++;
                i_porta = i ; // Tomamos el bit menos significativo como ejemplo
                i_portb =  j;   
				expected_tb_o_result_low = i - j;	  
				
                #20;//let some clock cycles for the registers store value
					 f_evauluation_debug=1;
                if( (expected_tb_o_result_low != o_result_low) && (f_overflow ==0 )	)begin
			
						failed_operations_counter++;		
						$display("ADDER subs ERROR %d - (%d) != %d , expecting %d", i_porta, i_portb,  o_result_low ,expected_tb_o_result_low);
						
				end

                  if( (expected_tb_o_result_low != o_result_low) && (f_overflow ==1 )	)begin
			
						overflow_operations_counter++;		
						//$display(" ADDER Subs OVERFLOW at operation # %d : %d - (%d) != %d , expecting %d",operations_executed,  i_porta, i_portb,  o_result_low ,expected_tb_o_result_low);
						
				end



					 #5;
					 f_evauluation_debug=0;
					#10;
            end
		end
        $display(" subtraction  verification results for %d operations executed",operations_executed );
        $display(" Ops failed %d ", failed_operations_counter );
        $display(" Ops overflowed %d ",overflow_operations_counter );
        if( failed_operations_counter ==0)
        $display(" operation with control %d PASSED", i_control );
        else
            $display(" operation with control %d FAILED!", i_control );
        $display(" ");
`endif
/*   Begin  OF Negative of B tb op2  **************************************************************************************************
**
*/
`ifdef TEST_NEG_B	
	    i_control = 4'd2; // do negative
        operations_executed= 0;
        failed_operations_counter=0;
        overflow_operations_counter=0;

        for (j = -(2**(LENGTH-1)); j <= (2**(LENGTH-1))-1; j = j + 1) begin   
            operations_executed++;
            i_portb =  j;   
            expected_tb_o_result_low =  - j;	              
            #20;//let some clock cycles for the registers store value
            f_evauluation_debug=1;
            if( (expected_tb_o_result_low != o_result_low) && (f_overflow ==0 )	)begin
                    
                    failed_operations_counter++;		
                  $display("NEGATIVE of B ERROR  (%d) *-1 != %d  , expecting %d see op#%d",  i_portb,  o_result_low ,expected_tb_o_result_low, operations_executed);                 
            end

             if( (expected_tb_o_result_low != o_result_low) && (f_overflow ==1 )	)begin
                    
                    overflow_operations_counter++;		
                    $display("NEGATIVE of B OVERFLOW  (%d) *-1 != %d  , expecting %d see op#%d",  i_portb,  o_result_low ,expected_tb_o_result_low, operations_executed);                 
             end  
               #5;
               f_evauluation_debug=0;
                #10;
        end
        $display(" negative of B  verification results for %d operations executed",operations_executed );
        $display(" Ops failed %d ", failed_operations_counter );
        $display(" Ops overflowed %d ",overflow_operations_counter );
        if( failed_operations_counter ==0)
            $display(" operation with control %d PASSED", i_control );
        else
            $display(" operation with control %d FAILED!", i_control );
        $display(" ");
`endif
/*   Begin of Multiplier TB op3 *******************************************************************************************************
**
*/	
`ifdef TEST_MULT
		i_control = 4'd3; // Set control code to 0 for AdditioN   
         operations_executed= 0;
         failed_operations_counter=0;
         overflow_operations_counter=0;

        for (i = -(2**(LENGTH-1)); i <= (2**(LENGTH-1))-1; i = i + 1) begin
        
            for (j = -(2**(LENGTH-1)); j <= (2**(LENGTH-1))-1; j = j + 1) begin   
                operations_executed++;
                i_porta = i ; // Tomamos el bit menos significativo como ejemplo
                i_portb =  j;   
				expected_tb_o_result_low = i  *j;	  	
                #20;// let some time for the registers capture inputs

				f_evauluation_debug=1;//used to know when the test bench is evaluating the output
                if( (expected_tb_o_result_low != o_result_low) 	)begin
						failed_operations_counter++;		
						//$display("MULtiplier ERROR %d + %d != %d , expecting %d", i_porta, i_portb,  o_result_low ,expected_tb_o_result_low);			
				end

			    #5;
				 f_evauluation_debug=0;
			    #10;
            end
		end
        $display(" multiplier verification results for %d operations executed",operations_executed );
        $display(" Ops failed %d ", failed_operations_counter );
        $display(" Ops overflowed %d ",overflow_operations_counter );
        if( failed_operations_counter ==0)
             $display(" operation with control %d PASSED", i_control) ;
        else
        $display(" multiplier FAILED!", i_control );
        $display(" ");

`endif
/*   Begin of AND TB , op4 ************************************************************************************************************
**
*/	
`ifdef TEST_AND
         i_control = 4'd4;   
         operations_executed= 0;
         failed_operations_counter=0;
         overflow_operations_counter=0;

  for (u_i = 0; u_i <= 5'd31; u_i = u_i + 1) begin
            for (u_j = 0; u_j <= 5'd31; u_j = u_j + 1) begin   
                operations_executed++;
                i_porta = u_i ; // Tomamos el bit menos significativo como ejemplo
                i_portb =  u_j;   
				expected_tb_o_result_low = u_i & u_j;	  	
                #20;// let some time for the registers capture inputs

				f_evauluation_debug=1;//used to know when the test bench is evaluating the output
                if( (expected_tb_o_result_low[LENGTH-1:0] != o_result_low) 	)begin
						failed_operations_counter++;		
						$display("AND ERROR %b + %b != %b , expecting %d", i_porta, i_portb,  o_result_low ,expected_tb_o_result_low);			
				end
  
			    #5;
				 f_evauluation_debug=0;
			    #10;
            end
           
	end

        $display(" AND verification results for %d operations executed",operations_executed );
        $display(" Ops failed %d ", failed_operations_counter );
        if( failed_operations_counter ==0)
             $display(" operation with control %d PASSED", i_control) ;
        else
        $display(" operation with control %d FAILED!", i_control );
        $display(" ");
`endif
/*   Begin of OR TB , op5 ************************************************************************************************************
**
*/	
`ifdef TEST_OR
    i_control = 4'd5; //  
         operations_executed= 0;
         failed_operations_counter=0;
         overflow_operations_counter=0;

  for (u_i = 0; u_i <= 5'd31; u_i = u_i + 1) begin
            for (u_j = 0; u_j <= 5'd31; u_j = u_j + 1) begin
                operations_executed++;
                i_porta = u_i ; // Tomamos el bit menos significativo como ejemplo
                i_portb =  u_j;   
				expected_tb_o_result_low = u_i | u_j;	  	
                #20;// let some time for the registers capture inputs

				f_evauluation_debug=1;//used to know when the test bench is evaluating the output
                if( (expected_tb_o_result_low[LENGTH-1:0] != o_result_low) 	)begin
						failed_operations_counter++;		
						$display("OR ERROR %d | %d != %d , expecting %d", i_porta, i_portb,  o_result_low ,expected_tb_o_result_low);			
				end
             
			    #5;
				 f_evauluation_debug=0;
			    #10;
            end
		end
        $display(" OR verification results for %d operations executed",operations_executed );
        $display(" Ops failed %d ", failed_operations_counter );
        if( failed_operations_counter ==0)
             $display(" operation with control %d PASSED", i_control) ;
        else
        $display(" operation with control %d FAILED!", i_control );
        $display(" ");
`endif
/*   Begin of logic negation of A  TB , op6 ******************************************************************************************
**
*/	
`ifdef TEST_NEG_LOG

    i_control = 4'd6; // do negative
        operations_executed= 0;
        failed_operations_counter=0;
        overflow_operations_counter=0;

        for (u_i = 0; u_i <= 5'd31; u_i = u_i + 1) begin
            operations_executed++;
            i_porta = u_i[LENGTH-1:0];   
            expected_tb_o_result_low =  ~ u_i[LENGTH-1:0];	              
            #20;//let some clock cycles for the registers store value
            f_evauluation_debug=1;
            if( (expected_tb_o_result_low[LENGTH-1:0] != o_result_low) 	)begin
                    failed_operations_counter++;		
                  $display("Logic negative of A ERROR  (%b) *-1 != %b  , expecting %b see op#%d",  i_portb,  o_result_low ,expected_tb_o_result_low, operations_executed);                 
            end
  
               #5;
               f_evauluation_debug=0;
                #10;
        end
        $display(" negative of B  verification results for %d operations executed",operations_executed );
        $display(" Ops failed %d ", failed_operations_counter );
        $display(" Ops overflowed %d ",overflow_operations_counter );
        if( failed_operations_counter ==0)
            $display(" Logic negative of A  PASSED 100 percent", i_control );
        else
            $display("Logic negative of A FAILED!", i_control );
        $display(" ");
`endif

/*   Begin of XOR TB , op7 ************************************************************************************************************
**
*/	
`ifdef TEST_XOR
         i_control = 4'd7;  
         operations_executed= 0;
         failed_operations_counter=0;
         overflow_operations_counter=0;

 for (u_i = 0; u_i <= 5'd31; u_i = u_i + 1) begin
            for (u_j = 0; u_j <= 5'd31; u_j = u_j + 1) begin 
                operations_executed++;
                i_porta =  u_i ; // Tomamos el bit menos significativo como ejemplo
                i_portb =  u_j;   
				expected_tb_o_result_low = u_i ^ u_j;	  	
                #20;// let some time for the registers capture inputs

				f_evauluation_debug=1;//used to know when the test bench is evaluating the output
                if( (expected_tb_o_result_low[LENGTH-1:0] != o_result_low) 	)begin
						failed_operations_counter++;		
						$display("XOR ERROR %b + %b != %b , expecting %b", i_porta, i_portb,  o_result_low ,expected_tb_o_result_low);			
				end
            
			    #5;
				 f_evauluation_debug=0;
			    #10;
            end
		end
        $display(" XOR verification results for %d operations executed",operations_executed );
        $display(" Ops failed %d ", failed_operations_counter );
        if( failed_operations_counter ==0)
             $display(" XOR operation  PASSED") ;
        else
        $display(" XOR operation FAILED!");
        $display(" ");
`endif

/*   Begin of bit shift A << B[3:0]TB , op8 ************************************************************************************************************
**
*/
`ifdef TEST_SHIFT_LEFT
         i_control = 4'd8; //    
         operations_executed= 0;
         failed_operations_counter=0;
         overflow_operations_counter=0;

        for (u_i = 0; u_i <= 5'd31; u_i = u_i + 1) begin
            for (u_j = 0; u_j <= 5'd15; u_j = u_j + 1) begin  
                operations_executed++;
                i_porta = u_i ; // Tomamos el bit menos significativo como ejemplo
                i_portb =  u_j;   
				expected_tb_o_result_low = u_i<< (u_j[LENGTH-2:0]);	  	
                #20;// let some time for the registers capture inputs

				f_evauluation_debug=1;//used to know when the test bench is evaluating the output
                if( (expected_tb_o_result_low[LENGTH-1:0] != o_result_low) 	)begin
						failed_operations_counter++;		
						$display("Shift << ERROR %b << %d != %b , expecting %b", i_porta, i_portb,  o_result_low ,expected_tb_o_result_low);			
				end
            
			    #5;
				 f_evauluation_debug=0;
			    #10;
            end
		end
        $display(" Shift << verification results for %d operations executed",operations_executed );
        $display(" Ops failed %d ", failed_operations_counter );
        if( failed_operations_counter ==0)
             $display(" Shift << PASSED", ) ;
        else
        $display("  Shift << PASSED");
        $display(" ");
`endif
/*   Begin of bit shift A >>B[3:0]TB , op9 ************************************************************************************************************
**
*/	
`ifdef TEST_SHIFT_RIGTH
         i_control = 4'd9; //    
         operations_executed= 0;
         failed_operations_counter=0;
         overflow_operations_counter=0;

        for (u_i = 0; u_i <= 5'd31; u_i = u_i + 1) begin
            for (u_j = 0; u_j <= 5'd15; u_j = u_j + 1) begin  
                operations_executed++;
                i_porta = u_i ; // Tomamos el bit menos significativo como ejemplo
                i_portb =  u_j;   
				expected_tb_o_result_low = u_i>> (u_j[LENGTH-2:0]);	  	
                #20;// let some time for the registers capture inputs

				f_evauluation_debug=1;//used to know when the test bench is evaluating the output
                if( (expected_tb_o_result_low[LENGTH-1:0] != o_result_low) 	)begin
						failed_operations_counter++;		
						$display("Shift >> ERROR %b >> %d != %b , expecting %b", i_porta, i_portb,  o_result_low ,expected_tb_o_result_low);			
				end
            
			    #5;
				 f_evauluation_debug=0;
			    #10;
            end
		end
        $display(" Shift >> verification results for %d operations executed",operations_executed );
        $display(" Ops failed %d ", failed_operations_counter );
        if( failed_operations_counter ==0)
             $display(" Shift >> PASSED", ) ;
        else
        $display("  Shift >> PASSED");
        $display(" ");
`endif

   $stop;
    end

endmodule
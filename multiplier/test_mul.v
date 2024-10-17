/* ACM Class System (I) Fall Assignment 1 
 *
 *
 * This file is used to test your adder. 
 * Please DO NOT modify this file.
 * 
 * GUIDE:
 *   1. Create a RTL project in Vivado
 *   2. Put `adder.v' OR `adder2.v' into `Sources', DO NOT add both of them at the same time.
 *   3. Put this file into `Simulation Sources'
 *   4. Run Behavioral Simulation
 *   5. Make sure to run at least 100 steps during the simulation (usually 100ns)
 *   6. You can see the results in `Tcl console'
 *
 */

`include "mul1.v"

module test_adder;
	wire [31:0] answer;
	reg  [15:0] a, b;
	reg	 [31:0] res;

	multiplier mul (a, b, answer);
	
	integer i;
	initial begin
		for(i=1; i<=100; i=i+1) begin
			a[15:0] = $random;
			b[15:0] = $random;
			res		= a * b;
			
			#1;
			$display("TESTCASE %d: %d * %d = %d [ans: %d]", i, a, b, answer, res);

			if (answer !== res) begin
				$display("Wrong Answer!");
			end
		end
		$display("Congratulations! You have passed all of the tests.");
		$finish;
	end
endmodule

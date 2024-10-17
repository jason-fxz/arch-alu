/* ACM Class System (I) Fall Assignment 1 
 *
 *
 * Implement your naive adder here
 * 
 * GUIDE:
 *   1. Create a RTL project in Vivado
 *   2. Put this file into `Sources'
 *   3. Put `test_adder.v' into `Simulation Sources'
 *   4. Run Behavioral Simulation
 *   5. Make sure to run at least 100 steps during the simulation (usually 100ns)
 *   6. You can see the results in `Tcl console'
 *
 */

module adder(
	// Hint: 
	//   The module needs 4 ports, 
	//     the first 2 ports are 16-bit unsigned numbers as the inputs of the adder
	//     the third port is a 16-bit unsigned number as the output
	//	   the forth port is a one bit port as the carry flag
	// 
	input [15:0] a,
	input [15:0] b,
	output [15:0] answer,
	output carry
);
	wire [16:0] temp; // temp carry

	assign temp[0] = 1'b0;

	genvar i;
	generate
		for (i = 0; i < 16; i = i + 1) begin
			assign answer[i] = a[i] ^ b[i] ^ temp[i];
			assign temp[i + 1] = (a[i] & b[i]) | (a[i] & temp[i]) | (b[i] & temp[i]);
		end
	endgenerate

	assign carry = temp[16];

	
endmodule

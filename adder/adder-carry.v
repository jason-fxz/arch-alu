// ref: https://blog.csdn.net/qq_39507748/article/details/108911941

module CLA4 (
	input [3:0] a,
	input [3:0] b,
	input Cin,
	output [3:0] sum,
	output Cout
);
	wire [3:0] G, P, C;
	assign P = a ^ b;
	assign G = a & b;

	assign C[0] = Cin;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C[0]);

	assign sum = P ^ C;
endmodule

module RCLA16 (
	input [15:0] a,
	input [15:0] b,
	input Cin,
	output [15:0] sum,
	output Cout
);
	wire [3:0] C;
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin
			CLA4 cla4_inst (
				.a(a[i*4 +: 4]),
				.b(b[i*4 +: 4]),
				.Cin(i == 0 ? Cin : C[i-1]),
				.sum(sum[i*4 +: 4]),
				.Cout(C[i])
			);
		end
	endgenerate
	
	assign Cout = C[3];
endmodule


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

	RCLA16 rcla16_inst (
		.a(a),
		.b(b),
		.Cin(1'b0),
		.sum(answer),
		.Cout(carry)
	);

	

	
endmodule

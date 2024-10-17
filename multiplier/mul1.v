module multiplier(
    input [15:0] a,
    input [15:0] b,
    output [31:0] res
);
    wire [31:0] b_shifted [15:0];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : shift_loop
            assign b_shifted[i] = (a[i] == 1'b1) ? (b << i) : 0;
        end
    endgenerate

    wire [31:0] sum01 = b_shifted[0] + b_shifted[1];
    wire [31:0] sum23 = b_shifted[2] + b_shifted[3];
    wire [31:0] sum45 = b_shifted[4] + b_shifted[5];
    wire [31:0] sum67 = b_shifted[6] + b_shifted[7];
    wire [31:0] sum89 = b_shifted[8] + b_shifted[9];
    wire [31:0] sumAB = b_shifted[10] + b_shifted[11];
    wire [31:0] sumCD = b_shifted[12] + b_shifted[13];
    wire [31:0] sumEF = b_shifted[14] + b_shifted[15];

    wire [31:0] sum0123 = sum01 + sum23;
    wire [31:0] sum4567 = sum45 + sum67;
    wire [31:0] sum89AB = sum89 + sumAB;
    wire [31:0] sumCDEF = sumCD + sumEF;

    wire [31:0] sum01234567 = sum0123 + sum4567;
    wire [31:0] sum89ABCDEF = sum89AB + sumCDEF;

    assign res = sum01234567 + sum89ABCDEF;
    


endmodule

// https://www.cnblogs.com/lyc-seu/p/12842399.html
module multiplier(
    input [15:0] a,
    input [15:0] b,
    output [31:0] res
);
    reg [31:0] tmp;
    reg [15:0] multiplier;
    reg [31:0] multiplicand;
    integer i;

    always @(*) begin
        tmp = 0;
        multiplier = b;
        multiplicand = {16'b0, a}; 

        for (i = 0; i < 16; i = i + 1) begin
            if (multiplier[i] == 1) begin
                tmp = tmp + multiplicand;
            end
            multiplicand = multiplicand << 1;
        end
    end

    assign res = tmp;
endmodule
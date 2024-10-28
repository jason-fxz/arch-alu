
`include "adder-float.v"

// `timescale 1ns/1ps
module floatadd_tb();
    reg clk,rst;
    reg [31:0] x,y;
    wire [31:0] z;
    wire [1:0] overflow;
    reg [31:0] ans;
    
    float_adder floatadd_test(
        .clk(clk),
        .rst(rst),
        .x(x),
        .y(y),
        .z(z),
        .overflow(overflow)
    );
    always #(10) clk<=~clk;
        
    initial begin
        rst = 1'b1;
        // data check in https://tooltt.com/ieee/
        clk=0;
        x=32'b00111111010001111010111000010100;//0.78
        y=32'b00111111000011001100110011001101;//0.55
        ans = 32'b00111111101010100011110101110000; // 1.3299999
        rst=1'b0; #10 rst=1'b1; #10
        // 0x3FAA3D70	0b00111111101010100011110101110000
        #1000
        $display("Test: %b + %b = %b", x, y, z);
        if (z !== ans) begin
            $display("Wrong Answer!");
        end

        x=32'h4248CCCD;//50.2
        y=32'h3F8CCCCD;//1.1
        ans = 32'h424D3333; // 51.3
        rst=1'b0; #10 rst=1'b1; #10
        // 0x424D3333	0b01000010010011010011001100110011
        #1000
        $display("Test: %b + %b = %b", x, y, z);
        if (z !== ans) begin
            $display("Wrong Answer!");
        end

        x=32'h10A0201D;//6.3158350761658E-29
        y=32'h1FFFFFF5;//1.0842014616272E-19
        ans=32'h1FFFFFF5; // 1.08420146E-19
        rst=1'b0; #10 rst=1'b1; #10
        // 0x1FFFFFF5	0b00011111111111111111111111110101
        #1000
        $display("Test: %b + %b = %b", x, y, z);
        if (z !== ans) begin
            $display("Wrong Answer!");
        end

    
        x=32'h00000000; // 0.0
        y=32'h4248CCCC; // 50.2
        ans=32'h4248CCCC; // 50.2
        rst=1'b0; #10 rst=1'b1; #10
        #1000
        $display("Test: %b + %b = %b", x, y, z);
        if (z !== ans) begin
            $display("Wrong Answer!");
        end

        x=32'h4248CCCC; // 50.2
        y=32'h00000000; // 0.0
        ans=32'h4248CCCC; // 50.2
        rst=1'b0; #10 rst=1'b1; #10
        #1000
        $display("Test: %b + %b = %b", x, y, z);
        if (z !== ans) begin
            $display("Wrong Answer!");
        end

        x=32'b01000010110010000000000000000000;//100
        y=32'b01000011010010000000000000000000;//200
        ans=32'h43960000; // 300
        rst=1'b0; #10 rst=1'b1; #10
        #1000
        $display("Test: %b + %b = %b", x, y, z);
        if (z !== ans) begin
            $display("Wrong Answer!");
        end

        x=32'hBF000000;//-0.5
        y=32'h3F99999A;//1.2
        ans=32'h3F333334; // 0.70000005
        // 0x3F333334	0b00111111001100110011001100110100
        rst=1'b0; #10 rst=1'b1; #10
        #1000
        $display("Test: %b + %b = %b", x, y, z);
        if (z !== ans) begin
            $display("Wrong Answer!");
        end
        

        
        x=32'h7F7FFFFF;
        y=32'h7F7FFFFF;//验证上溢出 overflow=2'b01 7FFFFFFF
        ans=32'h7F800000;
        rst=1'b0; #10 rst=1'b1; #10
        #1000
        $display("Test: %b + %b = %b", x, y, z);
        if (z !== ans) begin
            $display("Wrong Answer!");
        end


        #2000 $finish;
    end
endmodule

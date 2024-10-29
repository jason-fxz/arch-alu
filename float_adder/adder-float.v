module float_adder(
    input   clk,
    input   rst,
    input   [31:0]  x,
    input   [31:0]  y,
    output  reg [31:0]  z,
    output  reg [1:0]   overflow//2'b00:没有溢出   2'b01:上溢  2'b10:下溢  2'b11:输入 NaN/inf
);
    // 31-31  30-23  22-0
    // 1bit | 8bit | 23bit
    // S       E      M
    reg [24:0] m_x, m_y, m_z;
    reg [27:0] m_x_ext, m_y_ext, m_z_ext;
    reg [7:0] e_x, e_y, e_z;
    reg [2:0] s_x, s_y, s_z; 
    reg [2:0] state_now, state_next;


    parameter S_start = 3'b000;
    parameter S_align = 3'b001;
    parameter S_add = 3'b010;
    parameter S_normal = 3'b011;
    parameter S_overflow = 3'b100;
    parameter S_zerocheck = 3'b101;
    parameter S_IDLE = 3'b110;

    //  初始化 -> 判断0 -> 对阶 -> 尾数相加,判断正负 -> 规格化  
    //   |-> 溢出特判
    // S_start S_overflow  S_align  S_add S_normal S_zerocheck

    // 零附近有非规约数，先不管了

    
    wire [5:0] shift_bit;
    FHB32 fhb32_x(
        .x({4'b0, m_z_ext}),
        .high_bit(shift_bit)
    );

    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            //$display("RESET");
            state_now <= S_start;
        end
        else begin
            state_now <= state_next;
        end
    end

    always @(state_now, x, y) begin
        case(state_now)
            S_start: begin
                e_x = x[30:23];
                e_y = y[30:23];
                m_x = {2'b01 , x[22:0]}; // 留了一个空位方便进位
                m_y = {2'b01, y[22:0]};
                s_x = x[31];
                s_y = y[31];
                //$display("Hello x = %b y = %b; e_x=%b e_y=%b", x, y, e_x, e_y);

                // 一些特判
                // 输入有 NaN，=> NaN
                if ((e_x == 8'd255 && m_x[22:0] != 0) || (e_y == 8'd255 && m_y[22:0] != 0)) begin
                    overflow <= 2'b11;
                    state_next <= S_overflow;
                    s_z <= 1'b1;
                    e_z <= 8'd255;
                    m_z <= 23'b11111111111111111111111;
                end
                // 出现 inf
                else if ((e_x == 8'd255 && m_x[22:0] == 0) || (e_y == 8'd255 && m_y[22:0] == 0)) begin
                    // 两个 inf 相加 且符号不同, => NaN
                    // 否则，返回对应符号的 inf
                    //$display("inf+inf");
                    overflow <= 2'b11;
                    state_next <= S_overflow;
                    s_z <= s_x;
                    e_z <= 8'd255;
                    if ((e_x == 8'd255 && m_x[22:0] == 0) && (e_y == 8'd255 && m_y[22:0] == 0) && s_x != s_y) begin
                        m_z <= 23'b11111111111111111111111;
                    end else begin
                        m_z <= 23'b0;
                    end
                end
                else begin
                    overflow <= 2'b00;
                    state_next <= S_zerocheck;
                end
            end
            S_zerocheck: begin
                // x = 0
                if (m_x[22:0] == 0 && e_x == 8'b0) begin
                    s_z <= s_y;
                    e_z <= e_y;
                    m_z <= m_y;
                    state_next <= S_overflow;
                end
                else if (m_y[22:0] == 0 && e_y == 8'b0) begin
                    s_z <= s_x;
                    e_z <= e_x;
                    m_z <= m_x;
                    state_next <= S_overflow;
                end
                else begin
                    state_next <= S_align;
                end

                // 0 附近 非规格化浮点特判
                // if (m_x[22:0] != 23'd0 && e_x == 8'b0) 

                m_x_ext <= {m_x, 3'd0};
                m_y_ext <= {m_y, 3'd0};           
            end
            S_align: begin
                // 对阶
                //$display("align !" );
                if (e_x == e_y) begin
                   e_z <= e_x;
                    m_x_ext <= {m_x[23:0], 3'b0};
                    m_y_ext <= {m_y[23:0], 3'b0};
                end else if (e_x < e_y) begin
                    e_z <= e_y;
                    m_x_ext <= {m_x >> (e_y - e_x), 3'b0};
                    m_y_ext <= {m_y[23:0], 3'b0};
                end else begin// (e_x > e_y)
                    //$display("e_x > e_y");
                    e_z <= e_x;
                    m_x_ext <= {m_x[23:0], 3'b0};
                    m_y_ext <= {m_y >> (e_x - e_y), 3'b0};
                end
                
                state_next <= S_add;
            end
            S_add: begin
                //$display("m_x_ext = %b m_y_ext = %b", m_x_ext, m_y_ext);
                if (s_x == s_y) begin
                    m_z_ext <= m_x_ext + m_y_ext;

                    s_z <= s_x;
                    state_next <= S_normal;
                end else begin
                    if (m_x_ext < m_y_ext) begin
                        m_z_ext <= m_y_ext - m_x_ext;
                        s_z <= s_y;
                        state_next <= S_normal;
                    end else if (m_x_ext > m_y_ext) begin // m_x > m_y
                        m_z_ext <= m_x_ext - m_y_ext;
                        s_z <= s_x;
                        state_next <= S_normal;
                    end else begin
                        // m_x == m_y => 0
                        m_z <= 25'd0;
                        e_z <= 8'd0;
                        state_next <= S_overflow;
                    end
                end
            end
            S_normal: begin
                //$display("normal m_z_ext = %b", m_z_ext);
                if (m_z_ext[27] == 1'b1) begin
                    // 有进位
                    if (e_z == 8'd254) begin
                        // 上溢 inf 
                        //$display("carry ! inf");
                        s_z <= s_x;
                        e_z <= 8'd255;
                        m_z <= 0; 
                        overflow <= 2'b01;
                        state_next <= S_overflow;
                    end else begin
                        //$display("carry ! e_z = %d e_z+1 = %d", e_z, e_z + 8'b1);
                        m_z <= {1'b0, m_z_ext[26:4]};
                        e_z <= e_z + 8'b1;
                        state_next <= S_overflow;
                    end
                end else
                begin
                    if (m_z_ext[26] == 1'b0 && e_z >= 1) begin
                        // 需要左移
                        //$display("need shift %d", 26 - shift_bit);
                        m_z <= (m_z_ext << (6'd26 - shift_bit)) >> 3;
                        e_z <= e_z + shift_bit - 6'd26;
                        state_next <= S_overflow;
                    end
                    else begin
                        m_z <= m_z_ext[27:3];
                        state_next <= S_overflow;
                    end
                end
            end
            S_overflow: begin
                z = {s_z, e_z[7:0], m_z[22:0]};
                //$display("s=%b e=%b m=%b", s_z, e_z, m_z[22:0]);
                overflow <= overflow;
                state_next <= S_IDLE;
            end

            S_IDLE: begin
                state_next <= S_IDLE;
            end

            default: begin
                state_next <= S_IDLE;
            end

        endcase
    end

endmodule


module FHB32(
    input [31:0] x,
    output reg [5:0] high_bit
);
    reg ok;
    integer i;
    always @(x) begin
        ok = 0;
        for (i = 31; i >= 0; i = i - 1) begin
            if (x[i] == 1'b1 && ok == 0) begin
                high_bit = i;
                ok = 1;
            end
        end
    end
endmodule

// Copyright 2024-2025 Fe-Ti
//~ `include "./mux.v"
`include "./alu.v"

module RV32I_register_file(
    input wire sys_clk, sys_reset,
    input wire [31:0] indata,
    input wire [4:0] rd, rs1, rs2,
    input wire we, // we for dest reg
    output wire [31:0] outdata_rs1, outdata_rs2
    );
    reg [31:0] x[31:0];
    wire [31:0] xzero;
    assign xzero = 0;
    always @(posedge sys_clk or posedge sys_reset) begin // 4750
        if (sys_reset)
            for (integer i = 1; i < 32; i = i + 1) begin
                x[i] <= 0;
            end
        else if (we)
            x[rd] <= indata;
    end
    //~ always @(posedge sys_clk or posedge sys_reset) begin // 3147
        //~ if (sys_reset)
            //~ for (integer i = 1; i < 32; i = i + 1) begin
                //~ x[i] = 0;
            //~ end
        //~ else if (sys_clk)
            //~ x[rd & {5{we}}] = indata;
    //~ end
    mux rs1_mux (
            .indata ({
                    xzero,
                    x[1], x[2],
                    x[3], x[4],
                    x[5], x[6],
                    x[7], x[8],
                    x[9], x[10],
                    x[11], x[12],
                    x[13], x[14],
                    x[15], x[16],
                    x[17], x[18],
                    x[19], x[20],
                    x[21], x[22],
                    x[23], x[24],
                    x[25], x[26],
                    x[27], x[28],
                    x[29], x[30],
                    x[31]
                    }),
            .select (rs1),
            .outdata (outdata_rs1)
        );
    mux rs2_mux (
            .indata ({
                    xzero,
                    x[1], x[2],
                    x[3], x[4],
                    x[5], x[6],
                    x[7], x[8],
                    x[9], x[10],
                    x[11], x[12],
                    x[13], x[14],
                    x[15], x[16],
                    x[17], x[18],
                    x[19], x[20],
                    x[21], x[22],
                    x[23], x[24],
                    x[25], x[26],
                    x[27], x[28],
                    x[29], x[30],
                    x[31]
                    }),
            .select (rs2),
            .outdata (outdata_rs2)
        );
    //~ always @(posedge sys_clk) begin // 8k+
        //~ if (we)
            //~ x[rd] <= indata;
    //~ end
    //~ assign outdata_rs1 = (rs1 != 0) ? x[rs1] : 0;
    //~ assign outdata_rs2 = (rs2 != 0) ? x[rs2] : 0;
endmodule

//// other regfile implementations
    //~ always @(posedge sys_clk or posedge sys_reset) begin // 4809
        //~ if (sys_reset)
            //~ for (integer i = 1; i < 32; i = i + 1) begin
                //~ x[i] = 0;
            //~ end
        //~ else if (sys_clk && we)
            //~ x[rd] = indata;
    //~ end
    //~ always @(posedge write or posedge sys_reset) begin // 4750 cells/// idk
        //~ if (sys_reset)
            //~ for (integer i = 1; i < 32; i = i + 1) begin
                //~ x[i] = 0;
            //~ end
        //~ else if (write)
            //~ x[rd] = indata;
    //~ end
    
    //~ always @(posedge sys_clk or posedge sys_reset) begin // ubcomment to get +59 cells and -100 readability :)
        //~ if (sys_reset) begin
            //~ x[1] = 0;
            //~ x[2] = 0;
            //~ x[3] = 0;
            //~ x[4] = 0;
            //~ x[5] = 0;
            //~ x[6] = 0;
            //~ x[7] = 0;
            //~ x[8] = 0;
            //~ x[9] = 0;
            //~ x[10] = 0;
            //~ x[11] = 0;
            //~ x[12] = 0;
            //~ x[13] = 0;
            //~ x[14] = 0;
            //~ x[15] = 0;
            //~ x[16] = 0;
            //~ x[17] = 0;
            //~ x[18] = 0;
            //~ x[19] = 0;
            //~ x[20] = 0;
            //~ x[21] = 0;
            //~ x[22] = 0;
            //~ x[23] = 0;
            //~ x[24] = 0;
            //~ x[25] = 0;
            //~ x[26] = 0;
            //~ x[27] = 0;
            //~ x[28] = 0;
            //~ x[29] = 0;
            //~ x[30] = 0;
            //~ x[31] = 0;
            //~ end
        //~ else if (sys_clk && we)
            //~ x[rd] = indata;
    //~ end
    
    
    //~ reg [31:0] x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31;
    //~ always @(posedge sys_clk or posedge sys_reset) begin // ubcomment to get +59 cells and -100 readability :)
        //~ if (sys_reset) begin
            //~ x1 <= 0;
            //~ x2 <= 0;
            //~ x3 <= 0;
            //~ x4 <= 0;
            //~ x5 <= 0;
            //~ x6 <= 0;
            //~ x7 <= 0;
            //~ x8 <= 0;
            //~ x9 <= 0;
            //~ x10 <= 0;
            //~ x11 <= 0;
            //~ x12 <= 0;
            //~ x13 <= 0;
            //~ x14 <= 0;
            //~ x15 <= 0;
            //~ x16 <= 0;
            //~ x17 <= 0;
            //~ x18 <= 0;
            //~ x19 <= 0;
            //~ x20 <= 0;
            //~ x21 <= 0;
            //~ x22 <= 0;
            //~ x23 <= 0;
            //~ x24 <= 0;
            //~ x25 <= 0;
            //~ x26 <= 0;
            //~ x27 <= 0;
            //~ x28 <= 0;
            //~ x29 <= 0;
            //~ x30 <= 0;
            //~ x31 <= 0;
            //~ end
        //~ else if (sys_clk) begin
            //~ if(rd == 1)
                //~ x1 = indata;
            //~ if(rd == 2)
                //~ x2 = indata;
            //~ if(rd == 3)
                //~ x3 = indata;
            //~ if(rd == 4)
                //~ x4 = indata;
            //~ if(rd == 5)
                //~ x5 = indata;
            //~ if(rd == 6)
                //~ x6 = indata;
            //~ if(rd == 7)
                //~ x7 = indata;
            //~ if(rd == 8)
                //~ x8 = indata;
            //~ if(rd == 9)
                //~ x9 = indata;
            //~ if(rd == 10)
                //~ x10 = indata;
            //~ if(rd == 11)
                //~ x11 = indata;
            //~ if(rd == 12)
                //~ x12 = indata;
            //~ if(rd == 13)
                //~ x13 = indata;
            //~ if(rd == 14)
                //~ x14 = indata;
            //~ if(rd == 15)
                //~ x15 = indata;
            //~ if(rd == 16)
                //~ x16 = indata;
            //~ if(rd == 17)
                //~ x17 = indata;
            //~ if(rd == 18)
                //~ x18 = indata;
            //~ if(rd == 19)
                //~ x19 = indata;
            //~ if(rd == 20)
                //~ x20 = indata;
            //~ if(rd == 21)
                //~ x21 = indata;
            //~ if(rd == 22)
                //~ x22 = indata;
            //~ if(rd == 23)
                //~ x23 = indata;
            //~ if(rd == 24)
                //~ x24 = indata;
            //~ if(rd == 25)
                //~ x25 = indata;
            //~ if(rd == 26)
                //~ x26 = indata;
            //~ if(rd == 27)
                //~ x27 = indata;
            //~ if(rd == 28)
                //~ x28 = indata;
            //~ if(rd == 29)
                //~ x29 = indata;
            //~ if(rd == 30)
                //~ x30 = indata;
            //~ if(rd == 31)
                //~ x31 = indata;
        //~ end
    //~ end
    //~ mux rs1_mux (
            //~ .indata ({
                    //~ xzero,
                    //~ x1, x2,
                    //~ x3, x4,
                    //~ x5, x6,
                    //~ x7, x8,
                    //~ x9, x10,
                    //~ x11, x12,
                    //~ x13, x14,
                    //~ x15, x16,
                    //~ x17, x18,
                    //~ x19, x20,
                    //~ x21, x22,
                    //~ x23, x24,
                    //~ x25, x26,
                    //~ x27, x28,
                    //~ x29, x30,
                    //~ x31
                    //~ }),
            //~ .select (rs1),
            //~ .outdata (outdata_rs1)
        //~ );
    //~ mux rs2_mux (
            //~ .indata ({
                    //~ xzero,
                    //~ x1, x2,
                    //~ x3, x4,
                    //~ x5, x6,
                    //~ x7, x8,
                    //~ x9, x10,
                    //~ x11, x12,
                    //~ x13, x14,
                    //~ x15, x16,
                    //~ x17, x18,
                    //~ x19, x20,
                    //~ x21, x22,
                    //~ x23, x24,
                    //~ x25, x26,
                    //~ x27, x28,
                    //~ x29, x30,
                    //~ x31
                    //~ }),
            //~ .select (rs2),
            //~ .outdata (outdata_rs2)
        //~ );
//~ endmodule

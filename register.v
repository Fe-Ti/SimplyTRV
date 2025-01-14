// Copyright 2024-2025 Fe-Ti
`include "./mux.v"

module RV32I_register_file(
    input wire sys_clk, sys_reset,
    input wire [31:0] indata,
    input wire [4:0] rd, rs1, rs2,
    input wire we, // we for dest reg
    output wire [31:0] outdata_rs1, outdata_rs2
    );
    reg [31:0] x[31:1];
    wire [31:0] xzero;
    assign xzero = 0;
    always @(posedge sys_clk or posedge sys_reset) begin // 3147
        if (sys_reset)
            for (integer i = 1; i < 32; i = i + 1) begin
                x[i] = 0;
            end
        else if (sys_clk)
            x[rd & {5{we}}] = indata;
    end
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

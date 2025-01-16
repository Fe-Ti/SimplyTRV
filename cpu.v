// Copyright 2024-2025 Fe-Ti
//~ `include "./mux.v"
//~ `include "./alu.v"
`include "./register.v"

module RV32I_decoder_unit ( // get imm-s and decode inst to 'flags'
    input wire [31:0]   instruction,
    input wire [6:0]   aluflags,
    output wire [31:0]  imm12, // sign extended 12 bit imm
                        imm20,  // imm20 << 12
    output wire jumpf, // aka aluarg1sel
                branchf,
                memloadf,
                memstoref,
    output wire [1:0] aluarg2sel,
    output wire [3:0] selectop,
    output wire [4:0] dest_reg, source_reg1, source_reg2,
    output wire dest_reg_we //, mem_we
);
    wire we_rd, typer, typei, types, typeb, typeu, typej;
    wire [6:0]   opcode;
    wire [2:1] func3;
    wire [6:0] func7;
    wire [11:0] imm12, imm12B, imm12S;
    assign opcode = instruction[6:0];
    assign func3 = instruction[14:12];
    assign func3 = instruction[31:25];
    assign source_reg1 = instruction[19:15];
    assign source_reg2 = instruction[24:20];
    assign typeb = opcode
    assign we_rd = ~typeb & ~types;
    assign dest_reg = instruction[11:7] & {5{we}};
    
endmodule

module cpu (
    input wire [31:0] instruction,
    input wire [31:0] from_memory,
    input wire sys_clk, sys_reset,
    output wire [31:0] to_memory, memory_address, progctr
    output wire memstore_flag;
    );
    
    wire branchf, jumpf, memloadf, memstoref, regfile_we;
    wire [1:0] aluarg2sel;
    wire [3:0] selectop;
    wire [4:0] dest_reg, source_reg1, source_reg2;
    wire [6:0] aluflags;
    wire [31:0] memaddr, next_pc, imm12, imm20, aluarg1, aluarg2, aluresult, regfile_indata;
    reg [31:0]  pc; // program ctr

    RV32I_decoder_unit dcu (
    .instruction (instruction),
    .aluflags (aluflags),
    .imm12 (imm12), .imm20 (imm20),
    .jumpf (jumpf), .branchf (branchf),
    .memloadf (memloadf), .memstoref (memstoref),
    .aluarg2sel (aluarg2sel), .selectop (selectop),
    .dest_reg (dest_reg), .source_reg1 (source_reg1), .source_reg2 (source_reg2),
    .dest_reg_we(regfile_we)
    );
    
    assign progctr = pc;
    assign pc_imm_step = branchf ? imm12 : 4;
    assign pc_adder = pc + pc_imm_step;
    assign next_pc = jumpf ? aluresult : pc_adder;
    assign aluarg1 = jumpf ? pc : drs1;
    mux aluarg2mux (
                    .indata ({
                    drs2, imm12, imm20, 32'b0 // TODO: checkout order
                    }),
            .select (aluarg2sel),
            .outdata (aluarg2)
    );
    // for writing into memory
    assign memaddr = aluresult; // TODO: improve
    assign memory_address = memaddr;
    assign to_memory = drs2;
    assign memstore_flag = memstoref;
    // generating input to regfile
    assign memloaded_aluresult = memloadf ? from_memory : aluresult;
    assign regfile_indata = jumpf ? pc_adder : memloaded_aluresult;
    
    ALU32I ALU(
    .a (aluarg1),
    .b (aluarg2),
    .selectop (selectop), // {funct7[5], funct3[2:0]}
    .out (aluresult),
    .neq (aluflags[0]),
    .eq (aluflags[1]), 
    .lt (aluflags[2]), 
    .ge (aluflags[3]),
    .ltu (aluflags[4]),
    .geu (aluflags[5]),
    .zerof (aluflags[6])
    );

    RV32I_register_file regfile(
    .sys_clk (sys_clk),
    .sys_reset (sys_reset),
    .indata (regfile_indata),
    .rd (dest_reg),
    .rs1 (source_reg1),
    .rs2 (source_reg2),
    .we (regfile_we), // we for dest reg
    .outdata_rs1 (drs1),
    .outdata_rs2 (drs2)
    );
endmodule

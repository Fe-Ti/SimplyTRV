// Copyright 2024-2025 Fe-Ti
//~ `include "./mux.v"
`include "./alu.v"
`include "./register.v"
`default_nettype none

module RV32I_decoder_unit ( // get imm-s and decode inst to 'flags'
    input wire [31:0]   instruction,
    input wire [6:0]   aluflags,
    output wire [31:0]  imm,
                    // sign extended 12 bit imm12 or
                    // imm20,  // imm20 << 12
    output wire jumpf,
                branchf,
                memloadf,
                memstoref,
                aluarg1sel,
                aluarg2sel,
    //~ output wire [1:0] aluarg2sel,
    output wire [3:0] selectop,
    output wire [4:0] dest_reg, source_reg1, source_reg2,
    output wire dest_reg_we //, mem_we
);
    wire neq, eq, lt, ge, ltu, geu, zerof, branch_ready;
    assign neq = aluflags[0];
    assign eq = aluflags[1];
    assign lt = aluflags[2];
    assign ge = aluflags[3];
    assign ltu = aluflags[4];
    assign geu = aluflags[5];
    assign zerof = aluflags[6];
    wire we_rd, typeR, typeI, typeS, typeB, typeU, typeJ;
    wire immsign, aluopf;
    wire [2:0] func3;
    reg  [5:0] inst_type;
    wire [6:0] opcode, func7;
    wire [10:0] imm11IS;
    wire [31:0] imm12, imm20, imm12IS, imm12B, imm20U, imm20J;
    
    assign typeR = inst_type[5]; // just for ease of case :)
    assign typeI = inst_type[4];
    assign typeS = inst_type[3];
    assign typeB = inst_type[2];
    assign typeU = inst_type[1];
    assign typeJ = inst_type[0];
    reg rjumpf, rbranchf,
        rmemloadf,
        rmemstoref,
        raluarg1sel,
        raluarg2sel,
        raluopf, nzerordf, nzerors1f; //, nzerors2f;
    assign  dest_reg_we = 1;

    assign opcode = instruction[6:0];   // cut instruction into pieces
    assign func3 = instruction[14:12];
    assign func7 = instruction[31:25];

    always @(opcode[6:2]) begin // all noncompressed instructions end with 11,
        rmemloadf = 0;
        rmemstoref = 0;
        rjumpf = 0;
        rbranchf = 0;
        raluopf = 0;
        nzerordf = 1; nzerors1f = 1; //nzerors2f = 1;
        raluarg1sel = 0; raluarg2sel = 0;
        case(opcode[6:2])      // so for now forget about opcode[1:0]
            5'b01_100   : begin inst_type = 6'b100_000; raluopf = 1;end // R ALU OP
            5'b00_100   : begin inst_type = 6'b010_000; raluopf = 1; raluarg2sel = 1; end // I ALU OP
            5'b11_001   : begin inst_type = 6'b010_000; rjumpf = 1; raluarg2sel = 1; end // I JALR
            5'b00_000   : begin inst_type = 6'b010_000; rmemloadf = 1; raluarg2sel = 1; end // I LOAD
            5'b01_000   : begin inst_type = 6'b001_000; nzerordf = 0; rmemstoref = 1; end // S STORE
            5'b11_000   : begin inst_type = 6'b000_100; nzerordf = 0; rbranchf = 1; end // B
            5'b01_101   : begin inst_type = 6'b000_010; nzerors1f = 0; end // U LUI
            5'b00_101   : begin inst_type = 6'b000_010; raluarg1sel = 1; raluarg2sel = 1; end // U AUIPC
            5'b11_011   : begin inst_type = 6'b000_001; rjumpf = 1; nzerors1f = 0; raluarg2sel = 1; end // J JAL
            default     : begin inst_type = 6'b000_000; end // NOP
        endcase
        $display("rmemloadf=%h; rmemstoref=%h; rjumpf=%h; rbranchf=%h; raluopf=%h; nzerordf=%h; nzerors1f=%h;\n func7[5]=%h, func3[2:0]=%h",
            rmemloadf, rmemstoref, rjumpf, rbranchf, raluopf, nzerordf, nzerors1f,func7[5], func3[2:0]);
    end
    // Todo refactor below:
    assign  jumpf = rjumpf;
    assign  branch_ready = func3[0]^( ((~func3[2]) & eq) | (func3[2] & (((~func3[1]) & lt) | (func3[1] & ltu))) );
    assign  branchf = rbranchf & branch_ready;
    assign  memloadf = rmemloadf;
    assign  memstoref = rmemstoref;
    assign  aluarg1sel = raluarg1sel; // if 1 then pc, else rs1
    assign  aluarg2sel = raluarg2sel; // if 1 then imm, else rs2
    assign  aluopf = raluopf;
    
    assign selectop = {func7[5], func3[2:0]} & {4{aluopf}};
    assign source_reg1  = instruction[19:15] & {32{nzerors1f}};
    assign source_reg2  = instruction[24:20]; // & {32{nzerors2f}};
    assign dest_reg     = instruction[11:7]  & {32{nzerordf}};
    assign immsign = instruction[31];
    assign imm20U = {instruction[31:12], 12'b0};
    assign imm20J = {{12{immsign}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
    assign imm11IS = typeS ? {instruction[30:25], instruction[11:7]} : instruction[30:20];
    assign imm12IS = {{21{immsign}}, imm11IS};
    assign imm12B = {{20{immsign}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    assign imm12 = typeB ? imm12B : imm12IS;
    assign imm20 = typeJ ? imm20J : imm20U;
    assign imm = (typeJ | typeU) ? imm20 : imm12;
endmodule

module cpu (
    input wire [31:0] instruction,
    input wire [31:0] from_memory,
    input wire sys_clk, sys_reset,
    output wire [31:0] to_memory, memory_address, progctr, // next_pc,
    output wire memload_flag, memstore_flag
    );
    wire branchf, jumpf, aluarg1sel, aluarg2sel, memloadf, memstoref, regfile_we;
    //~ wire [1:0] aluarg2sel;
    wire [3:0] selectop;
    wire [4:0] dest_reg, source_reg1, source_reg2;
    wire [6:0] aluflags;
    wire [31:0] memaddr, next_pc, imm, aluarg1, aluarg2, aluresult, regfile_indata;
    wire [31:0] drs1, drs2, pc_imm_step, pc_adder, memloaded_aluresult;
    reg [31:0]  pc; // program ctr

    RV32I_decoder_unit dcu (
    .instruction (instruction),
    .aluflags (aluflags),
    .imm (imm), //.imm20 (imm20),
    .jumpf (jumpf), .branchf (branchf),
    .memloadf (memloadf), .memstoref (memstoref),
    .aluarg1sel (aluarg1sel), .aluarg2sel (aluarg2sel), .selectop (selectop),
    .dest_reg (dest_reg), .source_reg1 (source_reg1), .source_reg2 (source_reg2),
    .dest_reg_we(regfile_we)
    );
    
    assign progctr = pc;
    assign pc_imm_step = branchf ? imm : 32'd4;
    assign pc_adder = pc + pc_imm_step;
    assign next_pc = jumpf ? aluresult : pc_adder;
    always @(posedge sys_clk or posedge sys_reset) begin
        if (sys_reset) begin
            $display("sysr: inst = %h", instruction);
            $display("sysr: currpc = %h, next = %h, branchf = %h, imm = %h, jumpf = %h, aluresult = %h", pc, next_pc, branchf, imm, jumpf, aluresult);
            pc <= 0; end
        else begin
            $display("inst = %h", instruction);
            $display("currpc = %h, next = %h, branchf = %h, imm = %h, jumpf = %h, aluresult = %h, selectop = %h, rs1 = %h, rs2 = %h, rd = %h,\ndrs1=%h, drs2=%h",
            pc, next_pc, branchf, imm, jumpf, aluresult, selectop, source_reg1, source_reg2, dest_reg, drs1, drs2);
            $display("aluarg1 = %h, aluarg2 = %h, argsel1 = %h, argsel2 = %h",aluarg1, aluarg2, aluarg1sel,aluarg2sel);
            pc <= next_pc;end
    end
    assign aluarg1 = aluarg1sel ? pc    : drs1;
    assign aluarg2 = aluarg2sel ? imm   : drs2;

    // reading from/writing into memory
    assign memaddr = aluresult; // TODO: add LB/LH/LW and LBU/LHU
    assign memory_address = memaddr;
    assign to_memory = drs2;
    assign memstore_flag = memstoref;
    assign memload_flag = memloadf;

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

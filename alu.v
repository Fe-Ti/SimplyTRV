`include "./mux.v"

module adder1( // only for testing;
    input wire a,b,cin,
    output wire s, cout
);
    assign s = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin); 
endmodule

module adder32(
    input wire [31:0] a,b,
    input wire cin,
    output wire [31:0] s,
    output wire cout
);
    wire [32:0] p;
    //~ assign p = a + b + cin;
    //~ assign cout = p[32];
    //~ assign s = p[31:0];
    assign {cout,s} = a + b + cin;
endmodule

//~ module flagger32( // postprocessing after adder
    //~ input wire [31:0] a, b, s,
    //~ input wire cin, cout,
    //~ output wire neq, eq, lt, ge,
                //~ zerof, negativef, overf,
                //~ carryf
//~ );
    //~ assign zerof = (s == 0);
    //~ assign eq = (a == b);
    //~ assign neq = ~eq;
    //~ assign lt = ;
    //~ assign ge = ~lt;
    //~ assign negativef = s[31];
    //~ assign overf = ;
    //~ assign carryf = ;
//~ endmodule

//~ module shifter32(
    //~ input wire [31:0] a, b, s,
    //~ input wire cin, cout,
    //~ output wire neq, eq, lt, ge,
                //~ zerof, negativef, overf,
                //~ carryf
//~ );
//~ endmodule

module ALU32I(
    input wire [31:0] a,b,
    input wire [3:0] selectop, // {funct7[5], funct3[2:0]}
    output wire [31:0] out,
    output wire neq, eq, lt, ge,
                zerof, negativef,carryf //, overf, 
);
wire [2:0] muxselect = selectop[2:0]; // funct3[2:0] for mux select
wire cin = selectop[3]; // funct7[5] for diff SRL/SRA, ADD/SUB
wire cout;
wire [31:0] prepb, aandb, aorb, axorb, aplusb;
wire [31:0] sll, slt, sltu, sral;
wire [31:0] srl, sra, signext;

assign prepb = cin ? ~(b) : b;
adder32 adder(.a (a), .b (prepb), .cin (cin),
                .s (aplusb), .cout (cout));

// slt
assign slt[0] = (a[31] & (~b[31])) | ((~(a[31] ^ b[31])) & (a[30:0] < b[30:0])); // aplusb[31]
assign slt[31:1] = 0;
//~ assign slt  = ((a[31] > b[31]) | ((a[30:0] < b[30:0]) && (a[31] == b[31]))) ? 32'b1 : 32'b0;
assign sltu = (a < b) ? 32'b1 : 32'b0;

// shifty stuff
assign sll      = a << b[4:0];
assign srl      = a >> b[4:0];
assign signext  = a[31] ? (~(32'd0) << (32 - b[4:0])) : 0; // signext for 32bits
assign sra      = (a >> b[4:0]) | signext;
assign sral     = cin ? sra : srl;

// bitwise stuff
assign aandb    = a & b;
assign aorb     = a | b;
assign axorb    = a ^ b;

// muxify
mux #(32, 3) outmux ( 
        .indata ({aplusb, sll, slt, sltu, axorb, sral, aorb, aandb}),
        .select (muxselect),
        .outdata (out) );

//~ assign flags
assign neq = |(a ^ b);
assign eq = ~(neq);
assign lt = slt[0];
assign ge = ~lt;
assign zerof = ~|(aplusb);
assign negativef = aplusb[31];
//~ assign overf ;
assign carryf = cout;

endmodule


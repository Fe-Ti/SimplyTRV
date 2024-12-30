//
// (De)coder library
//

module decoder
    #(parameter BINBUSWIDTH = 5)
    (input wire [BINBUSWIDTH-1:0]    inbinbus,
    output reg [2**BINBUSWIDTH-1:0] oneshotbus);
    always @(inbinbus)
    begin
        oneshotbus = 0;
        oneshotbus[inbinbus] = 1;
    end
endmodule

//~ module encoder
    //~ #(parameter BINBUSWIDTH = 5)
    //~ (input wire [2**BINBUSWIDTH-1:0] oneshotbus,
    //~ output reg [BINBUSWIDTH-1:0]    outbinbus,);
    //~ always @(oneshotbus)
    //~ begin

    //~ end
//~ endmodule

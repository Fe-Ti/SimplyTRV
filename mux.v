//
// (De)Multiplexer library
//

module mux #(parameter BUSWIDTH=32, parameter SELWIDTH=5)(
            input wire [BUSWIDTH*(2**SELWIDTH)-1:0] indata,
            input wire [SELWIDTH-1:0] select,
            output reg [BUSWIDTH-1:0] outdata
            );
    always @ (indata or select) begin
        outdata = 0;
        for (integer i = 0; i < 2**SELWIDTH; i = i + 1) begin
            if (select == i) begin
                outdata[BUSWIDTH-1:0] = indata[BUSWIDTH*i +: BUSWIDTH];
            end
        end
    end
endmodule

module demux #(parameter BUSWIDTH=32, parameter SELWIDTH=5)(
            output reg [BUSWIDTH*(2**SELWIDTH)-1:0] outdata,
            input wire [SELWIDTH-1:0] select,
            input wire [BUSWIDTH-1:0] indata
            );
    always @ (indata or select) begin
        outdata = 0;
        for (integer i = 0; i < 2**SELWIDTH; i = i + 1) begin
            if (select == i) begin
                outdata[BUSWIDTH*i +: BUSWIDTH] = indata[BUSWIDTH-1:0];
            end
        end
    end
endmodule


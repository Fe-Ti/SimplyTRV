`include "./mux.v"

module testbench3();
    reg [31:0] result;
    reg [31:0] arr[31:0];
    reg [1000:0] success, fail;
    reg [1:0] cin;
    reg [4:0] sel;
    wire [31:0] y;
    wire cout;
    mux dut ({arr[31],arr[30],arr[29],arr[28],arr[27],arr[26],arr[25],arr[24],arr[23],arr[22],arr[21],arr[20],arr[19],arr[18],arr[17],arr[16],arr[15],arr[14],arr[13],arr[12],arr[11],arr[10],arr[9],arr[8],arr[7],arr[6],arr[5],arr[4],arr[3],arr[2],arr[1],arr[0]}, sel, y);
    //mux dut ({arr[31],arr[30],arr[29],arr[28],arr[27],arr[26],arr[25],arr[24],arr[23],arr[22],arr[21],arr[20],arr[19],arr[18],arr[17],arr[16],arr[15],arr[14],arr[13],arr[12],arr[11],arr[10],arr[9],arr[8],arr[7],arr[6],arr[5],arr[4],arr[3],arr[2],arr[1],arr[0]}, sel, y);
    initial begin
        success = 0;
        fail = 0;
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("i = %d", i);
            arr[i] = i;
        end
        for (integer i = 0; i < 32; i = i + 1) begin
            sel = i; #10;
            result = y;
            $display("sel = %d, result = %d", sel, result);
        end
        $finish;
    end
endmodule

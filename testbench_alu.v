`include "./alu.v"

module testbench3();
    reg [31:0] result;
    reg [31:0] a, b;
    reg [1000:0] success, fail;
    reg [3:0] functs;
    wire [31:0] y;
    wire [6:0] flags;
    reg [31:0] expected_result;
    ALU32I dut (
    .a          (a),
    .b          (b),
    .selectop   (functs), // {funct7[5], funct3[2:0]}
    .out        (y),
    .neq        (flags[0]),
    .eq         (flags[1]),
    .lt         (flags[2]),
    .ge         (flags[3]),
    .lt         (flags[5]),
    .ge         (flags[6]),
    .zerof      (flags[4]),
    //~ .negativef  (flags[5]),
    //~ .carryf     (flags[6]) //, overf, 
    );
    initial begin
        success = 0;
        fail = 0;
        
        //~ for (integer i = 0; i < 10; i = i + 1) begin
            //~ $display("", i);
            //~ for (integer j = 0; j < 33; j = j + 3) begin
                //~ a = i;b = j;
                //~ $display("a = %b, b = %b,", a, b);
            //~ for (integer k = 0; k < 16; k = k + 1) begin
                //~ functs = k;
                //~ #10;
                //~ result = y;
                //~ if (functs[3] == 0 && functs[2:0] == 0)
                //~ expected_result = a + b;
                //~ else if (functs[3] == 1 && functs[2:0] == 0)
                //~ expected_result = a - b;
                //~ else if (functs[2:0] == 1)
                //~ expected_result = a << b;
                //~ else if (functs[2:0] == 2)
                //~ expected_result = (a < b);
                //~ else if (functs[2:0] == 3)
                //~ expected_result = (a < b);
                //~ else if (functs[2:0] == 4)
                //~ expected_result = a ^ b;
                //~ else if (functs[3] == 0 && functs[2:0] == 5)
                //~ expected_result = a >> b;
                //~ else if (functs[3] == 1 && functs[2:0] == 5)
                //~ expected_result = a >> b;
                //~ else if (functs[2:0] == 6)
                //~ expected_result = a | b;
                //~ else if (functs[2:0] == 7)
                //~ expected_result = a & b;
                //~ $display(" funct7[5] =%b, funct3[2:0] = %b, flags = %b, result = %b, exp = %b", functs[3], functs[2:0],flags, result, expected_result);
            //~ end
        //~ end
        //~ end
        
        a = -61; b = 5;
                $display("a = %b, b = %b: aplusb, sll, slt, sltu, axorb, sral, aorb, aandb", a, b);
                    for (integer k = 0; k < 16; k = k + 1) begin
                functs = k;
                #10;
                result = y;
                if (functs[3] == 0 && functs[2:0] == 0)
                expected_result = a + b;
                else if (functs[3] == 1 && functs[2:0] == 0)
                expected_result = a - b;
                else if (functs[2:0] == 1)
                expected_result = a << b;
                else if (functs[2:0] == 2)
                expected_result = (a < b);
                else if (functs[2:0] == 3)
                expected_result = (a < b);
                else if (functs[2:0] == 4)
                expected_result = a ^ b;
                else if (functs[3] == 0 && functs[2:0] == 5)
                expected_result = a >> b;
                else if (functs[3] == 1 && functs[2:0] == 5)
                expected_result = a >> b;
                else if (functs[2:0] == 6)
                expected_result = a | b;
                else if (functs[2:0] == 7)
                expected_result = a & b;
                $display(" funct7[5] =%b, funct3[2:0] = %b, flags = %b, result = %b, exp = %b", functs[3], functs[2:0],flags, result, expected_result);
            end
        $finish;
    end
endmodule

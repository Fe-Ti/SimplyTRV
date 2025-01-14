`include "./register.v"

module testbench3();
    wire [31:0] outdata_rs1, outdata_rs2;
    reg [31:0] indata;
    reg [10:0] success, fail;
    reg [4:0] rd, rs1, rs2;
    reg we;
    reg sys_clk, sys_reset;
    reg [31:0] expected_rs1, expected_rs2;
    
    RV32I_register_file dut (
        sys_clk, sys_reset,
        indata,
        rd, rs1, rs2,
        we, // we for dest reg
        outdata_rs1, outdata_rs2
    );
    initial begin
        success = 0;
        fail = 0;
        sys_reset = 1; #10;
        sys_reset = 0;
        we = 0;
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("%d -x-> x[%d]", i, i);
            //~ $display("%d ---> x[%d]", i, i);
            rd = i[4:0];
            indata = i;
            sys_clk = 1; #10;
            sys_clk = 0; #10;
        end
        we = 1;
        for (integer i = 32; i < 64; i = i + 1) begin
            $display("%d --->  x[%d]", i, i-32);
            //~ $display("%d -x->  x[%d]", i, i-32);
            rd = i[4:0];
            indata = i;
            sys_clk = 1; #10;
            sys_clk = 0; #10;
        end
        we = 0;
        for (integer i = 0; i < 32; i = i + 1) begin
            rs1 = i;
            rs2 = 31-i;
            sys_clk = 1; #10;
            sys_clk = 0; #10;
            expected_rs1 = 32+i;
            expected_rs2 = 32+31-i;
            //~ expected_rs1 = i;
            //~ expected_rs2 = 31-i; 
            if(rs1 == 0)
                expected_rs1 = 0;
            if(rs2 == 0)
                expected_rs2 = 0;
            $display("rs1=%d, rs2=%d, data1=%d, data2=%d", rs1,rs2,outdata_rs1,outdata_rs2);
            if ((outdata_rs1 == expected_rs1) && (outdata_rs2 == expected_rs2)) begin
                success = success + 1;
                //~ $display("rs1=%d, rs2=%d, data1=%d, data2=%d", expected_rs1,outdata_rs1,expected_rs2,outdata_rs2);
            end
            else begin
                $display("Error ers1=%d, drs1=%d, ers2=%d, drs2=%d", expected_rs1,outdata_rs1,expected_rs2,outdata_rs2);
                fail = fail + 1;
            end
        end
        $display("Success = %d, fail = %d", success, fail);
        sys_reset = 1; #10;
        sys_reset = 0;
        for (integer i = 0; i < 32; i = i + 1) begin
            rs1 = i;
            rs2 = 31-i;
            sys_clk = 1; #10;
            sys_clk = 0; #10;
            expected_rs1 = 0;
            expected_rs2 = 0;
            $display("rs1=%d, rs2=%d, data1=%d, data2=%d", rs1,rs2,outdata_rs1,outdata_rs2);
            if ((outdata_rs1 == expected_rs1) && (outdata_rs2 == expected_rs2)) begin
                success = success + 1;
                //~ $display("rs1=%d, rs2=%d, data1=%d, data2=%d", expected_rs1,outdata_rs1,expected_rs2,outdata_rs2);
            end
            else begin
                $display("Error ers1=%d, drs1=%d, ers2=%d, drs2=%d", expected_rs1,outdata_rs1,expected_rs2,outdata_rs2);
                fail = fail + 1;
            end
        end
        $display("Success = %d, fail = %d", success, fail);
        $finish;
    end
endmodule

`include "./alu.v"

module testbench3();
    //~ reg clk, reset;
    //~ reg  a, b, cin;
    reg [32:0] a, b;
    reg [1000:0] success, fail;
    reg [1:0] cin;
    wire [31:0] y;
    wire cout;
    reg [32:0] yexpected, result;
    //~ reg [31:0] vectornum, errors;
    //~ reg [3:0] testvectors[10000:0];
    
    adder32 dut(a[31:0],b[31:0],cin[0],y,cout);
    initial begin
        success = 0;
        fail = 0;
        for (a = 32'd1; a < 4294967295; a = a*10) begin // 4294967295; a = a+1) begin
            $display("a = %d", a);
            for (b = 32'd9; b < 4294967295; b = b*10) begin // 4294967295; b = b+1) begin
                for (cin = 0; cin < 2; cin = cin + 1) begin
                #1;
                result[31:0] = y;
                result[32] = cout;
                yexpected = a+b+cin;
                if (result === yexpected)
                    success = success + 1;//~ $display("Yay, It works! y = %d, cout = %b <= a = %d, b = %d, cout = %b", y, cout, ,a,b,cin);
                else
                    begin
                    fail = fail + 1;
                    $display ("Failure: exp = %d, while result = %d <= a = %d, b = %d, cin = %b",  yexpected, result,a,b,cin);
                    end
                end
            end
        end
        a = 4294967295;
        b = 4294967295;
        cin = 1;
        #1;
        result[31:0] = y;
        result[32] = cout;
        yexpected = a+b+cin;
        if (result === yexpected) begin
            success = success + 1;
            $display("Yay, It works! exp = %d, while result = %d <= a = %d, b = %d, cin = %b",  yexpected, result,a,b,cin);
            end
        else
            begin
            fail = fail + 1;
            $display ("Failure: exp = %d, while result = %d <= a = %d, b = %d, cin = %b",  yexpected, result,a,b,cin);
            end
        $display("Success count: %d \n Error count: %d", success, fail);
        $finish;
    end
endmodule

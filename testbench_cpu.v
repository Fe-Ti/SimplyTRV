`include "./top.v"
`default_nettype none

module testbench3();
    //~ reg [];
    parameter c_ROWS = 8;
    parameter c_COLS = 4;
    parameter CLK_cnt = 10; //20;
    //~ reg [31:0] program[0:c_ROWS-1];
    reg [7:0] program[c_ROWS-1:0][c_COLS-1:0];
    reg [31:0]  memory_address, memory_read_data, memory_write_data;

    reg [31:0] pc, instruction, from_memory; //, memory_address, to_memory, program_ctr;

    wire [31:0] memaddr, memdata, progctr;
    
    reg [10:0] success, fail;
    
    reg sys_reset, dataoutbit,  clk_data,  data_sync_en, clk_sys, clk_board;
    wire datainbit, memstoref, memloadf;

    cpu dut (
        .instruction (instruction),
        .from_memory (from_memory),
        .sys_clk (clk_sys),
        .sys_reset (sys_reset),
        .to_memory (memdata),
        .memory_address (memaddr),
        .progctr (progctr),
        .memload_flag(memloadf),
        .memstore_flag(memstoref)
    );

    initial begin
        success = 0;
        fail = 0;
        $readmemh("program_testtop.bin", program);
        $display("Program:");
        for (integer i = 0; i < c_ROWS; i = i + 1) begin
            for (integer k = 0; k < c_COLS; k = k + 1)
                $write("%h ", program[i][c_COLS - k - 1]);
            //~ for (integer k = 0; k < c_COLS; k = k + 1)
                //~ $write("%d ", c_COLS - k - 1);
            $display();
        end

        clk_sys = 0;
        sys_reset = 1; #10;
        sys_reset = 0;
        #10;
        $display("Its execution (%d tics) by CPU:",CLK_cnt);
        for (integer i = 0; i < CLK_cnt; i = i + 1) begin
            pc = progctr;
            $display("\nPC = %h", pc);
            // fetch program_memory[PC] and send to top module
            instruction = {program[pc[31:2]][3],program[pc[31:2]][2],program[pc[31:2]][1],program[pc[31:2]][0]}; #10;
            $display("INST = %h", instruction);
            // get memaddr
            memory_address = memaddr; #10;
            $display("Mem addr = %h, mem load/store = %b/%b", memory_address, memloadf, memstoref);
            // load data from... let's say get constant from head
            memory_read_data = 32'hEAD;
            $display("Data to load from mem: %h", memory_read_data);
            // transfer memory data r|w
            from_memory = memory_read_data; #10;
            memory_write_data = memdata; #10;
            //if (memstoref) // Just output this thing
            $display("Data to store in mem: %h", memory_write_data);
            
            // sclk: now we can advance cpu clock :)
            clk_sys = 1; #10; clk_sys = 0; #10;
            $display("Cycle %d complete.", i);
        end
        $display("Success = %d, fail = %d", success, fail);
        $finish;
    end
endmodule

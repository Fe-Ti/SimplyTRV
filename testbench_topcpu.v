`include "./top.v"

module testbench3();
    //~ reg [];
    parameter c_ROWS = 8;
    parameter c_COLS = 4;
    parameter CLK_cnt = 10; //20;
    //~ reg [31:0] program[0:c_ROWS-1];
    reg [7:0] program[c_ROWS-1:0][c_COLS-1:0];
    reg [31:0]  instruction, pc, memory_address, memory_read_data, memory_write_data,
                data_in, data_out, unused;

    reg [10:0] success, fail;
    reg sys_reset, dataoutbit,  clk_data,  data_sync_en, clk_sys, clk_board;
    wire datainbit, memstoref, memloadf;

    top cpu_wrapper_dut (
    .datainbit(dataoutbit),  .clk_data(clk_data),   .data_sync_en(data_sync_en),
    .clk_sys(clk_sys),       .sys_reset(sys_reset), .clk_board(clk_board),
    .dataoutbit(datainbit),  .memstoref(memstoref), .memloadf(memloadf));
    
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
        
        pc = 0;
        instruction = 0;
        memory_address = 0;
        memory_read_data = 0;
        memory_write_data = 0;
        dataoutbit = 0;
        data_sync_en = 0; clk_data = 0; clk_board = 0; #10;
        clk_board = 1; #10; clk_board = 0;#10;
        #10;
        sys_reset = 1; #10;
        sys_reset = 0; #10;
        $display("Its execution (%d tics) by CPU:",CLK_cnt);
        for (integer i = 0; i < CLK_cnt; i = i + 1) begin
            // sync
            clk_board = 1; #10; clk_board = 0;#10;
            data_sync_en = 1; clk_data = 1; #10; clk_data = 0; clk_board = 1; #10; clk_board = 0; #10; data_sync_en = 0; #10;
            // get PC
            for (integer c = 0; c < 32; c=c+1) begin
                pc[c] = datainbit; //$write("databit=%b",datainbit);
                clk_data = 1; #10; clk_data = 0;  #10;
            end
            $display("\nPC = %h", pc);
            // fetch program_memory[PC] and send to top module
            instruction = {program[pc[31:2]][3],program[pc[31:2]][2],program[pc[31:2]][1],program[pc[31:2]][0]};
            $display("INST = %h", instruction);
            for (integer c = 0; c < 32; c=c+1) begin
                dataoutbit = instruction[c];
                clk_data = 1; #10; clk_data = 0;  #10;
            end
            
            // sync: inst --> cpu visible inst
            clk_board = 1; #10; clk_board = 0; #10;
            data_sync_en = 1; clk_data = 1; #10; clk_data = 0; clk_board = 1; #10; clk_board = 0; #10; data_sync_en = 0; #10;
            // sync: cpu memaddr|data valid --> top module regs
            clk_board = 1; #10; clk_board = 0;
            data_sync_en = 1; clk_data = 1; #10; clk_data = 0; clk_board = 1; #10; clk_board = 0; #10; data_sync_en = 0; #10;
            
            // get memaddr
            for (integer c = 0; c < 32; c=c+1) begin
                memory_address[c] = datainbit;
                clk_data = 1; #10; clk_data = 0;  #10;
            end
            
            $display("Mem addr = %h, mem load/store = %b/%b", memory_address, memloadf, memstoref);
            if (memloadf) // load data from... let's say get constant from head
                memory_read_data = 32'hEAD;
            $display("Data to load from mem: %h", memory_read_data);
            // transfer memory data r|w
            for (integer c = 0; c < 32; c=c+1) begin
                dataoutbit = memory_read_data[c];
                memory_write_data[c] = datainbit;
                clk_data = 1; #10; clk_data = 0;  #10;
            end
            if (memstoref) // Just output this thing
                $display("Data to store in mem: %h", memory_write_data);
            
            // sync: top memdata valid --> cpu module regs
            clk_board = 1; #10; clk_board = 0;
            data_sync_en = 1; clk_data = 1; #10; clk_data = 0; #10; clk_board = 1; #10; clk_board = 0; #10; data_sync_en = 0; #10;
            clk_board = 1; #10; clk_board = 0;
            // sclk: now we can advance cpu clock :)
            clk_sys = 1; #10; clk_sys = 0; #10;clk_board = 1; #10; clk_board = 0;
            $display("Cycle %d complete.", i);
        end
        $display("Success = %d, fail = %d", success, fail);
        $finish;
    end
endmodule

// Copyright 2024-2025 Fe-Ti
`include "./cpu.v"
`default_nettype none

module top (    // Repka-Tang ports                 // onboard ports
    input wire  datainbit,  clk_data,  data_sync_en,
                clk_sys,    sys_reset,              clk_board,
    output wire dataoutbit, memstoref, memloadf
);
    reg [31:0] input_regs[4:0];
    reg [31:0] output_regs[4:0]; 
    reg [31:0] instruction, from_memory; //, memory_address, to_memory, program_ctr;
    reg [31:0] data_out, data_in;
    wire [31:0] memaddr, memdata, progctr, muxed_out;
    
    reg [1:0] state;
    reg [4:0] counter;
    //wire memloadf, memstoref;

    assign dataoutbit = data_out[0];

    always @(posedge clk_data or posedge sys_reset) begin
        if (sys_reset) begin
            data_in <= 0;
            data_out <= 0;
            input_regs[0] <= 0;
            input_regs[1] <= 0;
            input_regs[2] <= 0;
            input_regs[3] <= 0;
        end
        else if (data_sync_en) begin 
            input_regs[state] <= data_in;
            data_in <= 0;
            data_out <= output_regs[state];
            $display("state = %d, data_out = %d", state, data_out);
        end
        else begin
            $display("state = %d, data_in = %d: dataloading", state, data_in);
                data_in <= (data_in << 1) ^ {31'b0, datainbit};
                data_out <= data_out >> 1;
        end
    end

    always @(posedge clk_board or posedge sys_reset) begin // refreshing registers from cpu module
        if (sys_reset) begin
            output_regs[0] <= 0; // program_ctr <= progctr;
            output_regs[2] <= 0; // memory_address <= memaddr;
            output_regs[3] <= 0; // to_memory <= memdata;
            instruction <= 0;
            from_memory <= 0;
            $display("rst: inst = %h", instruction);
        end
        output_regs[0] <= progctr; // program_ctr <= progctr;
        output_regs[2] <= memaddr; // memory_address <= memaddr;
        output_regs[3] <= memdata; // to_memory <= memdata;
        instruction <= input_regs[1];
        from_memory <= input_regs[3];
        
        $display("inst = %h", instruction);
    end

    // finite state machine (automaton) selects right registers at right time
    always @(posedge clk_data or posedge sys_reset) begin
        if (sys_reset) begin
            state <= 0;
            counter <= 0;
        end
        else if(~data_sync_en) begin
            $display("state = %d, ctr = %d", state, counter);
            counter <= counter + 1;
            if (&(counter))
                state <= state + 1;
        end
    end

    cpu rv32i_cpu (
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
endmodule

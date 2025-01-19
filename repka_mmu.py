# Copytright 2025 Fe-Ti
# A script for Repka Pi 4 Optimal to become simple MMU for custom cpu core

# From CST file:
# ~ IO_LOC "datainbit" 38;
# ~ IO_PORT "datainbit" IO_TYPE=LVCMOS33 PULL_MODE=UP;
# ~ IO_LOC "clk_data" 37;
# ~ IO_PORT "clk_data" IO_TYPE=LVCMOS33 PULL_MODE=UP;
# ~ IO_LOC "data_sync_en" 36;
# ~ IO_PORT "data_sync_en" IO_TYPE=LVCMOS33 PULL_MODE=UP;
# ~ IO_LOC "clk_sys" 39;
# ~ IO_PORT "clk_sys" IO_TYPE=LVCMOS33 PULL_MODE=UP;
# ~ IO_LOC "sys_reset" 25;
# ~ IO_PORT "sys_reset" IO_TYPE=LVCMOS33 PULL_MODE=UP;
# ~ IO_LOC "dataoutbit" 26;
# ~ IO_PORT "dataoutbit" IO_TYPE=LVCMOS33 PULL_MODE=UP DRIVE=8;
# ~ IO_LOC "memstoref" 27;
# ~ IO_PORT "memstoref" IO_TYPE=LVCMOS33 PULL_MODE=UP DRIVE=8;
# ~ IO_LOC "memloadf" 28;
# ~ IO_PORT "memloadf" IO_TYPE=LVCMOS33 PULL_MODE=UP DRIVE=8;
#
# Repka to Tang Nano 9k pin mapping:
# +--------+------+---------------+
# |  RPi4o | Tang |  Function     |
# +--------+------+---------------+
# |  26 o  | 38 i |  datainbit    |
# |  24 o  | 37 i |  clk_data     |
# |  22 o  | 36 i |  data_sync_en |
# |  40 o  | 39 i |  clk_sys      |
# |  23 o  | 25 i |  sys_reset    |
# |  21 i  | 26 o |  dataoutbit   |
# |  19 i  | 27 o |  memstoref    |
# |  18 i  | 28 o |  memloadf     |
# +--------+------+---------------+

import sys
import readline
from time import sleep

import OPi.GPIO as GPIO
import repka.repka4o

# Setup GPIO
GPIO.setmode(repka.repka4o.BOARD)

# inputs
PIN_DATAOUTBIT  = 21 # It's out for TangNano side
PIN_MEMSTOREF   = 19
PIN_MEMLOADF    = 18
INPUT_PINS = [
    PIN_DATAOUTBIT,
    PIN_MEMSTOREF,
    PIN_MEMLOADF
    ]
GPIO.setup(INPUT_PINS, GPIO.IN)

# outputs
PIN_DATAINBIT   = 26 # Actually output, but for Tang it's input
PIN_CLK_DATA    = 24
PIN_DATA_SYNC_EN= 22
PIN_CLK_SYS     = 40
PIN_SYS_RESET   = 23
OUTPUT_PINS = [
    PIN_DATAINBIT,
    PIN_CLK_DATA,
    PIN_DATA_SYNC_EN,
    PIN_CLK_SYS,
    PIN_SYS_RESET
    ]
GPIO.setup(OUTPUT_PINS, GPIO.OUT)

WELCOME_TXT = "Welcome to interactive SimplyTRV console!\nInput `help` to get help."
HELP_TXT = f"""SimplyTRV stands for Simply Tim's RISC-V. This script is
an interactive shell for controlling CPU core in FPGA using Repka Pi 4 GPIO.

Usage:
python[3] repka_mmu.py PROGRAM_FILE

Where PROGRAM_FILE is a set of verilog vectors produced by gcc-as for RV.
Example contents:
@00000000
B7 24 00 00 93 84 44 00 93 02 60 00 03 A3 C4 FF
23 A4 64 00 33 E2 62 00 E3 0A 42 FE

Currently program and memory are different things. May be changed in future.

Interactive shell commands:
exit        - exit
help        - print this message
prtprog     - print program file
tic         - run 1 tic
prtmem addr - print memory at address
run ntics   - run <ntics> tics

Editing and runtime history should be supported. Try pressing arrows.
"""
BUS_W = 32 # cpu (data) bus in bits
BUS_W_IN_BYTES = BUS_W // 8
BUS_W_IN_HEX   = BUS_W // 4

if len(sys.argv) < 2:
    print("No program file provided.\nShould be verilog vectors. Type --help to get help.")
    exit(1)
if len(sys.argv) > 2:
    print("Err... Too much args, I want only 2. Check your command.")
    exit(1)

memory = dict()
program = dict()

# Read program from file
address = 0
with open(sys.argv[1]) as ifile:
    for line in ifile:
        for lex in line.split():
            if lex.startswith('@'):
                address = int(lex[1:], 16)
            else:
                program[address//BUS_W_IN_BYTES*BUS_W_IN_BYTES +
                        (BUS_W_IN_BYTES-1-address%BUS_W_IN_BYTES)] = int(lex,16)
                address += 1

# Print program to console
def print_prog(program):
    for i in range(len(program)//(BUS_W_IN_BYTES)):
        print(f"{hex(i*4)[2:].zfill(BUS_W_IN_HEX)}:", end=' ')
        for j in range(BUS_W_IN_BYTES):
            print(f"{hex(program[i*BUS_W_IN_BYTES+j])[2:].zfill(2)}", end=' ')
        print()

class CPU:
    pc = 0
    real_pc = 0
    instruction = 0
    memaddr = 0
    cycle_counter = 0

    def __init__(self, prog, mem):
        self.program = prog
        self.memory = mem

    def wait(self,t=0.001):
        sleep(t)

    def setpin(self, pin):
        # ~ print(f"GPIO.output({pin}, 1)")
        GPIO.output(pin, 1)
        self.wait()

    def resetpin(self, pin):
        # ~ print(f"GPIO.output({pin}, 0)")
        GPIO.output(pin, 0)
        self.wait()

    def getpinval(self, pin):
        return GPIO.input(pin)
        # ~ return 0 #GPIO.input(pin)

    def pulse_clk(self,pin):
        self.resetpin(pin) # If somebody has forgotten to reset pin(s)
        self.setpin(pin)
        self.resetpin(pin)

    def pulse_clk_sync(self):
        self.setpin(PIN_DATA_SYNC_EN)
        self.pulse_clk(PIN_CLK_DATA)
        self.resetpin(PIN_DATA_SYNC_EN)

    def pulse_clk_data(self):
        self.resetpin(PIN_DATA_SYNC_EN)
        self.pulse_clk(PIN_CLK_DATA)
        # ~ self.resetpin(PIN_DATA_SYNC_EN)
    def pulse_clk_sys(self):
        self.pulse_clk(PIN_CLK_SYS)

    def reset(self):
        self.pc = 0
        self.real_pc = 0
        self.instruction = 0
        self.memaddr = 0
        self.cycle_counter = 0
        # reset cpu
        self.resetpin(OUTPUT_PINS)
        # ~ self.resetpin(PIN_CLK_DATA)
        # ~ self.resetpin(PIN_CLK_SYS)
        # ~ self.resetpin(PIN_DATAINBIT)
        # ~ self.resetpin(PIN_DATA_SYNC_EN)
        self.setpin(PIN_SYS_RESET)
        self.resetpin(PIN_SYS_RESET)

    def transfer_data(self, data_o):
        data_i = ''
        message = bin(data_o)[2:].zfill(BUS_W)
        print(f"Transfering data: {message}")
        for bit in message:
            if bit == '1':
                self.setpin(PIN_DATAINBIT)
            else:
                self.resetpin(PIN_DATAINBIT)
            data_i = str(int(self.getpinval(PIN_DATAOUTBIT))) + data_i
            self.pulse_clk_data()
        print(f"Recieved data: {data_i}")
        return int(data_i,2)

    def tic(self):
        # sync
        self.pulse_clk_sync()
        # get PC
        pc = int(self.transfer_data(0))
        print(f"\nPC = {hex(pc)}")
        
        # fetch program_memory[PC] and send to top module
        # ~ instruction = {program[pc[31:2]][3],program[pc[31:2]][2],program[pc[31:2]][1],program[pc[31:2]][0]};
        instruction_str = ""
        for j in range(BUS_W_IN_BYTES):
            # ~ print(f"{hex(program[i*BUS_W_IN_BYTES+j])[2:].zfill(2)}", end=' ')
            instruction_str += bin(program[pc*BUS_W_IN_BYTES+j])[2:].zfill(8)
        instruction = int(instruction_str,2)
        print(f"INST = {hex(instruction)}")
        self.transfer_data(instruction)
        
        # sync: inst --> cpu visible inst
        self.pulse_clk_sync()
        # sync: cpu memaddr|data valid --> top module regs
        self.pulse_clk_sync()
        
        # get memaddr
        memaddr = int(self.transfer_data(0))
        memloadf = self.getpinval(PIN_MEMLOADF)
        memstoref = self.getpinval(PIN_MEMSTOREF)
        print(f"Mem addr = {hex(memaddr)}, mem load/store = {memloadf}/{memstoref}")

        if memaddr not in self.memory:  # due to design of top.v we need to transfer
            self.memory[memaddr] = 0    # mem i|o data anyway, so fill empty with zeros
        # ~ memory_read_data = bin(self.memory[memaddr])[2:].zfill(BUS_W)
        memory_read_data = self.memory[memaddr]
        
        if memloadf == 1: # but if not needed we just ignore this stuff
            print(f"Data to load from mem: {hex(memory_read_data)}")
        
        # transfer memory data r|w
        memory_write_data = int(self.transfer_data(memory_read_data))
        
        if memstoref == 1: # output mem data thing... actually it's drs2 bus
            print(f"Data to store in mem: {hex(memory_write_data)}")
            self.memory[memaddr] = memory_write_data
        
        # sync: top memdata valid --> cpu module regs
        self.pulse_clk_sync()
        # sclk: now we can advance cpu clock :)
        self.pulse_clk_sys()
        
        print(f"Cycle #{self.cycle_counter} complete.")
        self.cycle_counter += 1

#print_prog(program)


command_help = "help"
command_exit = "exit"
command_tic = "tic"
command_run = "run"
command_prtmem = "prtmem"
command_prtprog = "prtprog"
command_reset = "reset"
commands = [command_exit, command_help, command_run, command_tic, command_prtmem, command_prtprog, command_reset]

user_input = ""
cpu = CPU(program, memory)
print(WELCOME_TXT)
while user_input != command_exit:
    user_input = input(">> ")
    splitted_input = user_input.split()
    if not splitted_input:
        continue
    elif splitted_input[0] == command_help:
        print(HELP_TXT)
    elif splitted_input[0] == command_exit:
        print('Bye!')
        GPIO.cleanup()
        exit(0)
    elif splitted_input[0] == command_prtprog:
        print("Here is your program:")
        print_prog(program)
    elif splitted_input[0] == command_tic:
        cpu.tic()
    elif splitted_input[0] == command_reset:
        cpu.reset()
    elif splitted_input[0] == command_prtmem:
        if len(splitted_input) < 2:
            print("Address is not specified. Try help.")
            continue
        try:
            if splitted_input[1].startswith('0x'):
                memaddr = int(splitted_input[1],16)
            else:
                memaddr = int(splitted_input[1])
            if memaddr in memory:
                print(f"At 0x{hex(memaddr)[2:].zfill(4)} there is 0x{hex(memory[memaddr])[2:].zfill(4)}")
            else:
                print(f"At 0x{hex(memaddr)[2:].zfill(4)} there is UNDEFINED value.")
        except:
            print("Bad address specified. Check spelling.")
            continue
    elif splitted_input[0] == command_run:
        if len(splitted_input) < 2:
            print("Tics count is not specified. Try help.")
            continue
        try:
            for i in range(int(splitted_input[1])):
                cpu.tic()
        except:
            print("Bad tics value specified. Check spelling.")
            continue
    else:
        print("Unrecognized commmand. Check ur spelling!")

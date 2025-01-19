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

# ~ import OPi.GPIO as GPIO
# ~ import repka.repka4o

# ~ # Setup GPIO
# ~ GPIO.setmode(repka.repka4o.BOARD)

# ~ # input
# ~ PIN_DATAOUTBIT  = 21
# ~ PIN_MEMSTOREF   = 19
# ~ PIN_MEMLOADF    = 18
# ~ INPUT_PINS = [
    # ~ PIN_DATAOUTBIT,
    # ~ PIN_MEMSTOREF,
    # ~ PIN_MEMLOADF
    # ~ ]
# ~ GPIO.setup(INPUT_PINS, GPIO.IN)

# ~ # output
# ~ PIN_DATAINBIT   = 26
# ~ PIN_CLK_DATA    = 24
# ~ PIN_DATA_SYNC_EN= 22
# ~ PIN_CLK_SYS     = 40
# ~ PIN_SYS_RESET   = 23
# ~ OUTPUT_PINS = [
    # ~ PIN_DATAINBIT,
    # ~ PIN_CLK_DATA,
    # ~ PIN_DATA_SYNC_EN,
    # ~ PIN_CLK_SYS,
    # ~ PIN_SYS_RESET
    # ~ ]
# ~ GPIO.setup(OUTPUT_PINS, GPIO.OUT)

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
                program[address//4*4 + (3-address%4)] = int(lex,16)
                address += 1

# Print program to console
def print_prog(program):
    for i in range(len(program)//4):
        print(f"{hex(i*4)[2:].zfill(8)}:", end=' ')
        for j in range(4):
            print(f"{hex(program[i*4+j])[2:].zfill(2)}", end=' ')
        print()

class CPU_image:
    pc = 0
    real_pc = 0
    instruction = 0
    memaddr = 0
    memdata_in = 0
    memdata_out = 0
    def __init__(self, prog, mem):
        self.program = prog
        self.memory = mem

    def tic(self):
        print("t-t-t-tic")
#print_prog(program)


command_help = "help"
command_exit = "exit"
command_tic = "tic"
command_run = "run"
command_prtmem = "prtmem"
command_prtprog = "prtprog"
commands = [command_exit, command_help, command_run, command_tic, command_prtmem, command_prtprog]

user_input = ""
cpu = CPU_image(program, memory)
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
        exit(0)
    elif splitted_input[0] == command_prtprog:
        print("Here is your program:")
        print_prog(program)
    elif splitted_input[0] == command_tic:
        cpu.tic()
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

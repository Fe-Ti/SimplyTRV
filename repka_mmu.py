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

import OPi.GPIO as GPIO
import repka.repka4o

# Setup GPIO
GPIO.setmode(repka.repka4o.BOARD)

# input
PIN_DATAOUTBIT  = 21
PIN_MEMSTOREF   = 19
PIN_MEMLOADF    = 18
INPUT_PINS = [
    PIN_DATAOUTBIT,
    PIN_MEMSTOREF,
    PIN_MEMLOADF
    ]
GPIO.setup(INPUT_PINS, GPIO.IN)

# output
PIN_DATAINBIT   = 26
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


if len(sys.argv) < 2:
    print("No program file provided.\nShould be verilog vectors as in.")
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
for i in range(7):
    print(f"{hex(i)[2:].zfill(8)}:", end=' ')
    for j in range(4):
        print(f"{hex(program[i*4+j])[2:].zfill(2)}", end=' ')
    print()



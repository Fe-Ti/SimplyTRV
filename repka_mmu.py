# Copytright 2025 Fe-Ti
# Repka Pi 4 Optimal as super simple MMU for custom cpu core

import sys

# ~ import OPi.GPIO as GPIO
# ~ import repka.repka4o

if len(sys.argv) < 2:
    print("No program file provided.\nShould be verilog vectors as in.")
    exit(1)
if len(sys.argv) > 2:
    print("Err... Too much args, I want only 2. Check your command.")
    exit(1)

memory = dict()
program = dict()

address = 0
with open(sys.argv[1]) as ifile:
    for line in ifile:
        for lex in line.split():
            if lex.startswith('@'):
                address = int(lex[1:], 16)
            else:
                program[address//4*4 + (3-address%4)] = int(lex,16)
                address += 1

for i in range(7):
    print(f"{hex(i)[2:].zfill(8)}:", end=' ') 
    for j in range(4):
        print(f"{hex(program[i*4+j])[2:].zfill(2)}", end=' ')
    print()


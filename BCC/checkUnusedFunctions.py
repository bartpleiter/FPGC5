#!/usr/bin/env python3

# tool to list all unused functions using the asm output of bcc

import sys

filename = "../Assembler/code.asm"

asm = []

with open(filename, "r") as f:
    asm = f.readlines()

asm = [x.strip() for x in asm]

functionNames = []

jumps = []

for x in asm:
    if len(x) > 0:
        if (x.split()[0][-1] == ':'):
            if ("Label_" not in x.split()[0]):
                functionNames.append(x[:-1])
        if (x.split()[0] == "addr2reg"):
            if ("Label_" not in x.split()[1]):
                jumps.append(x.split()[1])

        if (x.split()[0] == "jump"):
            if ("Label_" not in x.split()[1]):
                jumps.append(x.split()[1])

#for f in functionNames:
#    print(f)

#for j in jumps:
#    print(j)

unusedFunctions = list((set(functionNames).difference(jumps)).difference(["Main", "Int1", "Int2", "Int3", "Int4"]))
unusedFunctions.sort()

for u in unusedFunctions:
    print(u)
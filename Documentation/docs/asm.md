# Assembler for B322
The basic way to write code for the B322 is by using the B322 assembly language. Using the assembly language you can write the most optimal code, although it might not be the best way for big or complex programs. For high performance functions like copying VRAM tables, assembly is a good solution. For big and complex software, it is better to write the code in C. The C compiler compiles to this assembly language.

The assembler compiles the assembly code to 32 bit machine instructions. The input file is currently code.asm, and the output is printed to stdout.

## Line types
Each line is parsed on its own. There are five types of lines:

- Includes
- Comments
- Defines
- Labels
- Instructions

### Includes
By adding an \`include namehere.asm statement, it is possible to add code from other files, like libraries. The way this works in the assembler is by just adding all lines of that file to the code, while recursively importing includes from other files. The assembler makes sure that the same file is never included more than one time. The path to the file is relative to the assembler.

### Comments
Comments can be added by using the ';' character. For each line, only the part until the first ';' occurrence will be used by the assembler. This means that anything can be written after the ';'. This all does not go for .ds lines. They must not have any comments. This way it is not needed to use escape characters in the strings

### Defines
Defines are the first type of lines that are processed by the assembler. A define line should have the following structure:
``` asm
define TEXTTOREPLACE = textToReplaceWith
```
It is not necessary for 'define' to be in lower caps and 'TEXTTOREPLACE' to be in all caps. However, it is recommended to do so as a coding style. Also, it is recommended to place all define statements at the top of the file before the first instruction or label.
The define statement is used as a textual replacement. This means that no values or anything will be processed or converted during the processing of the define statements. This also means that is not smart to replace text that are used in instructions or labels.
Furthermore, 'TEXTTOREPLACE' should be unique for each define statement. If not, the assembler will complain.

### Labels
Labels can be used to get the address in the assembled code of the instruction below the label. To define a label, one should use the following syntax:
``` asm
LabelName:
```
LabelName can consist of any character, including numbers and special characters, as long as it is just one word (so no spaces, newlines etc.) The label must end with a ':' character. On the same line after this ':' character, no other text is allowed, except comments.

A label can be referenced by using the LabelName in certain instructions at specific places (see section Instructions).
The assembler will eventually compute the address of the label and replace all LabelName occurrences with this address. One can make forward and backward references, which means that one does not have to define a label earlier in the code before referencing, as long as the label is defined somewhere in the code.

Each program should at least contain the following labels (if not, the assembler will complain):
``` asm
Main: ; this is where the CPU will initially jump to
Int1: ; interrupt 1 handler
Int2: ; interrupt 2 handler
Int3: ; interrupt 3 handler
Int4: ; interrupt 4 handler
```

It is recommended to start each label with a capital letter, however this is not mandatory.
One should not use two labels directly after each other without any instruction in between (the compiler will now insert a NOP in between the labels if this happens, since the C compiler sometimes creates this issue), and one should not use a label at the end of the file. The assembler will complain if the latter happens.
When two identical labels are defined, the assembler will complain.
It does not matter if a label is never referenced.
However, it does matter when a reference is made to a label that is not defined. In that case the assembler will complain.
Each of the interrupt handler labels should 'end' with a reti instruction, otherwise the CPU will not return from the interrupt and could highly probably softlock. However, this is not checked by the assembler.

### Instructions
The instructions are the lines that will be assembled into machine code. Each instruction has its own format with the following description:
``` text
Instr   | Arg1  | Arg2 | Arg3   || Description
================================||=====================================================================
HALT    |       |       |       || Halts CPU by jumping to the current address
READ    | C16   | R     | R     || Read from addr in Arg2 with 16 bit offset*** from Arg1. Write to Arg3
WRITE   | C16   | R     | R     || Write to addr in Arg2 with 16 bit offset*** from Arg1. Data to write is in Arg3
COPY    | C16   | R     | R     || Copy from address in Arg2 to addr in Arg3 with 16 bit offset*** from Arg1
PUSH    | R     |       |       || Push Arg1 to stack
POP     | R     |       |       || Pop from stack to Arg1
JUMP    | L/C27 |       |       || Jump to Label or 27 bit constant in Arg1
JUMPO   | C27   |       |       || Jump to 27 bit constant offset in Arg1
JUMPR   | C16   | R     |       || Jump to Arg2 with 16 bit offset in Arg1
JUMPRO  | C16   | R     |       || Jump to offset in Arg2 with 16 bit offset in Arg1
LOAD    | C16   | R     |       || Load 16 bit constant from Arg1 into Arg2
LOADHI  | C16   | R     |       || Load 16 bit constant from Arg1 into highest 16 bits of Arg2
BEQ     | R     | R     | C16   || If Arg1 == Arg2, jump to 16 bit offset in Arg3
BNE     | R     | R     | C16   || If Arg1 != Arg2, jump to 16 bit offset in Arg3
BGT     | R     | R     | C16   || If Arg1 >  Arg2, jump to 16 bit offset in Arg3
BGE     | R     | R     | C16   || If Arg1 >= Arg2, jump to 16 bit offset in Arg3
SAVPC   | R     |       |       || Save program counter to Arg1
RETI    |       |       |       || Return from interrupt
OR      | R     | C11/R | R     || Compute Arg1 OR  Arg2, write result to Arg3
AND     | R     | C11/R | R     || Compute Arg1 AND Arg2, write result to Arg3
XOR     | R     | C11/R | R     || Compute Arg1 XOR Arg2, write result to Arg3
ADD     | R     | C11/R | R     || Compute Arg1 +   Arg2, write result to Arg3
SUB     | R     | C11/R | R     || Compute Arg1 -   Arg2, write result to Arg3
SHIFTL  | R     | C11/R | R     || Compute Arg1 <<  Arg2, write result to Arg3
SHIFTR  | R     | C11/R | R     || Compute Arg1 >>  Arg2, write result to Arg3
MULT    | R     | C11/R | R     || Compute Arg1 *   Arg2, write result to Arg3
NOT     | C11/R | R     |       || Compute NOT Arg1, write result to Arg2
NOP     |       |       |       || Does nothing, is converted to the instruction OR r0 r0 r0
ADDR2REG| L     | R     |       || Loads address from Arg1 to Arg2. Is converted into LOAD and LOADHI
READINTID| R    |       |       || Reads the interrupt ID from memory to Arg1 by setting the I flag in a READ instruction
.DW     | N32   | *     | *     || Data: Each argument is converted to 32bit binary
.DD     | N16   | *     | *     || Data: Each argument is converted to 16bit binary **
.DB     | N8    | *     | *     || Data: Each argument is converted to 8bit binary **
.DS     | N8    | S     |       || Data: Each character of the string is converted to 8bit ASCII **

/   = Or
R   = Register
Cx  = Constant that fits within x bits
L   = Label
S   = String

*  Optional argument with same type as Arg1. Has 'no limit' on number of arguments
** Data is placed after each other to make blocks of 32 bits. If a block cannot be made, it will be padded by zeros
*** Offset can be negative as well. This is useful for the C compiler
```

Each Cx type argument (constant) can be written in decimal, binary (with 0b prefix) or hex (with 0x prefix).

The assembler creates the first six lines of the program, since these are always the same instructions plus the length of the program:
``` text
Jump Main
Jump Int1
Jump Int2
Jump Int3
Jump Int4
[Length of program]
```

## Assembling process
The assembler does the following things the the following order:

1. Remove all comments, while reading the input file line by line
2. Process the define statements
3. Compile all lines that can directly be compiled (so without labels)
4. Create new lines for instructions that become multiple lines
5. Process all labels
6. Recompile the lines that had a label before
8. calculate and write program length
7. Write result to output file

### Input and output files
Currently one cannot pass arguments to the assembler. The assembler will read the code from code.asm and write the result to stdout. I might add file handling in the future.

## Important notes
One important assumption is that the code will be executed from addr 0 of the SDRAM. Otherwise the label addresses will not be calculated correctly. In the future I might add an offset argument where all labels are offsetted by this argument, and a flag to disable the required Interrupt handlers, though these features have no use right now and therefore no priority.

## Other things
I could create my own syntax highlighting for Sublime Text 3, however its Z80 syntax highlighting is already kinda decent. Might modify it in the future to support my assembly instead.

# C Compiler

!!! info "TODO"
	Update this page!

Using the C compiler it is possible to compile C code to B322 assembly. Using C it is way easier to write code for the FPGC4, although it is less optimized and currently not perfectly stable.

## How the C Compiler works
A C compiler is a very complex piece of software. To prevent having to spend a very long time on writing an instable, slow and unfinished C compiler, I modified an existing C compiler instead. I found a very good and well documented C compiler written in Python (the easiest programming language), called [ShivyC](https://github.com/ShivamSarodia/ShivyC). ShivyC outputs x86_64 assembly code. It has the following stages:

- lexer: reads C file, creates tokens
- preprocessor: handles include statements
- parser: parses tokens and creates an abstract syntax tree
- ILgen: generates Intermediate Language code from the AST
- ASMgen: generates x86_64 code from the IL

To make the compiler output B322 assembly, I (mostly) only needed to adjust the last stage. Luckily, the x86_64 assembly and B322 assembly have much in common in terms of registers and instructions (relatively), so no major modifications to the other stages, which were made with x86_64 in mind, were needed. Some assembly wrapping code is used to set up things like the stack, interrupt handlers and return code.

## Biggest differences between x86_64 and B322 assembly
There are a few big differences between these languages:

### Register sizes
B322 has 16 (15 if you ignore r0 which is always 0) 32 bit registers. x86_64 has multiple variants of its registers for 8, 16, 32 and 64 bit values. I 'fixed' this by forcing the C compiler to only use the 32 bit versions of the registers.

### Byte addressable memory
B322 uses word addressable memory, meaning that each address is 32 bits. x86_64 uses byte addressable memory, so I had to modify the compiler to use 1 address per integer (32 bits) instead of 4.

### Memory access in each instruction
B322 has READ, WRITE and COPY instruction to access memory. All other instructions can only be applied to registers (and in some cases literals). x86_64 can use literals, registers and memory (with offsets and multiplications!!!) for almost all instructions. This is by far the biggest problem I currently have and requires writing cases for almost all possibilities. I started doing this kind of ad hoc and need to spend more time on this to improve stability.

## Stack
C uses a stack. Since the hardware stack of the FPGC4 is too small, has no external pointers and is not addressable, a software stack is used instead. The stack starts at the end of SDRAM at 0x700000 and grows towards 0. The interrupt handlers have a separate (and smaller) stack, starting at 0x7B0000. R14 and R15 are used as base pointer and stack pointer respectively.

Since x86_64 has byte addressable memory, integers (32 bit) are stored with an offset of 4 of each other. The FPGC4 does not have byte addressable memory. This means that chars are stored in 32 bit spaces and therefore have no overflow. This also means that using variables longer that 32 bits (longs) are cutoff at 32 bits. Should not be a big issue, since we only have 27 bits addresses anyways. Worst case, this means that 75% of the stack is unused. While this sounds like a lot, it is currently not a problem because of the relatively huge memory size of 32MiB. Will probably fix it in the future.

## Register mapping
The registers are mapped in the following way:

``` text
x86_64 	| FPGC4
----------------
rax		| r1
rbx 	| r2
rcx 	| r3
rdx 	| r4
rsi 	| r5
rdi 	| r6
r8 		| r8
r9  	| r9
r10 	| r10
r11 	| r11
rbp 	| r14
rsp 	| r15
```
This leaves registers r7, r12 and r13 unused in the FPGC4.
r12 and r13 are currently used as temporary registers for certain assembly instructions, which is sometimes needed/convenient for converting single x86_64 instructions to multiple B322 instructions. For example, in x86_64 you can write a number to the stack at an offset using `mov [rbp-offset] 37`. In B322 you first need to load the literal into a register before using a write instruction. r7 is currently used as temp register for loading the address of global variables during for read/write instructions.


## Assembly wrapper
- Return value of Main() is sent over UART (mainly for testing)
- Initializes stack starting address
- Full context switch for interrupt handlers

## Testing the compiler
To make sure that everything still works after making a change in the compiler, I made a number of test .c files with an expected return value. Using the runCfiles.sh script, you can send compile and send multiple .c files to the FPGC4 and get their return value. So to automatically test all test files, you just have to run `runCfiles.sh test/*.c`. The script automatically compiles, assembles and sends the code over UART to the FPGC4 (so use the UART bootloader for the SPI flash module). When the program is done executing, the FPGC4 will send back the return value, which you can compare. The FPGC4 also resets between each file, because of the UART DTR reset (just like an Arduino).

## Supported and unsupported features
Most basic features like for/while loops are supported, so I will not list everything.

### Supported
- defines (only numbers, no expressions or strings)
- includes (.h files should also contain the code, because no linking). Circular dependencies are allowed. Defines from includes carry over, like real C
- inline assembly (see section inline assembly)
- structs (not fully tested)
- arrays
- pointers
- hex and binary numbers (using 0x and 0b prefixes), also in defines
- bitwise operators (shift, xor, etc.) (bitwise and uses `&&&` as sign!)
- probably some things that I don't use, see ShivyC on Github.

### Unsupported
- floating points
- negative numbers! (the FPGC4 does not do any signed operations)
- division and modulo (use div() and mod() in the math library for this)
- include guards, since this is handled internally inside the compiler (for includes)
- compiling and linking multiple .c files. So libraries should be written entirely in a single .h file
- certain array initializers (like `char a[] = "foo";`)
- complex things like varargs, which I never used anyways
- probably some other things :s

## Interrupt handler
Because of the way interrupts are handled in the assembler, it is required for each main .c file to have the functions (void) int1() int2() int3() and int4(). These can be empty, since the context switch (using the hardware stack) and `reti` are handled by the wrapper.

## Inline assembly
The C compiler supports inline B332 assembly. See the following code for an example:

``` c
int main() 
{
	int a = 7; // should be put into r1 by the compiler

	// backslashes are needed for the lexer, semicolons are needed to keep track of each line
	// comments can be added before the semicolon using //
	ASM("\
		load 4 r2								;\
		add r1 r2 r3 	//adding two regs		;\
		sub r3 1 r1 	//remove one to get 10 	;\
		");

	return a; // should now be 10
}
```
Inline assembly is especially useful for implementing fast functions like copying VRAM tables. It might also be useful for addressing I/O, though this will depend on the situation, since you cannot easily access values from the C code using assembly.

!!! danger
    The compiler does not parse the assembly code, so be very very careful to not mess up the registers. Use `pop` and `push` to back them up!





## Coding style recommendation
Since there is currently no OS, memory (heap) management needs to be done by the programmer. So write at top of program/library which variables are stored at which address. Also, see the Main Memory Map below.

- Some variables can be defined as global variables, which the compiler puts in the Program code (recommended way if possible)
- Libraries have their own heap, and each library should use different addresses within this space
- Use clear function names, and defines with prefixes if necessary, to avoid conflicts
- Use integers for pointers, as they are 32 bit
- Use mostly integers, since these are the same size as a register
- Program code is not different from any other place in memory, and therefore can be easily modified at runtime

### Main Memory Map
This memory map visualizes where what is (or should) be stored where in memory:

``` text
|00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|
|_______________________________________________________________________________________________|
|-----------------Program Code------------------|Usr Heap|L*|---------Stack---------|Int S*|-R*-|
					 16MiB						   3MiB  1MiB          8MiB         2.75MiB 1.25MiB

L* 		= Library heap, like a map with the currently pressed ps/2 buttons
Int S* 	= Interrupt stack, a separate stack for interrupt handlers
R* 		= Currently unused, reserved for future things

```

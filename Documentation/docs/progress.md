# Progress
Here I keep a list of my latest progress and a TODO list

## Big Progress log (truncated to latest progress, last entry at the bottom of the list)
- Reimplemented SPI module. Now uses 6.25MHz SPI clock (verified stable for CH376)
- Added a way to access SPI flash using a SPI(3) module. Can switch between SPIreader and SPI3 using a memory address
- Restructured Ccompiler changes to be less ad hoc and more streamlined (for working with and between memspots, regspots and literalspots)
- Designed and ordered V2 of the I/O Board PCB (4 layer)
- Created SPI flash programmer, removing the need for an external one
- Assembled new PCB
- New memory map, restructured the way SPI works (CS and Int), most libraries are updated now
- Started on OS (BDOS)
- Terminal GFX driver, FS driver, PS2 driver, USB keyboard driver, HID fifo driver done, started on shell
- More commands working for shell, new fast division algorithm
- USB bootloader (RUN command) and network bootloader implemented
- SPI speeds for flash and W5500 are now 25MHz

## TODO since new PCB
Things I need/want to fix/do since PCB v2 (has duplicates with Future plans)

- Implement true GPIO (Stabilize GPIO when module)
- Stabilize PS/2 input
- Add all signals to gtkwave for simulation
- Make pictures for documentation

## Future plans
These are kinda ordered based on priority

- Add option to compiler/assembler to compile for OS
- Write demo code in C, for OS
- Implement true GPIO
- Stabilize PS/2 input
- Stabilize GPIO when module
- Add all signals to gtkwave for simulation
- Improve C compiler
- Move ROM to MU
- Clean up and improve tools/scripts (arguments/functionality)
- Clean up unused files in PCB folders
- Change all static paths in the project to relative ones
- Improve ESP32Synth (for non-live settings, maybe midi buffer to reduce timers)
- Or, start designing Verilog Synth
- Improve sprite renderer design, since it uses (space/logic-wise) half of the entire design
- Create a pattern and palette table generator
- Write a platformer game
- Change speed of FT232RL to 1Mboud
- UART buffer mode in hardware
- Add Gameboy printer via Arduino to I/O

## Ideas
Random ideas that came up at some point. Some might be stupid tho.

- Create very very basic floating point unit, though it might be difficult to implement it into the C compiler
- Optimize timings in many Verilog files, since it has been quite some time
- Also, 'fix' as many warnings as possible
- Contstrain divided clocks?
- Write verilog tests for single modules

## Todo documentation
- BDOS page
	- memory map
	- all functions/libraries
- table of interrupt ids and how to obtain them
- gallery page
- installation/setup page
- build it yourself page
- really, I should add more pictures and examples (of video output, simulation, hardware)
- add DSUB9 pinout
- add (probably in specs section) the FPGA usage statistics
	- note that the sprite renderer takes almost half of the FPGA, because many big registers
- talk about memory bottleneck, Instructions per clock cycle
- add design mistakes for io wing (uart pulldown, no shield to ground)
- add uart bootloader code/description to bootloader section
- think about removing bootloader code in documentation
- add some snippet of code + binary in assembler documentation
- check if uart bootloader jumpt to addr 5 or addr 0 when done
- add something about the nconf button remapping wire on the PCB page
- add something about the automatic dtr reset
- add new functions to assembler page
	- rbp rsp mapped to r14 r15 for c compiler
	- added negative offset option for read, write and copy instruction
- add picture of SPI flasher, and add/improve instructions on how to use them (seperate page + commands + hardware mod of spi module)
- add something about WSL2
- note that r7 is used as temp reg to store address of label in read/write instructions
- only global int and int[x] are allowed, no char, since size allocation goes wrong
- register/assembly info for c compiler
- add schematic of pcb
- add info about w5500 hardware and software
- note about how to get the USB flash drive to properly formatted: Minitool Partition Wizard, reinitialize MBR, add Fat32 value with cluster? size of 2KB


## Todo C compiler related
- [done] Add neg offset flag in READ and WRITE and COPY instructions
- [done] Implement neg offset for READ and WRITE and COPY instructions
- [done] Map the name rbp and rsp to r14 and r15 in assembler
- [done] add int1-4 functions, with automatic backup and restore of ALL registers to HW stack
- [done] add prefix main (as header) with load 0x700000 rsp
- [done] in asm main prefix header, get return value from label_main and send it over UART
- [done] add more instructions and test files
- [done] add inline assembly for fast code like copying tables
- [done] add static defines
- [done] add hex support!!! (and binary while at it) (also in defines)
- [done] add bitwise | ^ and & operators (look at commit 31180511de0f95cf5dbda0bf98df71901a2fd1ed)
- [done] print static string in correct asm format (.dw without commas)
- [done] Fix empty label problem in ASSEMBLER! by adding a nop when detected
- [done] Rewrite and streamline il_cmds
- Fix global array indexing using variables in global variables
- Improve global array definition (eg: when no value is set)
- Fix commenting out asm code
- Remove requirement to add intX() functions
- Add wrapper for extended interrupts
- Improve performance of certain libraries by using assembly
- Add timer 1 interrupt code to assembly wrapper
- Change or r0 const rx to load const rx
- Maybe add some hotfix for number not fitting in register by using temp reg
- eventually clean up code, remove size arg

## Future hardware/pcb improvements
- Stop using hard to solder 32bit video dacs, and go back to a simple but 75ohm terminated 8 bit resistor dac (Which will fix yellow-ish white as well, use op-amps or buffers)
- Make sure logo is not covered up by W5500 module
- Pull-down? on dtr
- Find out what draws so much current
- New audio solution (TODO: requirements and goals)

## Future improvements (FPGC5?)
- Do not use any negedge statements. Do everything on posedge, because everyone says that is the way to go when using FPGAs
- Separate set of registers for interrupts, or an instruction that backs up/swaps given registers (bit per register)
- Better bus protocol between CPU and MU, with no cycles overhead
- Byte addressable memory
- Maybe DMA controller (probably not tho, unless useful for future OS)
- Maybe some way to use 3D rendering with a frame buffer, though it is already complicated to make use of 2D rendering.
- Optimize SPI to SDRAM by using one (two including size) big sequential read

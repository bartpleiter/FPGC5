# C Libraries
While working on the C compiler, I started writing some C libraries. Some libraries like the GFX library uses a lot of Assembly code to optimize performance.

!!! info "TODO"
	Extend and update this page

## CH376.h
This library is used to communicate with the CH376 chip. Currently it only contains functions for file system functions (see midiSynth.c for USB MIDI functions).
It can read and write large chunks of data and uses the interrupt signal (without using actual interrupts on the FPGC4) to read return values from the chip.
Most functions have a return value (1 on success and 0 on failure). Please note that you should use filenames that follow the 8.3 DOS standard (ALL CAPS!).

## GFX.h
Currently a direct copy from the ASM version of this library, while only adding two functions to convert X and Y positions to a memory offset for the background and window plane. Will be expanded when working on a program that acutally uses the GPU a lot (like a game).

## MATH.h
Contains functions for (currently only) modulo and division. A better algorithm should be used for big numbers, since it now just substracts only.

## STDLIB.h
Contains many useful functions, like converting integers to strings in decimal and hex (using some fancy recursion), uprint functions (print over UART), delay function (using timer1) and memcpy function. For better performance, I could write some of these function in ASM instead.
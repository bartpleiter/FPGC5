# Welcome to the FPGC4 Wiki!

[![FPGC4 Logo](images/logo_big_alpha.png)](https://www.github.com/b4rt-dev/FPGC4)

![photo](images/front.jpg)

On this page, you will find a brief introduction of this project. For (many) more details, use the navigation in the left menu.

## What it is
The FPGC4 (Field Programmable Game Console v4) is my big hobby project, built around a completely self designed SoC (System on a Chip) with my own CPU, GPU and Memory Unit, all implemented on an FPGA. The goal of this project is to understand how computers actually work. This is achieved by starting from scratch and adding a layer of complexity iteratively. Currently I am at the point of writing a simple OS for it in C.

Originally, the goal of this project, which started in 2017 when I bought my first FPGA, was to design a simple game console for an FPGA (hence the name FPGC). Eventually this idea shifted more towards creating an entire computer with the capabilities of a game console. 

To give you a general idea: The FPGC4 is kind of a Raspberry Pi, but with the performance of a Commodore 64, the graphics of a NES, and some "less retro" features like USB host, Ethernet, 32MiB SDRAM and a 32 bit architecture.

Most features of the FPGC4 are very retro, like tile and sprite based rendering, RGBs video signals for CRT TVs (using RGB SCART, though the signal also goes over the VGA port), PS/2 Keyboard and SNES controller support. However, some more modern features were also added, like a 32 bit architecture, 32MiB SDRAM, USB host support (through a CH376T controller) and Ethernet (using a W5500).

The main components of the FPGC4 are a self designed 32 bit CPU, a self designed GPU (tile/sprite based), and a self designed Memory Unit, handling many different types of memory and I/O. Now there is also an external APU, using an ESP32 with I2S DAC as software synthesizer, connected over UART. Since I have not implemented a proper sound synthesizer in Verilog yet, using a my ESP32Synth project as APU is a fine alternative.

Aside from the hardware, this project also contains other software projects built for the FPGC4, like an assembler, C compiler, Operating System, software libraries, programmer, software synthesizer for APU, MIDI converter and example code.

For this project I also designed an I/O board PCB.

## What it can do
Basically, the FPGC4 can run code, compute things, play games, output video, output audio, and can interact with certain peripherals using for example GPIO, SPI or UART. It also has two USB host port for mass storage and something else, a PS/2 port for a keyboard, a SNES controller port for a SNES controller and a Ethernet port for networking. It has 32MiB SDRAM and the program code is loaded from SPI flash or USB UART into SDRAM on boot. The board is powered from a single mini USB port, with UART capabilities for in-system programming.

As for performance, you should think of a computer from the 80's, but with 32MiB SDRAM, multiple gigabytes of mass storage using USB, and a 32 bit CPU (running at 25MHz). The GPU generates an RGBs video signal (for CRT TVs) and has a resolution of 320x200. Its performance is comparable to a NES (with more sprites). VGA can also be used, though it depends on your monitor if can actually handle a 240p 15KHz (horizontally) VGA signal correctly.

## Project hardware and software
The target FPGA is an Altera Cyclone IV EP4CE15. The development board used in this project is the [Cyclone IV EP4CE15 Core Board with 32MiB SDRAM from QMtech](https://www.aliexpress.com/i/32949281189.html). This board is plugged into a self designed expansion PCB, which provides all I/O and power.

All hardware designs are written in Verilog. Iverilog and GTKwave are used to simulate these hardware designs before writing the design to the FPGA using Quartus Prime (Lite).

The Assembler, C compiler and most other scripts are written in Python 3. The assembler assembles a self designed assembly language, and the C compiler compiles C to this assembly language.

Sublime Text 3 is used as text editor/IDE, with some handy build scripts to speed up the development and to quickly send code to the FPGC4.

## Structure of project files
The general structure of this project:
``` text
FPGC4
├── Assembler 			// Assembler and assembly code files
│   ├── bootloaders 	// Asm files of bootloaders
│   └── lib 			// Asm libraries
│
├── Ccompiler 			// C compiler project
│   ├── lib 		 	// C libraries
│   └── tests 			// Test .c files for compiler
│ 
├── Documentation 		// Documentation website project
├── ESP32Synth	 		// Arduino code for APU (ESP32)
├── Graphics 			// Scripts for converting/generating graphics data
├── MidiConverter 		// Scripts to convert .mid files into audio asm code
├── PCB 				// PCB KiCad source files
├── Programmer 			// Scripts for programming the FPGC4
│   ├── flash.sh 		// Programs the SPI flash module
│   └── uartFlasher.py  // Programs the FPGC4 via UART (ISP)
│
├── Quartus 			// Quartus project files
├── SublimeText3 		// Project build scripts for Sublime Text 3
└── Verilog 			// Verilog source files
    ├── memory 			// Memory init related files
    ├── modules 		// Hardware modules
    ├── output 			// Simulation output
    └── testbench 		// Simulation testbench
```

## Project Links
- [Github Repository](https://www.github.com/b4rt-dev/FPGC4)
- [Gogs Mirror](https://www.b4rt.nl/git/bart/FPGC4-mirror)
- [Documentation (this site)](https://www.b4rt.nl/fpgc4)
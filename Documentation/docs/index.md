# Welcome to the FPGC Wiki!

[![FPGC Logo](images/logo_big_alpha.png)](https://www.github.com/b4rt-dev/fpgc5)


!!! danger
    A lot of the documentation is outdated, since I definitely do not have the motivation to update this consistently. It is already a wonder how much I have written (basically for myself, nobody will read this anyways).

On this page, you will find a brief introduction of this project. For (many) more details, use the navigation in the left menu.

## What it is
The FPGC5 (Field Programmable Game Console/Computer v5) is my big hobby project, built around a completely self designed SoC (System on a Chip) with my own CPU, GPU and Memory Unit, all implemented on an FPGA. The goal of this project is to understand how computers actually work, by making one myself. This is achieved by starting from scratch and adding a layer of complexity iteratively. Currently I am at the point of writing a simple OS for it in C.

Originally, the goal of this project, which started in 2017 when I bought my first FPGA, was to design a simple game console for an FPGA (hence the name FPGC). Eventually this idea shifted more towards creating an entire computer with the capabilities of a game console. Now this is shifting even more to a computer rather than game console (the third PCB doesn't even have a game controller connector anymore).

To give you a general idea: The FPGC5 is kind of a Raspberry Pi, but with the performance of a Commodore 64, the graphics of a NES, and some "less retro" features like HDMI, USB host, Ethernet, 32MiB SDRAM and a 32 bit architecture.

The main components of the FPGC5 are a self designed 32 bit CPU (B322), tile/sprite based GPU (FSX3), Memory Unit (MU) that handles many different types of memory and I/O. I used to have an external APU, using an ESP32 with I2S DAC as software synthesizer, connected over UART. Since I have not implemented a proper sound synthesizer in Verilog yet, using a my ESP32Synth project as APU is a fine alternative, especially since it allows me to combine the two projects. On the PCB v3 I removed the ESP32 and added an I2S dac instead, since I want to move towards making my own synthesizer.

Aside from the FPGA hardware, this project also contains other software projects built for the FPGC, like an assembler, C compiler (modified version from ShivyC), Operating System, software libraries, programmer, software synthesizer for the APU, MIDI converter, example code and more.

For this project I also designed an I/O board PCB (currently at v3).

## What it can do
Basically, the FPGC5 can run code, compute things, play games, output video (over NTSC or HDMI), output audio, and can interact with certain peripherals using for example GPIO, SPI or UART. It also has two USB host port for mass storage and something else, a PS/2 port for a keyboard and a Ethernet port for networking. It has 32MiB SDRAM and the program code is loaded from SPI flash or USB UART into SDRAM on boot. The board is powered from a single mini USB port, with UART capabilities for in-system programming.

As for performance, you should think of a computer from the 80's, but with 32MiB SDRAM, multiple gigabytes of mass storage using USB, and a (not so efficient) 32 bit CPU running at 50MHz. The GPU creates a 320x200 video output which is currently sent over a 640x480 HDMI signal and a composite NTSC signal for my CRT TV (output can be selected using a dip switch). The graphics are comparable to a NES (currently sprites need to be reimplemented for the HDMI/Composite output).

## Project hardware and software
The target FPGA is an Altera Cyclone IV EP4CE15. The development board used in this project is the [Cyclone IV EP4CE15 Core Board with 32MiB SDRAM from QMtech](https://www.aliexpress.com/i/32949281189.html). This board is plugged into a self designed expansion PCB, which provides all I/O and power.

All hardware designs are written in Verilog. Iverilog and GTKwave are used to simulate these hardware designs before writing the design to the FPGA using Quartus Prime (Lite).

The Assembler, C compiler and most other scripts are written in Python 3. The assembler assembles a self designed assembly language, and the C compiler compiles C to this assembly language.

Sublime Text 3 is used as text editor/IDE, with some handy build scripts to speed up the development and to quickly send code to the FPGC5.

## Structure of project files
The general structure of this project:
``` text
FPGC5
├── Assembler           // Assembler and assembly code files
├── Ccompiler           // C compiler project, contains programs and OS as well
├── Documentation       // Documentation website project
├── ESP32Synth          // Arduino code for (old) ESP32 APU
├── Graphics            // Scripts for converting/generating graphics data
├── MidiConverter       // Scripts to convert .mid files into audio asm code
├── PCB                 // PCB KiCad source files
├── Programmer          // Scripts for programming the FPGC5
├── Quartus             // Quartus project files
├── SublimeText3        // Project build scripts for Sublime Text 3
└── Verilog             // Verilog source files
    ├── memory          // Memory init related files
    ├── modules         // Hardware modules
    ├── output          // Simulation output
    └── testbench       // Simulation testbench
```

## Project Links
- [Github Repository](https://www.github.com/b4rt-dev/FPGC5)
- [Gogs Mirror](https://www.b4rt.nl/git/bart/FPGC5-mirror)
- [Documentation (this site)](https://www.b4rt.nl/fpgc)
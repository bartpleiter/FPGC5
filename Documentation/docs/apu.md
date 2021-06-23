# APU
The APU, or audio processing unit, is responsible for generating and outputting (analog) sound. It is connected to the Memory Unit using UART.

The APU in the FPGC5 is a seperate MCU with its own RAM and storage, just like the SNES uses a seperate SPC700 and DSP chip to generate audio, saving FPGA resources and hours of time creating a complex APU. In the case of the FPGC5, a more modern and capable ESP32 is used as a software synthesizer with an I2S DAC attached to it. It currently works as a MIDI synthesizer, where the FPGC5 sends MIDI signals (three bytes per event) over UART to the ESP32 at 115200 bps, which then generates and outputs the sound in real time (with maybe one or two ms of delay because of the I2S buffer). For the future, I plan to use different sounds for different MIDI channels, so I can have multiple sounds at the same time.

The software is a modification from my ESP32Synth (standalone) project. It is written using the Arduino platform. 

## Why an ESP32?
Originally I had 8 simple square wave tone generators implemented in the FPGC, connected to the 3.5mm jack using some resistors and a capacitor. However, I found this way to basic and limiting compared to hardware from the 1980s. Designing and implementing a decent APU in hardware would take a very long time for me and would take a lot of space in the FPGA, so I opted for an easier solution: the synthesizer project I wrote for an ESP32.

While this all works great, I can take this into five directions:

1. Keep the ESP32 and maybe optimize the code for it to add some new features. Currently the capabilities are very basic like (probably even worse than) the APU of the NES, which is what I want.
2. Upgrade to a Teensy3.6/4.0 (because form factor) or some STM32 Cortex M7 (though those chips are HUGE), and make use of their DSP libraries to allow for floating point operations and more polyphony. This would allow for very complex sounds. However, having an APU that is >1000 times faster than the FPGC5 does not feel right.
3. Downgrade to a simple MCU like an Atmega 328. While this feels a lot better than using a dual core 240MHz ESP32, it might be too limiting as for performance/polyphony.
4. Use an external DSP/APU chip. This is not a good idea because it defeats the purpose of designing something myself. Furthermore, it would require quite some research to become familiar to the chip and removes a lot of flexibility.
5. Write something myself in hardware using either the EP4CE15 or a small external FPGA (or EP4CE6 that I can hand solder myself). This would be the ideal case, but also requires a lot of effort and time.

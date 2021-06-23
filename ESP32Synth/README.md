# ESP32Synth-FPGC4

* 28 voice polyphonic (currently only Wavetable) synthesizer using ESP32 + I2S audio DAC. Designed as APU for FPGC4, but also to play live.
* Can be controlled over UART. Accepts MIDI commands (for live performance), and (in the future) custom MIDI commands when controlled by MCU/FPGC4
* Uses exponential ADSR for each voice (when live, using 4 control knobs)
* Has 4 different waveforms: Square, Saw, Sine and Triangle (select using mod wheel)
* Width of square wave can be adjusted as well using pitch bend
* Outputs audio at 44.100 samples per second at I2S DAC
* Has low (not noticable for me) latency. Latency can be adjusted by setting different buffer sizes.
* Controlled completely over MIDI control commands (and in the future custom MIDI commands), so no hardware is needed for potentiometers and such
* Simple connectivity, only 3.3v, GND + UART(1) is needed (AT 115200 BOUD RATE!!!). Currently only RX is needed as it does not send anything back (yet)
* Display functionality and such has been removed, since the use case of this project has changed
* Designed (in live mode) for an Acorn Masterkey 61 (with 4 control knobs) (using a seperate device that converts USB MIDI to UART MIDI at 115200), but can be easily modified to work with other MIDI keyboards

# MIDI converter

!!! info "TODO"
	Extend and update

The MIDI converter Python script can be used to convert basic MIDI files to MIDI bytes and timings for the APU in the FPGC4.

There are some limitations, like it has to wait 1ms between each MIDI command, and only NOTE_ON and NOTE_OFF commands are sent.
Also the velocity is limited a bit (this is on purpose, to prevent clipping).
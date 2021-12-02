#include "lib/stdlib.h"
#include "lib/sys.h"


void AssemblyImports()
{
    ASM("\
    // Quick midi music test rom for ESP32Synth ;\
    `include example/data_music_midi.asm ;\
    ");
}

void startMidiPlayer()
{
    ASM("\
    load32 0x600000 r2 ;\
    ;\
    load 1 r1 ;\
    write 0 r2 r0 // reset midi index ;\
    write 1 r2 r1 // reset time index ;\
    ;\
    load32 0xC0273D r1  // r1 = Timer3 value register ;\
    ;\
    // start timer3 to start playing ;\
    load 1 r3 ;\
    write 0 r1 r3       // write timer3 value ;\
    write 1 r1 r3       // start timer3 ;\
    ");
}

int main() 
{

    BDOS_PrintConsole("Press ESC to quit\n");

    startMidiPlayer();

    while (1)
    {
        if (HID_FifoAvailable())
        {
            int c = HID_FifoRead();
            if (c == 27) // escape
            {
                return 'q';
            }
        }
    }

    return 'q';
}

// timer1 interrupt handler
void int1()
{
   timer1Value = 1; // notify ending of timer1
}

void int2()
{
    int i = getIntID();
    if (i == INTID_TIMER3)
    {
        ASM("\
        push r1 ;\
        push r2 ;\
        push r3 ;\
        push r4 ;\
        push r5 ;\
        push r8 ;\
        push r10 ;\
        push r11 ;\
        push r12 ;\
        ;\
        load32 0x600000 r2 ;\
        ;\
        //TIME ;\
        read 1 r2 r5        // read time index to r5 ;\
        ;\
        load32 0xC0273D r1  // r1 = Timer3 value register ;\
        ;\
        addr2reg MUSICLENS r3 ;\
        add r3 r5 r3        // add time index offset to address ;\
        read 0 r3 r3        // get time len data ;\
        ;\
        // set and start timer ;\
        load 1 r4 ;\
        write 0 r1 r3       // write timer3 value ;\
        write 1 r1 r4       // start timer3 ;\
        ;\
        // increase timer index ;\
        add r5 1 r5 ;\
        write 1 r2 r5 ;\
        ;\
        //NOTES ;\
        ;\
        read 0 r2 r5        // read midi index to r5 ;\
        ;\
        addr2reg MUSICNOTES r4 ;\
        add r4 r5 r4         // add midi index offset to address ;\
        read 0 r4 r10        // get byte1 ;\
        read 1 r4 r11        // get byte2 ;\
        read 2 r4 r12        // get byte3 ;\
        ;\
        // write to uart2 ;\
        load32 0xC02725 r8 ;\
        write 0 r8 r10 ;\
        write 0 r8 r11 ;\
        write 0 r8 r12 ;\
        ;\
        // increase midi index by 3 ;\
        add r5 3 r5 ;\
        write 0 r2 r5 ;\
        ;\
        // restore registers ;\
        pop r12 ;\
        pop r11 ;\
        pop r10 ;\
        pop r8 ;\
        pop r5 ;\
        pop r4 ;\
        pop r3 ;\
        pop r2 ;\
        pop r1 ;\
        ");
    }
    
}

void int3()
{
    
}

void int4()
{
}
#include "lib/stdlib.h" 

#define CH376_DEBUG              0
#define CH376_LOOP_DELAY         100
#define CH376_COMMAND_DELAY      20
#define CMD_SET_USB_SPEED        0x04
#define CMD_RESET_ALL            0x05
#define CMD_GET_STATUS           0x22
#define CMD_SET_USB_MODE         0x15
#define MODE_HOST_0              0x05
#define MODE_HOST_1              0x07
#define MODE_HOST_2              0x06
#define ANSW_USB_INT_CONNECT     0x15


/*
*   Global Variables
*/

int endp_mode = 0x80;

/*
*   Functions
*/

void AssemblyImports()
{
    ASM("\
    // Quick midi music test rom for ESP32Synth ;\
    `include example/data_music_midi.asm ;\
    ");
}

// Sets SPI2_CS low
void CH376_spiBeginTransfer()
{
    ASM("\
    // backup regs ;\
    push r1 ;\
    push r2 ;\
    \
    load32 0xC0272F r2          // r2 = 0xC0272F | SPI2_CS ;\
    \
    load 0 r1                   // r1 = 0 (enable) ;\
    write 0 r2 r1               // write to SPI2_CS ;\
    \
    // restore regs ;\
    pop r2 ;\
    pop r1 ;\
    ");
}

// Sets SPI2_CS high
void CH376_spiEndTransfer()
{
    ASM("\
    // backup regs ;\
    push r1 ;\
    push r2 ;\
    \
    load32 0xC0272F r2          // r2 = 0xC0272F | SPI2_CS ;\
    \
    load 1 r1                   // r1 = 1 (disable) ;\
    write 0 r2 r1               // write to SPI2_CS ;\
    \
    // restore regs ;\
    pop r2 ;\
    pop r1 ;\
    ");
}

// write dataByte and return read value
// write 0x00 for a read
// Writes byte over SPI to CH376
// INPUT:
//   r5: byte to write
// OUTPUT:
//   r1: read value
int CH376_spiTransfer(int dataByte)
{
    ASM("\
    load32 0xC0272E r1      // r1 = 0xC0272E | SPI address      ;\
    write 0 r1 r5           // write r5 over SPI                ;\
    read 0 r1 r1            // read return value                ;\
    ");
}


// Get status after waiting for an interrupt
int CH376_WaitGetStatus() {
    int intValue = 1;
    while(intValue)
    {
        int *i = (int *) 0xC02730;
        intValue = *i;
    }
    CH376_spiBeginTransfer();
    CH376_spiTransfer(CMD_GET_STATUS);
    CH376_spiEndTransfer(); 
    //delay(1);

    CH376_spiBeginTransfer();
    int retval = CH376_spiTransfer(0x00);
    CH376_spiEndTransfer(); 

    return retval;
}

// Get status without using interrupts
int CH376_noWaitGetStatus() {
    CH376_spiBeginTransfer();
    CH376_spiTransfer(CMD_GET_STATUS);
    int retval = CH376_spiTransfer(0x00);
    CH376_spiEndTransfer(); 

    return retval;
}


// Sets USB mode to mode, returns status code
// Which should be 0x51 when successful
int CH376_setUSBmode(int mode)
{
    CH376_spiBeginTransfer();
    CH376_spiTransfer(CMD_SET_USB_MODE);
    CH376_spiEndTransfer();
    delay(1);

    CH376_spiBeginTransfer();
    CH376_spiTransfer(mode);
    CH376_spiEndTransfer();
    delay(1);

    CH376_spiBeginTransfer();
    int status = CH376_spiTransfer(0x00);
    CH376_spiEndTransfer();
    delay(1);

    return status;
}


// resets and intitializes CH376
void CH376_init()
{
    CH376_spiEndTransfer(); // start with cs high
    delay(60);
    
    CH376_spiBeginTransfer();
    CH376_spiTransfer(CMD_RESET_ALL);
    CH376_spiEndTransfer();
    delay(100); // wait after reset
    
    if (CH376_DEBUG)
        uprintln("reset done");

    if (CH376_DEBUG)
        uprintln("Setting USB mode to HOST_0");

    int retval = CH376_setUSBmode(MODE_HOST_0);

    if (CH376_DEBUG)
    {
        char buffer[10];
        itoah(retval, &buffer[0]);
        uprint(&buffer[0]);
        uprintln(", USB mode set to HOST_0 (51 == operation successful)");
    }
    
}


// Not required
void setUSBspeed()   
{      
    CH376_spiBeginTransfer();
    CH376_spiTransfer(0x0b);
    CH376_spiTransfer(0x17);
    CH376_spiTransfer(0xd8);
    CH376_spiEndTransfer();
    delay(20);
}   


// Checks if a device is connected
// Sets USB mode to eventually 2
// Checks again if the device connected in new USB mode
void connectDevice()
{
    // Variables
    int retval = 0;
    char buffer[10];

    // Device connection
    if (CH376_DEBUG)
    uprintln("Checking device connection status");
    while(CH376_WaitGetStatus() != ANSW_USB_INT_CONNECT);
    if (CH376_DEBUG)
        uprintln("Device connected");
    


    // USB mode 1
    if (CH376_DEBUG)
        uprintln("Setting USB mode to HOST_1");

    retval = CH376_setUSBmode(MODE_HOST_1);
    
    if (CH376_DEBUG)
    {
        itoah(retval, &buffer[0]);
        uprint(&buffer[0]);
        uprintln(", USB mode set to HOST_1 (51 == operation successful)");
    }


    // USB mode 2
    if (CH376_DEBUG)
        uprintln("Setting USB mode to HOST_2");

    retval = CH376_setUSBmode(MODE_HOST_2);

    if (CH376_DEBUG)
    {
        itoah(retval, &buffer[0]);
        uprint(&buffer[0]);
        uprintln(", USB mode set to HOST_2 (51 == operation successful)");
    }


    if (CH376_DEBUG)
    uprintln("Checking device connection status");
    while(CH376_WaitGetStatus() != ANSW_USB_INT_CONNECT);
    if (CH376_DEBUG)
        uprintln("Device connected");
}


// I think this is required to start receiving data from USB
void toggle_recv()
{
  CH376_spiBeginTransfer();
  CH376_spiTransfer( 0x1C );
  CH376_spiTransfer( endp_mode );
  CH376_spiEndTransfer();
  endp_mode = endp_mode ^0x40;
}


// Set endpoint and pid
void issue_token(int endp_and_pid)
{
  CH376_spiBeginTransfer();
  CH376_spiTransfer( 0x4F );
  CH376_spiTransfer( endp_and_pid );  // Bit7~4 for EndPoint No, Bit3~0 for Token PID
  CH376_spiEndTransfer(); 
}


// Read data from USB, and do something with it
// First byte is the length,
// But since a MIDI keyboard always sends 4 bytes,
// We just ignore it
void RD_USB_DATA() 
{     
    CH376_spiBeginTransfer();
    CH376_spiTransfer(0x28); 
    CH376_spiTransfer(0x00);  // ignore len
   
    // read 4 bytes
    int b0 = CH376_spiTransfer(0x00);
    int b1 = CH376_spiTransfer(0x00);
    int b2 = CH376_spiTransfer(0x00);
    int b3 = CH376_spiTransfer(0x00);

    CH376_spiEndTransfer();

    int *p = (int*)0xC02725;    // address of UART1 TX
    //*p = (int)b0;                 // write char over UART1
    *p = (int)b1;               // write char over UART2
    *p = (int)b2;               // write char over UART2
    *p = (int)b3;               // write char over UART2


    if (CH376_DEBUG)
    {
        char buffer[10];

        uprintln("--RAW DATA--");
        itoah(b0, &buffer[0]);
        uprintln(&buffer[0]);

        itoah(b1, &buffer[0]);
        uprintln(&buffer[0]);

        itoah(b2, &buffer[0]);
        uprintln(&buffer[0]);

        itoah(b3, &buffer[0]);
        uprintln(&buffer[0]);

        // parse bytes
        int cableNumber = b0 &&& 0b11110000;
        int CIN         = b0 &&& 0b00001111;
        int channel     = b1 &&& 0b00001111;
        int event       = b1 &&& 0b11110000;
        int noteID      = b2;
        int velocity    = b3;

        uprintln("--PARSED DATA--");

        uprint("Cable Number: ");
        itoah(cableNumber, &buffer[0]);
        uprintln(&buffer[0]);

        uprint("CIN: ");
        itoah(CIN, &buffer[0]);
        uprintln(&buffer[0]);

        uprint("Channel: ");
        itoah(channel, &buffer[0]);
        uprintln(&buffer[0]);

        uprint("Event: ");
        itoah(event, &buffer[0]);
        uprintln(&buffer[0]);

        uprint("NoteID: ");
        itoah(noteID, &buffer[0]);
        uprintln(&buffer[0]);

        uprint("Velocity: ");
        itoah(velocity, &buffer[0]);
        uprintln(&buffer[0]);

        uprintln("\n");
    }
    
}


void set_addr(int addr) {    

    CH376_spiBeginTransfer();
    CH376_spiTransfer( 0x45 );     
    CH376_spiTransfer( addr );  
    CH376_spiEndTransfer();   
    delay(20);
    
    if (CH376_DEBUG)
        uprintln("------Host addr set------");

    CH376_spiBeginTransfer();
    CH376_spiTransfer( 0x13 ); 
    CH376_spiTransfer( addr ); 
    CH376_spiEndTransfer();   
    delay(20);

    if (CH376_DEBUG)
        uprintln("------Slave addr set------");
}   


void set_config(int cfg) {  
  CH376_spiBeginTransfer();   
  CH376_spiTransfer( 0x49 );     
  CH376_spiTransfer( cfg ); 
  CH376_spiEndTransfer();   
  delay(20);
}  


void startMidiPlayer()
{
    ASM("\
    load32 0x80000 r2 ;\
    ;\
    load 1 r1 ;\
    write 0 r2 r0 // reset midi index ;\
    write 1 r2 r1 // reset time index ;\
    ;\
    load32 0xC02628 r1  // r1 = Timer2 value register ;\
    ;\
    // start timer2 to start playing ;\
    load 1 r3 ;\
    write 0 r1 r3       // write timer2 value ;\
    write 1 r1 r3       // start timer2 ;\
    ");
}


int main() 
{
    startMidiPlayer();

    CH376_init();

    connectDevice();
    delay(10);

    set_addr(5);
    delay(10);

    set_config(1);
    delay(10);

    if (CH376_DEBUG)
        uprintln("------Ready to receive------");

    // Main loop
    while(1)
    {
        toggle_recv();

        issue_token(89);

        while (CH376_WaitGetStatus() != 0x14);

        RD_USB_DATA();
    }

    return 48;
}

// timer1 interrupt handler
void int1()
{
   int *p = (int *) 0x4C0000; // set address (timer1 state)
   *p = 1; // write value
}

void int2()
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
    load32 0x80000 r2 ;\
    ;\
    //TIME ;\
    read 1 r2 r5        // read time index to r5 ;\
    ;\
    load32 0xC02628 r1  // r1 = Timer2 value register ;\
    ;\
    addr2reg MUSICLENS r3 ;\
    add r3 r5 r3        // add time index offset to address ;\
    read 0 r3 r3        // get time len data ;\
    ;\
    // set and start timer ;\
    load 1 r4 ;\
    write 0 r1 r3       // write timer2 value ;\
    write 1 r1 r4       // start timer2 ;\
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
    load32 0xC02732 r8 ;\
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

void int3()
{

}

void int4()
{
    
}
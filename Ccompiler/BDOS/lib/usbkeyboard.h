// TODO: replace hardcoded opcodes with defines from table from doc2.pdf

#include "stdlib.h" 
#include "hidfifo.h"
#include "../data/USBSCANCODES.h"

#define CMD_SET_USB_SPEED        0x04
#define CMD_RESET_ALL            0x05
#define CMD_GET_STATUS           0x22
#define CMD_SET_USB_MODE         0x15
#define MODE_HOST_0              0x05
#define MODE_HOST_1              0x07
#define MODE_HOST_2              0x06
#define ANSW_USB_INT_CONNECT     0x15

#define USBKEYBOARD_POLLING_RATE 30
#define TIMER2_VAL 0xC0273B
#define TIMER2_CTRL 0xC0273C


/*
*   Global Variables
*/

int USBkeyboard_endp_mode = 0x80;
char USBkeyboard_buffer[8] = 0;
char USBkeyboard_buffer_prev[8] = 0;

/*
*   Functions
*/


// Sets SPI2_CS low
void USBkeyboard_spiBeginTransfer()
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
void USBkeyboard_spiEndTransfer()
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
// Writes byte over SPI2 to CH376
// INPUT:
//   r5: byte to write
// OUTPUT:
//   r1: read value
int USBkeyboard_spiTransfer(int dataByte)
{
    ASM("\
    load32 0xC0272E r1      // r1 = 0xC0272E | SPI2 address     ;\
    write 0 r1 r5           // write r5 over SPI2               ;\
    read 0 r1 r1            // read return value                ;\
    ");
}




// Get status after waiting for an interrupt
int USBkeyboard_WaitGetStatus() {
    int intValue = 1;
    while(intValue)
    {
        int *i = (int *) 0xC02730;
        intValue = *i;
    }
    USBkeyboard_spiBeginTransfer();
    USBkeyboard_spiTransfer(CMD_GET_STATUS);
    USBkeyboard_spiEndTransfer(); 
    //delay(1);

    USBkeyboard_spiBeginTransfer();
    int retval = USBkeyboard_spiTransfer(0x00);
    USBkeyboard_spiEndTransfer(); 

    return retval;
}

// Get status without using interrupts
int USBkeyboard_noWaitGetStatus() {
    USBkeyboard_spiBeginTransfer();
    USBkeyboard_spiTransfer(CMD_GET_STATUS);
    int retval = USBkeyboard_spiTransfer(0x00);
    USBkeyboard_spiEndTransfer(); 

    return retval;
}


// Sets USB mode to mode, returns status code
// Which should be 0x51 when successful
int USBkeyboard_setUSBmode(int mode)
{
    USBkeyboard_spiBeginTransfer();
    USBkeyboard_spiTransfer(CMD_SET_USB_MODE);
    USBkeyboard_spiEndTransfer();

    USBkeyboard_spiBeginTransfer();
    USBkeyboard_spiTransfer(mode);
    USBkeyboard_spiEndTransfer();

    for(int i = 0; i < 20000; i++); // non-interrupt wait

    USBkeyboard_spiBeginTransfer();
    int status = USBkeyboard_spiTransfer(0x00);
    USBkeyboard_spiEndTransfer();

    return status;
}


// Sets USB speed (0 = USB2, 2 = USB1)
void USBkeyboard_setUSBspeed(int speed)
{
    USBkeyboard_spiBeginTransfer();   
    USBkeyboard_spiTransfer( CMD_SET_USB_SPEED );     
    USBkeyboard_spiTransfer( speed ); 
    USBkeyboard_spiEndTransfer(); 
}


// resets and initializes CH376
void USBkeyboard_init()
{
    USBkeyboard_spiEndTransfer(); // start with cs high
    delay(60);
    
    USBkeyboard_spiBeginTransfer();
    USBkeyboard_spiTransfer(CMD_RESET_ALL);
    USBkeyboard_spiEndTransfer();
    delay(100); // wait after reset

    USBkeyboard_setUSBmode(MODE_HOST_0);

    // set polling interrupt
    // set timer
    int *p = (int *) TIMER2_VAL;
    *p = USBKEYBOARD_POLLING_RATE;
    // start timer
    int *q = (int *) TIMER2_CTRL;
    *q = 1;
    
}


// Sets USB mode to 2
// Checks again if the device connected in new USB mode
void USBkeyboard_connectDevice()
{
    USBkeyboard_setUSBmode(MODE_HOST_1);
    USBkeyboard_setUSBmode(MODE_HOST_2);

    while (USBkeyboard_WaitGetStatus() != ANSW_USB_INT_CONNECT); // Wait for reconnection of device
}


// I think this is required to start receiving data from USB
void USBkeyboard_toggle_recv()
{
  USBkeyboard_spiBeginTransfer();
  USBkeyboard_spiTransfer( 0x1C );
  USBkeyboard_spiTransfer( USBkeyboard_endp_mode );
  USBkeyboard_spiEndTransfer();
  USBkeyboard_endp_mode = USBkeyboard_endp_mode ^0x40;
}


// Set endpoint and pid
void USBkeyboard_issue_token(int endp_and_pid)
{
  USBkeyboard_spiBeginTransfer();
  USBkeyboard_spiTransfer( 0x4F );
  USBkeyboard_spiTransfer( endp_and_pid );  // Bit7~4 for EndPoint No, Bit3~0 for Token PID
  USBkeyboard_spiEndTransfer(); 
}


// Read data from USB, and do something with it
// First byte is the length, which should be 8 for an HID keyboard
// The other bytes are the data indicating which keys are pressed
void USBkeyboard_receive_data(char* usbBuf) 
{     
    USBkeyboard_spiBeginTransfer();
    USBkeyboard_spiTransfer(0x28); 
    int len = USBkeyboard_spiTransfer(0x00);

    // check for 8 bytes
    if (len != 8)
    {
        USBkeyboard_spiEndTransfer();
        return;
    }
   
    for (int i = 0; i < len; i++)
    {
        usbBuf[i] = USBkeyboard_spiTransfer(0x00);
    }

    USBkeyboard_spiEndTransfer();
}


void USBkeyboard_set_addr(int addr) {    

    USBkeyboard_spiBeginTransfer();
    USBkeyboard_spiTransfer( 0x45 );     
    USBkeyboard_spiTransfer( addr );  
    USBkeyboard_spiEndTransfer();   

    USBkeyboard_WaitGetStatus();

    USBkeyboard_spiBeginTransfer();
    USBkeyboard_spiTransfer( 0x13 ); 
    USBkeyboard_spiTransfer( addr ); 
    USBkeyboard_spiEndTransfer();   
}   


void USBkeyboard_set_config(int cfg) {  
    USBkeyboard_spiBeginTransfer();   
    USBkeyboard_spiTransfer( 0x49 );     
    USBkeyboard_spiTransfer( cfg ); 
    USBkeyboard_spiEndTransfer();   

    USBkeyboard_WaitGetStatus();
}  


// Parses USB keyboard buffer into ?
void USBkeyboard_parse_buffer(char* usbBuf, char* usbBufPrev)
{
    // detect which keys are pressed:
    // compare byte 2-7 with previous buffer
    for (int i = 2; i < 8; i++)
    {
        // if prev byte == 0 and new byte != 0, then new byte is new keypress
        if (usbBuf[i] != 0 && usbBufPrev[i] == 0)
        {

            // check first byte for both shift key bits
            if ((usbBuf[0] &&& 0x2) || (usbBuf[0] &&& 0x20))
            {
                // convert to ascii/code using table
                // add new ascii/code to fifo
                int *tableShifted = (int*) &DATA_USBSCANCODE_SHIFTED;
                tableShifted += 4; // set offset to data in function
                HID_FifoWrite(*(tableShifted+usbBuf[i]));
            }
            else // non-shifted
            {
                // convert to ascii/code using table
                // add new ascii/code to fifo
                int *tableNomal = (int*) &DATA_USBSCANCODE_NORMAL;
                tableNomal += 4; // set offset to data in function
                HID_FifoWrite(*(tableNomal+usbBuf[i]));
            } 
        }
    }
    
    // copy buffer to previous buffer
    memcpy(usbBufPrev, usbBuf, 8);
}

// Poll for USB
void USBkeyboard_poll()
{
    int status = USBkeyboard_noWaitGetStatus();
    if (status == 0x14)
    {
        USBkeyboard_receive_data(USBkeyboard_buffer);
        USBkeyboard_parse_buffer(USBkeyboard_buffer, USBkeyboard_buffer_prev);
        USBkeyboard_toggle_recv();
        USBkeyboard_issue_token(0x19); // result of endp 1 and pid 9 ( 1 << 4 ) | 0x09

    }
    // If reconnection TODO: move this to main loop, since we do not want to keep the interrupt occupied for so long
    else if (status == ANSW_USB_INT_CONNECT)
    {
        for (int x = 0; x < 100000; x++); // delay without interrupt, to make sure connection is stable
        USBkeyboard_connectDevice();
        USBkeyboard_setUSBspeed(0);
        USBkeyboard_set_addr(1); // endpoint 1 IN
        USBkeyboard_set_config(1);
        USBkeyboard_toggle_recv();
        USBkeyboard_issue_token(0x19); // result of endp 1 and pid 9 ( 1 << 4 ) | 0x09
    }
}


void USBkeyboard_HandleInterrupt()
{
    // poll the USB keyboard
    USBkeyboard_poll();

    // set timer to polling rate
    int *p = (int *) TIMER2_VAL;
    *p = USBKEYBOARD_POLLING_RATE;
    // start timer
    int *q = (int *) TIMER2_CTRL;
    *q = 1;
}

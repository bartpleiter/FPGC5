/*
* USB keyboard library
* Contains functions to read a generic USB keybaord from USB1 (SPI2)
* And writes the resulting characters to the HID fifo
*/

// uses stdlib.c
// uses hidfifo.c
// uses USBSCANCODES.c

#define USBKEYBOARD_CMD_SET_USB_SPEED        0x04
#define USBKEYBOARD_CMD_RESET_ALL            0x05
#define USBKEYBOARD_CMD_GET_STATUS           0x22
#define USBKEYBOARD_CMD_SET_USB_MODE         0x15
#define USBKEYBOARD_MODE_HOST_0              0x05
#define USBKEYBOARD_MODE_HOST_1              0x07
#define USBKEYBOARD_MODE_HOST_2              0x06
#define USBKEYBOARD_ANSW_USB_INT_CONNECT     0x15

#define USBKEYBOARD_POLLING_RATE 30
#define USBKEYBOARD_HOLD_COUNTS 20

// These are in stdlib.c already
// #define TIMER2_VAL 0xC0273B
// #define TIMER2_CTRL 0xC0273C

#define USBKEYBOARD_SPI2_INTERRUPT 0xC02730

#define USBKEYBOARD_DATA_OFFSET 3

/*
*   Global Variables
*/

word USBkeyboard_endp_mode = 0x80;
word USBkeyboard_buffer[8];
word USBkeyboard_buffer_parsed[8];
word USBkeyboard_buffer_prev[8];

word USBkeyboard_holdCounter = 0;
word USBkeyboard_holdButton = 0;
word USBkeyboard_holdButtonDataOrig = 0;


/*
*   Functions
*/

// Workaround for defines in ASM
void USBkeyboard_asmDefines()
{
    asm(
        "define USBkeyboard_SPI2_CS_ADDR = 0xC0272F ; address of SPI2_CS\n"
        "define USBkeyboard_SPI2_ADDR = 0xC0272E    ; address of SPI2\n"
        );
}

// Sets SPI2_CS low
void USBkeyboard_spiBeginTransfer()
{
    asm(
        "; backup regs\n"
        "push r1\n"
        "push r2\n"

        "load32 USBkeyboard_SPI2_CS_ADDR r2 ; r2 = USBkeyboard_SPI2_CS_ADDR\n"

        "load 0 r1                          ; r1 = 0 (enable)\n"
        "write 0 r2 r1                      ; write to SPI2_CS\n"

        "; restore regs\n"
        "pop r2\n"
        "pop r1\n"
        );
}

// Sets SPI2_CS high
void USBkeyboard_spiEndTransfer()
{
    asm(
        "; backup regs\n"
        "push r1\n"
        "push r2\n"

        "load32 USBkeyboard_SPI2_CS_ADDR r2 ; r2 = USBkeyboard_SPI2_CS_ADDR\n"

        "load 1 r1                          ; r1 = 1 (disable)\n"
        "write 0 r2 r1                      ; write to SPI2_CS\n"

        "; restore regs\n"
        "pop r2\n"
        "pop r1\n"
        );
}

// write dataByte and return read value
// write 0x00 for a read
// Writes byte over SPI2 to CH376
word USBkeyboard_spiTransfer(word dataByte)
{
    word retval = 0;
    asm(
        "load32 USBkeyboard_SPI2_ADDR r2    ; r2 = USBkeyboard_SPI2_ADDR\n"
        "write 0 r2 r4                      ; write r4 over SPI2\n"
        "read 0 r2 r2                       ; read return value\n"
        "write -4 r14 r2                    ; write to stack to return\n"
        );

    return retval;
}


// Get status after waiting for an interrupt
word USBkeyboard_WaitGetStatus() {
    word intValue = 1;
    while(intValue)
    {
        word *i = (word *) USBKEYBOARD_SPI2_INTERRUPT;
        intValue = *i;
    }
    USBkeyboard_spiBeginTransfer();
    USBkeyboard_spiTransfer(USBKEYBOARD_CMD_GET_STATUS);
    USBkeyboard_spiEndTransfer(); 
    //delay(1);

    USBkeyboard_spiBeginTransfer();
    word retval = USBkeyboard_spiTransfer(0x00);
    USBkeyboard_spiEndTransfer(); 

    return retval;
}

// Get status without using interrupts
word USBkeyboard_noWaitGetStatus() {
    USBkeyboard_spiBeginTransfer();
    USBkeyboard_spiTransfer(USBKEYBOARD_CMD_GET_STATUS);
    word retval = USBkeyboard_spiTransfer(0x00);
    USBkeyboard_spiEndTransfer(); 

    return retval;
}


// Sets USB mode to mode, returns status code
// Which should be 0x51 when successful
word USBkeyboard_setUSBmode(word mode)
{
    USBkeyboard_spiBeginTransfer();
    USBkeyboard_spiTransfer(USBKEYBOARD_CMD_SET_USB_MODE);
    USBkeyboard_spiEndTransfer();

    USBkeyboard_spiBeginTransfer();
    USBkeyboard_spiTransfer(mode);
    USBkeyboard_spiEndTransfer();

    word i;
    for(i = 0; i < 20000; i++); // non-interrupt wait

    USBkeyboard_spiBeginTransfer();
    word status = USBkeyboard_spiTransfer(0x00);
    USBkeyboard_spiEndTransfer();

    return status;
}


// Sets USB speed (0 = USB2, 2 = USB1)
void USBkeyboard_setUSBspeed(word speed)
{
    USBkeyboard_spiBeginTransfer();   
    USBkeyboard_spiTransfer( USBKEYBOARD_CMD_SET_USB_SPEED );     
    USBkeyboard_spiTransfer( speed ); 
    USBkeyboard_spiEndTransfer(); 
}


// resets and initializes CH376
void USBkeyboard_init()
{
    USBkeyboard_asmDefines(); // workaround to prevent deletion by optimizer
    USBkeyboard_spiEndTransfer(); // start with cs high
    delay(10);
    
    USBkeyboard_spiBeginTransfer();
    USBkeyboard_spiTransfer(USBKEYBOARD_CMD_RESET_ALL);
    USBkeyboard_spiEndTransfer();
    delay(100); // wait after reset

    USBkeyboard_setUSBmode(USBKEYBOARD_MODE_HOST_0);

    // set polling interrupt
    // set timer
    word *p = (word *) TIMER2_VAL;
    *p = USBKEYBOARD_POLLING_RATE;
    // start timer
    word *q = (word *) TIMER2_CTRL;
    *q = 1;
    
}


// Sets USB mode to 2
// Checks again if the device connected in new USB mode
void USBkeyboard_connectDevice()
{
    USBkeyboard_setUSBmode(USBKEYBOARD_MODE_HOST_1);
    USBkeyboard_setUSBmode(USBKEYBOARD_MODE_HOST_2);

    while (USBkeyboard_WaitGetStatus() != USBKEYBOARD_ANSW_USB_INT_CONNECT); // Wait for reconnection of device
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
void USBkeyboard_issue_token(word endp_and_pid)
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
    word len = USBkeyboard_spiTransfer(0x00);

    // check for 8 bytes
    if (len != 8)
    {
        USBkeyboard_spiEndTransfer();
        return;
    }

    word i;
    for (i = 0; i < len; i++)
    {
        usbBuf[i] = USBkeyboard_spiTransfer(0x00);

        // also put the parsed button into a separate buffer
        // convert to ascii/code using table
        // add new ascii/code to fifo
        word *tableNomal = (word*) &DATA_USBSCANCODE_NORMAL;
        tableNomal += USBKEYBOARD_DATA_OFFSET; // set offset to data in function
        USBkeyboard_buffer_parsed[i] = *(tableNomal+usbBuf[i]);
    }

    USBkeyboard_spiEndTransfer();
}


void USBkeyboard_set_addr(word addr) {    

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


void USBkeyboard_set_config(word cfg) {  
    USBkeyboard_spiBeginTransfer();   
    USBkeyboard_spiTransfer( 0x49 );     
    USBkeyboard_spiTransfer( cfg ); 
    USBkeyboard_spiEndTransfer();   

    USBkeyboard_WaitGetStatus();
} 


void USBkeyboard_sendToFifo(char usbCode, char* usbBuf)
{
    // check first byte for both shift key bits
    if ((usbBuf[0] & 0x2) || (usbBuf[0] & 0x20))
    {
        // convert to ascii/code using table
        // add new ascii/code to fifo
        word *tableShifted = (word*) &DATA_USBSCANCODE_SHIFTED;
        tableShifted += USBKEYBOARD_DATA_OFFSET; // set offset to data in function
        HID_FifoWrite(*(tableShifted+usbCode));
    }
    else // non-shifted
    {
        // convert to ascii/code using table
        // add new ascii/code to fifo
        word *tableNomal = (word*) &DATA_USBSCANCODE_NORMAL;
        tableNomal += USBKEYBOARD_DATA_OFFSET; // set offset to data in function
        HID_FifoWrite(*(tableNomal+usbCode));
    } 
}


// Parses USB keyboard buffer and writes result to HID FIFO
void USBkeyboard_parse_buffer(char* usbBuf, char* usbBufPrev)
{

    // detect which keys are pressed:
    // compare byte 2-7 with previous buffer
    word i;
    for (i = 2; i < 8; i++)
    {
        // if prev byte != new byte and new byte != 0, then new byte is new keypress
        if (usbBuf[i] != 0 && usbBufPrev[i] != usbBuf[i])
        {
            //uprintlnDec(usbBuf[i]); // usefull for adding new keys
            USBkeyboard_holdButton = i;
            USBkeyboard_sendToFifo(usbBuf[i], usbBuf);
        }
    }
    
    // copy buffer to previous buffer
    memcpy(usbBufPrev, usbBuf, 8);
}

// Poll for USB
void USBkeyboard_poll()
{
    word status = USBkeyboard_noWaitGetStatus();
    if (status == 0x14)
    {
        USBkeyboard_receive_data(USBkeyboard_buffer);
        USBkeyboard_parse_buffer(USBkeyboard_buffer, USBkeyboard_buffer_prev);
        USBkeyboard_toggle_recv();
        USBkeyboard_issue_token(0x19); // result of endp 1 and pid 9 ( 1 << 4 ) | 0x09

    }
    // If reconnection TODO: move this to main loop, since we do not want to keep the interrupt occupied for so long
    else if (status == USBKEYBOARD_ANSW_USB_INT_CONNECT)
    {
        word x;
        for (x = 0; x < 100000; x++); // delay without interrupt, to make sure connection is stable
        USBkeyboard_connectDevice();
        USBkeyboard_setUSBspeed(0);
        USBkeyboard_set_addr(1); // endpoint 1 IN
        USBkeyboard_set_config(1);
        USBkeyboard_toggle_recv();
        USBkeyboard_issue_token(0x19); // result of endp 1 and pid 9 ( 1 << 4 ) | 0x09
    }

    char* usbBuf = USBkeyboard_buffer;

    // Button hold detection
    if (USBkeyboard_holdButton != 0)
    {
        if (usbBuf[USBkeyboard_holdButton] != 0)
        {
            if (USBkeyboard_holdCounter == 0)
            {
                USBkeyboard_holdButtonDataOrig = usbBuf[USBkeyboard_holdButton];
                USBkeyboard_holdCounter++;
            }
            else // check if it is still the same button that is being held
            {
                if (usbBuf[USBkeyboard_holdButton] == USBkeyboard_holdButtonDataOrig)
                {
                    if (USBkeyboard_holdCounter < USBKEYBOARD_HOLD_COUNTS)
                        USBkeyboard_holdCounter++;
                }
                else
                {
                    USBkeyboard_holdButton = 0;
                    USBkeyboard_holdCounter = 0;
                }
            }
        }
        else
        {
            USBkeyboard_holdButton = 0;
            USBkeyboard_holdCounter = 0;
        }

        // Send repetitive code to HID FIFO when holding a button for a certain amount of time
        if (USBkeyboard_holdCounter >= USBKEYBOARD_HOLD_COUNTS)
        {
            USBkeyboard_sendToFifo(usbBuf[USBkeyboard_holdButton], usbBuf);
        }
    }
}


void USBkeyboard_HandleInterrupt()
{
    // poll the USB keyboard
    USBkeyboard_poll();

    // set timer to polling rate
    word *p = (word *) TIMER2_VAL;
    *p = USBKEYBOARD_POLLING_RATE;
    // start timer
    word *q = (word *) TIMER2_CTRL;
    *q = 1;
}

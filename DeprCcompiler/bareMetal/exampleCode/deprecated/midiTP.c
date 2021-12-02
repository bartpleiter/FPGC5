#include "lib/stdlib.h" 

#define CH376_DEBUG				 1
#define CH376_LOOP_DELAY 		 100
#define CH376_COMMAND_DELAY		 20
#define CMD_SET_USB_SPEED        0x04
#define CMD_RESET_ALL            0x05
#define CMD_GET_STATUS           0x22
#define CMD_SET_USB_MODE         0x15
#define MODE_HOST_0              0x05
#define MODE_HOST_1              0x07
#define MODE_HOST_2              0x06
#define ANSW_USB_INT_CONNECT     0x15


/*
*	Global Variables
*/

int endp_mode = 0x80;

// list of currently pressed notes
// values are the note ids. 0 = idle
int noteList[10] = 0;


/*
*	Functions
*/

// Sets GPO[0] (cs) low
void CH376_spiBeginTransfer()
{
	ASM("\
	// backup regs ;\
    push r1	;\
    push r2	;\
    push r3	;\
    \
    load32 0xC02630 r3          // r3 = 0xC02630 | GPIO ;\
    \
    read 0 r3 r1                // r1 = GPIO values ;\
    load 0b1111111011111111 r2  // r2 = bitmask ;\
    and r1 r2 r1                // set GPO[0] low ;\
    write 0 r3 r1               // write GPIO ;\
    \
    // restore regs ;\
    pop r3 ;\
    pop r2 ;\
    pop r1 ;\
    ");
}

// Sets GPO[0] (cs) high
void CH376_spiEndTransfer()
{
	ASM("\
	// backup regs ;\
    push r1	;\
    push r2	;\
    push r3	;\
    \
    load32 0xC02630 r3          // r3 = 0xC02630 | GPIO ;\
    \
    read 0 r3 r1                // r1 = GPIO values ;\
    load 0b100000000 r2         // r2 = bitmask ;\
    or r1 r2 r1                 // set GPO[0] high ;\
    write 0 r3 r1               // write GPIO ;\
    \
    // restore regs ;\
    pop r3 ;\
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
    load32 0xC02631 r1      // r1 = 0xC02631 | SPI address    	;\
    write 0 r1 r5           // write r5 over SPI				;\
    read 0 r1 r1            // read return value				;\
    ");
}


// Get status after waiting for an interrupt
int CH376_WaitGetStatus() {
	int intValue = 1;
	while(intValue)
    {
    	int *i = (int *) 0xC02624;
    	intValue = *i;
    }
    CH376_spiBeginTransfer();
    CH376_spiTransfer(CMD_GET_STATUS);
    CH376_spiEndTransfer(); 
    delay(1);

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


// Set a free note in the noteList to noteID
void press_note(int noteID)
{
  	int done = 0;
  	for (int i = 0; i < 8; i++)
  	{
  		if (done == 0)
  		{
  			int *p_noteList = noteList;
	  		if (*(p_noteList+i) == 0)
	  		{
	  			*(p_noteList+i) = noteID;
	  			done = 1;
	  		}
  		}
  	}
}


// Free all noted in noteList with noteID
void release_note(int noteID)
{
  	for (int i = 0; i < 8; i++)
  	{
  		int *p_noteList = noteList;
  		if (*(p_noteList+i) == noteID)
  		{
  			*(p_noteList+i) = 0;
  		}
  	}
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

    char buffer[10];

    if (CH376_DEBUG)
    {
		uprintln("--RAW DATA--");
		itoah(b0, &buffer[0]);
		uprintln(&buffer[0]);

		itoah(b1, &buffer[0]);
		uprintln(&buffer[0]);

		itoah(b2, &buffer[0]);
		uprintln(&buffer[0]);

		itoah(b3, &buffer[0]);
		uprintln(&buffer[0]);
	}

	
	// parse bytes
	int cableNumber = b0 &&& 0b11110000;
 	int CIN 		= b0 &&& 0b00001111;
  	int channel 	= b1 &&& 0b00001111;
  	int event 		= b1 &&& 0b11110000;
  	int noteID 		= b2;
  	int velocity 	= b3;

  	// note press
  	if (event == 0x90)
  	{
	  	press_note(noteID);
  	}

  	// note release
  	if (event == 0x80)
  	{
	  	release_note(noteID);
  	}

  	// control codes can be checked here as well
  	// when there is a use for it


  	if (CH376_DEBUG)
    {
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


// Write second part of noteList to tone player 2
void writeTP2()
{
	int quadNoteWord = noteList[4];
	quadNoteWord = quadNoteWord | (noteList[5] << 8);
	quadNoteWord = quadNoteWord | (noteList[6] << 16);
	quadNoteWord = quadNoteWord | (noteList[7] << 24);
	
	int *tp2 = (int *)0xC0262D;
	*tp2 = quadNoteWord;
}


// Write first part of noteList to tone player 1
void writeTP1()
{
	int quadNoteWord = noteList[0];
	quadNoteWord = quadNoteWord | (noteList[1] << 8);
	quadNoteWord = quadNoteWord | (noteList[2] << 16);
	quadNoteWord = quadNoteWord | (noteList[3] << 24);
	
	int *tp1 = (int *)0xC0262C;
	*tp1 = quadNoteWord;
}


// Print noteList
void printNoteList()   
{   
	uprintln("--PARSED DATA--");
	char buffer[10];
	for (int i = 0; i < 8; i++)
	{
		int q = i;
		int *p = noteList;
		itoah(*(p+q), &buffer[0]);
		uprintln(&buffer[0]);
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



int main() 
{

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

		if (CH376_DEBUG)
			printNoteList();

    	writeTP1();
    	writeTP2();
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
	int *p = (int *)0xC0262E; 	// address of UART TX
	*p = 44; 			// write char over UART
}

void int3()
{
   int *p = (int *)0xC0262E; 	// address of UART TX
	*p = 45; 			// write char over UART
}

void int4()
{
	
}
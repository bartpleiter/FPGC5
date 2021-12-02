#include "lib/USBlib.h"

#define USBPORT 2

int main() 
{

	for (int i = 0; i < 10000; i++)
	{
	USB2_spiBeginTransfer();
	USB2_spiTransfer(CMD_GET_IC_VER);
	delay(1);

	int icVer = USB2_spiTransfer(0x00);
	USB2_spiEndTransfer();

	char buffer[10];
	itoah(icVer, &buffer[0]);
	uprint(&buffer[0]);
	uprintln(", IC version 2");

	USB1_spiBeginTransfer();
	USB1_spiTransfer(CMD_GET_IC_VER);
	delay(1);

	int icVer2 = USB1_spiTransfer(0x00);
	USB1_spiEndTransfer();

	char buffer2[10];
	itoah(icVer2, &buffer2[0]);
	uprint(&buffer2[0]);
	uprintln(", IC version 1");

	delay(100);
	}

	//CH376_printICver(USBPORT);
	//TestReadingFile();
	//TestCreatingFile();
	//TestWritingFile();
	//return TestReadingFile();
	return 48;



	//----------OLD-----------


	//uprintln("------Deleting file------");
	//CH376_deleteFile();
	//uprintln("------File deleted------");

	/*
	NOTES:
	open file in subdirectory:
	- set filename to /FOLDER1
	- send open file
	- set filename to FOLDER2
	- send open file
	- set filename to A.TXT
	- send open file
	*/

	//return 48;
}

// timer1 interrupt handler
void int1()
{
   int *p = (int *) 0x4C0000; // set address (timer1 state)
   *p = 1; // write value
}

void int2()
{
}

void int3()
{
}

void int4()
{
}
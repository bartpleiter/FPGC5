#include "lib/USBlib.h"

#define USBPORT 1

char fileBuffer[4096] = 0;

// Test reading file
int TestReadingFile()
{
	if (!CH376_init(USBPORT))
		return 'a';

	delay(10);

	if (!CH376_connectDrive(USBPORT))
		return 'b';

	if (!CH376_sendFileName(USBPORT, "/INDEX.HTM"))
		return 'c';

	if (!CH376_openFile(USBPORT))
		return 'd';

	char buffer[10];
	int fzise = CH376_getFileSize(USBPORT);

	itoa(fzise, &buffer[0]);
	uprint("File size: ");
	uprintln(&buffer[0]);

	if (!CH376_setCursor(USBPORT, 0))
		return 'e';

	if (!CH376_readFile(USBPORT, fileBuffer, fzise))
		return 'f';

	if (!CH376_closeFile(USBPORT))
		return 'g';

	char *p_fileBuffer = fileBuffer;
	*(p_fileBuffer+fzise) = 0;

	uprintln(fileBuffer);

	return 48;
}

int TestCreatingFile()
{
	if (!CH376_init(USBPORT))
		return 49;

	if (!CH376_connectDrive(USBPORT))
		return 50;

	CH376_sendFileName(USBPORT, "/Y1.HTM");

	if (!CH376_createFile(USBPORT))
		return 51;

	if (!CH376_openFile(USBPORT))
		return 52;

	char buffer[10];
	int fzise = CH376_getFileSize(USBPORT);
	itoa(fzise, &buffer[0]);
	uprint("File size: ");
	uprintln(&buffer[0]);

	if (!CH376_closeFile(USBPORT))
		return 53;

	return 48;
}


int TestWritingFile()
{
	if (!CH376_init(USBPORT))
		return 49;

	if (!CH376_connectDrive(USBPORT))
		return 50;

	CH376_sendFileName(USBPORT, "/Y1.HTM");

	if (!CH376_createFile(USBPORT))
		return 51;

	CH376_sendFileName(USBPORT, "/Y1.HTM");

	if (!CH376_openFile(USBPORT))
		return 52;

	if (!CH376_setCursor(USBPORT, 0))
		return 53;

	if (!CH376_writeFile(USBPORT, "123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899100101102103104105106107108109110111112113114115116117118119120121122123124125126127128129130131132133134135136137138139140141142143144145146147148149150151152153154155156157158159160161162163164165166167168169170171172173174175176177178179180181182183184185186187188189190191192193194195196197198199200201202203204205206207208209210211212213214215216217218219220221222223224225226227228229230231232233234", 594))
		return 54;

	char buffer[10];
	int fzise = CH376_getFileSize(USBPORT);
	itoa(fzise, &buffer[0]);
	uprint("File size: ");
	uprintln(&buffer[0]);

	if (!CH376_closeFile(USBPORT))
		return 55;

	return 48;
}

int main() 
{
	CH376_printICver(USBPORT);
	//TestReadingFile();
	//TestCreatingFile();
	//TestWritingFile();
	return TestReadingFile();
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
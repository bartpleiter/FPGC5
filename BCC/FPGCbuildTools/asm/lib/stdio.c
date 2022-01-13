/*
* Very simple stdio library to read from or write to a single file
* implements a buffer for reading the input file
* Specially made for ASM, so it is kept very simple:
*  only one file can be open at the same time
*/

#define EOF -1

#define FOPEN_FILENAME_LIMIT 32

// Buffers for reading
// Length of buffer always should be less than 65536, since this is the maximum FS_readFile can do in a single call
#define STDIO_FBUF_LEN 4096
char *inputBuffer = (char*) STDIO_FBUF_ADDR; //inputBuffer[STDIO_FBUF_LEN];
word inbufStartPos = 0; // where in the file the buffer starts
word inbufCursor = 0; // where in the buffer we currently are working


// Opens file for reading
// requires full paths
// returns 1 on success
word fopenRead(const char* fname)
{
    if (strlen(fname) >= FOPEN_FILENAME_LIMIT)
    {
        BDOS_PrintConsole("E: Path too large\n");
        return 0;
    }

    if (fname[0] != '/')
    {
        BDOS_PrintConsole("E: Filename should be a full path\n");
        return 0;
    }

    FS_close(); // to be sure

    // convert to uppercase
    strToUpper(fname);

    // init read buffer
    inbufStartPos = 0; // start at 0
    inbufCursor = 0; // start at 0

    // if the resulting path is correct (can be file or directory)
    if (FS_sendFullPath(fname) == FS_ANSW_USB_INT_SUCCESS)
    {

        // if we can successfully open the file (not directory)
        if (FS_open() == FS_ANSW_USB_INT_SUCCESS)
        {
            FS_setCursor(0); // set cursor to start
            return 1;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }

    return 0;
}

// Opens file for writing
// requires full paths
// returns 1 on success
word fopenWrite(const char* fname)
{
    if (strlen(fname) >= FOPEN_FILENAME_LIMIT)
    {
        BDOS_PrintConsole("E: Path too large\n");
        return 0;
    }

    if (fname[0] != '/')
    {
        BDOS_PrintConsole("E: Filename should be a full path\n");
        return 0;
    }

    FS_close(); // to be sure

    // convert to uppercase
    strToUpper(fname);

    // if current path is correct (can be file or directory)
    if (FS_sendFullPath(fname) == FS_ANSW_USB_INT_SUCCESS)
    {
        // create the file
        
        if (FS_createFile() == FS_ANSW_USB_INT_SUCCESS)
        {
            //BDOS_PrintConsole("File created\n");
            // open again and start at 0
            FS_sendFullPath(fname);
            FS_open();
            FS_setCursor(0); // set cursor to start
            return 1;
        }
        else
        {
            BDOS_PrintConsole("E: Could not create file\n");
            return 0;
        }
    }
    else
    {
        BDOS_PrintConsole("E: Invalid path\n");
        return 0;
    }

    return 0;
}

// closes currently opened file
void fclose()
{

    FS_close();
}


// returns the current char at cursor (EOF if end of file)
// increments the cursor
word fgetc()
{
    // workaround for missing compiler check for ALU constants > 11 bit
    word stdioBufLen = STDIO_FBUF_LEN;

    if (inbufCursor >= STDIO_FBUF_LEN || inbufCursor == 0)  // we are at the end of the buffer (or it is not initialized yet)
    {
        // get filesize
        word sizeOfFile = FS_getFileSize();
        
        // if we cannot completely fill the buffer:
        if (inbufStartPos + stdioBufLen > sizeOfFile)
        {
            //  fill the buffer, and append with EOF token
            FS_readFile(inputBuffer, sizeOfFile - inbufStartPos, 0);
            inputBuffer[sizeOfFile - inbufStartPos] = EOF;
        }
        else
        {
            //  Fill buffer again
            FS_readFile(inputBuffer, STDIO_FBUF_LEN, 0);
        }
        
        inbufStartPos += stdioBufLen; // for the next fill

        inbufCursor = 0; // start at the beginning of the buffer again
    }

    // return from the buffer, and increment
    char gotchar = inputBuffer[inbufCursor];
    inbufCursor++;
    // BDOS_PrintcConsole(gotchar); // useful for debugging
    return gotchar;
}

word fputData(char* outbufAddr, word lenOfData)
{
    word bytesWritten = 0;

    // loop until all bytes are sent
    while (bytesWritten != lenOfData)
    {
        word partToSend = lenOfData - bytesWritten;
        // send in parts of 0xFFFF
        if (partToSend > 0xFFFF)
            partToSend = 0xFFFF;

        // write away
        if (FS_writeFile((outbufAddr +bytesWritten), partToSend) != FS_ANSW_USB_INT_SUCCESS)
            BDOS_PrintConsole("write error\n");

        // Update the amount of bytes sent
        bytesWritten += partToSend;
    }
}


/*
Prints a single char c by writing it to UART_TX_ADDR
*/
void uprintc(char c) 
{
  word *p = (word *)UART_TX_ADDR; // address of UART TX
  *p = (word)c;           // write char over UART
}


/*
Sends each character from str over UART
by writing them to UART_TX_ADDR
until a 0 value is found.
Does not send a newline afterwards.
*/
void uprint(char* str) 
{
  word *p = (word *)UART_TX_ADDR; // address of UART TX
  char chr = *str;        // first character of str

  while (chr != 0)        // continue until null value
  {
    *p = (word)chr;       // write char over UART
    str++;            // go to next character address
    chr = *str;         // get character from address
  }
}


/*
Same as uprint(char* str),
except it sends a newline afterwards.
*/
void uprintln(char* str) 
{
  uprint(str);
  uprintc('\n');
}

void exit(word i)
{
    asm("jump Return_BDOS\n");
}
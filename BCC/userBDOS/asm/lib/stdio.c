/*
* Stdio replacement library, modified from bcc
* Specially made for ASM
*/

// maximum number of files to open at the same time (+1 because we skip index 0)
#define FOPEN_MAX_FILES 16
#define FOPEN_FILENAME_LIMIT 32
#define EOF -1

#define OUTFILE_DATA_ADDR 0x500000

#define OUTFILE_PASS1_ADDR 0x540000

#define OUTFILE_PASS2_ADDR 0x580000

char fopenList[FOPEN_MAX_FILES][FOPEN_FILENAME_LIMIT]; // filenames for each opened file
word fopenCurrentlyOpen[FOPEN_MAX_FILES]; // which indexes are currently opened
word fopenCursors[FOPEN_MAX_FILES]; // cursors of currently opened files
word CH376CurrentlyOpened = 0; // index in fopenList which is currently opened on CH376

// Buffers for reading
// Length of buffer always should be less than 65536, since this is the maximum FS_readFile can do in a single call
#define STDIO_FBUF_LEN 4096
char inputBuffer[STDIO_FBUF_LEN];
word inbufStartPos = 0; // where in the file the buffer starts
word inbufCursor = 0; // where in the buffer we currently are working


// fopen replacement
// requires full paths
// returns 0 on error
// otherwise returns the index to the fopenList buffer
// append is not an option for now
word fopen(const char* fname)
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

    // conver to uppercase
    strToUpper(fname);

    
    FS_close();
    CH376CurrentlyOpened = 0;

    // init read buffer
    inbufStartPos = 0; // start at 0
    inbufCursor = 0; // start at 0

    word i = 1; // skip index 0
    while (i < FOPEN_MAX_FILES)
    {
        if (fopenCurrentlyOpen[i] == 0)
        {
            // found a free spot
            fopenCurrentlyOpen[i] = 1;
            fopenCursors[i] = 0;
            // write filename
            strcpy(fopenList[i], fname);

            return i; // return index
        }
        i++;
    }

    BDOS_PrintConsole("E: The maximum number of files are already opened. Forgot to close some files?\n");
    return 0;
}

// returns EOF if file cannot be opened
word fcanopen(word i)
{
    if (CH376CurrentlyOpened == i)
    {
        return 0;
    }

    FS_close();
    CH376CurrentlyOpened = 0;

    // if the resulting path is correct (can be file or directory)
    if (FS_sendFullPath(fopenList[i]) == FS_ANSW_USB_INT_SUCCESS)
    {

        // if we can successfully open the file (not directory)
        if (FS_open() == FS_ANSW_USB_INT_SUCCESS)
        {
            FS_close();
            return 0;
        }
        else
        {
            return EOF;
        }
    }
    else
    {
        return EOF;
    }

    return EOF;
}


// closes file at index
// also closes the file on CH376 if it is currently open there as well
void fclose(word i)
{
    if (CH376CurrentlyOpened == i)
    {
        FS_close(); // to be sure
        CH376CurrentlyOpened = 0;
    }

    fopenCurrentlyOpen[i] = 0;
    fopenList[i][0] = 0; // to be sure
}


// returns the current char at cursor (EOF if end of file)
// increments the cursor
word fgetc(word i)
{
    // check if file is open
    if (fopenCurrentlyOpen[i] == 0)
    {
        BDOS_PrintConsole("fgetc: File is not open\n");
        return EOF;
    }

    // open on CH376 if not open already
    if (CH376CurrentlyOpened != i)
    {
        // close last one first, unless there is no last
        if (CH376CurrentlyOpened != 0)
        {
            //BDOS_PrintConsole("fgetc: Closed previous file\n");
            FS_close();
        }


        // if the resulting path is correct (can be file or directory)
        if (FS_sendFullPath(fopenList[i]) == FS_ANSW_USB_INT_SUCCESS)
        {

            // if we can successfully open the file (not directory)
            if (FS_open() == FS_ANSW_USB_INT_SUCCESS)
            {
                CH376CurrentlyOpened = i;
                // set cursor to last position
                FS_setCursor(fopenCursors[i]);

                // reset the buffer
                inbufStartPos = fopenCursors[i];
                inbufCursor = 0;

                //BDOS_PrintConsole("fgetc: File opened on CH376\n");
            }
            else
            {
                BDOS_PrintConsole("E: Could not open file\n");
                return EOF;
            }
        }
        else
        {
            BDOS_PrintConsole("E: Invalid path\n");
            return EOF;
        }
    }

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
    fopenCursors[i]++;
    // BDOS_PrintcConsole(gotchar); // useful for debugging
    return gotchar;
}

word printf(char* s)
{
    BDOS_PrintConsole(s);
}

word printd(word d)
{
    if (d < 0)
    {
        BDOS_PrintcConsole('-');
        BDOS_PrintDecConsole(-d);
    }
    else
    {
        BDOS_PrintDecConsole(d);
    }
    
}

void exit(word i)
{
    asm("jump Return_BDOS\n");
}
/*
* Stdio replacement library
* Contains a subset of functions to use as drop-in replacement
* Specifically made for porting the BCC compiler
* Getc has a memory buffer, and puts is put entirely into memory
*/

// maximum number of files to open at the same time (+1 because we skip index 0)
#define FOPEN_MAX_FILES 16
#define FOPEN_FILENAME_LIMIT 32
#define EOF -1

#define FOPEN_OUTFILE_ADDR 0x500000

char fopenList[FOPEN_MAX_FILES][FOPEN_FILENAME_LIMIT]; // filenames for each opened file
word fopenCurrentlyOpen[FOPEN_MAX_FILES]; // which indexes are currently opened
word fopenCursors[FOPEN_MAX_FILES]; // cursors of currently opened files
word CH376CurrentlyOpened = 0; // index in fopenList which is currently opened on CH376

// Buffers for reading/writing
// Length of buffer always should be less than 65536, since this is the maximum FS_readFile can do in a single call
#define STDIO_FBUF_LEN 4096
char *inputBuffer = (char*) INPUTBUFFER_ADDR; //[STDIO_FBUF_LEN];
word inbufStartPos = 0; // where in the file the buffer starts
word inbufCursor = 0; // where in the buffer we currently are working

word outbufCursor = 0;
word outFileIndex = 0;

word includeDepth = 0; // keeping track how many levels we are deep compiling, for progress bar

// fopen replacement
// requires full paths
// returns 0 on error
// otherwise returns the index to the fopenList buffer
// creates new file if write is 1
// append is not an option for now
word fopen(const char* fname, const word write)
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

    // if write, create the file
    if (write)
    {
        outbufCursor = 0; // where in the buffer we currently are working

        FS_close(); // to be sure
        CH376CurrentlyOpened = 0;

        // if current path is correct (can be file or directory)
        if (FS_sendFullPath(fname) == FS_ANSW_USB_INT_SUCCESS)
        {
            // create the file
            
            if (FS_createFile() == FS_ANSW_USB_INT_SUCCESS)
            {
                //BDOS_PrintConsole("File created\n");
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
    }
    else // read
    {
        FS_close();
        CH376CurrentlyOpened = 0;

        // init read buffer
        inbufStartPos = 0; // start at 0
        inbufCursor = 0; // start at 0
    }

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

            // so we know which file is the output file
            if (write)
            {
                outFileIndex = i;
            }
            else
            {
                word x;
                for (x = 0; x < includeDepth; x++)
                {
                    BDOS_PrintConsole("-");
                }
                BDOS_PrintlnConsole(fname);
                includeDepth++;
            }
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

    // if output file, write entire buffer to the file
    if (outFileIndex == i && i > 0)
    {
        BDOS_PrintConsole("\nWriting to output file:\n");
        // close other file if open
        FS_close();
        CH376CurrentlyOpened = 0;

        // if the resulting path is correct (can be file or directory)
        if (FS_sendFullPath(fopenList[i]) == FS_ANSW_USB_INT_SUCCESS)
        {

            // if we can successfully open the file (not directory)
            if (FS_open() == FS_ANSW_USB_INT_SUCCESS)
            {
                FS_setCursor(0); // set cursor to start
                word bytesWritten = 0;
                word* outbufAddr = (word*) FOPEN_OUTFILE_ADDR;

                // loop until all bytes are sent
                while (bytesWritten != outbufCursor)
                {
                    word partToSend = outbufCursor - bytesWritten;
                    // send in parts of 0xFFFF
                    if (partToSend > 0xFFFF)
                        partToSend = 0xFFFF;

                    // write away
                    if (FS_writeFile((outbufAddr +bytesWritten), partToSend) != FS_ANSW_USB_INT_SUCCESS)
                        BDOS_PrintConsole("write error\n");

                    // Update the amount of bytes sent
                    bytesWritten += partToSend;

                    BDOS_PrintConsole(".");
                }
                BDOS_PrintConsole("\nDone!\n");
                FS_close();
            }
            else
            {
                BDOS_PrintConsole("E: could not open outfile\n");
                return;
            }
        }
        else
        {
            BDOS_PrintConsole("E: could not open outfile\n");
            return;
        }

        outFileIndex = 0;
    }
    else
    {
        includeDepth--;
        word x;
        for (x = 0; x < includeDepth; x++)
        {
            BDOS_PrintConsole("-");
        }
        BDOS_PrintlnConsole("Done");
    }

    fopenCurrentlyOpen[i] = 0;
    fopenList[i][0] = 0; // to be sure
}


// returns the current char at cursor (EOF is end of file)
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


// write to memory buffer
word fputs(word i, char* s)
{
    if (i != outFileIndex)
    {
        BDOS_PrintConsole("W: Writing to something else than outfile!\n");
    }
    word* outbufAddr = (word*) FOPEN_OUTFILE_ADDR;
    word slen = strlen(s);
    memcpy((outbufAddr +outbufCursor), s, slen);
    outbufCursor += slen;
    return 1;
}


// write to memory buffer
word fputc(word i, char c)
{
    if (i != outFileIndex)
    {
        BDOS_PrintConsole("W: Writing to something else than outfile!\n");
    }
    word* outbufAddr = (word*) FOPEN_OUTFILE_ADDR;
    *(outbufAddr +outbufCursor) = c;
    outbufCursor++;
    return 1;
}

int fgetpos(word i)
{
    if (i != outFileIndex)
    {
        BDOS_PrintConsole("W: Getting cursor for something else than outfile!\n");
    }
    return outbufCursor;
}

int fsetpos(word i, word c)
{
    if (i != outFileIndex)
    {
        BDOS_PrintConsole("W: Setting cursor for something else than outfile!\n");
    }
    outbufCursor = c;
    return 1;
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
#define word char

#include "lib/sys.c"
#include "lib/math.c" 
#include "lib/stdlib.c"
#include "lib/gfx.c"
#include "lib/fs.c"

// maximum number of files to open at the same time (+1 because we skip index 0)
#define FOPEN_MAX_FILES 16
#define FOPEN_FILENAME_LIMIT 32
#define EOF -1

char fopenList[FOPEN_MAX_FILES][FOPEN_FILENAME_LIMIT]; // filenames for each opened file
word fopenCurrentlyOpen[FOPEN_MAX_FILES]; // which indexes are currently opened
word fopenCursors[FOPEN_MAX_FILES]; // cursors of currently opened files
word CH376CurrentlyOpened = 0; // index in fopenList which is currently opened on CH376

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
        BDOS_PrintConsole("E: Filename too large\n");
        return 0;
    }

    if (fname[0] != '/')
    {
        BDOS_PrintConsole("E: Filename should be a full path\n");
        return 0;
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
            return i; // return index
        }
        i++;
    }
        BDOS_PrintConsole("E: The maximum number of files are already opened. Forgot to close some files?\n");
        return 0;
}


// closes file at index
// also closes the file on CH376 if it is currently open there as well
void fclose(word i)
{
    if (CH376CurrentlyOpened == i)
    {
        FS_close();
        CH376CurrentlyOpened = 0;
    }
    fopenCurrentlyOpen[i] = 0;
    fopenList[i][0] = 0; // to be sure
}


// returns the current char at cursor (EOF is end of file)
// increments the 
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

    // read char and increment cursor locally
    char gotchar = 0;
    word retval = FS_readFile(&gotchar, 1, 0);
    if (retval != FS_ANSW_USB_INT_SUCCESS)
    {
        // assume EOF
        return EOF;
    }

    fopenCursors[i]++;

    return gotchar;
}


int main() 
{

    BDOS_PrintConsole("Testing stdio implementation\n");

    char* file1 = "/test/file1.txt";
    char* file2 = "/test/file2.txt";

    word F1 = fopen(file1, 0);
    word F2 = fopen(file2, 0);


    word c = fgetc(F2);
    BDOS_PrintcConsole(c);
    while(c != '\'')
    {
        c = fgetc(F2);
        if (c == EOF)
            BDOS_PrintConsole("EOF!\n");
        else
            BDOS_PrintcConsole(c);
    }

    c = fgetc(F1);
    BDOS_PrintcConsole(c);
    while(c != 's')
    {
        c = fgetc(F1);
        if (c == EOF)
            BDOS_PrintConsole("EOF!\n");
        else
            BDOS_PrintcConsole(c);
    }

    c = fgetc(F2);
    BDOS_PrintcConsole(c);
    while(c != EOF)
    {
        c = fgetc(F2);
        if (c == EOF)
            BDOS_PrintConsole("EOF!\n");
        else
            BDOS_PrintcConsole(c);
    }

    c = fgetc(F1);
    BDOS_PrintcConsole(c);
    while(c != EOF)
    {
        c = fgetc(F1);
        if (c == EOF)
            BDOS_PrintConsole("EOF!\n");
        else
            BDOS_PrintcConsole(c);
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
}

void int3()
{
}

void int4()
{
}
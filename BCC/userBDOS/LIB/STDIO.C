/*
* Stdio replacement library
* Contains a subset of functions to use as drop-in replacement
* Originally made for porting the BCC compiler
* BDOS_PrintConsole could be replaced with uprint instead
*/

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
    FS_close(); // to be sure
    CH376CurrentlyOpened = 0;
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


// writes string s at cursor
// increments the cursor
// returns EOF on failure
// otherwise returns 1
word fputs(word i, char* s)
{
  // check if file is open
  if (fopenCurrentlyOpen[i] == 0)
  {
    BDOS_PrintConsole("fputs: File is not open\n");
    return EOF;
  }

  // open on CH376 if not open already
  if (CH376CurrentlyOpened != i)
  {
    // close last one first, unless there is no last
    if (CH376CurrentlyOpened != 0)
    {
      //BDOS_PrintConsole("fputs: Closed previous file\n");
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
        //BDOS_PrintConsole("fputs: File opened on CH376\n");
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

  // write string and increment cursor locally
  word slen = strlen(s);
  word retval = FS_writeFile(s, slen);
  if (retval != FS_ANSW_USB_INT_SUCCESS)
  {
    // assume EOF
    return EOF;
  }

  fopenCursors[i] += slen;

  return 1;
}


// fputs, but a single char
word fputc(word i, char c)
{
  char* s = "0";
  s[0] = c;
  return fputs(i, s);
}

word printf(char* s)
{
  //TODO: do escape character handling

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
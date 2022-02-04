// File move tool. Direct copy of CP but removes infile afterwards
// Currently not that efficient and reads entire file in memory
//  instead of doing it in chunks

/*
[x] check BDOS args for src and dst
[x] check src file is valid
[x] create dst file
[x] open src
[x] set cursor to start
[x] read chunk into mem
[x] close src
[x] open dst
[x] set cursor to start
[x] write mem into dst
[x] close dst
*/

#define word char

#include "LIB/MATH.C"
#include "LIB/SYS.C"
#include "LIB/STDLIB.C"
#include "LIB/FS.C"

char infilename[96];  // input filename
char outfilename[96];  // output filename


#define EOF -1
#define FOPEN_FILENAME_LIMIT 32
#define STDIO_FBUF_ADDR 0x420000
#define STDIO_MEMBUF_ADDR 0x440000
#define FOPEN_MAX_FILESIZE 0x200000 // 5 MiB

// Buffers for reading
// Length of buffer always should be less than 65536, since this is the maximum FS_readFile can do in a single call
#define STDIO_FBUF_LEN 32768
char *inputBuffer = (char*) STDIO_FBUF_ADDR; //inputBuffer[STDIO_FBUF_LEN];
word inbufStartPos = 0; // where in the file the buffer starts
word inbufCursor = 0; // where in the buffer we currently are working
word fileSize = 0; // size of input file

char *memBuf = (char*) STDIO_MEMBUF_ADDR; // where the entire input file is written to


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

      // get filesize
      fileSize = FS_getFileSize();
      word maxFileSize = FOPEN_MAX_FILESIZE;
      if (fileSize > maxFileSize)
      {
        BDOS_PrintConsole("E: File too large for memory\n");
        return 0;
      }

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


// reads all data from input file into memory
void readInFileToMem()
{
  word outputi = 0;
  char c = fgetc();
  // stop on EOF
  while (c != EOF)
  {
    memBuf[outputi] = c;
    outputi++;
    c = fgetc();
  }

  memBuf[outputi] = 0; // terminate
}


int main() 
{
  // output file
  BDOS_GetArgN(2, outfilename);

  if (outfilename[0] == 0)
  {
    BDOS_PrintConsole("E: Missing arguments\n");
    return 2;
  }

  // make full path if it is not already
  if (outfilename[0] != '/')
  {
    char bothPath[96];
    bothPath[0] = 0;
    strcat(bothPath, BDOS_GetPath());
    if (bothPath[strlen(bothPath)-1] != '/')
    {
      strcat(bothPath, "/");
    }
    strcat(bothPath, outfilename);
    strcpy(outfilename, bothPath);
  }

  // create output file, test if it can be created/opened
  if (!fopenWrite(outfilename))
  {
    BDOS_PrintConsole("Could not open output file\n");
    return 0;
  }
  fclose();



  // input file
  BDOS_GetArgN(1, infilename);

  // Default to out.asm
  if (infilename[0] == 0)
  {
    BDOS_PrintConsole("E: Missing arguments\n");
    return 2;
  }

  // Make full path if it is not already
  if (infilename[0] != '/')
  {
    char bothPath[96];
    bothPath[0] = 0;
    strcat(bothPath, BDOS_GetPath());
    if (bothPath[strlen(bothPath)-1] != '/')
    {
      strcat(bothPath, "/");
    }
    strcat(bothPath, infilename);
    strcpy(infilename, bothPath);
  }

  // Open the input file
  if (!fopenRead(infilename))
  {
    BDOS_PrintConsole("Cannot open input file\n");
    return 1;
  }

  // read into memory
  readInFileToMem();

  // write into file
  // write binary to output file
  if (!fopenWrite(outfilename))
  {
    BDOS_PrintConsole("Could not open output file\n");
    return 1;
  }
  fputData(memBuf, fileSize);
  fclose();

  // delete input file
  strToUpper(infilename);

  // if the resulting path is correct (can be file or directory)
  if (FS_sendFullPath(infilename) == FS_ANSW_USB_INT_SUCCESS)
  {
    // if we can successfully open the file (not directory)
    if (FS_open() == FS_ANSW_USB_INT_SUCCESS)
    {
      if (FS_delete() == FS_ANSW_USB_INT_SUCCESS)
      {
        return 'q';
      }
    }
  }

  BDOS_PrintConsole("Could not delete input file\n");
  return 3;
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
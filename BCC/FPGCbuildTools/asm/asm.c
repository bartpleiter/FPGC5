/*****************************************************************************/
/*                                                                           */
/*                           ASM (B322 Assembler)                            */
/*                                                                           */
/*                           Assembler for B322                              */
/*         Specifically made to assemble the output of BCC on FPGC           */
/*                   Assembles for userBDOS specifically                     */
/*                                                                           */
/*                                Main file                                  */
/*                                                                           */
/*****************************************************************************/

/* Notes:
- everything after the last \n is ignored, should not be a problem because wrapper
- does not support includes or other things that are not used when using BCC
- does not support asm defines, because of performance reasons
- also does not keep track of line numbers for errors and does less checks for errors
    since the input is from BCC and therefore has some kind of standard
*/

#define word char

#define STDIO_FBUF_ADDR 0x440000

#include "lib/math.c"
#include "lib/sys.c"
#include "lib/stdlib.c"
#include "lib/fs.c"
#include "lib/stdio.c"

#define USERBDOS_OFFSET 0x400000 // applied offset to all labels

#define OUTFILE_DATA_ADDR 0x500000
#define OUTFILE_CODE_ADDR 0x540000
#define OUTFILE_PASS1_ADDR 0x580000
#define OUTFILE_PASS2_ADDR 0x600000

#define LABELLISTLINENR_ADDR 0x65F000
#define LABELLIST_ADDR 0x660000

#define LINEBUFFER_ADDR 0x4C0000
char infilename[96];
char *lineBuffer = (char*) LINEBUFFER_ADDR;

word memCursor = 0; // cursor for readMemLine
word globalLineCursor = 0; // to keep track of the line number for labels

#define LABELLIST_SIZE 2048 // expecting a lot of labels! as of writing, BDOS has ~1000 TODO: 2048 when done
#define LABEL_NAME_SIZE 32 // max length of a label (therefore of a function name)

char (*labelListName)[LABEL_NAME_SIZE] = (char (*)[LABEL_NAME_SIZE]) LABELLIST_ADDR; // 2d array containing all lines of the input file
//char labelListName[LABELLIST_SIZE][LABEL_NAME_SIZE]; // old version, makes binary too large

word* labelListLineNumber = (word*) LABELLISTLINENR_ADDR;
//word labelListLineNumber[LABELLIST_SIZE]; // value should be the line number of the corresponding label name

word labelListIndex = 0; // current index in the label list
word prevLinesWereLabels = 0; // allows the current line to know how many labels are pointing to it

// reads a line from the input file, tries to remove all extra characters
word readFileLine()
{
    word foundStart = 0;
    word foundComment = 0;

    word outputi = 0;

    char c = fgetc();
    char cprev = c;
    // stop on EOF or newline
    while (c != EOF && c != '\n')
    {
        // if we have found a comment, ignore everything after
        if (c == ';')
        {
            foundComment = 1;
        }

        if (!foundComment)
        {
            // if we have not found the first non-space yet, ignore until a non-space
            if (!foundStart)
            {
                if (c == ' ')
                {
                    // do nothing until we find a non-space
                }
                else
                {
                    foundStart = 1;
                    lineBuffer[outputi] = c;
                    outputi++;
                }
            }
            else
            {
                if (cprev == ' ' && c == ' ')
                {
                    // ignore double space
                }
                else
                {
                    lineBuffer[outputi] = c;
                    outputi++;
                }
            }
        }
            
        
        cprev = c;
        c = fgetc();
    }

    lineBuffer[outputi] = 0; // terminate

    if (c == EOF)
    {
        if (lineBuffer[0] != 0)
        {
            // all code after the last \n is ignored!
            BDOS_PrintConsole("Skipped: ");
            BDOS_PrintConsole(lineBuffer);
            BDOS_PrintConsole("\n");
        }
        return EOF;
    }

    // if empty line, read next line
    if (outputi == 0)
    {
        return readFileLine();
    }
    else if (lineBuffer[outputi-1] == ' ')
    {
        // remove trailing space
        lineBuffer[outputi-1] = 0;
    }

    return 0;
}


// Reads a line from memory
// Assumes all extra characters are already processed
word readMemLine(char* memAddr)
{
    word outputi = 0;

    char c = memAddr[memCursor];
    memCursor++;
    while (c != 0 && c != '\n')
    {
        lineBuffer[outputi] = c;
        outputi++;
        c = memAddr[memCursor];
        memCursor++;
    }

    lineBuffer[outputi] = 0; // terminate

    // memory ends with a 0
    if (c == 0)
    {
        return EOF;
    }

    // if empty line, read next line
    if (outputi == 0)
    {
        BDOS_PrintConsole("Empty string in readMemLine!!!\n");
        return EOF;
    }

    return 0;
}


// Fills bufOut with argi in linebuffer
void getArgPos(word argi, char* bufOut)
{
    word linei = 0;
    char c = 0;
    word lineLength = strlen(lineBuffer);
    while(argi > 0 && linei < lineLength)
    {
        c = lineBuffer[linei];
        if (c == ' ')
        {
            argi--;
        }
        linei++;
    }
    if (linei == 0)
    {
        BDOS_PrintConsole("getArgPos error");
        exit(1);
    }
    // copy until space or \n
    word i = 0;
    c = lineBuffer[linei];
    while (c != ' ' && c != 0)
    {
        bufOut[i] = c;
        linei++;
        i++;
        c = lineBuffer[linei];
    }
    bufOut[i] = 0; // terminate
}


// parses the number at argument i in linebuffer
// can be hex or decimal or binary
word getNumberAtArg(word argi)
{
    word linei = 0;
    char c = 0;
    word lineLength = strlen(lineBuffer);
    while(argi > 0 && linei < lineLength)
    {
        c = lineBuffer[linei];
        if (c == ' ')
        {
            argi--;
        }
        linei++;
    }
    if (linei == 0)
    {
        BDOS_PrintConsole("NumberAtArg error");
        exit(1);
    }

    // linei is now at the start of the number string
    // copy until space or \n
    char strNumberBuf[36];
    word i = 0;
    c = lineBuffer[linei];
    while (c != ' ' && c != 0)
    {
        strNumberBuf[i] = c;
        linei++;
        i++;
        c = lineBuffer[linei];
    }
    strNumberBuf[i] = 0; // terminate

    word valueToReturn = 0;
    if (strNumberBuf[1] == 'x' || strNumberBuf[1] == 'X')
    {
        // hex number
        valueToReturn = hexToInt(strNumberBuf);
    }
    else if (strNumberBuf[1] == 'b' || strNumberBuf[1] == 'B')
    {
        // binary number
        valueToReturn = binToInt(strNumberBuf);
    }
    else
    {
        // dec number
        valueToReturn = decToInt(strNumberBuf);
    }

    return valueToReturn;
}


// returns 1 if the current line is a label
word isLabel()
{
    // loop until \0 or space
    word i = 0;
    while(lineBuffer[i] != 0 && lineBuffer[i] != ' ')
    {
        i++;
    }

    // empty line
    if (i == 0)
    {
        return 0;
    }

    // label if ends with :
    if (lineBuffer[i-1] == ':')
    {
        return 1;
    }

    return 0;
}

void Pass1StoreLabel()
{
    // loop until \0 or space
    word labelStrLen = 0;
    while(lineBuffer[labelStrLen] != 0 && lineBuffer[labelStrLen] != ' ')
    {
        labelStrLen++;
    }

    // store label name minus the :
    memcpy(labelListName[labelListIndex], lineBuffer, labelStrLen-1);
    // terminate
    labelListName[labelListIndex][labelStrLen-1] = 0;

    labelListIndex++;
    // labelListLineNumber will be set when the next instruction is found

    // notify next line that it has a label
    prevLinesWereLabels++;
}

void Pass1StoreDefine()
{
    // defines are not supported right now, so they are skipped
}

// Create two lines with the same args:
// loadLabelLow
// loadLabelHigh
// returns the number of lines added
word Pass1Addr2reg(char* outputAddr, char* outputCursor)
{
    word lineBufArgsLen = strlen(lineBuffer) - 9; // minus addr2len and space
    // copy name of instruction
    memcpy((outputAddr + *outputCursor), "loadLabelLow ", 13);
    (*outputCursor) += 13;
    // copy args
    memcpy((outputAddr + *outputCursor), (lineBuffer+9), lineBufArgsLen);
    (*outputCursor) += lineBufArgsLen;
    // add a newline
    *(outputAddr + *outputCursor) = '\n';
    (*outputCursor)++;

    // copy name of instruction
    memcpy((outputAddr + *outputCursor), "loadLabelHigh ", 14);
    (*outputCursor) += 14;
    // copy args
    memcpy((outputAddr + *outputCursor), (lineBuffer+9), lineBufArgsLen);
    (*outputCursor) += lineBufArgsLen;
    // add a newline
    *(outputAddr + *outputCursor) = '\n';
    (*outputCursor)++;

    return 2;
}

// Converts into load and loadhi
// skips loadhi if the value fits in 32bits
// returns the number of lines added
word Pass1Load32(char* outputAddr, char* outputCursor)
{
    // get the destination register
    char dstRegBuf[16];
    getArgPos(2, dstRegBuf);
    word dstRegBufLen = strlen(dstRegBuf);

    // get and parse the value that is being loaded
    word load32Value = getNumberAtArg(1);

    // split into 16 bit unsigned values
    word mask16Bit = 0xFFFF;
    word lowVal = load32Value & mask16Bit;
    word highVal = (load32Value >> 16) & mask16Bit;

    // add lowval
    char buf[16];
    itoa(lowVal, buf);
    word buflen = strlen(buf);
    // copy name of instruction
    memcpy((outputAddr + *outputCursor), "load ", 5);
    (*outputCursor) += 5;
    // copy value
    memcpy((outputAddr + *outputCursor), buf, buflen);
    (*outputCursor) += buflen;
    // add a space
    *(outputAddr + *outputCursor) = ' ';
    (*outputCursor)++;
    // copy destination register
    memcpy((outputAddr + *outputCursor), dstRegBuf, dstRegBufLen);
    (*outputCursor) += dstRegBufLen;
    // add a newline
    *(outputAddr + *outputCursor) = '\n';
    (*outputCursor)++;

    // add highval
    if (highVal) // skip if 0
    {
        itoa(highVal, buf);
        word buflen = strlen(buf);
        // copy name of instruction
        memcpy((outputAddr + *outputCursor), "loadhi ", 7);
        (*outputCursor) += 7;
        // copy value
        memcpy((outputAddr + *outputCursor), buf, buflen);
        (*outputCursor) += buflen;
        // add a space
        *(outputAddr + *outputCursor) = ' ';
        (*outputCursor)++;
        // copy destination register
        memcpy((outputAddr + *outputCursor), dstRegBuf, dstRegBufLen);
        (*outputCursor) += dstRegBufLen;
        // add a newline
        *(outputAddr + *outputCursor) = '\n';
        (*outputCursor)++;
        return 2;
    }

    return 1;
}

// Creates a single .dw line using numBuf as value
void addSingleDwLine(char* outputAddr, char* outputCursor, char* numBuf)
{
    word numBufLen = strlen(numBuf);
    // copy name of instruction
    memcpy((outputAddr + *outputCursor), ".dw ", 4);
    (*outputCursor) += 4;
    // copy value
    memcpy((outputAddr + *outputCursor), numBuf, numBufLen);
    (*outputCursor) += numBufLen;
    // add a newline
    *(outputAddr + *outputCursor) = '\n';
    (*outputCursor)++;
}

// Puts each value after .dw on its own line with its own .dw prefix
// returns the number of lines added
word Pass1Dw(char* outputAddr, char* outputCursor)
{
    word numberOfLinesAdded = 0;
    char numBuf[36]; // buffer to store each space separated number in
    word i = 0;
    word linei = 4; // index of linebuffer, start after .dw

    char c = lineBuffer[linei];
    while (c != 0)
    {
        if (c == ' ')
        {
            numBuf[i] = 0; // terminate
            addSingleDwLine(outputAddr, outputCursor, numBuf); // process number
            numberOfLinesAdded++;
            i = 0; // reset numBuf index
        }
        else
        {
            numBuf[i] = c;
            i++;
        }
        linei++;
        c = lineBuffer[linei];
    }

    numBuf[i] = 0; // terminate
    addSingleDwLine(outputAddr, outputCursor, numBuf); // process the final number
    numberOfLinesAdded++;

    return numberOfLinesAdded;
}

void Pass1Db(char* outputAddr, char* outputCursor)
{
    BDOS_PrintConsole(".DB is not yet implemented!\n");
    exit(1);
}


// Convert each line into the number of lines equal to the number of words in binary
// Also reads defines and processes labels
void LinePass1(char* outputAddr, char* outputCursor)
{
    // non-instructions
    if (memcmp(lineBuffer, "define ", 7))
    {
        Pass1StoreDefine();
    }
    else if (isLabel())
    {
        Pass1StoreLabel();
    }
    else
    {
        // all instructions that can end up in multiple lines

        // set values to the labels (while loop, since multiple labels can point to the same addr)
        while(prevLinesWereLabels > 0)
        {
            labelListLineNumber[labelListIndex - prevLinesWereLabels] = globalLineCursor;
            prevLinesWereLabels--;
        }

        if (memcmp(lineBuffer, "addr2reg ", 9))
        {
            globalLineCursor += Pass1Addr2reg(outputAddr, outputCursor);
        }
        else if (memcmp(lineBuffer, "load32 ", 7))
        {
            globalLineCursor += Pass1Load32(outputAddr, outputCursor);
        }
        else if (memcmp(lineBuffer, ".dw ", 4))
        {
            globalLineCursor += Pass1Dw(outputAddr, outputCursor);
        }
        else if (memcmp(lineBuffer, ".db ", 4))
        {
            Pass1Db(outputAddr, outputCursor);
        }
        else
        {
            // just copy the line
            word lineBufLen = strlen(lineBuffer);
            memcpy((outputAddr + *outputCursor), lineBuffer, lineBufLen);
            (*outputCursor) += lineBufLen;
            // add a newline
            *(outputAddr + *outputCursor) = '\n';
            (*outputCursor)++;
            globalLineCursor++;
        }
    }    
}

void doPass1()
{
    BDOS_PrintConsole("Doing pass 1\n");

    memCursor = 0; // reset cursor for readMemLine
    globalLineCursor = 0; // keep track of the line number for the labels

    char* outfileCodeAddr = (char*) OUTFILE_CODE_ADDR; // read from
    char* outfilePass1Addr = (char*) OUTFILE_PASS1_ADDR; // write to
    word filePass1Cursor = 0;

    // add userBDOS header instructions
    memcpy(outfilePass1Addr, "jump Main\njump Int1\njump Int2\njump Int3\njump Int4\n", 50);
    filePass1Cursor += 50;
    globalLineCursor += 5;

    while (readMemLine(outfileCodeAddr) != EOF)
    {
        LinePass1(outfilePass1Addr, &filePass1Cursor);
    }

    outfilePass1Addr[*(&filePass1Cursor)] = 0; // terminate

}

#include "pass2.c"

void LinePass2(char* outputAddr, char* outputCursor)
{
    // Go through all possible instructions:
    if (memcmp(lineBuffer, "halt", 4))
        pass2Halt(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "read ", 5))
        pass2Read(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "write ", 6))
        pass2Write(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "copy ", 5))
        pass2Copy(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "push ", 5))
        pass2Push(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "pop ", 4))
        pass2Pop(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "jump ", 5))
        pass2Jump(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "jumpo ", 6))
        pass2Jumpo(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "jumpr ", 6))
        pass2Jumpr(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "load ", 5))
        pass2Load(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "loadhi ", 7))
        pass2Loadhi(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "beq ", 4))
        pass2Beq(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "bne ", 4))
        pass2Bne(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "bgt ", 4))
        pass2Bgt(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "bge ", 4))
        pass2Bge(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "bgts ", 5))
        pass2Bgts(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "bges ", 5))
        pass2Bges(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "savpc ", 6))
        pass2Savpc(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "reti", 4))
        pass2Reti(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "or ", 3))
        pass2Or(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "and ", 4))
        pass2And(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "xor ", 4))
        pass2Xor(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "add ", 4))
        pass2Add(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "sub ", 4))
        pass2Sub(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "shiftl ", 7))
        pass2Shiftl(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "shiftr ", 7))
        pass2Shiftr(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "mult ", 5))
        pass2Mult(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "not ", 4))
        pass2Not(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "loadLabelLow ", 13))
        pass2LoadLabelLow(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "loadLabelHigh ", 14))
        pass2LoadLabelHigh(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "nop", 3))
        pass2Nop(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, ".dw ", 4))
        pass2Dw(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, ".dl ", 4))
        pass2Dl(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "readintid ", 10))
        pass2Readintid(outputAddr, outputCursor);
    else
    {
        BDOS_PrintConsole("Unknown instruction!\n");
        BDOS_PrintConsole(lineBuffer);
        BDOS_PrintConsole("\n");
        exit(1);
    }
}


// returns the length of the binary
word doPass2()
{
    BDOS_PrintConsole("Doing pass 2\n");

    memCursor = 0; // reset cursor for readMemLine

    char* outfilePass1Addr = (char*) OUTFILE_PASS1_ADDR; // read from
    char* outfilePass2Addr = (char*) OUTFILE_PASS2_ADDR; // write to
    word filePass2Cursor = 0;

    while (readMemLine(outfilePass1Addr) != EOF)
    {
        LinePass2(outfilePass2Addr, &filePass2Cursor);
    }

    return filePass2Cursor;
}


void moveDataDown()
{
    char* outfileDataAddr = (char*) OUTFILE_DATA_ADDR;
    *outfileDataAddr = 0; // initialize to 0
    word fileDataCursor = 0;

    char* outfileCodeAddr = (char*) OUTFILE_CODE_ADDR;
    *outfileCodeAddr = 0; // initialize to 0
    word fileCodeCursor = 0;

    BDOS_PrintConsole("Looking for .data and .code sections\n");

    // .data, also do pass one on the code
    word inDataSection = 0;
    word inCodeSection = 0;
    while (readFileLine() != EOF)
    {
        if (memcmp(lineBuffer, ".data", 5))
        {
            inDataSection = 1;
            inCodeSection = 0;
            continue; // skip this line
        }
        if (memcmp(lineBuffer, ".rdata", 6))
        {
            inDataSection = 0;
            inCodeSection = 0;
            continue; // skip this line
        }
        if (memcmp(lineBuffer, ".code", 5))
        {
            inDataSection = 0;
            inCodeSection = 1;
            continue; // skip this line
        }
        if (memcmp(lineBuffer, ".bss", 4))
        {
            inDataSection = 0;
            inCodeSection = 0;
            continue; // skip this line
        }


        if (inDataSection)
        {
            // copy to data section
            word lineBufLen = strlen(lineBuffer);
            memcpy((outfileDataAddr + fileDataCursor), lineBuffer, lineBufLen);
            fileDataCursor += lineBufLen;
            // add a newline
            *(outfileDataAddr + fileDataCursor) = '\n';
            fileDataCursor++;
        }

        if (inCodeSection)
        {
            // copy to code section
            word lineBufLen = strlen(lineBuffer);
            memcpy((outfileCodeAddr + fileCodeCursor), lineBuffer, lineBufLen);
            fileCodeCursor += lineBufLen;
            // add a newline
            *(outfileCodeAddr + fileCodeCursor) = '\n';
            fileCodeCursor++;
        }
    }

    *(outfileCodeAddr+fileCodeCursor) = 0; // terminate code section
    // do not increment the codeCursor, because we will append the data section

    BDOS_PrintConsole("Looking for .rdata and .bss sections\n");

    // reopen file to reiterate
    fclose();
    fopenRead(infilename);

    //.rdata and .bss at the same time
    inDataSection = 0;
    while (readFileLine() != EOF)
    {
        if (memcmp(lineBuffer, ".data", 5))
        {
            inDataSection = 0;
            continue; // skip this line
        }
        if (memcmp(lineBuffer, ".rdata", 6))
        {
            inDataSection = 1;
            continue; // skip this line
        }
        if (memcmp(lineBuffer, ".code", 5))
        {
            inDataSection = 0;
            continue; // skip this line
        }
        if (memcmp(lineBuffer, ".bss", 4))
        {
            inDataSection = 1;
            continue; // skip this line
        }

        if (inDataSection)
        {
            // copy to data section
            word lineBufLen = strlen(lineBuffer);
            memcpy((outfileDataAddr + fileDataCursor), lineBuffer, lineBufLen);
            fileDataCursor += lineBufLen;
            // add a newline
            *(outfileDataAddr + fileDataCursor) = '\n';
            fileDataCursor++;
        }
    }

    *(outfileDataAddr+fileDataCursor) = 0; // terminate data section
    fileDataCursor++;

    BDOS_PrintConsole("Appending all to .code section\n");

    // append data section to code section, including \0
    memcpy((outfileCodeAddr+fileCodeCursor), outfileDataAddr, fileDataCursor);
}


int main() 
{
    BDOS_PrintConsole("B322 Assembler\n");

    // output file

    char outfilename[96];
    BDOS_GetArgN(2, outfilename);

    // Default to a.out
    if (outfilename[0] == 0)
    {
        strcat(outfilename, BDOS_GetPath());
        if (outfilename[strlen(outfilename)-1] != '/')
        {
            strcat(outfilename, "/");
        }
        strcat(outfilename, "A.OUT");
    }

    // Make full path if it is not already
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
        BDOS_PrintConsole("Could not open outfile\n");
        return 0;
    }
    fclose();



    // input file

    BDOS_GetArgN(1, infilename);

    // Default to out.asm
    if (infilename[0] == 0)
    {
        strcat(infilename, BDOS_GetPath());
        if (infilename[strlen(infilename)-1] != '/')
        {
            strcat(infilename, "/");
        }
        strcat(infilename, "OUT.ASM");
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

    moveDataDown(); // move all data sections below the code sections

    fclose(); // done reading file, everything else can be done in memory

    doPass1();

    word pass2Length = doPass2();

    BDOS_PrintConsole("Writing to file\n");

    // write binary to output file
    if (!fopenWrite(outfilename))
    {
        BDOS_PrintConsole("Could not open outfile\n");
        return 0;
    }
    char* outfilePass2Addr = (char*) OUTFILE_PASS2_ADDR;
    fputData(outfilePass2Addr, pass2Length-1);
    fclose();
    
    return 0;
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
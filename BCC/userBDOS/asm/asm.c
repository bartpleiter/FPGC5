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
- also does not keep track of line numbers and does not check on errors that much
    since this is not really needed when the input is from BCC
*/

#define word char

#include "lib/math.c"
#include "lib/sys.c"
#include "lib/gfx.c"
#include "lib/stdlib.c"
#include "lib/fs.c"
#include "lib/stdio.c"


#define OUTFILE_DATA_ADDR 0x500000
#define OUTFILE_CODE_ADDR 0x540000
#define OUTFILE_PASS1_ADDR 0x580000

#define LINEBUFFER_ADDR 0x4C0000
char infilename[64];
char *lineBuffer = (char*) LINEBUFFER_ADDR;

word memCursor = 0; // cursor for readMemLine

#define LABELLIST_SIZE 1024 // expecting a lot of labels! as of writing, BDOS has ~1000 TODO: 2048 when done
#define LABEL_NAME_SIZE 32 // max length of a label (therefore of a function name)
char labelListName[LABELLIST_SIZE][LABEL_NAME_SIZE];
word labelListLineNumber[LABELLIST_SIZE]; // value should be the line number of the corresponding label name
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


// Returns the poition of argi in linebuffer
word getArgPos(word argi)
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

    return linei;
}


// parses the number at argument i in linebuffer
// can be hex or decimal
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
    char strNumberBuf[12];
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

    // store label name
    memcpy(labelListName[labelListIndex], lineBuffer, labelStrLen);
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
void Pass1Addr2reg(char* outputAddr, char* outputCursor)
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
}

// Converts into load and loadhi
// skips loadhi if the value fits in 32bits
void Pass1Load32(char* outputAddr, char* outputCursor)
{
    // get the destination register
    word linei = getArgPos(2); // linei is now at the start of the dst reg
    // copy until space or \n
    char dstRegBuf[12];
    word i = 0;
    char c = lineBuffer[linei];
    while (c != ' ' && c != 0)
    {
        dstRegBuf[i] = c;
        linei++;
        i++;
        c = lineBuffer[linei];
    }
    dstRegBuf[i] = 0; // terminate
    word dstRegBufLen = strlen(dstRegBuf);

    // get and parse the value that is being loaded
    word load32Value = getNumberAtArg(1);

    // split into 16 bit unsigned values
    word mask16Bit = 0xFFFF;
    word lowVal = load32Value & mask16Bit;
    word highVal = (load32Value >> 16) & mask16Bit;

    // add lowval
    char buf[10];
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
    }
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
void Pass1Dw(char* outputAddr, char* outputCursor)
{
    char numBuf[12]; // buffer to store each space separated number in
    word i = 0;
    word linei = 4; // index of linebuffer, start after .dw

    char c = lineBuffer[linei];
    while (c != 0)
    {
        if (c == ' ')
        {
            numBuf[i] = 0; // terminate
            addSingleDwLine(outputAddr, outputCursor, numBuf); // process number
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
}

void Pass1Db(char* outputAddr, char* outputCursor)
{
    BDOS_PrintConsole(".DB is not yet implemented!\n");
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
            labelListLineNumber[labelListIndex - prevLinesWereLabels] = *outputCursor;
            prevLinesWereLabels--;
        }

        if (memcmp(lineBuffer, "addr2reg ", 9))
        {
            Pass1Addr2reg(outputAddr, outputCursor);
        }
        else if (memcmp(lineBuffer, "load32 ", 7))
        {
            Pass1Load32(outputAddr, outputCursor);
        }
        else if (memcmp(lineBuffer, ".dw ", 4))
        {
            Pass1Dw(outputAddr, outputCursor);
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
        }
    }

    
}

void doPass1()
{
    BDOS_PrintConsole("Doing pass 1\n");

    memCursor = 0; // reset cursor for readMemLine

    char* outfileCodeAddr = (char*) OUTFILE_CODE_ADDR; // read from
    char* outfilePass1Addr = (char*) OUTFILE_PASS1_ADDR; // write to
    word filePass1Cursor = 0;

    while (readMemLine(outfileCodeAddr) != EOF)
    {
        LinePass1(outfilePass1Addr, &filePass1Cursor);
    }

    outfilePass1Addr[*(&filePass1Cursor)] = 0; // terminate
}

void doPass2(char* outputAddr, char* outputCursor)
{
    /*
    // Go through all possible instructions:
    if (memcmp(lineBuffer, "halt ", 5))
        processHalt(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "read ", 5))
        processRead(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "write ", 6))
        processWrite(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "copy ", 5))
        processCopy(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "push ", 5))
        processPush(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "pop ", 4))
        processPop(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "jump ", 5))
        processJump(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "jumpo ", 6))
        processJumpo(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "jumpr ", 6))
        processJumpr(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "jumpro ", 7))
        processJumpro(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "load ", 5))
        processLoad(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "loadhi ", 7))
        processLoadhi(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "beq ", 4))
        processBeq(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "bne ", 4))
        processBne(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "bgt ", 4))
        processBgt(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "bge ", 4))
        processBge(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "bgts ", 5))
        processBgts(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "bges ", 5))
        processBges(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "savpc ", 6))
        processSavpc(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "reti ", 5))
        processReti(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "or ", 3))
        processOr(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "and ", 4))
        processAnd(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "xor ", 4))
        processXor(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "add ", 4))
        processAdd(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "sub ", 4))
        processSub(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "shiftl ", 7))
        processShiftl(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "shiftr ", 7))
        processShiftr(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "mult ", 5))
        processMult(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "not ", 4))
        processNot(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "addr2reg ", 9))
        processAddr2reg(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "load32 ", 7))
        processLoad32(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "nop ", 4))
        processNop(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, ".dw ", 4))
        processDw(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, ".dl ", 4))
        processDl(outputAddr, outputCursor);
    else if (memcmp(lineBuffer, "readintid ", 10))
        processReadintid(outputAddr, outputCursor);
    else
    {
        processLabel(outputAddr, outputCursor);
    }
    */
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

    // create output file, test if it can be created/opened
    if (!fopenWrite("/ASM.OUT"))
    {
        BDOS_PrintConsole("Could not open outfile\n");
        return 0;
    }
    fclose();

    //BDOS_GetArgN(1, infilename);
    infilename[0] = 0;

    // Default to out.asm
    if (infilename[0] == 0)
    {
        strcat(infilename, BDOS_GetPath());
        if (infilename[strlen(infilename)-1] != '/')
        {
            strcat(infilename, "/");
        }
        strcat(infilename, "C/ASM/OUT.ASM");
    }

    // Make full path if it is not already
    if (infilename[0] != '/')
    {
        char bothPath[64];
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

    BDOS_PrintConsole("Writing to file\n");
    // write to output file
    if (!fopenWrite("/ASM.OUT"))
    {
        BDOS_PrintConsole("Could not open outfile\n");
        return 0;
    }
    char* outfilePass1Addr = (char*) OUTFILE_PASS1_ADDR;
    fputs(outfilePass1Addr);
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
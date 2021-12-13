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

#define word char

#include "lib/math.c"
#include "lib/sys.c"
#include "lib/gfx.c"
#include "lib/stdlib.c"
#include "lib/fs.c"
#include "lib/stdio.c"

#define LINEBUFFER_ADDR 0x4C0000

char infilename[64];

char *lineBuffer = (char*) LINEBUFFER_ADDR;

word infileIndex = 0;


void processHalt(char* outputAddr, char* outputCursor)
{
    
}


void doPass1(char* outputAddr, char* outputCursor)
{
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
}


// reads a line, tries to remove all extra characters
word readLine()
{
    word foundStart = 0;

    word inputi = 0;
    word outputi = 0;

    char c = fgetc(infileIndex);
    char cprev = c;
    // stop on EOF, newline or comment
    while (c != EOF && c != '\n' && c != ';')
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
        
        inputi++;
        cprev = c;
        c = fgetc(infileIndex);
    }

    lineBuffer[outputi] = 0; // terminate

    if (c == EOF)
    {
        return EOF;
    }

    // if empty line, read next line
    if (outputi == 0)
    {
        return readLine();
    }

    return 0;
}

void moveAndPass1()
{
    char* outfileDataAddr = (char*) OUTFILE_DATA_ADDR;
    *outfileDataAddr = 0; // initialize to 0
    word fileDataCursor = 0;

    char* outfileCodeAddr = (char*) OUTFILE_PASS1_ADDR;
    *outfileCodeAddr = 0; // initialize to 0
    word fileCodeCursor = 0;

    // .data, also do pass one on the code
    word inDataSection = 0;
    word inCodeSection = 0;
    while (readLine() != EOF)
    {
        if (memcmp(lineBuffer, ".data", 5))
        {
            inDataSection = 1;
            inCodeSection = 0;
        }
        if (memcmp(lineBuffer, ".rdata", 6))
        {
            inDataSection = 0;
            inCodeSection = 0;
        }
        if (memcmp(lineBuffer, ".code", 5))
        {
            inDataSection = 0;
            inCodeSection = 1;
        }
        if (memcmp(lineBuffer, ".bss", 4))
        {
            inDataSection = 0;
            inCodeSection = 0;
        }

        if (inDataSection)
        {
            doPass1(outfileDataAddr, &fileDataCursor);
            /*word lineCursor = 0;
            char c = *(lineBuffer+lineCursor);
            while(c != 0)
            {
                *(outfileDataAddr+fileCursor) = c;
                fileCursor++;
                lineCursor++;
                c = *(lineBuffer+lineCursor);
            }
            *(outfileDataAddr+fileCursor) = '\n'; // add newline
            fileCursor++;
            */
        }

        if (inCodeSection)
        {
            doPass1(outfileCodeAddr, &fileCodeCursor);
        }
    }
    BDOS_PrintConsole("Done with finding .data and pass1\n");

    *(outfileCodeAddr+fileCodeCursor) = 0; // terminate

    // reopen file to reiterate
    fclose(infileIndex);
    infileIndex = fopen(infilename);

    //.rdata and .bss at the same time
    inDataSection = 0;
    while (readLine() != EOF)
    {
        if (memcmp(lineBuffer, ".data", 5))
        {
            inDataSection = 0;
        }
        if (memcmp(lineBuffer, ".rdata", 6))
        {
            inDataSection = 1;
        }
        if (memcmp(lineBuffer, ".code", 5))
        {
            inDataSection = 0;
        }
        if (memcmp(lineBuffer, ".bss", 4))
        {
            inDataSection = 1;
        }

        if (inDataSection)
        {
            doPass1(outfileDataAddr, &fileDataCursor);
        }
    }
    BDOS_PrintConsole("Done with finding .rdata and .bss\n");

    *(outfileDataAddr+fileDataCursor) = 0; // terminate
}


int main() 
{
    BDOS_PrintConsole("B322 Assembler\n");

    BDOS_GetArgN(1, infilename);

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

    // Open the file
    infileIndex = fopen(infilename);
    if (fcanopen(infileIndex) == EOF)
    {
        BDOS_PrintConsole("Cannot open input file\n");
        return 1;
    }


    moveAndPass1();

    fclose(infileIndex);




    // TODO: append outfileDataAddr to the output file

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
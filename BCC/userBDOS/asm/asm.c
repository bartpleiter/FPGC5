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

void moveDataDown()
{
    word inDataSection = 0;
    while (readLine() != EOF)
    {
        if (memcmp(lineBuffer, ".data", 5))
        {
            inDataSection = 1;
        }
        if (memcmp(lineBuffer, ".rdata", 6))
        {
            inDataSection = 0;
        }
        if (memcmp(lineBuffer, ".code", 5))
        {
            inDataSection = 0;
        }
        if (memcmp(lineBuffer, ".bss", 4))
        {
            inDataSection = 0;
        }

        if (inDataSection)
        {
            BDOS_PrintlnConsole(lineBuffer);
        }
    }

    fclose(infileIndex);
    infileIndex = fopen(infilename, 0);
    BDOS_PrintConsole("Done with finding .data\n");
}

void moveRdataDown()
{
    word inDataSection = 0;
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
            inDataSection = 0;
        }

        if (inDataSection)
        {
            BDOS_PrintlnConsole(lineBuffer);
        }
    }

    fclose(infileIndex);
    infileIndex = fopen(infilename, 0);
    BDOS_PrintConsole("Done with finding .rdata\n");
}

void moveBssDown()
{
    word inDataSection = 0;
    while (readLine() != EOF)
    {
        if (memcmp(lineBuffer, ".data", 5))
        {
            inDataSection = 0;
        }
        if (memcmp(lineBuffer, ".rdata", 6))
        {
            inDataSection = 0;
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
            BDOS_PrintlnConsole(lineBuffer);
        }
    }

    fclose(infileIndex);
    infileIndex = fopen(infilename, 0);
    BDOS_PrintConsole("Done with finding .bss\n");
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
        strcat(infilename, "OUT.ASM");
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
    infileIndex = fopen(infilename, 0);
    if (fcanopen(infileIndex) == EOF)
    {
        BDOS_PrintConsole("Cannot open input file\n");
        return 1;
    }


    moveDataDown();
    moveRdataDown();
    moveBssDown();
    

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
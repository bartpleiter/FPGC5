/*****************************************************************************/
/*                                                                           */
/*                           ASM (B322 Assembler)                            */
/*                                                                           */
/*                           Assembler for B322                              */
/*                      Contains all pass 2 functions                        */
/*                                                                           */
/*****************************************************************************/

word getNumberForLabel(char* labelName)
{
    word bdosOffset = USERBDOS_OFFSET;
    word i;
    for (i = 0; i < labelListIndex; i++)
    {
        if (strcmp(labelName, labelListName[i]) == 0)
        {
            return (labelListLineNumber[i] + bdosOffset);
        }
    }
    BDOS_PrintConsole("Could not find label: ");
    BDOS_PrintConsole(labelName);
    BDOS_PrintConsole("\n");
    exit(1);
    return 0;
}

// Convert a 32 bit word into an array of 4 bytes
void instrToByteArray(word instr, char* byteArray)
{
    byteArray[0] = (instr >> 24) & 0xFF;
    byteArray[1] = (instr >> 16) & 0xFF;
    byteArray[2] = (instr >> 8) & 0xFF;
    byteArray[3] = instr & 0xFF;
}

void pass2Halt(char* outputAddr, char* outputCursor)
{
    char instr[4] = {0xff, 0xff, 0xff, 0xff};
    memcpy((outputAddr + *outputCursor), instr, 4);
    (*outputCursor) += 4;
}

void pass2Read(char* outputAddr, char* outputCursor)
{
    word instr = 0xE0000000;

    word arg1num = getNumberAtArg(1);
    word negative = 0;
    if (arg1num < 0)
    {
        negative = 1;
        arg1num = -arg1num;
    }

    // arg1 should fit in 16 bits
    if ((arg1num >> 16) > 0)
    {
        BDOS_PrintConsole("READ: arg1 is >16 bits\n");
        exit(1);
    }

    instr += (arg1num << 12);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("READ: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += (arg2num << 8);

    // arg3
    char arg3buf[16];
    getArgPos(3, arg3buf);
    // arg3 should be a reg
    if (arg3buf[0] != 'r')
    {
        BDOS_PrintConsole("READ: arg3 not a reg\n");
        exit(1);
    }
    word arg3num = strToInt(&arg3buf[1]);

    instr += arg3num;

    if (negative)
    {
        instr ^= (1 << 5);
    }

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Write(char* outputAddr, char* outputCursor)
{
    word instr = 0xD0000000;

    word arg1num = getNumberAtArg(1);
    word negative = 0;
    if (arg1num < 0)
    {
        negative = 1;
        arg1num = -arg1num;
    }

    // arg1 should fit in 16 bits
    if ((arg1num >> 16) > 0)
    {
        BDOS_PrintConsole("WRITE: arg1 is >16 bits\n");
        exit(1);
    }

    instr += (arg1num << 12);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("WRITE: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += (arg2num << 8);

    // arg3
    char arg3buf[16];
    getArgPos(3, arg3buf);
    // arg3 should be a reg
    if (arg3buf[0] != 'r')
    {
        BDOS_PrintConsole("WRITE: arg3 not a reg\n");
        exit(1);
    }
    word arg3num = strToInt(&arg3buf[1]);

    instr += (arg3num << 4);

    if (negative)
    {
        instr ^= 1;
    }

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Copy(char* outputAddr, char* outputCursor)
{
    word instr = 0xC0000000;

    word arg1num = getNumberAtArg(1);
    word negative = 0;
    if (arg1num < 0)
    {
        negative = 1;
        arg1num = -arg1num;
    }

    // arg1 should fit in 16 bits
    if ((arg1num >> 16) > 0)
    {
        BDOS_PrintConsole("COPY: arg1 is >16 bits\n");
        exit(1);
    }

    instr += (arg1num << 12);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("COPY: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += (arg2num << 8);

    // arg3
    char arg3buf[16];
    getArgPos(3, arg3buf);
    // arg3 should be a reg
    if (arg3buf[0] != 'r')
    {
        BDOS_PrintConsole("COPY: arg3 not a reg\n");
        exit(1);
    }
    word arg3num = strToInt(&arg3buf[1]);

    instr += (arg3num << 4);

    if (negative)
    {
        instr ^= 1;
    }

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Push(char* outputAddr, char* outputCursor)
{
    word instr = 0xB0000000;

    // arg1
    char arg1buf[16];
    getArgPos(1, arg1buf);
    // arg1 should be a reg
    if (arg1buf[0] != 'r')
    {
        BDOS_PrintConsole("PUSH: arg1 not a reg\n");
        exit(1);
    }
    word arg1num = strToInt(&arg1buf[1]);

    instr += (arg1num << 4);

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Pop(char* outputAddr, char* outputCursor)
{
    word instr = 0xA0000000;

    // arg1
    char arg1buf[16];
    getArgPos(1, arg1buf);
    // arg1 should be a reg
    if (arg1buf[0] != 'r')
    {
        BDOS_PrintConsole("POP: arg1 not a reg\n");
        exit(1);
    }
    word arg1num = strToInt(&arg1buf[1]);

    instr += arg1num;

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Jump(char* outputAddr, char* outputCursor)
{
    word instr = 0x90000000;
    
    // check if jump to label
    // if yes, replace label with line number
    char arg1buf[LABEL_NAME_SIZE+1];
    getArgPos(1, arg1buf);
    word arg1bufLen = strlen(arg1buf);
    word argIsLabel = 0;
    word i;
    for (i = 0; i < arg1bufLen; i++)
    {
        if (arg1buf[i] < '0' || arg1buf[i] > '9')
        {
            argIsLabel = 1;
            break;
        }
    }

    word arg1num = 0;
    if (argIsLabel)
    {
        arg1num = getNumberForLabel(arg1buf);
    }
    else
    {
        arg1num = getNumberAtArg(1);
    }

    // arg1 should fit in 27 bits
    if ((arg1num >> 27) > 0)
    {
        BDOS_PrintConsole("JUMPO: arg1 is >27 bits\n");
        exit(1);
    }

    instr += (arg1num << 1);

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Jumpo(char* outputAddr, char* outputCursor)
{
    word instr = 0x90000000;

    word arg1num = getNumberAtArg(1);

    // arg1 should fit in 27 bits
    if ((arg1num >> 27) > 0)
    {
        BDOS_PrintConsole("JUMPO: arg1 is >27 bits\n");
        exit(1);
    }

    instr += (arg1num << 1);
    instr ^= 1;

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Jumpr(char* outputAddr, char* outputCursor)
{
    word instr = 0x80000000;

    word arg1num = getNumberAtArg(1);

    // arg1 should fit in 16 bits
    if ((arg1num >> 16) > 0)
    {
        BDOS_PrintConsole("JUMPR: arg1 is >16 bits\n");
        exit(1);
    }

    instr += (arg1num << 12);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("JUMPR: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += (arg2num << 4);

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Load(char* outputAddr, char* outputCursor)
{
    word instr = 0x70000000;

    word arg1num = getNumberAtArg(1);

    // arg1 should fit in 16 bits
    if ((arg1num >> 16) > 0)
    {
        BDOS_PrintConsole("LOAD: arg1 is >16 bits\n");
        exit(1);
    }

    instr += (arg1num << 12);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("LOAD: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += arg2num;

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Loadhi(char* outputAddr, char* outputCursor)
{
    word instr = 0x70000000;

    word arg1num = getNumberAtArg(1);

    // arg1 should fit in 16 bits
    if ((arg1num >> 16) > 0)
    {
        BDOS_PrintConsole("LOADHI: arg1 is >16 bits\n");
        exit(1);
    }

    instr += (arg1num << 12);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("LOADHI: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += arg2num;

    instr ^= (1 << 8);

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Beq(char* outputAddr, char* outputCursor)
{
    word instr = 0x60000000;

    // arg1
    char arg1buf[16];
    getArgPos(1, arg1buf);
    // arg1 should be a reg
    if (arg1buf[0] != 'r')
    {
        BDOS_PrintConsole("BEQ: arg1 not a reg\n");
        exit(1);
    }
    word arg1num = strToInt(&arg1buf[1]);

    instr += (arg1num << 8);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("BEQ: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += (arg2num << 4);


    // arg3
    word arg3num = getNumberAtArg(3);

    // arg3 should fit in 16 bits
    if ((arg3num >> 16) > 0)
    {
        BDOS_PrintConsole("BEQ: arg3 is >16 bits\n");
        exit(1);
    }

    instr += (arg3num << 12);

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Bne(char* outputAddr, char* outputCursor)
{
    word instr = 0x50000000;

    // arg1
    char arg1buf[16];
    getArgPos(1, arg1buf);
    // arg1 should be a reg
    if (arg1buf[0] != 'r')
    {
        BDOS_PrintConsole("BNE: arg1 not a reg\n");
        exit(1);
    }
    word arg1num = strToInt(&arg1buf[1]);

    instr += (arg1num << 8);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("BNE: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += (arg2num << 4);


    // arg3
    word arg3num = getNumberAtArg(3);

    // arg3 should fit in 16 bits
    if ((arg3num >> 16) > 0)
    {
        BDOS_PrintConsole("BNE: arg3 is >16 bits\n");
        exit(1);
    }

    instr += (arg3num << 12);

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Bgt(char* outputAddr, char* outputCursor)
{
    word instr = 0x40000000;

    // arg1
    char arg1buf[16];
    getArgPos(1, arg1buf);
    // arg1 should be a reg
    if (arg1buf[0] != 'r')
    {
        BDOS_PrintConsole("BGT: arg1 not a reg\n");
        exit(1);
    }
    word arg1num = strToInt(&arg1buf[1]);

    instr += (arg1num << 8);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("BGT: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += (arg2num << 4);


    // arg3
    word arg3num = getNumberAtArg(3);

    // arg3 should fit in 16 bits
    if ((arg3num >> 16) > 0)
    {
        BDOS_PrintConsole("BGT: arg3 is >16 bits\n");
        exit(1);
    }

    instr += (arg3num << 12);

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Bge(char* outputAddr, char* outputCursor)
{
    word instr = 0x30000000;

    // arg1
    char arg1buf[16];
    getArgPos(1, arg1buf);
    // arg1 should be a reg
    if (arg1buf[0] != 'r')
    {
        BDOS_PrintConsole("BGE: arg1 not a reg\n");
        exit(1);
    }
    word arg1num = strToInt(&arg1buf[1]);

    instr += (arg1num << 8);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("BGE: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += (arg2num << 4);


    // arg3
    word arg3num = getNumberAtArg(3);

    // arg3 should fit in 16 bits
    if ((arg3num >> 16) > 0)
    {
        BDOS_PrintConsole("BGE: arg3 is >16 bits\n");
        exit(1);
    }

    instr += (arg3num << 12);

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Bgts(char* outputAddr, char* outputCursor)
{
    word instr = 0x40000000;

    // arg1
    char arg1buf[16];
    getArgPos(1, arg1buf);
    // arg1 should be a reg
    if (arg1buf[0] != 'r')
    {
        BDOS_PrintConsole("BGTS: arg1 not a reg\n");
        exit(1);
    }
    word arg1num = strToInt(&arg1buf[1]);

    instr += (arg1num << 8);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("BGTS: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += (arg2num << 4);


    // arg3
    word arg3num = getNumberAtArg(3);

    // arg3 should fit in 16 bits
    if ((arg3num >> 16) > 0)
    {
        BDOS_PrintConsole("BGTS: arg3 is >16 bits\n");
        exit(1);
    }

    instr += (arg3num << 12);

    instr ^= 1;

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Bges(char* outputAddr, char* outputCursor)
{
    word instr = 0x30000000;

    // arg1
    char arg1buf[16];
    getArgPos(1, arg1buf);
    // arg1 should be a reg
    if (arg1buf[0] != 'r')
    {
        BDOS_PrintConsole("BGES: arg1 not a reg\n");
        exit(1);
    }
    word arg1num = strToInt(&arg1buf[1]);

    instr += (arg1num << 8);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("BGES: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += (arg2num << 4);


    // arg3
    word arg3num = getNumberAtArg(3);

    // arg3 should fit in 16 bits
    if ((arg3num >> 16) > 0)
    {
        BDOS_PrintConsole("BGES: arg3 is >16 bits\n");
        exit(1);
    }

    instr += (arg3num << 12);

    instr ^= 1;

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Savpc(char* outputAddr, char* outputCursor)
{
    word instr = 0x20000000;

    // arg1
    char arg1buf[16];
    getArgPos(1, arg1buf);
    // arg1 should be a reg
    if (arg1buf[0] != 'r')
    {
        BDOS_PrintConsole("SAVPC: arg1 not a reg\n");
        exit(1);
    }
    word arg1num = strToInt(&arg1buf[1]);

    instr += arg1num;

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Reti(char* outputAddr, char* outputCursor)
{
    char instr[4] = {0x10, 0x00, 0x00, 0x00};
    memcpy((outputAddr + *outputCursor), instr, 4);
    (*outputCursor) += 4;
}

void pass2ArithBase(char* outputAddr, char* outputCursor, word arithOpCode)
{
    word instr = 0;

    instr += (arithOpCode << 23);

    // arg1
    char arg1buf[16];
    getArgPos(1, arg1buf);
    // arg1 should be a reg
    if (arg1buf[0] != 'r')
    {
        BDOS_PrintConsole("ARITH: arg1 not a reg\n");
        exit(1);
    }
    word arg1num = strToInt(&arg1buf[1]);

    instr += (arg1num << 8);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    word arg2num = 0;
    // if arg2 is a const
    if (arg2buf[0] != 'r')
    {
        arg2num= getNumberAtArg(2);

        // arg1 should fit in 11 bits
        if ((arg2num >> 11) > 0)
        {
            BDOS_PrintConsole("ARITH: const is >11 bits\n");
            exit(1);
        }

        instr += (arg2num << 12);
        instr ^= (1 << 27); // set constant bit
    }
    else // arg2 is a reg
    {
        arg2num = strToInt(&arg2buf[1]);
        instr += (arg2num << 4);
    }

    // arg3
    char arg3buf[16];
    getArgPos(3, arg3buf);
    // arg3 should be a reg
    if (arg3buf[0] != 'r')
    {
        BDOS_PrintConsole("ARITH: arg3 not a reg\n");
        exit(1);
    }
    word arg3num = strToInt(&arg3buf[1]);

    instr += arg3num;

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Or(char* outputAddr, char* outputCursor)
{
    pass2ArithBase(outputAddr, outputCursor, 0x0);
}

void pass2And(char* outputAddr, char* outputCursor)
{
    pass2ArithBase(outputAddr, outputCursor, 0x1);
}

void pass2Xor(char* outputAddr, char* outputCursor)
{
    pass2ArithBase(outputAddr, outputCursor, 0x2);
}

void pass2Add(char* outputAddr, char* outputCursor)
{
    pass2ArithBase(outputAddr, outputCursor, 0x3);
}

void pass2Sub(char* outputAddr, char* outputCursor)
{
    pass2ArithBase(outputAddr, outputCursor, 0x4);
}

void pass2Shiftl(char* outputAddr, char* outputCursor)
{
    pass2ArithBase(outputAddr, outputCursor, 0x5);
}

void pass2Shiftr(char* outputAddr, char* outputCursor)
{
    pass2ArithBase(outputAddr, outputCursor, 0x6);
}

void pass2Mult(char* outputAddr, char* outputCursor)
{
    pass2ArithBase(outputAddr, outputCursor, 0x7);
}

void pass2Not(char* outputAddr, char* outputCursor)
{
    pass2ArithBase(outputAddr, outputCursor, 0x8);
}

void pass2LoadLabelLow(char* outputAddr, char* outputCursor)
{
    word instr = 0x70000000;

    char arg1buf[LABEL_NAME_SIZE+1];
    getArgPos(1, arg1buf);
    word arg1num = getNumberForLabel(arg1buf);

    // only use the lowest 16 bits
    arg1num = arg1num << 16;
    arg1num = arg1num >> 16;

    instr += (arg1num << 12);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("LOADLABELLOW: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += arg2num;

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2LoadLabelHigh(char* outputAddr, char* outputCursor)
{
    word instr = 0x70000000;

    char arg1buf[LABEL_NAME_SIZE+1];
    getArgPos(1, arg1buf);
    word arg1num = getNumberForLabel(arg1buf);

    // only use the highest 16 bits
    arg1num = arg1num >> 16;

    instr += (arg1num << 12);

    // arg2
    char arg2buf[16];
    getArgPos(2, arg2buf);
    // arg2 should be a reg
    if (arg2buf[0] != 'r')
    {
        BDOS_PrintConsole("LOADLABELHIGH: arg2 not a reg\n");
        exit(1);
    }
    word arg2num = strToInt(&arg2buf[1]);

    instr += arg2num;

    instr ^= (1 << 8);

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Nop(char* outputAddr, char* outputCursor)
{
    char instr[4] = {0x00, 0x00, 0x00, 0x00};
    memcpy((outputAddr + *outputCursor), instr, 4);
    (*outputCursor) += 4;
}

void pass2Dw(char* outputAddr, char* outputCursor)
{
    word dwValue = getNumberAtArg(1);

    // write to mem
    char byteInstr[4];
    instrToByteArray(dwValue, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Dl(char* outputAddr, char* outputCursor)
{
    char arg1buf[LABEL_NAME_SIZE+1];
    getArgPos(1, arg1buf);
    word dlValue = getNumberForLabel(arg1buf);

    // write to mem
    char byteInstr[4];
    instrToByteArray(dlValue, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

void pass2Readintid(char* outputAddr, char* outputCursor)
{
    word instr = 0xE0000000;

    // arg1
    char arg1buf[16];
    getArgPos(1, arg1buf);
    // arg1 should be a reg
    if (arg1buf[0] != 'r')
    {
        BDOS_PrintConsole("READINTID: arg1 not a reg\n");
        exit(1);
    }
    word arg1num = strToInt(&arg1buf[1]);

    instr += arg1num;

    instr ^= (1 << 4);

    // write to mem
    char byteInstr[4];
    instrToByteArray(instr, byteInstr);
    memcpy((outputAddr + *outputCursor), byteInstr, 4);
    (*outputCursor) += 4;
}

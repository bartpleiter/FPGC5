/*
Copyright (c) 2021, b4rt-dev
Copyright (c) 2012-2015, Alexey Frunze
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*****************************************************************************/
/*                                                                           */
/*                           BCC (B322 C Compiler)                           */
/*                                                                           */
/*                           C compiler for B322                             */
/*                 Modified version intended to run on FPGC                  */
/*                                                                           */
/*                            Based on SmallerC:                             */
/*                 A simple and small single-pass C compiler                 */
/*                                                                           */
/*                           B322 code generator                             */
/*                  Modified from the MIPS code generator                    */
/*                                                                           */
/*****************************************************************************/

// NOTE: Very clearly inefficient, because of the direct-ish translation from MIPS to B322

/* MAIN TODOs:
- Remove all MIPS code leftovers
- Do optimizations (like size stuff)
*/

/* WORDSIZE issue tags (to look into if I will ever try to fix it)
//WORDSIZE
//CurFxnLocalOfs (gcc.c)
*/


void GenInit(void)
{
  // initialization of target-specific code generator
  // Assembler should move all .data and .rdata parts away from the code
  SizeOfWord = 4;
  OutputFormat = FormatSegmented;
  CodeHeaderFooter[0] = ".code";
  DataHeaderFooter[0] = ".data";
  RoDataHeaderFooter[0] = ".rdata";
  BssHeaderFooter[0] = ".bss"; // object data
  UseLeadingUnderscores = 0;
}


void GenInitFinalize(void)
{
  // finalization of initialization of target-specific code generator
  // Put all C specific wrapper code (start) here

  if (compileUserBDOS)
  {
    printf2(
      ".code\n"
      
      "Main:\n"
      "    load32 0 r14\n"
      "    load32 0x73FFFF r13\n"
      "    addr2reg Return_BDOS r1\n"
      "    or r0 r1 r15\n"
      "    jump main\n"
      "    halt\n"
      
      "Return_BDOS:\n"
      
      "    load32 0x100300 r1\n"
      "    write 0 r1 r0\n"
      
      "    pop r1\n"
      "    jumpr 3 r1\n"
      "    halt\n"
      );
  }
  else
  {
    printf2(
      ".code\n"
      
      "Main:\n"
      "    load32 0 r14\n"
      "    load32 0x77FFFF r13\n"
      "    addr2reg Return_UART r1\n"
      "    or r0 r1 r15\n"
      "    jump main\n"
      
      "    halt\n"
      
      "Return_UART:\n"
      "    load32 0xC02723 r1\n"
      "    write 0 r1 r2\n"
      "    halt\n"
      );
  }
}

void GenStartCommentLine(void)
{
  printf2(" ; ");
}

// No alignment needed on B322
void GenWordAlignment(word bss)
{
  (void)bss;
  if (doAnnotations)
  {
    printf2("; .align 2\n");
  }
}

void GenLabel(char* Label, word Static)
{
  {
    if (!Static && GenExterns && doAnnotations)
    {
      printf2("; .globl ");
      printf2(Label);
      printf2("\n");
    }
    printf2(Label);
    printf2(":\n");
  }
}

void GenPrintLabel(char* Label)
{
  {
    if (isdigit(*Label))
    {
      printf2("Label_");
      printf2(Label);
    }
    else
    {
      printf2(Label);
    }
  }
}

void GenNumLabel(word Label)
{
  printf2("Label_");
  printd2(Label);
  printf2(":\n");
}

void GenPrintNumLabel(word label)
{
  printf2("Label_");
  printd2(label);
}

void GenZeroData(unsigned Size, word bss)
{
  (void)bss;
  if (doAnnotations)
  {
    printf2("; .space ");
    printd2(truncUint(Size));
    printf2("\n");
  }

  // B322 implementation of .space:
  if (Size > 0)
  {
    word i;
    for (i = 0; i < Size; i++)
    {
      if (MATH_modU(i, 100) == 0)
      {
        if (i == 0)
        {
          printf2(".dw");
        }
        else
        {
          printf2("\n.dw");
        }
      }
      printf2(" 0");
    }
    printf2("\n");
  }

}

void GenIntData(word Size, word Val)
{
  Val = truncInt(Val);

  // Print multiple times, since the compiler does not know yet B322 is word addressable
  if (Size == 1)
  {
    printf2(" .dw ");
    printd2(Val);
    printf2("\n");
  }
  else if (Size == 2)
  {
    printf2(" .dw ");
    printd2(Val);
    printf2(" ");
    printd2(Val);
    printf2("\n");
  }
  else if (Size == 4)
  {
    printf2(" .dw ");
    printd2(Val);
    printf2(" ");
    printd2(Val);
    printf2(" ");
    printd2(Val);
    printf2(" ");
    printd2(Val);
    printf2("\n");
  }
  
}

void GenStartAsciiString(void)
{
  printf2(".dw "); // String should be converted into 1 character per word
}

void GenAddrData(word Size, char* Label, word ofs)
{
  ofs = truncInt(ofs);

  word i;
  for (i = 0; i < 4; i++) // label is 4 "bytes", hotfix since the compiler does not know yet B322 is word addressable
  {
    printf2(".dl ");

    GenPrintLabel(Label);

    // Still not sure if this ever gets called (and probably will not work until an Assembler update)
    if (ofs)
    {
      printf2(" +");
      printd2(ofs);
    }
    puts2("");
  }
}

word GenFxnSizeNeeded(void)
{
  return 0;
}

void GenRecordFxnSize(char* startLabelName, word endLabelNo)
{
  (void)startLabelName;
  (void)endLabelNo;
}

#define B322InstrHalt       0x30
#define B322InstrRead       0x31
#define B322InstrWrite      0x32
#define B322InstrCopy       0x33
#define B322InstrPush       0x34
#define B322InstrPop        0x35
#define B322InstrJump       0x36
#define B322InstrJumpo      0x37
#define B322InstrJumpr      0x38
#define B322InstrJumpro     0x39
#define B322InstrLoad       0x3A
#define B322InstrLoadhi     0x3B
#define B322InstrBeq        0x3C
#define B322InstrBne        0x3D
#define B322InstrBgt        0x3E
#define B322InstrBge        0x3F
#define B322InstrSavpc      0x40
#define B322InstrReti       0x41
#define B322InstrOr         0x42
#define B322InstrAnd        0x43
#define B322InstrXor        0x44
#define B322InstrAdd        0x45
#define B322InstrSub        0x46
#define B322InstrShiftl     0x47
#define B322InstrShiftr     0x48
#define B322InstrMult       0x49
#define B322InstrNot        0x4A
#define B322InstrNop        0x4B
#define B322InstrAddr2reg   0x4C
#define B322InstrReadintid  0x4D
#define B322InstrBgtU        0x4E
#define B322InstrBgeU        0x4F


void GenPrintInstr(word instr, word val)
{
  char* p = "";

  (void)val;

  switch (instr)
  {
  case B322InstrHalt       : p = "halt"; break;
  case B322InstrRead       : p = "read"; break;
  case B322InstrWrite      : p = "write"; break;
  case B322InstrCopy       : p = "copy"; break;
  case B322InstrPush       : p = "push"; break;
  case B322InstrPop        : p = "pop"; break;
  case B322InstrJump       : p = "jump"; break;
  case B322InstrJumpo      : p = "jumpo"; break;
  case B322InstrJumpr      : p = "jumpr"; break;
  case B322InstrJumpro     : p = "jumpro"; break;
  case B322InstrLoad       : p = "load32"; break;
  case B322InstrLoadhi     : p = "loadhi"; break;
  case B322InstrBeq        : p = "beq"; break;
  case B322InstrBne        : p = "bne"; break;
  case B322InstrBgt        : p = "bgts"; break; // HACK: Default signed comparison, because 32 bit should be large enough for most things
  case B322InstrBge        : p = "bges"; break; // HACK: Default signed comparison, because 32 bit should be large enough for most things
  case B322InstrBgtU       : p = "bgt"; break; // Special case for unsigned
  case B322InstrBgeU       : p = "bge"; break; // Special case for unsigned
  case B322InstrSavpc      : p = "savpc"; break;
  case B322InstrReti       : p = "reti"; break;
  case B322InstrOr         : p = "or"; break;
  case B322InstrAnd        : p = "and"; break;
  case B322InstrXor        : p = "xor"; break;
  case B322InstrAdd        : p = "add"; break;
  case B322InstrSub        : p = "sub"; break;
  case B322InstrShiftl     : p = "shiftl"; break;
  case B322InstrShiftr     : p = "shiftr"; break;
  case B322InstrMult       : p = "mult"; break;
  case B322InstrNot        : p = "not"; break;
  case B322InstrNop        : p = "nop"; break;
  case B322InstrAddr2reg   : p = "addr2reg"; break;
  case B322InstrReadintid  : p = "readintid"; break;
  }

  printf2(" ");
  printf2(p);
  printf2(" ");
}

#define B322OpRegZero                    0x00 //0  0
#define B322OpRegAt                      0x01 //1  at
#define B322OpRegV0                      0x02 //2  ret0
#define B322OpRegV1                      0x03 //3  ret1
#define B322OpRegA0                      0x04 //4  arg0
#define B322OpRegA1                      0x05 //5  arg1
#define B322OpRegA2                      0x06 //6  arg2
#define B322OpRegA3                      0x07 //7  arg3
#define B322OpRegT0                      0x08 //8  gp0
#define B322OpRegT1                      0x09 //9  gp1
#define B322OpRegT2                      0x0A //10 gp2
#define B322OpRegT8                      0x0B //11 tempa
#define B322OpRegT9                      0x0C //12 tempb
#define B322OpRegSp                      0x0D //13 sp
#define B322OpRegFp                      0x0E //14 fp
#define B322OpRegRa                      0x0F //15 retaddr

#define B322OpIndRegZero                 0x20
#define B322OpIndRegAt                   0x21
#define B322OpIndRegV0                   0x22
#define B322OpIndRegV1                   0x23
#define B322OpIndRegA0                   0x24
#define B322OpIndRegA1                   0x25
#define B322OpIndRegA2                   0x26
#define B322OpIndRegA3                   0x27
#define B322OpIndRegT0                   0x28
#define B322OpIndRegT1                   0x29
#define B322OpIndRegSp                   0x2D
#define B322OpIndRegFp                   0x2E
#define B322OpIndRegRa                   0x2F

#define B322OpConst                      0x80
#define B322OpLabel                      0x81
#define B322OpNumLabel                   0x82
#define B322OpLabelLo                    0x83
#define B322OpIndLocal                   B322OpIndRegFp

#define MAX_TEMP_REGS 3 // this many temp registers used beginning with T0 to hold subexpression results
#define TEMP_REG_A B322OpRegT8 // two temporary registers used for momentary operations, similarly to the AT register
#define TEMP_REG_B B322OpRegT9

void GenPrintOperand(word op, word val)
{
  if (op >= B322OpRegZero && op <= B322OpRegRa)
  {
    printf2("r");
    printd2(op);
  }
  else if (op >= B322OpIndRegZero && op <= B322OpIndRegRa)
  {
    printd2(truncInt(val));
    printf2(" r");
    printd2(op - B322OpIndRegZero);
  }
  else
  {
    switch (op)
    {
    case B322OpConst: printd2(truncInt(val)); break;
    case B322OpLabelLo:
      // should not be called anymore
      printf("LABELLO WHOOPS!\n");
      /*
      printf2("%%lo(");
      GenPrintLabel(IdentTable + val);
      printf2(")(r1)");
      */
      break;
    case B322OpLabel: GenPrintLabel(IdentTable + val); break;
    case B322OpNumLabel: GenPrintNumLabel(val); break;

    default:
      //error("WTF!\n");
      errorInternal(100);
      break;
    }
  }
}

void GenPrintOperandSeparator(void)
{
  printf2(" ");
}

void GenPrintNewLine(void)
{
  puts2("");
}

void GenPrintInstr1Operand(word instr, word instrval, word operand, word operandval)
{
  GenPrintInstr(instr, instrval);
  GenPrintOperand(operand, operandval);
  GenPrintNewLine();
}

void GenPrintInstr2Operands(word instr, word instrval, word operand1, word operand1val, word operand2, word operand2val)
{
  // TODO: figure out if this ever happens because ADD and SUB need 3 args
  if (operand2 == B322OpConst && operand2val == 0 &&
      (instr == B322InstrAdd || instr == B322InstrSub))
    return;

  GenPrintInstr(instr, instrval);
  GenPrintOperand(operand1, operand1val);
  GenPrintOperandSeparator();
  GenPrintOperand(operand2, operand2val);
  GenPrintNewLine();
}

void GenPrintInstr3Operands(word instr, word instrval,
                            word operand1, word operand1val,
                            word operand2, word operand2val,
                            word operand3, word operand3val)
{
  if (operand3 == B322OpConst && operand3val == 0 &&
      (instr == B322InstrAdd || instr == B322InstrSub) &&
      operand1 == operand2)
    return;

  // If constant is negative, swap B322InstrAdd for B322InstrSUB and vice versa
  // and flip sign of constant
  if (operand2 == B322OpConst && operand2val < 0)
  {
    if (instr == B322InstrAdd)
    {
      instr = B322InstrSub;
      operand2val = -operand2val;
    }
    else if (instr == B322InstrSub)
    {
      instr = B322InstrAdd;
      operand2val = -operand2val;
    }
  }

  GenPrintInstr(instr, instrval);
  GenPrintOperand(operand1, operand1val);
  GenPrintOperandSeparator();
  GenPrintOperand(operand2, operand2val);
  GenPrintOperandSeparator();
  GenPrintOperand(operand3, operand3val);
  GenPrintNewLine();
}


// Currently we do not want to "extend" any reg
void GenExtendRegIfNeeded(word reg, word opSz)
{
  if (opSz == -1)
  {
/* // Sign extension is currently not a thing in B322
#ifdef DONT_USE_SEH
    GenPrintInstr3Operands(MipsInstrSLL, 0,
                           reg, 0,
                           reg, 0,
                           B322OpConst, 24);
    GenPrintInstr3Operands(MipsInstrSRA, 0,
                           reg, 0,
                           reg, 0,
                           B322OpConst, 24);
#else
    GenPrintInstr2Operands(MipsInstrSeb, 0,
                           reg, 0,
                           reg, 0);
#endif
*/
  }
  else if (opSz == 1)
  {
    /*
    GenPrintInstr3Operands(B322InstrAnd, 0,
                           reg, 0,
                           B322OpConst, 0xFF,
                           reg, 0);
    */
  }
  else if (opSz == -2)
  {
/* // Sign extension is currently not a thing in B322
#ifdef DONT_USE_SEH
    GenPrintInstr3Operands(MipsInstrSLL, 0,
                           reg, 0,
                           reg, 0,
                           B322OpConst, 16);
    GenPrintInstr3Operands(MipsInstrSRA, 0,
                           reg, 0,
                           reg, 0,
                           B322OpConst, 16);
#else
    GenPrintInstr2Operands(MipsInstrSeh, 0,
                           reg, 0,
                           reg, 0);
#endif
*/
  }
  else if (opSz == 2)
  {
    /*
    GenPrintInstr3Operands(MipsInstrAnd, 0,
                           reg, 0,
                           reg, 0,
                           B322OpConst, 0xFFFF);
    */
    // Use shiftl 16 and shiftr 16 as equivalent to AND 0xFFFF
    //  (because constants in ARITH can only be 11 bits)
    /*
    GenPrintInstr3Operands(B322InstrShiftl, 0,
                           reg, 0,
                           B322OpConst, 16,
                           reg, 0);
    GenPrintInstr3Operands(B322InstrShiftr, 0,
                           reg, 0,
                           B322OpConst, 16,
                           reg, 0);
    */
  }
}

void GenJumpUncond(word label)
{
  GenPrintInstr1Operand(B322InstrJump, 0,
                        B322OpNumLabel, label);
}

extern word GenWreg; // GenWreg is defined below

void GenJumpIfEqual(word val, word label)
{

  GenPrintInstr2Operands(B322InstrLoad, 0,
                         B322OpConst, val,
                         TEMP_REG_B, 0);
  /*
  GenPrintInstr3Operands(MipsInstrBEQ, 0,
                         GenWreg, 0,
                         TEMP_REG_B, 0,
                         B322OpNumLabel, label);
  */
  GenPrintInstr3Operands(B322InstrBne, 0,
                         GenWreg, 0,
                         TEMP_REG_B, 0,
                         B322OpConst, 2);
  GenPrintInstr1Operand(B322InstrJump, 0,
                         B322OpNumLabel, label);
}

void GenJumpIfZero(word label)
{
  if (doAnnotations)
  {
    printf2(" ; JumpIfZero\n");
  }
  /* if Wreg == 0, jump to label
  GenPrintInstr3Operands(MipsInstrBEQ, 0,
                         GenWreg, 0,
                         B322OpRegZero, 0,
                         B322OpNumLabel, label);
  */
  GenPrintInstr3Operands(B322InstrBne, 0,
                         GenWreg, 0,
                         B322OpRegZero, 0,
                         B322OpConst, 2);
  GenPrintInstr1Operand(B322InstrJump, 0,
                         B322OpNumLabel, label);
}

void GenJumpIfNotZero(word label)
{
  if (doAnnotations)
  {
    printf2(" ; JumpIfNotZero\n");
  }
  /* if Wreg != 0, jump to label
  GenPrintInstr3Operands(MipsInstrBNE, 0,
                         GenWreg, 0,
                         B322OpRegZero, 0,
                         B322OpNumLabel, label);
  */
  GenPrintInstr3Operands(B322InstrBeq, 0,
                         GenWreg, 0,
                         B322OpRegZero, 0,
                         B322OpConst, 2);
  GenPrintInstr1Operand(B322InstrJump, 0,
                         B322OpNumLabel, label);
}

word GenPrologPos = 0;
word GenLeaf;

void GenWriteFrameSize(void) //WORDSIZE
{
  unsigned size = 8/*RA + FP*/ - CurFxnMinLocalOfs;
  //printf2(" subu r13, r13, %10u\n", size); // 10 chars are enough for 32-bit unsigned ints
  printf2(" sub r13 "); // r13 = r13 - size
  printd2(size); // r13 = r13 - size
  printf2(" r13\n"); // r13 = r13 - size

  //printf2(" sw r14, %10u r13\n", size - 8);
  printf2(" write "); // write r14 to memory[r13+(size-8)]
  printd2(size - 8); // write r14 to memory[r13+(size-8)]
  printf2(" r13 r14\n"); // write r14 to memory[r13+(size-8)]
  
  //printf2(" addu r14, r13, %10u\n", size - 8);
  printf2(" add r13 "); // r14 = r13 + (size-8)
  printd2(size - 8); // r14 = r13 + (size-8)
  printf2(" r14\n"); // r14 = r13 + (size-8)

  //printf2(" %csw r15, 4 r14\n", GenLeaf ? ';' : ' ');
  if (GenLeaf)
  {
    printf2("                 ");
  }
  else
  {
    printf2(" write 4 r14 r15\n"); // write r15 to memory[r14+4]
  }
  
}

void GenUpdateFrameSize(void)
{
  word curpos = 0;
  curpos = fgetpos(OutFile);
  //printf("cur: ");
  //printd(curpos);
  //printf("\ngoto: ");
  //printd(GenPrologPos);
  //printf("\n");
  fsetpos(OutFile, GenPrologPos);
  GenWriteFrameSize();

  //printf("back to cur: ");
  //printd(curpos);
  //printf("\n");
  //printf("\n");

  fsetpos(OutFile, curpos);
}

void GenFxnProlog(void)
{
  if (CurFxnParamCntMin && CurFxnParamCntMax)
  {
    word i, cnt = CurFxnParamCntMax;
    if (cnt > 4)
      cnt = 4; //WORDSIZE?
    // TBD!!! for structure passing use the cumulative parameter size
    // instead of the number of parameters. Currently this bug is masked
    // by the subroutine that pushes structures on the stack (it copies
    // all words except the first to the stack). But passing structures
    // in registers from assembly code won't always work.
    for (i = 0; i < cnt; i++)
      GenPrintInstr2Operands(B322InstrWrite, 0,
                             B322OpIndRegSp, 4 * i, //WORDSIZE
                             B322OpRegA0 + i, 0);
  }

  GenLeaf = 1; // will be reset to 0 if a call is generated

  GenPrologPos = fgetpos(OutFile);
  
  // write an empty space for the frame size
  word x;
  for(x = 0; x < 100; x++)
  {
    printf2(" ");
  }
  printf2("\n");
}

void GenGrowStack(word size) //WORDSIZE
{
  if (!size)
    return;

  if (size > 0)
  {
    GenPrintInstr3Operands(B322InstrSub, 0,
                           B322OpRegSp, 0,
                           B322OpConst, size,
                           B322OpRegSp, 0);
  }
  else
  {
    GenPrintInstr3Operands(B322InstrAdd, 0,
                           B322OpRegSp, 0,
                           B322OpConst, -size,
                           B322OpRegSp, 0);
  }
}

void GenFxnEpilog(void)
{

  //printf("DONE with function\n");
  GenUpdateFrameSize();
  //printf("BackToEnd\n");

  if (!GenLeaf)
    GenPrintInstr2Operands(B322InstrRead, 0,
                           B322OpIndRegFp, 4, //WORDSIZE
                           B322OpRegRa, 0);

  GenPrintInstr2Operands(B322InstrRead, 0,
                         B322OpIndRegFp, 0,
                         B322OpRegFp, 0);

  GenPrintInstr3Operands(B322InstrAdd, 0,
                         B322OpRegSp, 0,
                         B322OpConst, 8/*RA + FP*/ - CurFxnMinLocalOfs, //WORDSIZE
                         B322OpRegSp, 0);

  GenPrintInstr2Operands(B322InstrJumpr, 0,
                        B322OpConst, 0,
                        B322OpRegRa, 0);
}

word GenMaxLocalsSize(void)
{
  return 0x7FFFFFFF;
}

word GenGetBinaryOperatorInstr(word tok)
{
  switch (tok)
  {
  case tokPostAdd:
  case tokAssignAdd:
  case '+':
    return B322InstrAdd;
  case tokPostSub:
  case tokAssignSub:
  case '-':
    return B322InstrSub;
  case '&':
  case tokAssignAnd:
    return B322InstrAnd;
  case '^':
  case tokAssignXor:
    return B322InstrXor;
  case '|':
  case tokAssignOr:
    return B322InstrOr;
  case '<':
  case '>':
  case tokLEQ:
  case tokGEQ:
  case tokEQ:
  case tokNEQ:
  case tokULess:
  case tokUGreater:
  case tokULEQ:
  case tokUGEQ:
    return B322InstrNop;
  case '*':
  case tokAssignMul:
    return B322InstrMult;
  case '/':
  case '%':
  case tokAssignDiv:
  case tokAssignMod:
    printf("DIVISION/MOD is not supported!\n");
    return B322InstrHalt;
  case tokUDiv:
  case tokUMod:
  case tokAssignUDiv:
  case tokAssignUMod:
    printf("DIVISION/MOD is not supported!\n");
    return B322InstrHalt;
  case tokLShift:
  case tokAssignLSh:
    return B322InstrShiftl;
  case tokRShift:
  case tokAssignRSh:
    return B322InstrShiftr; // B322 does not know about signed, so normal shiftr is done instead
  case tokURShift:
  case tokAssignURSh:
    return B322InstrShiftr;

  default:
    //error("Error: Invalid operator\n");
    errorInternal(101);
    return 0;
  }
}

void GenReadIdent(word regDst, word opSz, word label)
{
  GenPrintInstr2Operands(B322InstrAddr2reg, 0,
                         B322OpLabel, label,
                         B322OpRegAt, 0);

  GenPrintInstr3Operands(B322InstrRead, 0,
                         B322OpConst, 0,
                         B322OpRegAt, 0,
                         regDst, 0);

  //int instr = B322InstrAddr2reg;
  //GenPreIdentAccess(label);
  /* Always LW, because no byte addressable memory, and no distinction between neg and pos
  if (opSz == -1)
  {
    instr = MipsInstrLB;
  }
  else if (opSz == 1)
  {
    instr = MipsInstrLBU;
  }
  else if (opSz == -2)
  {
    instr = MipsInstrLH;
  }
  else if (opSz == 2)
  {
    instr = MipsInstrLHU;
  }
  */
  //GenPrintInstr2Operands(instr, 0,
  //                       B322OpLabel, label,
  //                       regDst, 0);
  //GenPostIdentAccess();
}

void GenReadLocal(word regDst, word opSz, word ofs)
{
  word instr = B322InstrRead;
  /* Always LW, because no byte addressable memory, and no distinction between neg and pos
  if (opSz == -1)
  {
    instr = MipsInstrLB;
  }
  else if (opSz == 1)
  {
    instr = MipsInstrLBU;
  }
  else if (opSz == -2)
  {
    instr = MipsInstrLH;
  }
  else if (opSz == 2)
  {
    instr = MipsInstrLHU;
  }
  */
  GenPrintInstr2Operands(instr, 0,
                         B322OpIndRegFp, ofs,
                         regDst, 0);
}

void GenReadIndirect(word regDst, word regSrc, word opSz)
{
  word instr = B322InstrRead;
  /* Always LW, because no byte addressable memory, and no distinction between neg and pos
  if (opSz == -1)
  {
    instr = MipsInstrLB;
  }
  else if (opSz == 1)
  {
    instr = MipsInstrLBU;
  }
  else if (opSz == -2)
  {
    instr = MipsInstrLH;
  }
  else if (opSz == 2)
  {
    instr = MipsInstrLHU;
  }
  */
  GenPrintInstr2Operands(instr, 0,
                         regSrc + B322OpIndRegZero, 0,
                         regDst, 0);
}

void GenWriteIdent(word regSrc, word opSz, word label)
{
  GenPrintInstr2Operands(B322InstrAddr2reg, 0,
                         B322OpLabel, label,
                         B322OpRegAt, 0);

  GenPrintInstr3Operands(B322InstrWrite, 0,
                         B322OpConst, 0,
                         B322OpRegAt, 0,
                         regSrc, 0);
  //word instr = B322InstrWrite;
  //GenPreIdentAccess(label);

  /* Always SW, because no byte addressable memory
  if (opSz == -1 || opSz == 1)
  {
    instr = MipsInstrSB;
  }
  else if (opSz == -2 || opSz == 2)
  {
    instr = MipsInstrSH;
  }
  */
  
  //GenPostIdentAccess();
}

void GenWriteLocal(word regSrc, word opSz, word ofs)
{
  word instr = B322InstrWrite;

  /* Always SW, because no byte addressable memory
  if (opSz == -1 || opSz == 1)
  {
    instr = MipsInstrSB;
  }
  else if (opSz == -2 || opSz == 2)
  {
    instr = MipsInstrSH;
  }
  */
  GenPrintInstr2Operands(instr, 0,
                         B322OpIndRegFp, ofs,
                         regSrc, 0);
}

void GenWriteIndirect(word regDst, word regSrc, word opSz)
{
  word instr = B322InstrWrite;

  /* Always SW, because no byte addressable memory
  if (opSz == -1 || opSz == 1)
  {
    instr = MipsInstrSB;
  }
  else if (opSz == -2 || opSz == 2)
  {
    instr = MipsInstrSH;
  }
  */
  GenPrintInstr2Operands(instr, 0,
                         regDst + B322OpIndRegZero, 0,
                         regSrc, 0);
}

void GenIncDecIdent(word regDst, word opSz, word label, word tok)
{
  word instr = B322InstrAdd;

  if (tok != tokInc)
    instr = B322InstrSub;

  GenReadIdent(regDst, opSz, label);
  GenPrintInstr3Operands(instr, 0,
                         regDst, 0,
                         B322OpConst, 1,
                         regDst, 0);
  GenWriteIdent(regDst, opSz, label);
  GenExtendRegIfNeeded(regDst, opSz);
}

void GenIncDecLocal(word regDst, word opSz, word ofs, word tok)
{
  word instr = B322InstrAdd;

  if (tok != tokInc)
    instr = B322InstrSub;

  GenReadLocal(regDst, opSz, ofs);
  GenPrintInstr3Operands(instr, 0,
                         regDst, 0,
                         B322OpConst, 1,
                         regDst, 0);
  GenWriteLocal(regDst, opSz, ofs);
  GenExtendRegIfNeeded(regDst, opSz);
}

void GenIncDecIndirect(word regDst, word regSrc, word opSz, word tok)
{
  word instr = B322InstrAdd;

  if (tok != tokInc)
    instr = B322InstrSub;

  GenReadIndirect(regDst, regSrc, opSz);
  GenPrintInstr3Operands(instr, 0,
                         regDst, 0,
                         B322OpConst, 1,
                         regDst, 0);
  GenWriteIndirect(regSrc, regDst, opSz);
  GenExtendRegIfNeeded(regDst, opSz);
}

void GenPostIncDecIdent(word regDst, word opSz, word label, word tok)
{
  word instr = B322InstrAdd;

  if (tok != tokPostInc)
    instr = B322InstrSub;

  GenReadIdent(regDst, opSz, label);
  GenPrintInstr3Operands(instr, 0,
                         regDst, 0,
                         B322OpConst, 1,
                         regDst, 0);
  GenWriteIdent(regDst, opSz, label);

  GenPrintInstr3Operands(instr, 0,
                         regDst, 0,
                         B322OpConst, -1,
                         regDst, 0);
  GenExtendRegIfNeeded(regDst, opSz);
}

void GenPostIncDecLocal(word regDst, word opSz, word ofs, word tok)
{
  word instr = B322InstrAdd;

  if (tok != tokPostInc)
    instr = B322InstrSub;

  GenReadLocal(regDst, opSz, ofs);
  GenPrintInstr3Operands(instr, 0,
                         regDst, 0,
                         B322OpConst, 1,
                         regDst, 0);
  GenWriteLocal(regDst, opSz, ofs);

  GenPrintInstr3Operands(instr, 0,
                         regDst, 0,
                         B322OpConst, -1,
                         regDst, 0);
  GenExtendRegIfNeeded(regDst, opSz);
}

void GenPostIncDecIndirect(word regDst, word regSrc, word opSz, word tok)
{
  word instr = B322InstrAdd;

  if (tok != tokPostInc)
    instr = B322InstrSub;

  GenReadIndirect(regDst, regSrc, opSz);
  GenPrintInstr3Operands(instr, 0,
                         regDst, 0,
                         B322OpConst, 1,
                         regDst, 0);
  GenWriteIndirect(regSrc, regDst, opSz);

  GenPrintInstr3Operands(instr, 0,
                         regDst, 0,
                         B322OpConst, -1,
                         regDst, 0);
  GenExtendRegIfNeeded(regDst, opSz);
}

word CanUseTempRegs;
word TempsUsed;
word GenWreg = B322OpRegV0; // current working register (V0 or Tn or An)
word GenLreg, GenRreg; // left operand register and right operand register after GenPopReg()

/*
  General idea behind GenWreg, GenLreg, GenRreg:

  - In expressions w/o function calls:

    Subexpressions are evaluated in V0, T0, T1, ..., T<MAX_TEMP_REGS-1>. If those registers
    aren't enough, the stack is used additionally.

    The expression result ends up in V0, which is handy for returning from
    functions.

    In the process, GenWreg is the current working register and is one of: V0, T0, T1, ... .
    All unary operators are evaluated in the current working register.

    GenPushReg() and GenPopReg() advance GenWreg as needed when handling binary operators.

    GenPopReg() sets GenWreg, GenLreg and GenRreg. GenLreg and GenRreg are the registers
    where the left and right operands of a binary operator are.

    When the exression runs out of the temporary registers, the stack is used. While it is being
    used, GenWreg remains equal to the last temporary register, and GenPopReg() sets GenLreg = TEMP_REG_A.
    Hence, after GenPopReg() the operands of the binary operator are always in registers and can be
    directly manipulated with.

    Following GenPopReg(), binary operator evaluation must take the left and right operands from
    GenLreg and GenRreg and write the evaluated result into GenWreg. Care must be taken as GenWreg
    will be the same as either GenLreg (when the popped operand comes from T0-T<MAX_TEMP_REGS-1>)
    or GenRreg (when the popped operand comes from the stack in TEMP_REG_A).

  - In expressions with function calls:

    GenWreg is always V0 in subexpressions that aren't function parameters. These subexpressions
    get automatically pushed onto the stack as necessary.

    GenWreg is always V0 in expressions, where return values from function calls are used as parameters
    into other called functions. IOW, this is the case when the function call depth is greater than 1.
    Subexpressions in such expressions get automatically pushed onto the stack as necessary.

    GenWreg is A0-A3 in subexpressions that are function parameters when the function call depth is 1.
    Basically, while a function parameter is evaluated, it's evaluated in the register from where
    the called function will take it. This avoids some of unnecessary register copies and stack
    manipulations in the most simple and very common cases of function calls.
*/

void GenWregInc(word inc)
{
  if (inc > 0)
  {
    // Advance the current working register to the next available temporary register
    if (GenWreg == B322OpRegV0)
      GenWreg = B322OpRegT0;
    else
      GenWreg++;
  }
  else
  {
    // Return to the previous current working register
    if (GenWreg == B322OpRegT0)
      GenWreg = B322OpRegV0;
    else
      GenWreg--;
  }
}

void GenPushReg(void)
{
  if (CanUseTempRegs && TempsUsed < MAX_TEMP_REGS)
  {
    GenWregInc(1);
    TempsUsed++;
    return;
  }

  GenPrintInstr3Operands(B322InstrSub, 0,
                         B322OpRegSp, 0,
                         B322OpConst, 4, //WORDSIZE
                         B322OpRegSp, 0);

  GenPrintInstr2Operands(B322InstrWrite, 0,
                         B322OpIndRegSp, 0,
                         GenWreg, 0);

  TempsUsed++;
}

void GenPopReg(void)
{
  TempsUsed--;

  if (CanUseTempRegs && TempsUsed < MAX_TEMP_REGS)
  {
    GenRreg = GenWreg;
    GenWregInc(-1);
    GenLreg = GenWreg;
    return;
  }

  GenPrintInstr2Operands(B322InstrRead, 0,
                         B322OpIndRegSp, 0,
                         TEMP_REG_A, 0);

  GenPrintInstr3Operands(B322InstrAdd, 0,
                         B322OpRegSp, 0,
                         B322OpConst, 4, //WORDSIZE
                         B322OpRegSp, 0);
  GenLreg = TEMP_REG_A;
  GenRreg = GenWreg;
}

#define tokRevIdent    0x100
#define tokRevLocalOfs 0x101
#define tokAssign0     0x102
#define tokNum0        0x103

void GenPrep(word* idx)
{
  word tok;
  word oldIdxRight, oldIdxLeft, t0, t1;

  if (*idx < 0)
    //error("GenFuse(): idx < 0\n");
    errorInternal(100);

  tok = stack[*idx][0];

  oldIdxRight = --*idx;

  switch (tok)
  {
  case tokUDiv:
  case tokUMod:
  case tokAssignUDiv:
  case tokAssignUMod:
    if (stack[oldIdxRight][0] == tokNumInt || stack[oldIdxRight][0] == tokNumUint)
    {
      // Change unsigned division to right shift and unsigned modulo to bitwise and
      unsigned m = truncUint(stack[oldIdxRight][1]);
      if (m && !(m & (m - 1)))
      {
        if (tok == tokUMod || tok == tokAssignUMod)
        {
          stack[oldIdxRight][1] = (word)(m - 1);
          tok = (tok == tokUMod) ? '&' : tokAssignAnd;
        }
        else
        {
          t1 = 0;
          while (m >>= 1) t1++;
          stack[oldIdxRight][1] = t1;
          tok = (tok == tokUDiv) ? tokURShift : tokAssignURSh;
        }
        stack[oldIdxRight + 1][0] = tok;
      }
    }
  }

  switch (tok)
  {
  case tokNumUint:
    stack[oldIdxRight + 1][0] = tokNumInt; // reduce the number of cases since tokNumInt and tokNumUint are handled the same way
    // fallthrough
  case tokNumInt:
  case tokNum0:
  case tokIdent:
  case tokLocalOfs:
    break;

  case tokPostAdd:
  case tokPostSub:
  case '-':
  case '/':
  case '%':
  case tokUDiv:
  case tokUMod:
  case tokLShift:
  case tokRShift:
  case tokURShift:
  case tokLogAnd:
  case tokLogOr:
  case tokComma:
    GenPrep(idx);
    // fallthrough
  case tokShortCirc:
  case tokGoto:
  case tokUnaryStar:
  case tokInc:
  case tokDec:
  case tokPostInc:
  case tokPostDec:
  case '~':
  case tokUnaryPlus:
  case tokUnaryMinus:
  case tok_Bool:
  case tokVoid:
  case tokUChar:
  case tokSChar:
  case tokShort:
  case tokUShort:
    GenPrep(idx);
    break;

  case '=':
    if (oldIdxRight + 1 == sp - 1 &&
        (stack[oldIdxRight][0] == tokNumInt || stack[oldIdxRight][0] == tokNumUint) &&
        truncUint(stack[oldIdxRight][1]) == 0)
    {
      // Special case for assigning 0 while throwing away the expression result value
      // TBD??? ,
      stack[oldIdxRight][0] = tokNum0; // this zero constant will not be loaded into a register
      stack[oldIdxRight + 1][0] = tokAssign0; // change '=' to tokAssign0
    }
    // fallthrough
  case tokAssignAdd:
  case tokAssignSub:
  case tokAssignMul:
  case tokAssignDiv:
  case tokAssignUDiv:
  case tokAssignMod:
  case tokAssignUMod:
  case tokAssignLSh:
  case tokAssignRSh:
  case tokAssignURSh:
  case tokAssignAnd:
  case tokAssignXor:
  case tokAssignOr:
    GenPrep(idx);
    oldIdxLeft = *idx;
    GenPrep(idx);
    // If the left operand is an identifier (with static or auto storage), swap it with the right operand
    // and mark it specially, so it can be used directly
    if ((t0 = stack[oldIdxLeft][0]) == tokIdent || t0 == tokLocalOfs)
    {
      t1 = stack[oldIdxLeft][1];
      memmove(stack[oldIdxLeft], stack[oldIdxLeft + 1], (oldIdxRight - oldIdxLeft) * sizeof(stack[0]));
      stack[oldIdxRight][0] = (t0 == tokIdent) ? tokRevIdent : tokRevLocalOfs;
      stack[oldIdxRight][1] = t1;
    }
    break;

  case '+':
  case '*':
  case '&':
  case '^':
  case '|':
  case tokEQ:
  case tokNEQ:
  case '<':
  case '>':
  case tokLEQ:
  case tokGEQ:
  case tokULess:
  case tokUGreater:
  case tokULEQ:
  case tokUGEQ:
    GenPrep(idx);
    oldIdxLeft = *idx;
    GenPrep(idx);
    // If the right operand isn't a constant, but the left operand is, swap the operands
    // so the constant can become an immediate right operand in the instruction
    t1 = stack[oldIdxRight][0];
    t0 = stack[oldIdxLeft][0];
    if (t1 != tokNumInt && t0 == tokNumInt)
    {
      word xor;

      t1 = stack[oldIdxLeft][1];
      memmove(stack[oldIdxLeft], stack[oldIdxLeft + 1], (oldIdxRight - oldIdxLeft) * sizeof(stack[0]));
      stack[oldIdxRight][0] = t0;
      stack[oldIdxRight][1] = t1;

      switch (tok)
      {
      case '<':
      case '>':
        xor = '<' ^ '>'; break;
      case tokLEQ:
      case tokGEQ:
        xor = tokLEQ ^ tokGEQ; break;
      case tokULess:
      case tokUGreater:
        xor = tokULess ^ tokUGreater; break;
      case tokULEQ:
      case tokUGEQ:
        xor = tokULEQ ^ tokUGEQ; break;
      default:
        xor = 0; break;
      }
      tok ^= xor;
    }
    // Handle a few special cases and transform the instruction
    if (stack[oldIdxRight][0] == tokNumInt)
    {
      unsigned m = truncUint(stack[oldIdxRight][1]);
      switch (tok)
      {
      case '*':
        // Change multiplication to left shift, this helps indexing arrays of ints/pointers/etc
        if (m && !(m & (m - 1)))
        {
          t1 = 0;
          while (m >>= 1) t1++;
          stack[oldIdxRight][1] = t1;
          tok = tokLShift;
        }
        break;
      case tokLEQ:
        // left <= const will later change to left < const+1, but const+1 must be <=0x7FFFFFFF
        if (m == 0x7FFFFFFF)
        {
          // left <= 0x7FFFFFFF is always true, change to the equivalent left >= 0u
          stack[oldIdxRight][1] = 0;
          tok = tokUGEQ;
        }
        break;
      case tokULEQ:
        // left <= const will later change to left < const+1, but const+1 must be <=0xFFFFFFFFu
        if (m == 0xFFFFFFFF)
        {
          // left <= 0xFFFFFFFFu is always true, change to the equivalent left >= 0u
          stack[oldIdxRight][1] = 0;
          tok = tokUGEQ;
        }
        break;
      case '>':
        // left > const will later change to !(left < const+1), but const+1 must be <=0x7FFFFFFF
        if (m == 0x7FFFFFFF)
        {
          // left > 0x7FFFFFFF is always false, change to the equivalent left & 0
          stack[oldIdxRight][1] = 0;
          tok = '&';
        }
        break;
      case tokUGreater:
        // left > const will later change to !(left < const+1), but const+1 must be <=0xFFFFFFFFu
        if (m == 0xFFFFFFFF)
        {
          // left > 0xFFFFFFFFu is always false, change to the equivalent left & 0
          stack[oldIdxRight][1] = 0;
          tok = '&';
        }
        break;
      }
    }
    stack[oldIdxRight + 1][0] = tok;
    break;

  case ')':
    while (stack[*idx][0] != '(')
    {
      GenPrep(idx);
      if (stack[*idx][0] == ',')
        --*idx;
    }
    --*idx;
    break;

  default:
    //error("GenPrep: unexpected token %s\n", GetTokenName(tok));
    errorInternal(101);
  }
}

/*
;     l <[u] 0       // slt[u] w, w, 0                            "k"
      l <[u] const   // slt[u] w, w, const                        "m"
      l <[u] r       // slt[u] w, l, r                            "i"
* if (l <    0)      // bgez w, Lskip                             "f"
  if (l <[u] const)  // slt[u] w, w, const; beq w, r0, Lskip      "mc"
  if (l <[u] r)      // slt[u] w, l, r; beq w, r0, Lskip          "ic"

;     l <=[u] 0      // slt[u] w, w, 1                            "l"
      l <=[u] const  // slt[u] w, w, const + 1                    "n"
      l <=[u] r      // slt[u] w, r, l; xor w, w, 1               "js"
* if (l <=    0)     // bgtz w, Lskip                             "g"
  if (l <=[u] const) // slt[u] w, w, const + 1; beq w, r0, Lskip  "nc"
  if (l <=[u] r)     // slt[u] w, r, l; bne w, r0, Lskip          "jd"

      l >[u] 0       // slt[u] w, r0, w                           "o"
      l >[u] const   // slt[u] w, w, const + 1; xor w, w, 1       "ns"
      l >[u] r       // slt[u] w, r, l                            "j"
* if (l >    0)      // blez w, Lskip                             "h"
**if (l >u   0)      // beq w, r0, Lskip
  if (l >[u] const)  // slt[u] w, w, const + 1; bne w, r0, Lskip  "nd"
  if (l >[u] r)      // slt[u] w, r, l; beq w, r0, Lskip          "jc"

;     l >=[u] 0      // slt[u] w, w, 0; xor w, w, 1               "ks"
      l >=[u] const  // slt[u] w, w, const; xor w, w, 1           "ms"
      l >=[u] r      // slt[u] w, l, r; xor w, w, 1               "is"
* if (l >=    0)     // bltz w, Lskip                             "e"
  if (l >=[u] const) // slt[u] w, w, const; bne w, r0, Lskip      "md"
  if (l >=[u] r)     // slt[u] w, l, r; bne w, r0, Lskip          "id"

      l == 0         // sltu w, w, 1                              "q"
      l == const     // xor w, w, const; sltu w, w, 1             "tq"
      l == r         // xor w, l, r; sltu w, w, 1                 "rq"
  if (l == 0)        // bne w, r0, Lskip                          "d"
  if (l == const)    // xor w, w, const; bne w, r0, Lskip         "td"
  if (l == r)        // bne l, r, Lskip                           "b"

      l != 0         // sltu w, r0, w                             "p"
      l != const     // xor w, w, const; sltu w, r0, w            "tp"
      l != r         // xor w, l, r; sltu w, r0, w                "rp"
  if (l != 0)        // beq w, r0, Lskip                          "c"
  if (l != const)    // xor w, w, const; beq w, r0, Lskip         "tc"
  if (l != r)        // beq l, r, Lskip                           "a"
*/
char CmpBlocks[6/*op*/][2/*condbranch*/][3/*constness*/][2] =
{
  {
    { "k", "m", "i" },
    { "f", "mc", "ic" }
  },
  {
    { "l", "n", "js" },
    { "g", "nc", "jd" }
  },
  {
    { "o", "ns", "j" },
    { "h", "nd", "jc" }
  },
  {
    { "ks", "ms", "is" },
    { "e", "md", "id" }
  },
  {
    { "q", "tq", "rq" },
    { "d", "td", "b" }
  },
  {
    { "p", "tp", "rp" },
    { "c", "tc", "a" }
  }
};

void GenCmp(word* idx, word op)
{
  // TODO: direct conversion from MIPS to B322 is very inefficient, so optimize this!
  /*
  MIPS:
  slt reg, s < t (reg := 1, else reg := 0)

  B322 equivalent:
  bge s >= t 2
  load 1 reg
  load 0 reg
  */
  /*
  Inverses:
  BEQ a b         BNE a b
  BNE a b         BEQ a b

  BLTZ a (a < 0)  BGE a r0 (a >= 0)
  BGEZ a (a >=0)  BGT r0 a (a < 0) == (0 > a)

  BGTZ a (a > 0)  BGE r0 a (a <= 0) == (0 >= a)
  BLEZ a (a <=0)  BGT a r0 (a > 0)
  */
  // constness: 0 = zero const, 1 = non-zero const, 2 = non-const
  word constness = (stack[*idx - 1][0] == tokNumInt) ? (stack[*idx - 1][1] != 0) : 2;
  word constval = (constness == 1) ? truncInt(stack[*idx - 1][1]) : 0;
  // condbranch: 0 = no conditional branch, 1 = branch if true, 2 = branch if false
  word condbranch = (*idx + 1 < sp) ? (stack[*idx + 1][0] == tokIf) + (stack[*idx + 1][0] == tokIfNot) * 2 : 0;
  word unsign = op >> 4;
  word instrBGEdependingOnSign = unsign ? B322InstrBgeU : B322InstrBge;
  word instrBGTdependingOnSign = unsign ? B322InstrBgtU : B322InstrBgt;

  word label = condbranch ? stack[*idx + 1][1] : 0;
  char* p;
  word i;

  op &= 0xF;
  if (constness == 2)
    GenPopReg();

  // bltz, blez, bgez, bgtz are for signed comparison with 0 only,
  // so for conditional branches on <0u, <=0u, >0u, >=0u use the general method instead
  if (condbranch && op < 4 && constness == 0 && unsign)
  {
    // Except, >0u is more optimal as !=0
    if (op == 2)
      op = 5;
    else
      constness = 1;
  }

  p = CmpBlocks[op][condbranch != 0][constness];

  for (i = 0; i < 2; i++)
  {
    switch (p[i])
    {
    case 'a':
      condbranch ^= 3;
      // fallthrough
    case 'b':
      GenPrintInstr3Operands((condbranch == 1) ? B322InstrBne : B322InstrBeq, 0,
                             GenLreg, 0,
                             GenRreg, 0,
                             B322OpConst, 2);
      GenPrintInstr1Operand(B322InstrJump, 0,
                             B322OpNumLabel, label);
      break;
    case 'c':
      condbranch ^= 3;
      // fallthrough
    case 'd':
      GenPrintInstr3Operands((condbranch == 1) ? B322InstrBne : B322InstrBeq, 0,
                             GenWreg, 0,
                             B322OpRegZero, 0,
                             B322OpConst, 2);
      GenPrintInstr1Operand(B322InstrJump, 0,
                             B322OpNumLabel, label);
      break;
    case 'e':
      condbranch ^= 3;
      // fallthrough
    case 'f':
      /*
        BLTZ a (a < 0)  BGE a r0 (a >= 0)
        BGEZ a (a >=0)  BGT r0 a (a < 0) == (0 > a)
      */
      if (condbranch == 1)
      {
        GenPrintInstr3Operands(B322InstrBge, 0,
                               GenWreg, 0,
                               B322OpRegZero, 0,
                               B322OpConst, 2);
      }
      else
      {
        GenPrintInstr3Operands(B322InstrBgt, 0,
                               B322OpRegZero, 0,
                               GenWreg, 0,
                               B322OpConst, 2);
      }
      GenPrintInstr1Operand(B322InstrJump, 0,
                             B322OpNumLabel, label);
      break;
    case 'g':
      condbranch ^= 3;
      // fallthrough
    case 'h':
      /*
      BGTZ a (a > 0)  BGE r0 a (a <= 0) == (0 >= a)
      BLEZ a (a <=0)  BGT a r0 (a > 0)
      */
      if (condbranch == 1)
      {
        GenPrintInstr3Operands(B322InstrBge, 0,
                               B322OpRegZero, 0,
                               GenWreg, 0,
                               B322OpConst, 2);
      }
      else
      {
        GenPrintInstr3Operands(B322InstrBgt, 0,
                               GenWreg, 0,
                               B322OpRegZero, 0,
                               B322OpConst, 2);
      }
      GenPrintInstr1Operand(B322InstrJump, 0,
                             B322OpNumLabel, label);
      break;
    case 'i':
      GenPrintInstr3Operands(instrBGEdependingOnSign, 0,
                             GenLreg, 0,
                             GenRreg, 0,
                             B322OpConst, 3);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 1,
                               GenWreg, 0);
      GenPrintInstr1Operand(B322InstrJumpo, 0,
                             B322OpConst, 2);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 0,
                               GenWreg, 0);
      break;
    case 'j':
      GenPrintInstr3Operands(instrBGEdependingOnSign, 0,
                             GenRreg, 0,
                             GenLreg, 0,
                             B322OpConst, 3);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 1,
                               GenWreg, 0);
      GenPrintInstr1Operand(B322InstrJumpo, 0,
                             B322OpConst, 2);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 0,
                               GenWreg, 0);
      break;
    case 'k':
      GenPrintInstr3Operands(instrBGEdependingOnSign, 0,
                             GenWreg, 0,
                             B322OpRegZero, 0,
                             B322OpConst, 3);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 1,
                               GenWreg, 0);
      GenPrintInstr1Operand(B322InstrJumpo, 0,
                             B322OpConst, 2);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 0,
                               GenWreg, 0);
      break;
    case 'l':
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 1,
                               TEMP_REG_A, 0);
      GenPrintInstr3Operands(instrBGEdependingOnSign, 0,
                             GenWreg, 0,
                             TEMP_REG_A, 0,
                             B322OpConst, 3);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 1,
                               GenWreg, 0);
      GenPrintInstr1Operand(B322InstrJumpo, 0,
                             B322OpConst, 2);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 0,
                               GenWreg, 0);
      break;
    case 'n':
      constval++;
      // fallthrough
    case 'm':
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, constval,
                               TEMP_REG_A, 0);
      GenPrintInstr3Operands(instrBGEdependingOnSign, 0,
                             GenWreg, 0,
                             TEMP_REG_A, 0,
                             B322OpConst, 3);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 1,
                               GenWreg, 0);
      GenPrintInstr1Operand(B322InstrJumpo, 0,
                             B322OpConst, 2);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 0,
                               GenWreg, 0);
      break;
    case 'o':
      GenPrintInstr3Operands(instrBGEdependingOnSign, 0,
                             B322OpRegZero, 0,
                             GenWreg, 0,
                             B322OpConst, 3);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 1,
                               GenWreg, 0);
      GenPrintInstr1Operand(B322InstrJumpo, 0,
                             B322OpConst, 2);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 0,
                               GenWreg, 0);
      break;
    case 'p':
      GenPrintInstr3Operands(B322InstrBgeU, 0,
                             B322OpRegZero, 0,
                             GenWreg, 0,
                             B322OpConst, 3);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 1,
                               GenWreg, 0);
      GenPrintInstr1Operand(B322InstrJumpo, 0,
                             B322OpConst, 2);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 0,
                               GenWreg, 0);
      break;
    case 'q':
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 1,
                               B322OpRegAt, 0);
      GenPrintInstr3Operands(B322InstrBgeU, 0,
                             GenWreg, 0,
                             B322OpRegAt, 0,
                             B322OpConst, 3);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 1,
                               GenWreg, 0);
      GenPrintInstr1Operand(B322InstrJumpo, 0,
                             B322OpConst, 2);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 0,
                               GenWreg, 0);
      break;
    case 'r':
      GenPrintInstr3Operands(B322InstrXor, 0,
                             GenLreg, 0,
                             GenRreg, 0,
                             GenWreg, 0);
      break;
    case 's':
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 1,
                               B322OpRegAt, 0);
      GenPrintInstr3Operands(B322InstrXor, 0,
                             GenWreg, 0,
                             B322OpRegAt, 0,
                             GenWreg, 0);
      break;
    case 't':
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, constval,
                               B322OpRegAt, 0);
      GenPrintInstr3Operands(B322InstrXor, 0,
                             GenWreg, 0,
                             B322OpRegAt, 0,
                             GenWreg, 0);
      break;
    }
  }

  *idx += condbranch != 0;
}

word GenIsCmp(word t)
{
  return
    t == '<' ||
    t == '>' ||
    t == tokGEQ ||
    t == tokLEQ ||
    t == tokULess ||
    t == tokUGreater ||
    t == tokUGEQ ||
    t == tokULEQ ||
    t == tokEQ ||
    t == tokNEQ;
}

// Improved register/stack-based code generator
// DONE: test 32-bit code generation
void GenExpr0(void)
{
  word i;
  word gotUnary = 0;
  word maxCallDepth = 0;
  word callDepth = 0;
  word paramOfs = 0;
  word t = sp - 1;

  if (stack[t][0] == tokIf || stack[t][0] == tokIfNot || stack[t][0] == tokReturn)
    t--;
  GenPrep(&t);

  for (i = 0; i < sp; i++)
    if (stack[i][0] == '(')
    {
      if (++callDepth > maxCallDepth)
        maxCallDepth = callDepth;
    }
    else if (stack[i][0] == ')')
    {
      callDepth--;
    }

  CanUseTempRegs = maxCallDepth == 0;
  TempsUsed = 0;
  if (GenWreg != B322OpRegV0)
    errorInternal(102);

  for (i = 0; i < sp; i++)
  {
    word tok = stack[i][0];
    word v = stack[i][1];

    if (doAnnotations)
    {
      switch (tok)
      {
      case tokNumInt: printf2(" ; "); printd2(truncInt(v)); printf2("\n"); break;
      //case tokNumUint: printf2(" ; %uu\n", truncUint(v)); break;
      case tokIdent: case tokRevIdent: printf2(" ; "); printf2(IdentTable + v); printf2("\n"); break;
      case tokLocalOfs: case tokRevLocalOfs: printf2(" ; local ofs\n"); break;
      case ')': printf2(" ; ) fxn call\n"); break;
      case tokUnaryStar: printf2(" ; * (read dereference)\n"); break;
      case '=': printf2(" ; = (write dereference)\n"); break;
      case tokShortCirc: printf2(" ; short-circuit "); break;
      case tokGoto: printf2(" ; sh-circ-goto "); break;
      case tokLogAnd: printf2(" ; short-circuit && target\n"); break;
      case tokLogOr: printf2(" ; short-circuit || target\n"); break;
      case tokIf: case tokIfNot: case tokReturn: break;
      case tokNum0: printf2(" ; 0\n"); break;
      case tokAssign0:  printf2(" ; =\n"); break;
      default: printf2(" ; "); printf2(GetTokenName(tok)); printf2("\n"); break;
      }
    }

    switch (tok)
    {
    case tokNumInt:
      if (!(i + 1 < sp && ((t = stack[i + 1][0]) == '+' ||
                           t == '-' ||
                           t == '&' ||
                           t == '^' ||
                           t == '|' ||
                           t == tokLShift ||
                           t == tokRShift ||
                           t == tokURShift ||
                           GenIsCmp(t))))
      {
        if (gotUnary)
          GenPushReg();

        GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, v,
                               GenWreg, 0);
      }
      gotUnary = 1;
      break;

    case tokIdent:
      if (gotUnary)
        GenPushReg();
      if (!(i + 1 < sp && ((t = stack[i + 1][0]) == ')' ||
                           t == tokUnaryStar ||
                           t == tokInc ||
                           t == tokDec ||
                           t == tokPostInc ||
                           t == tokPostDec)))
      {
        GenPrintInstr2Operands(B322InstrAddr2reg, 0,
                               B322OpLabel, v,
                               GenWreg, 0);
      }
      gotUnary = 1;
      break;

    case tokLocalOfs:
      if (gotUnary)
        GenPushReg();
      if (!(i + 1 < sp && ((t = stack[i + 1][0]) == tokUnaryStar ||
                           t == tokInc ||
                           t == tokDec ||
                           t == tokPostInc ||
                           t == tokPostDec)))
      {
        GenPrintInstr3Operands(B322InstrAdd, 0,
                               B322OpRegFp, 0,
                               B322OpConst, v,
                               GenWreg, 0);
      }
      gotUnary = 1;
      break;

    case '(':
      if (gotUnary)
        GenPushReg();
      gotUnary = 0;
      if (maxCallDepth != 1 && v < 16)
        GenGrowStack(16 - v);
      paramOfs = v - 4;
      if (maxCallDepth == 1 && paramOfs >= 0 && paramOfs <= 12)
      {
        // Work directly in A0-A3 instead of working in V0 and avoid copying V0 to A0-A3
        GenWreg = B322OpRegA0 + division(paramOfs, 4);
      }
      break;

    case ',':
      if (maxCallDepth == 1)
      {
        if (paramOfs == 16)
        {
          // Got the last on-stack parameter, the rest will go in A0-A3
          GenPushReg();
          gotUnary = 0;
          GenWreg = B322OpRegA3;
        }
        if (paramOfs >= 0 && paramOfs <= 12)
        {
          // Advance to the next An reg or revert to V0
          if (paramOfs)
            GenWreg--;
          else
            GenWreg = B322OpRegV0;
          gotUnary = 0;
        }
        paramOfs -= 4;
      }
      break;

    case ')':
      GenLeaf = 0;
      if (maxCallDepth != 1)
      {
        if (v >= 4)
          GenPrintInstr2Operands(B322InstrRead, 0,
                                 B322OpIndRegSp, 0,
                                 B322OpRegA0, 0);
        if (v >= 8)
          GenPrintInstr2Operands(B322InstrRead, 0,
                                 B322OpIndRegSp, 4,
                                 B322OpRegA1, 0);
        if (v >= 12)
          GenPrintInstr2Operands(B322InstrRead, 0,
                                 B322OpIndRegSp, 8,
                                 B322OpRegA2, 0);
        if (v >= 16)
          GenPrintInstr2Operands(B322InstrRead, 0,
                                 B322OpIndRegSp, 12,
                                 B322OpRegA3, 0);
      }
      else
      {
        GenGrowStack(16);
      }
      if (stack[i - 1][0] == tokIdent)
      {
        GenPrintInstr1Operand(B322InstrSavpc, 0,
                              B322OpRegRa, 0);
        GenPrintInstr3Operands(B322InstrAdd, 0,
                             B322OpRegRa, 0,
                             B322OpConst, 3,
                             B322OpRegRa, 0);
        GenPrintInstr1Operand(B322InstrJump, 0,
                              B322OpLabel, stack[i - 1][1]);
      }
      else
      {
        GenPrintInstr1Operand(B322InstrSavpc, 0,
                              B322OpRegRa, 0);
        GenPrintInstr3Operands(B322InstrAdd, 0,
                             B322OpRegRa, 0,
                             B322OpConst, 3,
                             B322OpRegRa, 0);
        GenPrintInstr2Operands(B322InstrJumpr, 0,
                              B322OpConst, 0,
                              GenWreg, 0);
      }
      if (v < 16)
        v = 16;
      GenGrowStack(-v);
      break;

    case tokUnaryStar:
      if (stack[i - 1][0] == tokIdent)
        GenReadIdent(GenWreg, v, stack[i - 1][1]);
      else if (stack[i - 1][0] == tokLocalOfs)
        GenReadLocal(GenWreg, v, stack[i - 1][1]);
      else
        GenReadIndirect(GenWreg, GenWreg, v);
      break;

    case tokUnaryPlus:
      break;
    case '~': //nor
      GenPrintInstr3Operands(B322InstrOr, 0,
                             GenWreg, 0,
                             GenWreg, 0,
                             GenWreg, 0);
      GenPrintInstr2Operands(B322InstrNot, 0,
                             GenWreg, 0,
                             GenWreg, 0);

      break;
    case tokUnaryMinus:
      GenPrintInstr3Operands(B322InstrSub, 0,
                             B322OpRegZero, 0,
                             GenWreg, 0,
                             GenWreg, 0);
      break;

    case '+':
    case '-':
    case '*':
    case '&':
    case '^':
    case '|':
    case tokLShift:
    case tokRShift:
    case tokURShift:
      if (stack[i - 1][0] == tokNumInt && tok != '*')
      {
        word instr = GenGetBinaryOperatorInstr(tok);
        GenPrintInstr3Operands(instr, 0,
                               GenWreg, 0,
                               B322OpConst, stack[i - 1][1],
                               GenWreg, 0);
      }
      else
      {
        word instr = GenGetBinaryOperatorInstr(tok);
        GenPopReg();
        GenPrintInstr3Operands(instr, 0,
                               GenLreg, 0,
                               GenRreg, 0,
                               GenWreg, 0);
      }
      break;

    case '/':
    case tokUDiv:
    case '%':
    case tokUMod:
      {
        printf("DIVISION/MOD is not supported!\n");
        /*
        GenPopReg();
        if (tok == '/' || tok == '%')
          GenPrintInstr3Operands(MipsInstrDiv, 0,
                                 B322OpRegZero, 0,
                                 GenLreg, 0,
                                 GenRreg, 0);
        else
          GenPrintInstr3Operands(MipsInstrDivU, 0,
                                 B322OpRegZero, 0,
                                 GenLreg, 0,
                                 GenRreg, 0);
        if (tok == '%' || tok == tokUMod)
          GenPrintInstr1Operand(MipsInstrMfHi, 0,
                                GenWreg, 0);
        else
          GenPrintInstr1Operand(MipsInstrMfLo, 0,
                                GenWreg, 0);
        */
      }
      break;

    case tokInc:
    case tokDec:
      if (stack[i - 1][0] == tokIdent)
      {
        GenIncDecIdent(GenWreg, v, stack[i - 1][1], tok);
      }
      else if (stack[i - 1][0] == tokLocalOfs)
      {
        GenIncDecLocal(GenWreg, v, stack[i - 1][1], tok);
      }
      else
      {
        GenPrintInstr3Operands(B322InstrOr, 0,
                               B322OpRegZero, 0,
                               GenWreg, 0,
                               TEMP_REG_A, 0);
        GenIncDecIndirect(GenWreg, TEMP_REG_A, v, tok);
      }
      break;
    case tokPostInc:
    case tokPostDec:
      if (stack[i - 1][0] == tokIdent)
      {
        GenPostIncDecIdent(GenWreg, v, stack[i - 1][1], tok);
      }
      else if (stack[i - 1][0] == tokLocalOfs)
      {
        GenPostIncDecLocal(GenWreg, v, stack[i - 1][1], tok);
      }
      else
      {
        GenPrintInstr3Operands(B322InstrOr, 0,
                               B322OpRegZero, 0,
                               GenWreg, 0,
                               TEMP_REG_A, 0);
        GenPostIncDecIndirect(GenWreg, TEMP_REG_A, v, tok);
      }
      break;

    case tokPostAdd:
    case tokPostSub:
      {
        word instr = GenGetBinaryOperatorInstr(tok);
        GenPopReg();
        if (GenWreg == GenLreg)
        {
          GenPrintInstr3Operands(B322InstrOr, 0,
                                 B322OpRegZero, 0,
                                 GenLreg, 0,
                                 TEMP_REG_B, 0);

          GenReadIndirect(GenWreg, TEMP_REG_B, v);
          GenPrintInstr3Operands(instr, 0,
                                 GenWreg, 0,
                                 GenRreg, 0,
                                 TEMP_REG_A, 0);
          GenWriteIndirect(TEMP_REG_B, TEMP_REG_A, v);
        }
        else
        {
          // GenWreg == GenRreg here
          GenPrintInstr3Operands(B322InstrOr, 0,
                                 B322OpRegZero, 0,
                                 GenRreg, 0,
                                 TEMP_REG_B, 0);

          GenReadIndirect(GenWreg, GenLreg, v);
          GenPrintInstr3Operands(instr, 0,
                                 GenWreg, 0,
                                 TEMP_REG_B, 0,
                                 TEMP_REG_B, 0);
          GenWriteIndirect(GenLreg, TEMP_REG_B, v);
        }
      }
      break;

    case tokAssignAdd:
    case tokAssignSub:
    case tokAssignMul:
    case tokAssignAnd:
    case tokAssignXor:
    case tokAssignOr:
    case tokAssignLSh:
    case tokAssignRSh:
    case tokAssignURSh:
      if (stack[i - 1][0] == tokRevLocalOfs || stack[i - 1][0] == tokRevIdent)
      {
        word instr = GenGetBinaryOperatorInstr(tok);

        if (stack[i - 1][0] == tokRevLocalOfs)
          GenReadLocal(TEMP_REG_B, v, stack[i - 1][1]);
        else
          GenReadIdent(TEMP_REG_B, v, stack[i - 1][1]);

        GenPrintInstr3Operands(instr, 0,
                               TEMP_REG_B, 0,
                               GenWreg, 0,
                               GenWreg, 0);

        if (stack[i - 1][0] == tokRevLocalOfs)
          GenWriteLocal(GenWreg, v, stack[i - 1][1]);
        else
          GenWriteIdent(GenWreg, v, stack[i - 1][1]);
      }
      else
      {
        word instr = GenGetBinaryOperatorInstr(tok);
        word lsaved, rsaved;
        GenPopReg();
        if (GenWreg == GenLreg)
        {
          GenPrintInstr3Operands(B322InstrOr, 0,
                                 B322OpRegZero, 0,
                                 GenLreg, 0,
                                 TEMP_REG_B, 0);
          lsaved = TEMP_REG_B;
          rsaved = GenRreg;
        }
        else
        {
          // GenWreg == GenRreg here
          GenPrintInstr3Operands(B322InstrOr, 0,
                                 B322OpRegZero, 0,
                                 GenRreg, 0,
                                 TEMP_REG_B, 0);
          rsaved = TEMP_REG_B;
          lsaved = GenLreg;
        }

        GenReadIndirect(GenWreg, GenLreg, v); // destroys either GenLreg or GenRreg because GenWreg coincides with one of them
        GenPrintInstr3Operands(instr, 0,
                               GenWreg, 0,
                               rsaved, 0,
                               GenWreg, 0);
        GenWriteIndirect(lsaved, GenWreg, v);
      }
      GenExtendRegIfNeeded(GenWreg, v);
      break;

    case tokAssignDiv:
    case tokAssignUDiv:
    case tokAssignMod:
    case tokAssignUMod:
      if (stack[i - 1][0] == tokRevLocalOfs || stack[i - 1][0] == tokRevIdent)
      {
        if (stack[i - 1][0] == tokRevLocalOfs)
          GenReadLocal(TEMP_REG_B, v, stack[i - 1][1]);
        else
          GenReadIdent(TEMP_REG_B, v, stack[i - 1][1]);

        if (tok == tokAssignDiv || tok == tokAssignMod)
        {
          printf("DIVISION/MOD is not supported!\n");
          /*
          GenPrintInstr3Operands(MipsInstrDiv, 0,
                                 B322OpRegZero, 0,
                                 TEMP_REG_B, 0,
                                 GenWreg, 0);*/
        }
        else
        {
          printf("DIVISION/MOD is not supported!\n");
          /*
          GenPrintInstr3Operands(MipsInstrDivU, 0,
                                 B322OpRegZero, 0,
                                 TEMP_REG_B, 0,
                                 GenWreg, 0);*/
        }
        if (tok == tokAssignMod || tok == tokAssignUMod)
        {
          printf("DIVISION/MOD is not supported!\n");
          /*
          GenPrintInstr1Operand(MipsInstrMfHi, 0,
                                GenWreg, 0);*/
        }
        else
        {
          printf("DIVISION/MOD is not supported!\n");
          /*
          GenPrintInstr1Operand(MipsInstrMfLo, 0,
                                GenWreg, 0);*/
        }

        if (stack[i - 1][0] == tokRevLocalOfs)
          GenWriteLocal(GenWreg, v, stack[i - 1][1]);
        else
          GenWriteIdent(GenWreg, v, stack[i - 1][1]);
      }
      else
      {
        word lsaved, rsaved;
        GenPopReg();
        if (GenWreg == GenLreg)
        {
          GenPrintInstr3Operands(B322InstrOr, 0,
                                 B322OpRegZero, 0,
                                 GenLreg, 0,
                                 TEMP_REG_B, 0);
          lsaved = TEMP_REG_B;
          rsaved = GenRreg;
        }
        else
        {
          // GenWreg == GenRreg here
          GenPrintInstr3Operands(B322InstrOr, 0,
                                 B322OpRegZero, 0,
                                 GenRreg, 0,
                                 TEMP_REG_B, 0);
          rsaved = TEMP_REG_B;
          lsaved = GenLreg;
        }

        GenReadIndirect(GenWreg, GenLreg, v); // destroys either GenLreg or GenRreg because GenWreg coincides with one of them
        if (tok == tokAssignDiv || tok == tokAssignMod)
        {
          printf("DIVISION/MOD is not supported!\n");
          /*
          GenPrintInstr3Operands(MipsInstrDiv, 0,
                                 B322OpRegZero, 0,
                                 GenWreg, 0,
                                 rsaved, 0);*/
        }
        else
        {
          printf("DIVISION/MOD is not supported!\n");
          /*
          GenPrintInstr3Operands(MipsInstrDivU, 0,
                                 B322OpRegZero, 0,
                                 GenWreg, 0,
                                 rsaved, 0);*/
        }
        if (tok == tokAssignMod || tok == tokAssignUMod)
        {
          printf("DIVISION/MOD is not supported!\n");
          /*
          GenPrintInstr1Operand(MipsInstrMfHi, 0,
                                GenWreg, 0);*/
        }
        else
        {
          printf("DIVISION/MOD is not supported!\n");
          /*
          GenPrintInstr1Operand(MipsInstrMfLo, 0,
                                GenWreg, 0);*/
        }
        GenWriteIndirect(lsaved, GenWreg, v);
      }
      GenExtendRegIfNeeded(GenWreg, v);
      break;

    case '=':
      if (stack[i - 1][0] == tokRevLocalOfs)
      {
        GenWriteLocal(GenWreg, v, stack[i - 1][1]);
      }
      else if (stack[i - 1][0] == tokRevIdent)
      {
        GenWriteIdent(GenWreg, v, stack[i - 1][1]);
      }
      else
      {
        GenPopReg();
        GenWriteIndirect(GenLreg, GenRreg, v);
        if (GenWreg != GenRreg)
          GenPrintInstr3Operands(B322InstrOr, 0,
                                 B322OpRegZero, 0,
                                 GenRreg, 0,
                                 GenWreg, 0);
      }
      GenExtendRegIfNeeded(GenWreg, v);
      break;

    case tokAssign0: // assignment of 0, while throwing away the expression result value
      if (stack[i - 1][0] == tokRevLocalOfs)
      {
        GenWriteLocal(B322OpRegZero, v, stack[i - 1][1]);
      }
      else if (stack[i - 1][0] == tokRevIdent)
      {
        GenWriteIdent(B322OpRegZero, v, stack[i - 1][1]);
      }
      else
      {
        GenWriteIndirect(GenWreg, B322OpRegZero, v);
      }
      break;

    case '<':         GenCmp(&i, 0x00); break;
    case tokLEQ:      GenCmp(&i, 0x01); break;
    case '>':         GenCmp(&i, 0x02); break;
    case tokGEQ:      GenCmp(&i, 0x03); break;
    case tokULess:    GenCmp(&i, 0x10); break;
    case tokULEQ:     GenCmp(&i, 0x11); break;
    case tokUGreater: GenCmp(&i, 0x12); break;
    case tokUGEQ:     GenCmp(&i, 0x13); break;
    case tokEQ:       GenCmp(&i, 0x04); break;
    case tokNEQ:      GenCmp(&i, 0x05); break;

    case tok_Bool:
      /* if 0 < wreg (if wreg > 0)
          wreg = 1
         else
          wreg = 0
      GenPrintInstr3Operands(MipsInstrSLTU, 0,
                             GenWreg, 0,
                             B322OpRegZero, 0,
                             GenWreg, 0);
      */
      GenPrintInstr3Operands(B322InstrBgtU, 0,
                             GenWreg, 0,
                             B322OpRegZero, 0,
                             B322OpConst, 3);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 0,
                               GenWreg, 0);
      GenPrintInstr1Operand(B322InstrJumpo, 0,
                             B322OpConst, 2);
      GenPrintInstr2Operands(B322InstrLoad, 0,
                               B322OpConst, 1,
                               GenWreg, 0);
      break;

    case tokSChar:
      /* just use as an int for now
      GenPrintInstr3Operands(B322InstrShiftl, 0,
                             GenWreg, 0,
                             B322OpConst, 24,
                             GenWreg, 0);
      GenPrintInstr3Operands(B322InstrShiftr, 0, //TODO this should have also replicated the sign bit (SRA)
                             GenWreg, 0,
                             B322OpConst, 24,
                             GenWreg, 0);
      */
      break;
    case tokUChar:
      /* just use as an int for now
      GenPrintInstr3Operands(B322InstrAnd, 0,
                             GenWreg, 0,
                             B322OpConst, 0xFF,
                             GenWreg, 0);
      */
      break;
    case tokShort:
      /* just use as an int for now
      GenPrintInstr3Operands(B322InstrShiftl, 0,
                             GenWreg, 0,
                             B322OpConst, 16,
                             GenWreg, 0);
      GenPrintInstr3Operands(B322InstrShiftr, 0, //TODO this should have also replicated the sign bit (SRA)
                             GenWreg, 0,
                             B322OpConst, 16,
                             GenWreg, 0);
      */
      break;
    case tokUShort:
      /*
      GenPrintInstr3Operands(MipsInstrAnd, 0,
                             GenWreg, 0,
                             GenWreg, 0,
                             B322OpConst, 0xFFFF);*/

      /* just use as an int for now
      GenPrintInstr3Operands(B322InstrShiftl, 0,
                             GenWreg, 0,
                             B322OpConst, 16,
                             GenWreg, 0);
      GenPrintInstr3Operands(B322InstrShiftr, 0,
                             GenWreg, 0,
                             B322OpConst, 16,
                             GenWreg, 0);
      */
      break;

    case tokShortCirc:
      if (doAnnotations)
      {
        if (v >= 0)
          printf2("&&\n");
        else
          printf2("||\n");
      }
      if (v >= 0)
        GenJumpIfZero(v); // &&
      else
        GenJumpIfNotZero(-v); // ||
      gotUnary = 0;
      break;
    case tokGoto:
      if (doAnnotations)
      {
        printf2("goto\n");
      }
      GenJumpUncond(v);
      gotUnary = 0;
      break;
    case tokLogAnd:
    case tokLogOr:
      GenNumLabel(v);
      break;

    case tokVoid:
      gotUnary = 0;
      break;

    case tokRevIdent:
    case tokRevLocalOfs:
    case tokComma:
    case tokReturn:
    case tokNum0:
      break;

    case tokIf:
      GenJumpIfNotZero(stack[i][1]);
      break;
    case tokIfNot:
      GenJumpIfZero(stack[i][1]);
      break;

    default:
      //error("Error: Internal Error: GenExpr0(): unexpected token %s\n", GetTokenName(tok));
      errorInternal(103);
      break;
    }
  }

  if (GenWreg != B322OpRegV0)
    errorInternal(104);
}

void GenDumpChar(word ch)
{
  if (ch < 0)
  {
    if (TokenStringLen)
      printf2("\n");
    return;
  }

  if (TokenStringLen == 0)
  {
    GenStartAsciiString();
    //printf2("\"");
  }

  // Just print as ascii value
  printd2(ch);
  printf2(" ");
}

void GenExpr(void)
{
  GenExpr0();
}

void GenFin(void)
{
  // No idea what this does (something with structs??), so I just literally converted it to B322 asm
  if (StructCpyLabel)
  {
    word lbl = LabelCnt++;

    puts2(CodeHeaderFooter[0]);

    GenNumLabel(StructCpyLabel);

    //puts2(" move r2, r6\n" //r2 := r6
    //      " move r3, r6"); //r3 := r3
    puts2(" or r0 r6 r2\n"
          " or r0 r6 r3");


    GenNumLabel(lbl);

    //puts2(" lbu r6, 0 r5\n"       // r6:=mem[r5]
    //      " addiu r5, r5, 1\n"    // r5:= r5+1
    //      " addiu r4, r4, -1\n"   // r4:= r4-1
    //      " sb r6, 0 r3\n"        // mem[r3]:=r6
    //      " addiu r3, r3, 1");    // r3:= r3+1

    puts2(" read 0 r5 r6\n"
          " add r5 1 r5\n"
          " sub r4 1 r4\n"
          " write 0 r3 r6\n"
          " add r3 1 r3");

    //printf2(" bne r4, r0, "); GenPrintNumLabel(lbl); // if r4 != 0, jump to lbl
    printf2("beq r4 r0 2\n");
    printf2("jump ");GenPrintNumLabel(lbl);


    puts2("");
    puts2(" jumpr 0 r15");

    puts2(CodeHeaderFooter[1]);
  }

  // Put all ending C specific wrapper code here
  if (compileUserBDOS)
  {
    printf2(
      ".code\n"
      
      "Int1:\n"
      
      "    load32 0x7BFFFF r13\n"
      "    load32 0 r14\n"
      "    addr2reg Return_Interrupt r1\n"
      "    or r0 r1 r15\n"
      "    jump int1\n"
      
      "    halt\n"
      
      "Int2:\n"
      
      "    load32 0x7BFFFF r13\n"
      "    load32 0 r14\n"
      "    addr2reg Return_Interrupt r1\n"
      "    or r0 r1 r15\n"
      "    jump int2\n"
      
      "    halt\n"
      
      
      "Int3:\n"
      
      "    load32 0x7BFFFF r13\n"
      "    load32 0 r14\n"
      "    addr2reg Return_Interrupt r1\n"
      "    or r0 r1 r15\n"
      "    jump int3\n"
      
      "    halt\n"
      
      
      "Int4:\n"
      
      "    load32 0x7BFFFF r13\n"
      "    load32 0 r14\n"
      "    addr2reg Return_Interrupt r1\n"
      "    or r0 r1 r15\n"
      "    jump int4\n"
      
      "    halt\n"
      
      "Return_Interrupt:\n"
      
      
      "    pop r1\n"
      "    jumpr 3 r1\n"
      
      "    halt\n"
    );
  }
  else
  {
    printf2(

      ".code\n"
      "Int1:\n"
      "    push r1\n"
      "    push r2\n"
      "    push r3\n"
      "    push r4\n"
      "    push r5\n"
      "    push r6\n"
      "    push r7\n"
      "    push r8\n"
      "    push r9\n"
      "    push r10\n"
      "    push r11\n"
      "    push r12\n"
      "    push r13\n"
      "    push r14\n"
      "    push r15\n"
      
      "    load32 0x7FFFFF r13\n"
      "    load32 0 r14\n"
      "    addr2reg Return_Interrupt r1\n"
      "    or r0 r1 r15\n"
      "    jump int1\n"
      
      "    halt\n"
      
      
      "Int2:\n"
      "    push r1\n"
      "    push r2\n"
      "    push r3\n"
      "    push r4\n"
      "    push r5\n"
      "    push r6\n"
      "    push r7\n"
      "    push r8\n"
      "    push r9\n"
      "    push r10\n"
      "    push r11\n"
      "    push r12\n"
      "    push r13\n"
      "    push r14\n"
      "    push r15\n"
      
      "    load32 0x7FFFFF r13\n"
      "    load32 0 r14\n"
      "    addr2reg Return_Interrupt r1\n"
      "    or r0 r1 r15\n"
      "    jump int2\n"
      
      "    halt\n"
      
      
      "Int3:\n"
      "    push r1\n"
      "    push r2\n"
      "    push r3\n"
      "    push r4\n"
      "    push r5\n"
      "    push r6\n"
      "    push r7\n"
      "    push r8\n"
      "    push r9\n"
      "    push r10\n"
      "    push r11\n"
      "    push r12\n"
      "    push r13\n"
      "    push r14\n"
      "    push r15\n"
      
      "    load32 0x7FFFFF r13\n"
      "    load32 0 r14\n"
      "    addr2reg Return_Interrupt r1\n"
      "    or r0 r1 r15\n"
      "    jump int3\n"
      
      "    halt\n"
      
      
      "Int4:\n"
      "    push r1\n"
      "    push r2\n"
      "    push r3\n"
      "    push r4\n"
      "    push r5\n"
      "    push r6\n"
      "    push r7\n"
      "    push r8\n"
      "    push r9\n"
      "    push r10\n"
      "    push r11\n"
      "    push r12\n"
      "    push r13\n"
      "    push r14\n"
      "    push r15\n"
      
      "    load32 0x7FFFFF r13\n"
      "    load32 0 r14\n"
      "    addr2reg Return_Interrupt r1\n"
      "    or r0 r1 r15\n"
      "    jump int4\n"
      
      "    halt\n"
      
      
      "Return_Interrupt:\n"
      "    pop r15\n"
      "    pop r14\n"
      "    pop r13\n"
      "    pop r12\n"
      "    pop r11\n"
      "    pop r10\n"
      "    pop r9\n"
      "    pop r8\n"
      "    pop r7\n"
      "    pop r6\n"
      "    pop r5\n"
      "    pop r4\n"
      "    pop r3\n"
      "    pop r2\n"
      "    pop r1\n"
      
      "    reti\n"
      "    halt\n");
  }

  if (compileOS)
  {
    printf2(
      ".code\n"
      
      "Syscall:\n"
      "    load32 0x3FFFFF r13\n"
      "    load32 0 r14\n"
      "    addr2reg Return_Syscall r1\n"
      "    or r0 r1 r15\n"
      "    jump syscall\n"
      
      "    halt\n"
      
      "Return_Syscall:\n"
      "    pop r1\n"
      "    jumpr 3 r1\n"
      
      "    halt\n"
      );
  }

  

}

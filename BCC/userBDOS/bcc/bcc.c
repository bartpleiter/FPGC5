/*
Copyright (c) 2021, b4rt-dev
Copyright (c) 2012-2020, Alexey Frunze
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
/*                                Main file                                  */
/*                                                                           */
/*****************************************************************************/

/* PLAN:
- move through program from execution start to finish
- implement missing (mostly FS) functions on the go (skip unimportant ones first, and do them later)
- try to implement vararg printf, since it will save hours of printf replacements
- FS functions (test/create library in a seperate test program):
  - fopen: just return a pointer to (global var!) the full path of the file, init cursor (private)
  - fput/get: open the file if not already opened, use cursor to read/write
*/


/* TODO: implement:
[] void exit(int);
[] int atoi(char*);

[x] size_t strlen(char*);
[x] char* strcpy(char*, char*);
[x] char* strchr(char*, int);
[x] int strcmp(char*, char*);
[x] int strncmp(char*, char*, size_t);
[x] void* memmove(void*, void*, size_t);
[x] void* memcpy(void*, void*, size_t);
[] void* memset(void*, int, size_t);
[x] int memcmp(void*, void*, size_t);

[] int isspace(int);
[x] int isdigit(int);
[x] int isalpha(int);
[x] int isalnum(int);

[] FILE* fopen(char*, char*);
[] int fclose(FILE*);
[] int putchar(int);
[] int fputc(int, FILE*);
[] int fgetc(FILE*);
[] int puts(char*);
[] int fputs(char*, FILE*);
[] int sprintf(char*, char*, ...);
[] int vsprintf(char*, char*, void*);
[] int printf(char*, ...);
[] int fprintf(FILE*, char*, ...);
[] int vprintf(char*, void*);
[] int vfprintf(FILE*, char*, void*);
[] int fgetpos(FILE*, fpos_t*);
[] int fsetpos(FILE*, fpos_t*);
*/


// Making most functions static helps with code optimization,
// use that to further reduce compiler's code size on RetroBSD.
#define STATIC

#define word char

#define NO_EXTRAS
#define CAN_COMPILE_32BIT
#define MIPS
#define B322
#define NO_PPACK
#define NO_TYPEDEF_ENUM
#define NO_FUNC_
#define NO_EXTRA_WARNS
#define NO_FOR_DECL
#define NO_STRUCT_BY_VAL
#define NO_FP
#define NO_WCHAR

#define NULL 0

#define size_t word //unsigned int

#define CHAR_BIT (8)
#define CHAR_MIN (-128)
#define CHAR_MAX (127)

#define INT_MAX (2147483647)
#define INT_MIN (-2147483648)

#define UINT_MAX (4294967295u)
#define UINT_MIN (0u)

#define EXIT_FAILURE 1



#include "lib/math.c"
#include "lib/sys.c"
#include "lib/gfx.c"
#include "lib/stdlib.c"
#include "lib/fs.c"
#include "lib/stdio.c"

////////////////////////////////////////////////////////////////////////////////


struct fpos_t_
{
  union
  {
    unsigned short halves[2]; // for 16-bit memory models without 32-bit longs
    int align; // for alignment on machine word boundary
  } u;
}; // keep in sync with stdio.h !!!
#define fpos_t struct fpos_t_
int fgetpos(word, fpos_t*);
int fsetpos(word, fpos_t*);



// all public macros

#define MAX_IDENT_LEN         63
#define MAX_STRING_LEN        255
#define MAX_CHAR_QUEUE_LEN    (MAX_STRING_LEN + 1)
#define MAX_MACRO_TABLE_LEN   (4096+1024)
#define MAX_IDENT_TABLE_LEN   (4096+1024+512) // must be greater than MAX_IDENT_LEN
#define SYNTAX_STACK_MAX      (2048+1024)
#define MAX_FILE_NAME_LEN     95

#define MAX_INCLUDES         8
#define PREP_STACK_SIZE      8
#define MAX_SEARCH_PATH      256


/* +-~* /% &|^! << >> && || < <= > >= == !=  () *[] ++ -- = += -= ~= *= /= %= &= |= ^= <<= >>= {} ,;: -> ... */

#define tokEof        0
#define tokNumInt     1
#define tokNumUint    2
#define tokLitStr     3

#define tokLShift     4
#define tokRShift     5
#define tokLogAnd     6
#define tokLogOr      7
#define tokEQ         8
#define tokNEQ        9
#define tokLEQ        10
#define tokGEQ        11
#define tokInc        12
#define tokDec        13
#define tokArrow      14
#define tokEllipsis   15

#define tokIdent      16
#define tokVoid       17
#define tokChar       18
#define tokInt        19
#define tokReturn     20
#define tokGoto       21
#define tokIf         22
#define tokElse       23
#define tokWhile      24
#define tokCont       25
#define tokBreak      26
#define tokSizeof     27

#define tokAssignMul  'A'
#define tokAssignDiv  'B'
#define tokAssignMod  'C'
#define tokAssignAdd  'D'
#define tokAssignSub  'E'
#define tokAssignLSh  'F'
#define tokAssignRSh  'G'
#define tokAssignAnd  'H'
#define tokAssignXor  'I'
#define tokAssignOr   'J'

#define tokFloat      'a'
#define tokDouble     'b'
#define tokLong       'c'
#define tokShort      'd'
#define tokUnsigned   'e'
#define tokSigned     'f'
#define tokConst      'g'
#define tokVolatile   'h'
#define tokRestrict   'i'
#define tokStatic     'j'
#define tokInline     'k'
#define tokExtern     'l'
#define tokAuto       'm'
#define tokRegister   'n'
#define tokTypedef    'o'
#define tokEnum       'p'
#define tokStruct     'q'
#define tokUnion      'r'
#define tokDo         's'
#define tokFor        't'
#define tokSwitch     'u'
#define tokCase       'v'
#define tokDefault    'w'
#define tok_Bool      'x'
#define tok_Complex   'y'
#define tok_Imagin    'z'

#define tok_Asm       '`'

/* Pseudo-tokens (converted from others or generated) */
#define tokURShift    28
#define tokUDiv       29
#define tokUMod       30
#define tokAssignURSh 31
#define tokAssignUDiv '@'
#define tokAssignUMod 'K'
#define tokComma      '0'

#define tokIfNot      'L'

#define tokUnaryAnd   'M'
#define tokUnaryStar  'N'
#define tokUnaryPlus  'O'
#define tokUnaryMinus 'P'

#define tokPostInc    'Q'
#define tokPostDec    'R'
#define tokPostAdd    'S'
#define tokPostSub    'T'

#define tokULess      'U'
#define tokUGreater   'V'
#define tokULEQ       'W'
#define tokUGEQ       'X'

#define tokLocalOfs   'Y'
#define tokShortCirc  'Z'

#define tokSChar      0x80
#define tokUChar      0x81
#define tokUShort     0x82
#define tokULong      0x83
//#define tokLongLong   0x84
//#define tokULongLong  0x85
//#define tokLongDbl    0x86
#define tokGotoLabel  0x8F
#define tokStructPtr  0x90
#define tokTag        0x91
#define tokMemberIdent 0x92
#define tokEnumPtr    0x93
#define tokIntr       0x94
#define tokNumFloat   0x95
#define tokNumCharWide 0x96
#define tokLitStrWide 0x97

//#define FormatFlat      0
#define FormatSegmented 1
//#define FormatSegTurbo  2
#define FormatSegHuge   3
#define FormatSegUnreal 4

#define SymVoidSynPtr 0
#define SymIntSynPtr  1
#define SymUintSynPtr 2
#define SymWideCharSynPtr 3
#define SymFloatSynPtr 4
#define SymFuncPtr    5

#define STACK_SIZE 129

#define SymFxn       1
#define SymGlobalVar 2
#define SymGlobalArr 3
#define SymLocalVar  4
#define SymLocalArr  5


// all public prototypes
STATIC
unsigned truncUint(unsigned);
STATIC
word truncInt(word);

STATIC
word GetToken(void);
STATIC
char* GetTokenName(word token);


STATIC
void DumpMacroTable(void);


STATIC
word AddIdent(char* name);
STATIC
word FindIdent(char* name);

STATIC
void DumpIdentTable(void);

STATIC
char* lab2str(char* p, word n);

STATIC
void GenInit(void);
STATIC
void GenFin(void);
STATIC
word GenInitParams(word argc, char** argv, word* idx);
STATIC
void GenInitFinalize(void);
STATIC
void GenStartCommentLine(void);
STATIC
void GenWordAlignment(word bss);
STATIC
void GenLabel(char* Label, word Static);
STATIC
void GenNumLabel(word Label);
STATIC
void GenZeroData(unsigned Size, word bss);
STATIC
void GenIntData(word Size, word Val);
STATIC
void GenStartAsciiString(void);
STATIC
void GenAddrData(word Size, char* Label, word ofs);

STATIC
void GenJumpUncond(word Label);
STATIC
void GenJumpIfZero(word Label);
STATIC
void GenJumpIfNotZero(word Label);
STATIC
void GenJumpIfEqual(word val, word Label);

STATIC
void GenFxnProlog(void);
STATIC
void GenFxnEpilog(void);
void GenIsrProlog(void);
void GenIsrEpilog(void);

STATIC
word GenMaxLocalsSize(void);

STATIC
void GenDumpChar(word ch);
STATIC
void GenExpr(void);

STATIC
void PushSyntax(word t);
STATIC
void PushSyntax2(word t, word v);


STATIC
void DumpSynDecls(void);


STATIC
void push2(word v, word v2);
STATIC
void ins2(word pos, word v, word v2);
STATIC
void ins(word pos, word v);
STATIC
void del(word pos, word cnt);

STATIC
word TokenStartsDeclaration(word t, word params);
STATIC
word ParseDecl(word tok, unsigned structInfo[4], word cast, word label);

STATIC
void ShiftChar(void);
STATIC
word puts2(char*);
STATIC
word printf2(char*, ...);

STATIC
void error(char* format, ...);
STATIC
void warning(char* format, ...);
STATIC
void errorFile(char* n);
STATIC
void errorFileName(void);
STATIC
void errorInternal(word n);
STATIC
void errorChrStr(void);
STATIC
void errorStrLen(void);
STATIC
void errorUnexpectedToken(word tok);
STATIC
void errorDirective(void);
STATIC
void errorCtrlOutOfScope(void);
STATIC
void errorDecl(void);
STATIC
void errorVarSize(void);
STATIC
void errorInit(void);
STATIC
void errorUnexpectedVoid(void);
STATIC
void errorOpType(void);
STATIC
void errorNotLvalue(void);
STATIC
void errorNotConst(void);
STATIC
void errorLongExpr(void);

STATIC
word FindSymbol(char* s);
STATIC
word SymType(word SynPtr);
STATIC
word FindTaggedDecl(char* s, word start, word* CurScope);
STATIC
word GetDeclSize(word SyntaxPtr, word SizeForDeref);

STATIC
word ParseExpr(word tok, word* GotUnary, word* ExprTypeSynPtr, word* ConstExpr, word* ConstVal, word option, word option2);
STATIC
word GetFxnInfo(word ExprTypeSynPtr, word* MinParams, word* MaxParams, word* ReturnExprTypeSynPtr, word* FirstParamSynPtr);

// all data

word verbose = 0;
word warnings = 0;
word warnCnt = 0;

// custom compiler flags
word compileUserBDOS = 0;
word compileOS = 0;

// prep.c data

// TBD!!! get rid of TokenIdentName[] and TokenValueString[]
// and work with CharQueue[] directly
word TokenValueInt = 0;
char TokenIdentName[MAX_IDENT_LEN + 1];
word TokenIdentNameLen = 0;
char TokenValueString[MAX_STRING_LEN + 1];
unsigned TokenStringLen = 0;
unsigned TokenStringSize = 0; // TokenStringLen * sizeof(char/wchar_t)
word LineNo = 1;
word LinePos = 1;
char CharQueue[MAX_CHAR_QUEUE_LEN];
word CharQueueLen = 0;

/*
  Macro table entry format:
    idlen char:     identifier length (<= 127)
    id char[idlen]: identifier (ASCIIZ)
    exlen char:     length of what the identifier expands into (<= 127)
    ex char[exlen]: what the identifier expands into (ASCII)
*/
char MacroTable[MAX_MACRO_TABLE_LEN];
word MacroTableLen = 0;

/*
  Identifier table entry format:
    id char[idlen]: string (ASCIIZ)
    idlen char:     string length (<= 127)
*/
char IdentTable[MAX_IDENT_TABLE_LEN];
word IdentTableLen = 0;
word DummyIdent; // corresponds to empty string

#define MAX_GOTO_LABELS 16

word gotoLabels[MAX_GOTO_LABELS][2];
// gotoLabStat[]: bit 1 = used (by "goto label;"), bit 0 = defined (with "label:")
char gotoLabStat[MAX_GOTO_LABELS];
word gotoLabCnt = 0;

#define MAX_CASES 128

word Cases[MAX_CASES][2]; // [0] is case constant, [1] is case label number
word CasesCnt = 0;

// Data structures to support #include
word FileCnt = 0;
char FileNames[MAX_INCLUDES][MAX_FILE_NAME_LEN + 1];
word Files[MAX_INCLUDES]; // FILE
word OutFile; // FILE
char CharQueues[MAX_INCLUDES][3];
word LineNos[MAX_INCLUDES];
word LinePoss[MAX_INCLUDES];
char SysSearchPaths[MAX_SEARCH_PATH];
word SysSearchPathsLen = 0;
char SearchPaths[MAX_SEARCH_PATH];
word SearchPathsLen = 0;

// Data structures to support #ifdef/#ifndef,#else,#endif
word PrepDontSkipTokens = 1;
word PrepStack[PREP_STACK_SIZE][2];
word PrepSp = 0;


// expr.c data

word ExprLevel = 0;

// TBD??? merge expression and operator stacks into one
word stack[STACK_SIZE][2];
word sp = 0;

#define OPERATOR_STACK_SIZE STACK_SIZE
word opstack[OPERATOR_STACK_SIZE][2];
word opsp = 0;

// smc.c data

word OutputFormat = FormatSegmented;
word GenExterns = 1;
word UseBss = 1;

// Names of C functions and variables are usually prefixed with an underscore.
// One notable exception is the ELF format used by gcc in Linux.
// Global C identifiers in the ELF format should not be predixed with an underscore.
word UseLeadingUnderscores = 1;

char* FileHeader = "";
char* CodeHeaderFooter[2] = { "", "" };
char* DataHeaderFooter[2] = { "", "" };
char* RoDataHeaderFooter[2] = { "", "" };
char* BssHeaderFooter[2] = { "", "" };
char** CurHeaderFooter;

word CharIsSigned = 1;
word SizeOfWord = 2; // in chars (char can be a multiple of octets); ints and pointers are of word size
word SizeOfWideChar = 2; // in chars/bytes, 2 or 4
word WideCharIsSigned = 0; // 0 or 1
word WideCharType1;
word WideCharType2; // (un)signed counterpart of WideCharType1

// TBD??? implement a function to allocate N labels with overflow checks
word LabelCnt = 1; // label counter for jumps
word StructCpyLabel = 0; // label of the function to copy structures/unions
word StructPushLabel = 0; // label of the function to push structures/unions onto the stack

// call stack (from higher to lower addresses):
//   arg n
//   ...
//   arg 1
//   return address
//   saved xbp register
//   local var 1
//   ...
//   local var n
word CurFxnSyntaxPtr = 0;
word CurFxnParamCntMin = 0;
word CurFxnParamCntMax = 0;
word CurFxnLocalOfs = 0; // negative
word CurFxnMinLocalOfs = 0; // negative

word CurFxnReturnExprTypeSynPtr = 0;
word CurFxnEpilogLabel = 0;

char* CurFxnName = NULL;
word IsMain; // if inside main()

word ParseLevel = 0; // Parse level/scope (file:0, fxn:1+)
word ParamLevel = 0; // 1+ if parsing params, 0 otherwise

unsigned char SyntaxStack0[SYNTAX_STACK_MAX];
word SyntaxStack1[SYNTAX_STACK_MAX];
word SyntaxStackCnt;






// all code

STATIC
unsigned truncUint(unsigned n)
{
  // Truncate n to SizeOfWord * 8 bits
  if (SizeOfWord == 2)
    n &= ~(~0u << 8 << 8);
  else if (SizeOfWord == 4)
    n &= ~(~0u << 8 << 12 << 12);
  return n;
}

STATIC
word truncInt(word n)
{
  // Truncate n to SizeOfWord * 8 bits and then sign-extend it
  unsigned un = n;
  if (SizeOfWord == 2)
  {
    un &= ~(~0u << 8 << 8);
    un |= (((un >> 8 >> 7) & 1) * ~0u) << 8 << 8;
  }
  else if (SizeOfWord == 4)
  {
    un &= ~(~0u << 8 << 12 << 12);
    un |= (((un >> 8 >> 12 >> 11) & 1) * ~0u) << 8 << 12 << 12;
  }
  return (word)un;
}

// prep.c code

STATIC
word FindMacro(char* name)
{
  word i;

  for (i = 0; i < MacroTableLen; )
  {
    if (!strcmp(MacroTable + i + 1, name))
      return i + 1 + MacroTable[i];

    i = i + 1 + MacroTable[i]; // skip id
    i = i + 1 + MacroTable[i]; // skip ex
  }

  return -1;
}

STATIC
word UndefineMacro(char* name)
{
  word i;

  for (i = 0; i < MacroTableLen; )
  {
    if (!strcmp(MacroTable + i + 1, name))
    {
      word len = 1 + MacroTable[i]; // id part len
      len = len + 1 + MacroTable[i + len]; // + ex part len

      memmove(MacroTable + i,
              MacroTable + i + len,
              MacroTableLen - i - len);
      MacroTableLen -= len;

      return 1;
    }

    i = i + 1 + MacroTable[i]; // skip id
    i = i + 1 + MacroTable[i]; // skip ex
  }

  return 0;
}

STATIC
void AddMacroIdent(char* name)
{
  word l = strlen(name);

  if (l >= 127)
  {
    error("Macro identifier too long ");
    error(name);
    error("\n");
  }

  if (MAX_MACRO_TABLE_LEN - MacroTableLen < l + 3)
    error("Macro table exhausted\n");

  MacroTable[MacroTableLen++] = l + 1; // idlen
  strcpy(MacroTable + MacroTableLen, name);
  MacroTableLen += l + 1;

  MacroTable[MacroTableLen] = 0; // exlen
}

STATIC
void AddMacroExpansionChar(char e)
{
  if (e == '\0')
  {
    // finalize macro definition entry
    // remove trailing space first
    while (MacroTable[MacroTableLen] &&
           strchr(" \t", MacroTable[MacroTableLen + MacroTable[MacroTableLen]]))
      MacroTable[MacroTableLen]--;
    MacroTableLen += 1 + MacroTable[MacroTableLen];
    return;
  }

  if (MacroTableLen + 1 + MacroTable[MacroTableLen] >= MAX_MACRO_TABLE_LEN)
    error("Macro table exhausted\n");

  if (MacroTable[MacroTableLen] >= 127)
    error("Macro definition too long\n");

  MacroTable[MacroTableLen + 1 + MacroTable[MacroTableLen]] = e;
  MacroTable[MacroTableLen]++;
}

STATIC
void DefineMacro(char* name, char* expansion)
{
  AddMacroIdent(name);
  do
  {
    AddMacroExpansionChar(*expansion);
  } while (*expansion++ != '\0');
}

STATIC
void DumpMacroTable(void)
{
  word i, j;

  puts2("");
  GenStartCommentLine(); printf2("Macro table:\n");
  for (i = 0; i < MacroTableLen; )
  {
    GenStartCommentLine(); 
    printf2("Macro ");
    printf2(MacroTable + i + 1);
    printf2(" = ");

    i = i + 1 + MacroTable[i]; // skip id
    printf2("`");
    j = MacroTable[i++];
    while (j--)
    {
      char* c = " ";
      c[0] = MacroTable[i++];
      printf2(c);
    }
    printf2("`\n");
  }
  GenStartCommentLine(); //TODO: printf2("Bytes used: %d/%d\n\n", MacroTableLen, MAX_MACRO_TABLE_LEN);
}

STATIC
word FindIdent(char* name)
{
  word i;
  for (i = IdentTableLen; i > 0; )
  {
    i -= 1 + IdentTable[i - 1];
    if (!strcmp(IdentTable + i, name))
      return i;
  }
  return -1;
}

STATIC
word AddIdent(char* name)
{
  word i, len;

  if ((i = FindIdent(name)) >= 0)
    return i;

  i = IdentTableLen;
  len = strlen(name);

  if (len >= 127)
    error("Identifier too long\n");

  if (MAX_IDENT_TABLE_LEN - IdentTableLen < len + 2)
    error("Identifier table exhausted\n");

  strcpy(IdentTable + IdentTableLen, name);
  IdentTableLen += len + 1;
  IdentTable[IdentTableLen++] = len + 1;

  return i;
}

STATIC
word AddNumericIdent(word n)
{
  char s[1 + (2 + CHAR_BIT * sizeof n) / 3];
  char *p = s + sizeof s;
  *--p = '\0';
  p = lab2str(p, n);
  return AddIdent(p);
}

STATIC
word AddGotoLabel(char* name, word label)
{
  word i;
  for (i = 0; i < gotoLabCnt; i++)
  {
    if (!strcmp(IdentTable + gotoLabels[i][0], name))
    {
      if (gotoLabStat[i] & label)
      {
        error("Redefinition of label ");
        error(name);
        error("\n");
      }
      gotoLabStat[i] |= 2*!label + label;
      return gotoLabels[i][1];
    }
  }
  if (gotoLabCnt >= MAX_GOTO_LABELS)
    error("Goto table exhausted\n");
  gotoLabels[gotoLabCnt][0] = AddIdent(name);
  gotoLabels[gotoLabCnt][1] = LabelCnt++;
  gotoLabStat[gotoLabCnt] = 2*!label + label;
  return gotoLabels[gotoLabCnt++][1];
}

STATIC
void UndoNonLabelIdents(word len)
{
  word i;
  IdentTableLen = len;
  for (i = 0; i < gotoLabCnt; i++)
    if (gotoLabels[i][0] >= len)
    {
      char* pfrom = IdentTable + gotoLabels[i][0];
      char* pto = IdentTable + IdentTableLen;
      word l = strlen(pfrom) + 2;
      memmove(pto, pfrom, l);
      IdentTableLen += l;
      gotoLabels[i][0] = pto - IdentTable;
    }
}

STATIC
void AddCase(word val, word label)
{
  if (CasesCnt >= MAX_CASES)
    error("Case table exhausted\n");

  Cases[CasesCnt][0] = val;
  Cases[CasesCnt++][1] = label;
}

STATIC
void DumpIdentTable(void)
{
  word i;
  puts2("");
  GenStartCommentLine(); printf2("Identifier table:\n");
  for (i = 0; i < IdentTableLen; )
  {
    GenStartCommentLine(); 
    printf2("Ident ");
    printf2(IdentTable + i);
    printf2("\n");
    i += strlen(IdentTable + i) + 2;
  }
  GenStartCommentLine(); //TODO: printf2("Bytes used: %d/%d\n\n", IdentTableLen, MAX_IDENT_TABLE_LEN);
}

char* rws[] =
{
  "break", "case", "char", "continue", "default", "do", "else",
  "extern", "for", "if", "int", "return", "signed", "sizeof",
  "static", "switch", "unsigned", "void", "while", "asm", "auto",
  "const", "double", "enum", "float", "goto", "inline", "long",
  "register", "restrict", "short", "struct", "typedef", "union",
  "volatile", "_Bool", "_Complex", "_Imaginary",
  "__interrupt"
};

unsigned char rwtk[] =
{
  tokBreak, tokCase, tokChar, tokCont, tokDefault, tokDo, tokElse,
  tokExtern, tokFor, tokIf, tokInt, tokReturn, tokSigned, tokSizeof,
  tokStatic, tokSwitch, tokUnsigned, tokVoid, tokWhile, tok_Asm, tokAuto,
  tokConst, tokDouble, tokEnum, tokFloat, tokGoto, tokInline, tokLong,
  tokRegister, tokRestrict, tokShort, tokStruct, tokTypedef, tokUnion,
  tokVolatile, tok_Bool, tok_Complex, tok_Imagin,
  tokIntr
};

STATIC
word GetTokenByWord(char* wrd)
{
  unsigned i;

  for (i = 0; i < division(sizeof rws, sizeof rws[0]); i++)
    if (!strcmp(rws[i], wrd))
      return rwtk[i];

  return tokIdent;
}

unsigned char tktk[] =
{
  tokEof,
  // Single-character operators and punctuators:
  '+', '-', '~', '*', '/', '%', '&', '|', '^', '!',
  '<', '>', '(', ')', '[', ']',
  '{', '}', '=', ',', ';', ':', '.', '?',
  // Multi-character operators and punctuators:
  tokLShift, tokLogAnd, tokEQ, tokLEQ, tokInc, tokArrow, tokAssignMul,
  tokAssignMod, tokAssignSub, tokAssignRSh, tokAssignXor,
  tokRShift, tokLogOr, tokNEQ, tokGEQ, tokDec, tokEllipsis,
  tokAssignDiv, tokAssignAdd, tokAssignLSh, tokAssignAnd, tokAssignOr,
  // Some of the above tokens get converted into these in the process:
  tokUnaryAnd, tokUnaryPlus, tokPostInc, tokPostAdd,
  tokULess, tokULEQ, tokURShift, tokUDiv, tokUMod, tokComma,
  tokUnaryStar, tokUnaryMinus, tokPostDec, tokPostSub,
  tokUGreater, tokUGEQ, tokAssignURSh, tokAssignUDiv, tokAssignUMod,
  // Helper (pseudo-)tokens:
  tokNumInt, tokLitStr, tokLocalOfs, tokNumUint, tokIdent, tokShortCirc,
  tokSChar, tokShort, tokLong, tokUChar, tokUShort, tokULong, tokNumFloat,
  tokNumCharWide, tokLitStrWide
};

char* tks[] =
{
  "<EOF>",
  // Single-character operators and punctuators:
  "+", "-", "~", "*", "/", "%", "&", "|", "^", "!",
  "<", ">", "(", ")", "[", "]",
  "{", "}", "=", ",", ";", ":", ".", "?",
  // Multi-character operators and punctuators:
  "<<", "&&", "==", "<=", "++", "->", "*=",
  "%=", "-=", ">>=", "^=",
  ">>", "||", "!=", ">=", "--", "...",
  "/=", "+=", "<<=", "&=", "|=",
  // Some of the above tokens get converted into these in the process:
  "&u", "+u", "++p", "+=p",
  "<u", "<=u", ">>u", "/u", "%u", ",b",
  "*u", "-u", "--p", "-=p",
  ">u", ">=u", ">>=u", "/=u", "%=u",
  // Helper (pseudo-)tokens:
  "<NumInt>",  "<LitStr>", "<LocalOfs>", "<NumUint>", "<Ident>", "<ShortCirc>",
  "signed char", "short", "long", "unsigned char", "unsigned short", "unsigned long", "float",
  "<NumCharWide>", "<LitStrWide>"
};

STATIC
char* GetTokenName(word token)
{
  unsigned i;

/* +-~* /% &|^! << >> && || < <= > >= == !=  () *[] ++ -- = += -= ~= *= /= %= &= |= ^= <<= >>= {} ,;: -> ... */

  // Tokens other than reserved keywords:
  for (i = 0; i < division(sizeof tktk , sizeof tktk[0]); i++)
    if (tktk[i] == token)
      return tks[i];

  // Reserved keywords:
  for (i = 0; i < division(sizeof rws , sizeof rws[0]); i++)
    if (rwtk[i] == token)
      return rws[i];

  //error("Internal Error: GetTokenName(): Invalid token %d\n", token);
  errorInternal(1);
  return "";
}

STATIC
word GetNextChar(void)
{
  word ch = EOF;

  if (FileCnt && Files[FileCnt - 1])
  {
    if ((ch = fgetc(Files[FileCnt - 1])) == EOF)
    {
      fclose(Files[FileCnt - 1]);
      Files[FileCnt - 1] = NULL;

      // store the last line/pos, they may still be needed later
      LineNos[FileCnt - 1] = LineNo;
      LinePoss[FileCnt - 1] = LinePos;

      // don't drop the file record just yet
    }
  }

  return ch;
}

STATIC
void ShiftChar(void)
{
  if (CharQueueLen)
    memmove(CharQueue, CharQueue + 1, --CharQueueLen);

  // make sure there always are at least 3 chars in the queue
  while (CharQueueLen < 3)
  {
    word ch = GetNextChar();
    if (ch == EOF)
      ch = '\0';
    CharQueue[CharQueueLen++] = ch;
  }
}

STATIC
void ShiftCharN(word n)
{
  while (n-- > 0)
  {
    ShiftChar();
    LinePos++;
  }
}

STATIC
void IncludeFile(word quot)
{
  word nlen = strlen(TokenValueString);

  if (CharQueueLen != 3)
    //error("#include parsing error\n");
    errorInternal(2);

  if (FileCnt >= MAX_INCLUDES)
    error("Too many include files\n");

  // store the including file's position and buffered chars
  LineNos[FileCnt - 1] = LineNo;
  LinePoss[FileCnt - 1] = LinePos;
  memcpy(CharQueues[FileCnt - 1], CharQueue, CharQueueLen);

  // open the included file

  if (nlen > MAX_FILE_NAME_LEN)
    //error("File name too long\n");
    errorFileName();

  // DONE: differentiate between quot == '"' and quot == '<'

  // First, try opening "file" in the current directory
  // (Open Watcom C/C++ 1.9, Turbo C++ 1.01 use the current directory,
  // unlike gcc, which uses the same directory as the current file)
  if (quot == '"')
  {
    // Get path from c file to compile, so it can be appended to the include paths
    char cFileDir[255] = "";
    strcpy(cFileDir, FileNames[0]);

    word len = strlen(cFileDir);  
    while (len > 0) 
    {
       len--;
       if (cFileDir[len] == '/') 
       {
          cFileDir[len+1] = '\0'; // keep the slash
          break;
       }
    }
    if (len == 0) // remove directory if there is none
    {
      cFileDir[0] = '\0';
    }
    strcpy(FileNames[FileCnt], TokenValueString);
    strcat(cFileDir, FileNames[FileCnt]);
    Files[FileCnt] = fopen(cFileDir, "r");
  }

  // Next, iterate the search paths trying to open "file" or <file>.
  // "file" is first searched using the list provided by the -I option.
  // "file" is then searched using the list provided by the -SI option.
  // <file> is searched using the list provided by the -SI option.
  if (Files[FileCnt] == NULL)
  {
    word i;
    char *paths = SearchPaths;
    word pl = SearchPathsLen;
    for (;;)
    {
      if (quot == '<')
      {
        paths = SysSearchPaths;
        pl = SysSearchPathsLen;
      }
      for (i = 0; i < pl; )
      {
        word plen = strlen(paths + i);
        if (plen + 1 + nlen < MAX_FILE_NAME_LEN)
        {
          strcpy(FileNames[FileCnt], paths + i);
          strcpy(FileNames[FileCnt] + plen + 1, TokenValueString);
          // Use '/' as a separator, typical for Linux/Unix,
          // but also supported by file APIs in DOS/Windows just as '\\'
          FileNames[FileCnt][plen] = '/';
          if ((Files[FileCnt] = fopen(FileNames[FileCnt], "r")) != NULL)
            break;
        }
        i += plen + 1;
      }
      if (Files[FileCnt] || quot == '<')
        break;
      quot = '<';
    }
  }

  if (Files[FileCnt] == NULL)
  {
    //error("Cannot open file \"%s\"\n", TokenValueString);
    errorFile(TokenValueString);
  }

  // reset line/pos and empty the char queue
  CharQueueLen = 0;
  LineNo = LinePos = 1;
  FileCnt++;

  // fill the char queue with file data
  ShiftChar();
}

STATIC
word EndOfFiles(void)
{
  // if there are no including files, we're done
  if (!--FileCnt)
    return 1;

  // restore the including file's position and buffered chars
  LineNo = LineNos[FileCnt - 1];
  LinePos = LinePoss[FileCnt - 1];
  CharQueueLen = 3;
  memcpy(CharQueue, CharQueues[FileCnt - 1], CharQueueLen);

  return 0;
}

STATIC
void SkipSpace(word SkipNewLines)
{
  char* p = CharQueue;

  while (*p != '\0')
  {
    if (strchr(" \t\f\v", *p))
    {
      ShiftCharN(1);
      continue;
    }

    if (strchr("\r\n", *p))
    {
      if (!SkipNewLines)
        return;

      if (*p == '\r' && p[1] == '\n')
        ShiftChar();

      ShiftChar();
      LineNo++;
      LinePos = 1;
      continue;
    }

    if (*p == '/')
    {
      if (p[1] == '/')
      {
        // // comment
        ShiftCharN(2);
        while (!strchr("\r\n", *p))
          ShiftCharN(1);
        continue;
      }
      else if (p[1] == '*')
      {
        // /**/ comment
        ShiftCharN(2);
        while (*p != '\0' && !(*p == '*' && p[1] == '/'))
        {
          if (strchr("\r\n", *p))
          {
            if (!SkipNewLines)
              error("Invalid comment\n");

            if (*p == '\r' && p[1] == '\n')
              ShiftChar();

            ShiftChar();
            LineNo++;
            LinePos = 1;
          }
          else
          {
            ShiftCharN(1);
          }
        }
        if (*p == '\0')
          error("Invalid comment\n");
        ShiftCharN(2);
        continue;
      }
    } // endof if (*p == '/')

    break;
  } // endof while (*p != '\0')
}

STATIC
void SkipLine(void)
{
  char* p = CharQueue;

  while (*p != '\0')
  {
    if (strchr("\r\n", *p))
    {
      if (*p == '\r' && p[1] == '\n')
        ShiftChar();

      ShiftChar();
      LineNo++;
      LinePos = 1;
      break;
    }
    else
    {
      ShiftCharN(1);
    }
  }
}

STATIC
void GetIdent(void)
{
  char* p = CharQueue;

  if (*p != '_' && !isalpha(*p & 0xFFu))
    error("Identifier expected\n");

  TokenIdentNameLen = 0;
  TokenIdentName[TokenIdentNameLen++] = *p;
  TokenIdentName[TokenIdentNameLen] = '\0';
  ShiftCharN(1);

  while (*p == '_' || isalnum(*p & 0xFFu))
  {
    if (TokenIdentNameLen == MAX_IDENT_LEN)
    {
      error("Identifier too long ");
      error(TokenIdentName);
      error("\n");
    }
    TokenIdentName[TokenIdentNameLen++] = *p;
    TokenIdentName[TokenIdentNameLen] = '\0';
    ShiftCharN(1);
  }
}

STATIC
unsigned GetCharValue(word wide)
{
  char* p = CharQueue;
  unsigned ch = 0;
  word cnt = 0;
  if (*p == '\\')
  {
    ShiftCharN(1);
    if (strchr("\n\r", *p))
      goto lerr;
    if (*p == 'x')
    {
      // hexadecimal character codes \xN+
      // hexadecimal escape sequence is not limited in length per se
      // (may have many leading zeroes)
      static char digs[] = "0123456789ABCDEFabcdef";
      static char vals[] =
      {
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
        10, 11, 12, 13, 14, 15,
        10, 11, 12, 13, 14, 15
      };
      char* pp;
      word zeroes = 0;
      ShiftCharN(1);
      if (strchr("\n\r", *p))
        goto lerr;
      if (*p == '0')
      {
        do
        {
          ShiftCharN(1);
        } while (*p == '0');
        zeroes = 1;
      }
      while (*p && (pp = strchr(digs, *p)) != NULL)
      {
        ch <<= 4;
        ch |= vals[pp - digs];
        ShiftCharN(1);
        if (++cnt > 2)
        {
          if (PrepDontSkipTokens)
            goto lerr;
        }
      }
      if (zeroes + cnt == 0)
        goto lerr;
    }
    else if (*p >= '0' && *p <= '7')
    {
      // octal character codes \N+
      // octal escape sequence is terminated after three octal digits
      do
      {
        ch <<= 3;
        ch |= *p - '0';
        ShiftCharN(1);
        ++cnt;
      } while (*p >= '0' && *p <= '7' && cnt < 3);
      if (ch >> 8)
        goto lerr;
    }
    else
    {
      switch (*p)
      {
      case 'a': ch = '\a'; ShiftCharN(1); break;
      case 'b': ch = '\b'; ShiftCharN(1); break;
      case 'f': ch = '\f'; ShiftCharN(1); break;
      case 'n': ch = '\n'; ShiftCharN(1); break;
      case 'r': ch = '\r'; ShiftCharN(1); break;
      case 't': ch = '\t'; ShiftCharN(1); break;
      case 'v': ch = '\v'; ShiftCharN(1); break;
      default:
        goto lself;
      }
    }
  }
  else
  {
lself:
    if (strchr("\n\r", *p))
    {
lerr:
      //error("Unsupported or invalid character/string constant\n");
      errorChrStr();
    }
    ch = *p & 0xFFu;
    ShiftCharN(1);
  }
  return ch;
}

STATIC
void GetString(char terminator, word wide, word option)
{
  char* p = CharQueue;
  unsigned ch = '\0';
  unsigned chsz = 1;
  word i;
  char* ctmp = " ";

  TokenStringLen = 0;
  TokenStringSize = 0;
  TokenValueString[TokenStringLen] = '\0';

  ShiftCharN(1);
  while (!(*p == terminator || strchr("\n\r", *p)))
  {
    ch = GetCharValue(wide);
    switch (option)
    {
    case '#': // string literal (with file name) for #line and #include
      if (TokenStringLen == MAX_STRING_LEN)
        errorStrLen();
      TokenValueString[TokenStringLen++] = ch;
      TokenValueString[TokenStringLen] = '\0';
      TokenStringSize += chsz;
      break;
    case 'a': // string literal for asm()
      ctmp[0] = ch;
      printf2(ctmp);
      break;
    case 'd': // string literal / array of char in expression or initializer
      // Dump the char data to the appropriate data section
      for (i = 0; i < chsz; i++)
      {
        GenDumpChar(ch & 0xFFu);
        ch >>= 8;
        TokenStringLen++; // GenDumpChar() expects it to grow, doesn't know about wchar_t
      }
      TokenStringLen -= chsz;
      // fallthrough
    default: // skipped string literal (we may still need the size)
      if (TokenStringSize > UINT_MAX - chsz)
        errorStrLen();
      TokenStringSize += chsz;
      TokenStringLen++;
      break;
    } // endof switch (option)
  } // endof while (!(*p == '\0' || *p == terminator || strchr("\n\r", *p)))

  if (*p != terminator)
    //error("Unsupported or invalid character/string constant\n");
    errorChrStr();

  if (option == 'd')
    GenDumpChar(-1);

  ShiftCharN(1);

  SkipSpace(option != '#');
}

STATIC
void pushPrep(word NoSkip)
{
  if (PrepSp >= PREP_STACK_SIZE)
    error("Too many #if(n)def's\n");
  PrepStack[PrepSp][0] = PrepDontSkipTokens;
  PrepStack[PrepSp++][1] = NoSkip;
  PrepDontSkipTokens &= NoSkip;
}

STATIC
word popPrep(void)
{
  if (PrepSp <= 0)
    error("#else or #endif without #if(n)def\n");
  PrepDontSkipTokens = PrepStack[--PrepSp][0];
  return PrepStack[PrepSp][1];
}


STATIC
word GetNumber(void)
{
  char* p = CharQueue;
  word ch = *p;
  word leadingZero = (ch == '0');
  unsigned n = 0;
  word type = 0;
  word uSuffix = 0;
  word lSuffix = 0;
  char* eTooBig = "Constant too big\n";

  // First, detect and handle hex constants. Octals can't be detected immediately
  // because floating-point constants also may begin with the digit 0.

  if (leadingZero && (p[1] == 'x' || p[1] == 'X'))
  {
    // this is a hex constant
    word cnt = 0;
    type = 'h';
    ShiftCharN(1);
    ShiftCharN(1);
    while ((ch = *p) != '\0' && (isdigit(ch & 0xFFu) || strchr("abcdefABCDEF", ch)))
    {
      if (ch >= 'a') ch -= 'a' - 10;
      else if (ch >= 'A') ch -= 'A' - 10;
      else ch -= '0';
      //if (PrepDontSkipTokens && (n * 16 / 16 != n || n * 16 + ch < n * 16))
      //  error(eTooBig);
      n = n * 16 + ch;
      ShiftCharN(1);
      cnt++;
    }
    if (!cnt)
      error("Invalid hexadecimal constant\n");
  }
  else
  {
    // handle decimal and octal integers
    word base = leadingZero ? 8 : 10;
    type = leadingZero ? 'o' : 'd';
    while ((ch = *p) >= '0' && ch < base + '0')
    {
      ch -= '0';
      if (PrepDontSkipTokens && (n * base + ch < n * base)) //n * base / base != n || 
        error(eTooBig);
      n = n * base + ch;
      ShiftCharN(1);
    }
  }

  // possible combinations of integer suffixes:
  //   none
  //   U
  //   UL
  //   L
  //   LU
  {
    if ((ch = *p) == 'u' || ch == 'U')
    {
      uSuffix = 1;
      ShiftCharN(1);
    }
    if ((ch = *p) == 'l' || ch == 'L')
    {
      lSuffix = 1;
      ShiftCharN(1);
      if (!uSuffix && ((ch = *p) == 'u' || ch == 'U'))
      {
        uSuffix = 1;
        ShiftCharN(1);
      }
    }
  }

  if (!PrepDontSkipTokens)
  {
    // Don't fail on big constants when skipping tokens under #if
    TokenValueInt = 0;
    return tokNumInt;
  }


  // Ensure the constant fits into 16(32) bits
  if (
      (SizeOfWord == 2 && n >> 8 >> 8) // equiv. to SizeOfWord == 2 && n > 0xFFFF
      || (SizeOfWord == 2 && lSuffix) // long (which must have at least 32 bits) isn't supported in 16-bit models
      || (SizeOfWord == 4 && n >> 8 >> 12 >> 12) // equiv. to SizeOfWord == 4 && n > 0xFFFFFFFF
     )
    error("Constant too big for %d-bit type\n", SizeOfWord * 8);

  TokenValueInt = (word)n;

  // Unsuffixed (with 'u') integer constants (octal, decimal, hex)
  // fitting into 15(31) out of 16(32) bits are signed ints
  if (!uSuffix &&
      (
       (SizeOfWord == 2 && !(n >> 15)) // equiv. to SizeOfWord == 2 && n <= 0x7FFF
       || (SizeOfWord == 4 && !(n >> 8 >> 12 >> 11)) // equiv. to SizeOfWord == 4 && n <= 0x7FFFFFFF
      )
     )
    return tokNumInt;

  // Unlike octal and hex constants, decimal constants are always
  // a signed type. Error out when a decimal constant doesn't fit
  // into an int since currently there's no next bigger signed type
  // (e.g. long) to use instead of int.
  if (!uSuffix && type == 'd')
    error("Constant too big for 32-bit signed type\n");

  return tokNumUint;
}

STATIC
word GetTokenInner(void)
{
  char* p = CharQueue;
  word ch = *p;
  word wide = 0;

  // these single-character tokens/operators need no further processing
  if (strchr(",;:()[]{}~?", ch))
  {
    ShiftCharN(1);
    return ch;
  }

  // parse multi-character tokens/operators

  // DONE: other assignment operators
  switch (ch)
  {
  case '+':
    if (p[1] == '+') { ShiftCharN(2); return tokInc; }
    if (p[1] == '=') { ShiftCharN(2); return tokAssignAdd; }
    ShiftCharN(1); return ch;
  case '-':
    if (p[1] == '-') { ShiftCharN(2); return tokDec; }
    if (p[1] == '=') { ShiftCharN(2); return tokAssignSub; }
    if (p[1] == '>') { ShiftCharN(2); return tokArrow; }
    ShiftCharN(1); return ch;
  case '!':
    if (p[1] == '=') { ShiftCharN(2); return tokNEQ; }
    ShiftCharN(1); return ch;
  case '=':
    if (p[1] == '=') { ShiftCharN(2); return tokEQ; }
    ShiftCharN(1); return ch;
  case '<':
    if (p[1] == '=') { ShiftCharN(2); return tokLEQ; }
    if (p[1] == '<') { ShiftCharN(2); if (p[0] != '=') return tokLShift; ShiftCharN(1); return tokAssignLSh; }
    ShiftCharN(1); return ch;
  case '>':
    if (p[1] == '=') { ShiftCharN(2); return tokGEQ; }
    if (p[1] == '>') { ShiftCharN(2); if (p[0] != '=') return tokRShift; ShiftCharN(1); return tokAssignRSh; }
    ShiftCharN(1); return ch;
  case '&':
    if (p[1] == '&') { ShiftCharN(2); return tokLogAnd; }
    if (p[1] == '=') { ShiftCharN(2); return tokAssignAnd; }
    ShiftCharN(1); return ch;
  case '|':
    if (p[1] == '|') { ShiftCharN(2); return tokLogOr; }
    if (p[1] == '=') { ShiftCharN(2); return tokAssignOr; }
    ShiftCharN(1); return ch;
  case '^':
    if (p[1] == '=') { ShiftCharN(2); return tokAssignXor; }
    ShiftCharN(1); return ch;
  case '.':
    if (p[1] == '.' && p[2] == '.') { ShiftCharN(3); return tokEllipsis; }
    ShiftCharN(1); return ch;
  case '*':
    if (p[1] == '=') { ShiftCharN(2); return tokAssignMul; }
    ShiftCharN(1); return ch;
  case '%':
    if (p[1] == '=') { ShiftCharN(2); return tokAssignMod; }
    ShiftCharN(1); return ch;
  case '/':
    if (p[1] == '=') { ShiftCharN(2); return tokAssignDiv; }
    ShiftCharN(1); return ch;
  }

  // DONE: hex and octal constants
  if (isdigit(ch & 0xFFu))
    return GetNumber();

  // parse character and string constants
  if (ch == '\'')
  {
    unsigned v = 0;
    word cnt = 0;
    word max_cnt = SizeOfWord;
    ShiftCharN(1);
    if (strchr("'\n\r", *p))
      //error("Character constant too short\n");
      errorChrStr();
    do
    {
      v <<= 8;
      v |= GetCharValue(wide);
      if (++cnt > max_cnt)
        //error("Character constant too long\n");
        errorChrStr();
    } while (!strchr("'\n\r", *p));
    if (*p != '\'')
      //error("Unsupported or invalid character/string constant\n");
      errorChrStr();
    ShiftCharN(1);
    {
      if (cnt == 1)
      {
        TokenValueInt = v;
        TokenValueInt -= (CharIsSigned && TokenValueInt >= 0x80) * 0x100;
      }
      else
      {
        TokenValueInt = v;
        TokenValueInt -= (SizeOfWord == 2 && TokenValueInt >= 0x8000) * 0x10000;
      }
      return tokNumInt;
    }
  }
  else if (ch == '"')
  {
    // The caller of GetTokenInner()/GetToken() will call GetString('"', wide, 'd')
    // to complete string literal parsing and storing as appropriate

    return tokLitStr;

  }

  return tokEof;
}


STATIC
void Reserve4Expansion(char* name, word len)
{
  if (MAX_CHAR_QUEUE_LEN - CharQueueLen < len + 1)
  {
    error("Too long expansion of macro ");
    error(name);
    error("\n");
  }

  memmove(CharQueue + len + 1, CharQueue, CharQueueLen);

  CharQueue[len] = ' '; // space to avoid concatenation

  CharQueueLen += len + 1;
}


// TBD??? implement file I/O for input source code and output code (use fxn ptrs/wrappers to make librarization possible)
// DONE: support string literals
STATIC
word GetToken(void)
{
  char* p = CharQueue;
  word ch;
  word tok;

  for (;;)
  {
/* +-~* /% &|^! << >> && || < <= > >= == !=  () *[] ++ -- = += -= ~= *= /= %= &= |= ^= <<= >>= {} ,;: -> ... */

    // skip white space and comments
    SkipSpace(1);

    if ((ch = *p) == '\0')
    {
      // done with the current file, drop its record,
      // pick up the including files (if any) or terminate
      if (EndOfFiles())
        break;
      continue;
    }

    if ((tok = GetTokenInner()) != tokEof)
    {
      if (PrepDontSkipTokens)
        return tok;
      if (tok == tokLitStr)
        GetString('"', 0, 0);

      continue;
    }

    // parse identifiers and reserved keywords
    if (ch == '_' || isalpha(ch & 0xFFu))
    {

      word midx;


      GetIdent();

      if (!PrepDontSkipTokens)
        continue;

      tok = GetTokenByWord(TokenIdentName);


      // TBD!!! think of expanding macros in the context of concatenating string literals,
      // maybe factor out this piece of code
      if (!strcmp(TokenIdentName, "__FILE__"))
      {
        char* p = FileNames[FileCnt - 1];
        word len = strlen(p);
        Reserve4Expansion(TokenIdentName, len + 2);
        *CharQueue = '"';
        memcpy(CharQueue + 1, p, len);
        CharQueue[len + 1] = '"';
        continue;
      }
      else if (!strcmp(TokenIdentName, "__LINE__"))
      {
        char s[(2 + CHAR_BIT * sizeof LineNo) / 3];
        char *p = lab2str(s + sizeof s, LineNo);
        word len = s + sizeof s - p;
        Reserve4Expansion(TokenIdentName, len);
        memcpy(CharQueue, p, len);
        continue;
      }
      else if ((midx = FindMacro(TokenIdentName)) >= 0)
      {
        // this is a macro identifier, need to expand it
        word len = MacroTable[midx];
        Reserve4Expansion(TokenIdentName, len);
        memcpy(CharQueue, MacroTable + midx + 1, len);
        continue;
      }


      // treat keywords auto, const, register, restrict and volatile as white space for now
      if ((tok == tokConst) | (tok == tokVolatile) |
          (tok == tokAuto) | (tok == tokRegister) |
          (tok == tokRestrict))
        continue;

      return tok;
    } // endof if (ch == '_' || isalpha(ch))

    // parse preprocessor directives
    if (ch == '#')
    {
      word line = 0;

      ShiftCharN(1);

      // Skip space
      SkipSpace(0);

      // Allow # not followed by a directive
      if (strchr("\r\n", *p))
        continue;

      // Get preprocessor directive
      if (isdigit(*p & 0xFFu))
      {
        // gcc-style #line directive without "line"
        line = 1;
      }
      else
      {
        GetIdent();
        if (!strcmp(TokenIdentName, "line"))
        {
          // C89-style #line directive
          SkipSpace(0);
          if (!isdigit(*p & 0xFFu))
            errorDirective();
          line = 1;
        }
      }

      if (line)
      {
        // Support for external, gcc-like, preprocessor output:
        //   # linenum filename flags
        //
        // no flags, flag = 1 -- start of a file
        //           flag = 2 -- return to a file after #include
        //        other flags -- uninteresting

        // DONE: should also support the following C89 form:
        // # line linenum filename-opt

        if (GetNumber() != tokNumInt)
          //error("Invalid line number in preprocessor output\n");
          errorDirective();
        line = TokenValueInt;

        SkipSpace(0);

        if (*p == '"' || *p == '<')
        {
          if (*p == '"')
            GetString('"', 0, '#');
          else
            GetString('>', 0, '#');

          if (strlen(TokenValueString) > MAX_FILE_NAME_LEN)
            //error("File name too long in preprocessor output\n");
            errorFileName();
          strcpy(FileNames[FileCnt - 1], TokenValueString);
        }

        // Ignore gcc-style #line's flags, if any
        while (!strchr("\r\n", *p))
          ShiftCharN(1);

        LineNo = line - 1; // "line" is the number of the next line
        LinePos = 1;

        continue;
      } // endof if (line)



      if (!strcmp(TokenIdentName, "define"))
      {
        // Skip space and get macro name
        SkipSpace(0);
        GetIdent();

        if (!PrepDontSkipTokens)
        {
          SkipSpace(0);
          while (!strchr("\r\n", *p))
            ShiftCharN(1);
          continue;
        }

        if (FindMacro(TokenIdentName) >= 0)
        {
          error("Redefinition of macro ");
          error(TokenIdentName);
          error("\n");
        }
        if (*p == '(')
          //error("Unsupported type of macro '%s'\n", TokenIdentName);
          errorDirective();

        AddMacroIdent(TokenIdentName);

        SkipSpace(0);

        // accumulate the macro expansion text
        while (!strchr("\r\n", *p))
        {
          AddMacroExpansionChar(*p);
          ShiftCharN(1);
          if (*p != '\0' && (strchr(" \t", *p) || (*p == '/' && (p[1] == '/' || p[1] == '*'))))
          {
            SkipSpace(0);
            AddMacroExpansionChar(' ');
          }
        }
        AddMacroExpansionChar('\0');

        continue;
      }
      else if (!strcmp(TokenIdentName, "undef"))
      {
        // Skip space and get macro name
        SkipSpace(0);
        GetIdent();

        if (PrepDontSkipTokens)
          UndefineMacro(TokenIdentName);

        SkipSpace(0);
        if (!strchr("\r\n", *p))
          //error("Invalid preprocessor directive\n");
          errorDirective();
        continue;
      }
      else if (!strcmp(TokenIdentName, "include"))
      {
        word quot;

        // Skip space and get file name
        SkipSpace(0);

        quot = *p;
        if (*p == '"')
          GetString('"', 0, '#');
        else if (*p == '<')
          GetString('>', 0, '#');
        else
          //error("Invalid file name\n");
          errorFileName();

        SkipSpace(0);
        if (!strchr("\r\n", *p))
          //error("Unsupported or invalid preprocessor directive\n");
          errorDirective();

        if (PrepDontSkipTokens)
          IncludeFile(quot);

        continue;
      }
      else if (!strcmp(TokenIdentName, "ifdef"))
      {
        word def;
        // Skip space and get macro name
        SkipSpace(0);
        GetIdent();
        def = FindMacro(TokenIdentName) >= 0;
        SkipSpace(0);
        if (!strchr("\r\n", *p))
          //error("Invalid preprocessor directive\n");
          errorDirective();
        pushPrep(def);
        continue;
      }
      else if (!strcmp(TokenIdentName, "ifndef"))
      {
        word def;
        // Skip space and get macro name
        SkipSpace(0);
        GetIdent();
        def = FindMacro(TokenIdentName) >= 0;
        SkipSpace(0);
        if (!strchr("\r\n", *p))
          //error("Invalid preprocessor directive\n");
          errorDirective();
        pushPrep(!def);
        continue;
      }
      else if (!strcmp(TokenIdentName, "else"))
      {
        word def;
        SkipSpace(0);
        if (!strchr("\r\n", *p))
          //error("Invalid preprocessor directive\n");
          errorDirective();
        def = popPrep();
        if (def >= 2)
          error("#else or #endif without #if(n)def\n");
        pushPrep(2 + !def); // #else works in opposite way to its preceding #if(n)def
        continue;
      }
      else if (!strcmp(TokenIdentName, "endif"))
      {
        SkipSpace(0);
        if (!strchr("\r\n", *p))
          //error("Invalid preprocessor directive\n");
          errorDirective();
        popPrep();
        continue;
      }

      if (!PrepDontSkipTokens)
      {
        // If skipping code and directives under #ifdef/#ifndef/#else,
        // ignore unsupported directives #if, #elif, #error (no error checking)
        if (!strcmp(TokenIdentName, "if"))
          pushPrep(0);
        else if (!strcmp(TokenIdentName, "elif"))
          popPrep(), pushPrep(0);
        SkipLine();
        continue;
      }

      //error("Unsupported or invalid preprocessor directive\n");
      errorDirective();
    } // endof if (ch == '#')

    error("Invalid or unsupported character");
    //error("Invalid or unsupported character with code 0x%02X\n", *p & 0xFFu);
  } // endof for (;;)

  return tokEof;
}

STATIC
void errorRedecl(char* s)
{
  error("Invalid or unsupported redeclaration of ");
  error(s);
  error("\n");
}


#include "backend.c"






int main() 
{
  word i;

    // Run-time initializer for SyntaxStack0[] to reduce
    // executable file size (SyntaxStack0[] will be in .bss)
    static unsigned char SyntaxStackInit[] =
    {
      tokVoid,     // SymVoidSynPtr
      tokInt,      // SymIntSynPtr
      tokUnsigned, // SymUintSynPtr
      tokVoid,     // SymWideCharSynPtr
      tokFloat,    // SymFloatSynPtr
      tokIdent,    // SymFuncPtr
      '[',
      tokNumUint,
      ']',
      tokChar
    }; // SyntaxStackCnt must be initialized to the number of elements in SyntaxStackInit[]
    memcpy(SyntaxStack0, SyntaxStackInit, sizeof SyntaxStackInit);
    SyntaxStackCnt = 10;

    SyntaxStack1[SymFuncPtr] = DummyIdent = AddIdent("");



  return 'q';
}

void int1()
{
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
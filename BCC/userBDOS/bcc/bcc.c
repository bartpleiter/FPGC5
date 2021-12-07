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

// functions needed to be implemented for the FPGC specifically:

void exit(word);
word atoi(char*);

size_t strlen(char*);
char* strcpy(char*, char*);
char* strchr(char*, word);
word strcmp(char*, char*);
word strncmp(char*, char*, size_t);
void* memmove(void*, void*, size_t);
void* memcpy(void*, void*, size_t);
void* memset(void*, word, size_t);
word memcmp(void*, void*, size_t);

word isspace(word);
word isdigit(word);
word isalpha(word);
word isalnum(word);

#define FILE void
#define EOF (-1)
FILE* fopen(char*, char*);
word fclose(FILE*);
word putchar(word);
word fputc(word, FILE*);
word fgetc(FILE*);
word puts(char*);
word fputs(char*, FILE*);
word sprintf(char*, char*, ...);
//word vsprintf(char*, char*, va_list);
word vsprintf(char*, char*, void*);
word printf(char*, ...);
word fprintf(FILE*, char*, ...);
//word vprintf(char*, va_list);
word vprintf(char*, void*);
//word vfprintf(FILE*, char*, va_list);
word vfprintf(FILE*, char*, void*);
/*
struct fpos_t_
{
  union
  {
    unsigned short halves[2]; // for 16-bit memory models without 32-bit longs
    word align; // for alignment on machine word boundary
  } u;
}; // keep in sync with stdio.h !!!
#define fpos_t struct fpos_t_
word fgetpos(FILE*, fpos_t*);
word fsetpos(FILE*, fpos_t*);*/


#include "lib/math.c"
#include "lib/stdlib.c"

////////////////////////////////////////////////////////////////////////////////

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
FILE* Files[MAX_INCLUDES];
FILE* OutFile;
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


int main() 
{
  int i;

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
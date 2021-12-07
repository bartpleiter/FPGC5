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
/*                                                                           */
/*                            Based on SmallerC:                             */
/*                 A simple and small single-pass C compiler                 */
/*                                                                           */
/*                                Main file                                  */
/*                                                                           */
/*****************************************************************************/

// NOTE: still has a lot of extras in it that are not needed
//  only the "MIPS" part is needed with no extras

// Making most functions static helps with code optimization,
// use that to further reduce compiler's code size on RetroBSD.
#ifndef STATIC
#define STATIC
#else
#undef STATIC
#define STATIC static
#endif

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

#define size_t unsigned int

#define CHAR_BIT (8)
#define CHAR_MIN (-128)
#define CHAR_MAX (127)

#define INT_MAX (2147483647)
#define INT_MIN (-2147483647-1)

#define UINT_MAX (4294967295u)
#define UINT_MIN (0u)

#define EXIT_FAILURE 1

void exit(int);
int atoi(char*);

size_t strlen(char*);
char* strcpy(char*, char*);
char* strchr(char*, int);
int strcmp(char*, char*);
int strncmp(char*, char*, size_t);
void* memmove(void*, void*, size_t);
void* memcpy(void*, void*, size_t);
void* memset(void*, int, size_t);
int memcmp(void*, void*, size_t);

int isspace(int);
int isdigit(int);
int isalpha(int);
int isalnum(int);

#define FILE void
#define EOF (-1)
FILE* fopen(char*, char*);
int fclose(FILE*);
int putchar(int);
int fputc(int, FILE*);
int fgetc(FILE*);
int puts(char*);
int fputs(char*, FILE*);
int sprintf(char*, char*, ...);
//int vsprintf(char*, char*, va_list);
int vsprintf(char*, char*, void*);
int printf(char*, ...);
int fprintf(FILE*, char*, ...);
//int vprintf(char*, va_list);
int vprintf(char*, void*);
//int vfprintf(FILE*, char*, va_list);
int vfprintf(FILE*, char*, void*);
struct fpos_t_
{
  union
  {
    unsigned short halves[2]; // for 16-bit memory models without 32-bit longs
    int align; // for alignment on machine word boundary
  } u;
}; // keep in sync with stdio.h !!!
#define fpos_t struct fpos_t_
int fgetpos(FILE*, fpos_t*);
int fsetpos(FILE*, fpos_t*);


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


int main() 
{
    return 1;
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
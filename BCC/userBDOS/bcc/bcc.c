#define word char


#ifndef STATIC
#define STATIC
#else
#undef STATIC
#define STATIC static
#endif

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

#ifndef __SMALLER_C__

//#include <limits.h>
#define CHAR_BIT        8
#define UINT_MAX        4294967295U
#define INT_MIN         -2147483648


#else // #ifndef __SMALLER_C__

#define NULL 0
#define size_t unsigned int

#define CHAR_BIT (8)

#ifdef __SMALLER_C_SCHAR__
#define CHAR_MIN (-128)
#define CHAR_MAX (127)
#endif
#ifdef __SMALLER_C_UCHAR__
#define CHAR_MIN (0)
#define CHAR_MAX (255)
#endif

#ifndef __SMALLER_C_SCHAR__
#ifndef __SMALLER_C_UCHAR__
#error __SMALLER_C_SCHAR__ or __SMALLER_C_UCHAR__ must be defined
#endif
#endif

#ifdef __SMALLER_C_16__
#define INT_MAX (32767)
#define INT_MIN (-32767-1)
#define UINT_MAX (65535u)
#define UINT_MIN (0u)
#endif
#ifdef __SMALLER_C_32__
#define INT_MAX (2147483647)
#define INT_MIN (-2147483647-1)
#define UINT_MAX (4294967295u)
#define UINT_MIN (0u)
//#define CAN_COMPILE_32BIT
#endif

#ifndef __SMALLER_C_16__
#ifndef __SMALLER_C_32__
#error __SMALLER_C_16__ or __SMALLER_C_32__ must be defined
#endif
#endif


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
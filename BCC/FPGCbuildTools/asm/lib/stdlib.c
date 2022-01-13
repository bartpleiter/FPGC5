/*
* Standard library
* Contains basic functions, including timer and memory functions
* Modified version for BCC
*/

// uses math.c 

#define UART_TX_ADDR 0xC02723

// Timer I/O Addresses
#define TIMER1_VAL 0xC02739
#define TIMER1_CTRL 0xC0273A
#define TIMER2_VAL 0xC0273B
#define TIMER2_CTRL 0xC0273C
#define TIMER3_VAL 0xC0273D
#define TIMER3_CTRL 0xC0273E

word timer1Value = 0;

void* memcpy(void *dest, const void *src, word len)
{
   // Typecast src and dest addresses to (char *)
   char *csrc = (char *)src;
   char *cdest = (char *)dest;
  
   // Copy contents of src[] to dest[]
   word i;
   for (i=0; i<len; i++)
       cdest[i] = csrc[i];
}

/*
Compares n words between a and b
Returns 1 if similar, 0 otherwise
*/
word memcmp(word* a, word* b, word n)
{
    word i;
    for (i = 0; i < n; i++)
    {
        if (a[i] != b[i])
        {
            return 0;
        }
    }

    return 1;
}

// Function to implement `strcpy()` function
char* strcpy(char* destination, const char* source)
{
    // take a pointer pointing to the beginning of the destination string
    char *ptr = destination;
 
    // copy the C-string pointed by source into the array
    // pointed by destination
    while (*source != '\0')
    {
        *destination = *source;
        destination++;
        source++;
    }
 
    // include the terminating null character
    *destination = '\0';
 
    // the destination is returned by standard `strcpy()`
    return ptr;
}


word strlen(const char *str)
{
        const char *s;
        for (s = str; *s; ++s);
        return (s - str);
}

char* strcat (char *dest, const char *src)
{
  strcpy (dest + strlen (dest), src);
  return dest;
}


word strcmp(const char* s1, const char* s2)
{
  while(*s1 && (*s1 == *s2))
  {
    s1++;
    s2++;
  }
  return *(unsigned char*)s1 - *(unsigned char*)s2;
}


/*
Recursive helper function for itoa
Eventually returns the number of digits in n
s is the output buffer
*/
word itoar(word n, char *s)
{
    word digit = MATH_modU(n, 10);
    word i = 0;

    n = MATH_divU(n,10);
    if ((unsigned int) n > 0)
        i += itoar(n, s);

    s[i++] = digit + '0';

    return i;
}


/*
Converts integer n to characters.
The characters are placed in the buffer s.
The buffer is terminated with a 0 value.
Uses recursion, division and mod to compute.
*/
void itoa(word n, char *s)
{
    // compute and fill the buffer
    word i = itoar(n, s);

    // end with terminator
    s[i] = 0;
} 



/*
Converts string into int.
Assumes the string is valid.
Unsigned only!
*/
word strToInt(char* str)
{
    word retval = 0;
    word multiplier = 1;
    word i = 0;
    while (str[i] != 0)
    {
        i++;
    }
    if (i == 0)
        return 0;

    i--;

    while (i > 0)
    {
        // Return 0 if not a digit
        if (str[i] < '0' || str[i] > '9')
            return 0;
        
        word currentDigit = str[i] - '0';
        word toAdd = multiplier * currentDigit;
        retval += toAdd;
        multiplier = multiplier * 10;
        i--;
    }

    word currentDigit = str[i] - '0';
    word toAdd = multiplier * currentDigit;
    retval += toAdd;

    return retval;
}

/*
Converts dec string into int.
Assumes the string is valid.
Can be signed.
*/
word decToInt(char* dec)
{
    if (dec[0] == '-')
    {
        // signed
        return -strToInt((dec+1));
    }
    else
    {
        return strToInt(dec);
    }

    return 0;
}

/*
Converts hex string into int.
Assumes the string is valid.
*/
word hexToInt(char *hex) {
    word val = 0;
    hex += 2; // skip the 0x
    while (*hex) 
    {
        // get current character then increment
        char byte = *hex++; 
        // transform hex character to the 4bit equivalent number, using the ascii table indexes
        if (byte >= '0' && byte <= '9') byte = byte - '0';
        else if (byte >= 'a' && byte <='f') byte = byte - 'a' + 10;
        else if (byte >= 'A' && byte <='F') byte = byte - 'A' + 10;    
        // shift 4 to make space for new digit, and add the 4 bits of the new digit 
        val = (val << 4) | (byte & 0xF);
    }
    return val;
}

// 0b1100101

/*
Converts binary string into int.
Assumes the string is valid.
*/
word binToInt(char *binStr) {
    binStr += 2; // skip the 0b

    word retval = 0;

    word binLength = strlen(binStr);
    word i;
    for (i = 0; i < binLength; i++)
    {
        char c = binStr[(binLength - 1) - i];
        if (c == '1')
        {
            retval += 1 << i;
        }
        else if (c != '0')
        {
            BDOS_PrintConsole("Invalid binary number\n");
            exit(1);
        }
    }

    return retval;
}

// Converts char c to uppercase if possible
char toUpper(char c)
{
    if (c>96 && c<123) 
        c = c ^ 0x20;

    return c;
}


// Converts string str to uppercase if possible
void strToUpper(char* str) 
{
    char chr = *str;            // first character of str

    while (chr != 0)            // continue until null value
    {
        *str = toUpper(chr);    // uppercase char
        str++;                  // go to next character address
        chr = *str;             // get character from address
    }
}

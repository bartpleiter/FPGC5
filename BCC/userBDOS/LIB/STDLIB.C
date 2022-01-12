/*
* Standard library
* Contains basic functions, including timer and memory functions
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
word timer2Value = 0;
word timer3Value = 0;

/*
* TODO:
* - Convert most of these functions to assembly
*/

/*
Copies n words from src to dest
*/
void memcpy(word* dest, word* src, word n)
{
  word i;
  for (i = 0; i < n; i++)
  {
    dest[i] = src[i];
  }
}

char* memmove(char* dest, const char* src, word n)
{
  char* from = src;
  char* to = dest;

  if (from == to || n == 0)
    return dest;
  if (to > from && to-from < (word)n)
  {
    /* to overlaps with from */
    /*  <from......>         */
    /*         <to........>  */
    /* copy in reverse, to avoid overwriting from */
    word i;
    for(i=n-1; i>=0; i--)
      to[i] = from[i];
    return dest;
  }
  if (from > to && from-to < (word)n)
  {
    /* to overlaps with from */
    /*        <from......>   */
    /*  <to........>         */
    /* copy forwards, to avoid overwriting from */
    word i;
    for(i=0; i<n; i++)
      to[i] = from[i];
    return dest;
  }
  memcpy(dest, src, n);
  return dest;
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


// Returns length of string
word strlen(char* str)
{
  word retval = 0;
  char chr = *str;      // first character of str

  while (chr != 0)      // continue until null value
  {
    retval += 1;
    str++;          // go to next character address
    chr = *str;       // get character from address
  }

  return retval;
}


/*
Copies string from src to dest
Returns number of characters copied
*/
word strcpy(char* dest, char* src)
{
  // write to buffer
  word i = 0;
  while (src[i] != 0)
  {
    dest[i] = src[i];
    i++;
  }

  // terminate
  dest[i] = 0;

  return i;
}


/*
Appends string from src to dest
Returns number of characters appended
*/
word strcat(char* dest, char* src)
{
  // move to end of destination
  word endOfDest = 0;
  while (dest[endOfDest] != 0)
    endOfDest++;

  // copy to end of destination
  return strcpy(dest+endOfDest, src);
}


/*
Compares two strings a and b
Returns 1 if similar, 0 otherwise
*/
word strcmp(char* a, char* b)
{
  if (strlen(a) != strlen(b))
    return 0;


  word i = 0;
  while (a[i] != 0)
  {
    if (a[i] != b[i])
    {
      return 0;
    }
    i++;
  }

  return 1;
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
Recursive helper function for itoa
Eventually returns the number of digits in n
s is the output buffer
*/
word itoahr(word n, char *s)
{
  word digit = MATH_modU(n, 16);
  word i = 0;

  n = MATH_divU(n,16);
  if ((unsigned int) n > 0)
    i += itoahr(n, s);

  char c;
  if (digit > 9)
  {
    c = digit + 'A' - 10;
  }
  else
  {
    c = digit + '0';
  }
  s[i++] = c;

  return i;
}


/*
Converts integer n to hex string characters.
The characters are placed in the buffer s.
A prefix of 0x is added.
The buffer is terminated with a 0 value.
Uses recursion, division and mod to compute.
*/
void itoah(word n, char *s)
{
  // add prefix
  s[0] = '0';
  s[1] = 'x';
  s+=2;

  // compute and fill the buffer
  word i = itoahr(n, s);

  // end with terminator
  s[i] = 0;
}


// isalpha
word isalpha(char c)
{
  if (c >= 'A' && c <= 'Z')
    return 2;
  if (c >= 'a' && c <= 'z')
    return 1;
  return 0;
}

// isdigit
word isdigit(char c)
{
  if (c >= '0' && c <= '9')
    return 1;
  return 0;
}

// isalnum
word isalnum(char c)
{
  if (isdigit(c) || isalpha(c))
    return 1;
  return 0;
}


/*
Converts string into int.
Assumes the string is valid.
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
Prints a single char c by writing it to UART_TX_ADDR
*/
void uprintc(char c) 
{
  word *p = (word *)UART_TX_ADDR; // address of UART TX
  *p = (word)c;           // write char over UART
}


/*
Sends each character from str over UART
by writing them to UART_TX_ADDR
until a 0 value is found.
Does not send a newline afterwards.
*/
void uprint(char* str) 
{
  word *p = (word *)UART_TX_ADDR; // address of UART TX
  char chr = *str;        // first character of str

  while (chr != 0)        // continue until null value
  {
    *p = (word)chr;       // write char over UART
    str++;            // go to next character address
    chr = *str;         // get character from address
  }
}


/*
Same as uprint(char* str),
except it sends a newline afterwards.
*/
void uprintln(char* str) 
{
  uprint(str);
  uprintc('\n');
}


/*
Prints decimal integer over UART
*/
void uprintDec(word i) 
{
  char buffer[11];
  itoa(i, buffer);
  uprint(buffer);
  uprintc('\n');
}

/*
Prints hex integer over UART
*/
void uprintHex(word i) 
{
  char buffer[11];
  itoah(i, buffer);
  uprint(buffer);
  uprintc('\n');
}


/*
Prints decimal integer over UART, with newline
*/
void uprintlnDec(word i) 
{
  char buffer[11];
  itoa(i, buffer);
  uprint(buffer);
  uprintc('\n');
}

/*
Prints hex integer over UART, with newline
*/
void uprintlnHex(word i) 
{
  char buffer[11];
  itoah(i, buffer);
  uprint(buffer);
  uprintc('\n');
}


// sleeps ms using timer1.
// blocking.
// requires int1() to set timer1Value to 1:
/*
  timer1Value = 1; // notify ending of timer1
*/
void delay(word ms)
{

  // clear result
  timer1Value = 0;

  // set timer
  word *p = (word *) TIMER1_VAL;
  *p = ms;
  // start timer
  word *q = (word *) TIMER1_CTRL;
  *q = 1;

  // wait until timer done
  while (timer1Value == 0);
}


// Returns interrupt ID by using the readintid asm instruction
word getIntID()
{
  word retval = 0;

  asm(
    "readintid r2  ;reads interrupt id to r2\n"
    "write -4 r14 r2 ;write to stack to return\n"
    );

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
  char chr = *str;      // first character of str

  while (chr != 0)      // continue until null value
  {
    *str = toUpper(chr);  // uppercase char
    str++;          // go to next character address
    chr = *str;       // get character from address
  }
}


/*
For debugging
Prints a hex dump of size 'len' for each word starting from 'addr'
Values are printed over UART
*/
void hexdump(char* addr, word len)
{
  char buf[16];
  word i;
  for (i = 0; i < len; i++)
  {
    // newline every 8 words
    if (i != 0 && MATH_modU(i, 8) == 0)
      uprintc('\n');
    itoah(addr[i], buf);
    uprint(buf);
    uprintc(' ');
  }
}
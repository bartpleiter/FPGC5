#include "math.h" 

/*
* TODO:
* - Convert most of these functions to assembly
* - Add writeToAddress(data, addr, len)
* - Add writeWordToAddress(data, addr)
* - Add readFromAddress(dst, addr, len)
* - Add readWordFromAddress(dst, addr)
*/

/*
memcpy(char* dest, char* src, int n)

Copies n characters from src to dest
*/
void memcpy(char* dest, char* src, int n)
{
	for (int i = 0; i < n; i++)
	{
		dest[i] = src[i];
	}
}


/*
uprintc(char c)

Prints a single char c by writing it to 0xC02723
*/
void uprintc(char c) 
{
	int *p = (int *)0xC02723; 	// address of UART TX
	*p = (int)c; 			// write char over UART
}


/*
uprint(char* str)

Sends each character from str over UART
by writing them to 0xC02723
until a 0 value is found.
Does not send a newline afterwards.
*/
void uprint(char* str) 
{
	int *p = (int *)0xC02723; 	// address of UART TX
	char chr = *str; 			// first character of str

	while (chr != 0) 			// continue until null value
	{
		*p = (int)chr; 			// write char over UART
		str++; 					// go to next character address
		chr = *str; 			// get character from address
	}
}


/*
uprintln(char* str)

Same as uprint(char* str),
except it sends a newline afterwards.
*/
void uprintln(char* str) 
{
	uprint(str);
	uprint("\n");
}



/*
itoar(int n, char *s)

Recursive helper function for itoa
Eventually returns the number of digits in n
*/
int itoar(int n, char *s)
{
	int digit = mod(n, 10);
    int i = 0;

    n = div(n,10);
    if (n > 0)
    	i += itoar(n, s);

    s[i++] = digit + '0';

    return i;
}


/*
itoa(int n, char *s)

Converts integer n to characters.
The characters are placed in the buffer s.
The buffer is terminated with a 0 value.
Uses recursion, division and mod to compute.
*/
void itoa(int n, char *s)
{
	// compute and fill the buffer
	int i = itoar(n, s);

	// end with terminator
	s[i] = 0;
} 





/*
itoahr(int n, char *s)

Recursive helper function for itoa
Eventually returns the number of digits in n
*/
int itoahr(int n, char *s)
{
	int digit = mod(n, 16);
    int i = 0;

    n = div(n,16);
    if (n > 0)
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
itoah(int n, char *s)

Converts integer n to hex string characters.
The characters are placed in the buffer s.
A prefix of 0x is added.
The buffer is terminated with a 0 value.
Uses recursion, division and mod to compute.
*/
void itoah(int n, char *s)
{
	// add prefix
	s[0] = '0';
	s[1] = 'x';
	s+=2;

	// compute and fill the buffer
	int i = itoahr(n, s);

	// end with terminator
	s[i] = 0;
} 



// sleeps ms using timer1.
// blocking.
// requires int1() to set 0x4C0000 to 1:
/*
	int *p = (int *) 0x4C0000; // set address (timer1 state)
	*p = 1; // write value
*/
void delay(int ms)
{

	// clear result
	int *o = (int *) 0x4C0000;
	*o = 0;

	// set timer
	int *p = (int *) 0xC02739;
	*p = ms;
	// start timer
	int *q = (int *) 0xC0273A;
	*q = 1;

	// wait until timer done
	while (*o == 0);
}
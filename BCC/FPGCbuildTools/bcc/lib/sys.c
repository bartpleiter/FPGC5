/*
Contains System Call functions
*/

#define SYSCALL_RETVAL_ADDR 0x200000

// Interrupt IDs for extended interrupt handler
#define INTID_TIMER2 0x0
#define INTID_TIMER3 0x1
#define INTID_PS2 0x2
#define INTID_UART1 0x3
#define INTID_UART2 0x4


// executes system call to BDOS
// ID is written to the same location as the output of the system call
//  at address SYSCALL_RETVAL_ADDR
// This address is also returned
word* syscall(word ID)
{
    word* p = (word*) SYSCALL_RETVAL_ADDR;
    *p = ID;

    asm("push r1\n"
        "push r2\n"
        "push r3\n"
        "push r4\n"
        "push r5\n"
        "push r6\n"
        "push r7\n"
        "push r8\n"
        "push r9\n"
        "push r10\n"
        "push r11\n"
        "push r12\n"
        "push r13\n"
        "push r14\n"
        "push r15\n"
        "savpc r1\n"
        "push r1\n"
        "jump 6\n"
        "pop r15\n"
        "pop r14\n"
        "pop r13\n"
        "pop r12\n"
        "pop r11\n"
        "pop r10\n"
        "pop r9\n"
        "pop r8\n"
        "pop r7\n"
        "pop r6\n"
        "pop r5\n"
        "pop r4\n"
        "pop r3\n"
        "pop r2\n"
        "pop r1\n");

    return p;
}

void BDOS_PrintcConsole(char c)
{
    char* p = (char*) SYSCALL_RETVAL_ADDR;
    p[1] = c;
    syscall(3);
}

// Prints string on BDOS console untill terminator
// Does not add newline at end
void BDOS_PrintConsole(char* str)
{
    char chr = *str;            // first character of str

    while (chr != 0)            // continue until null value
    {
        BDOS_PrintcConsole(chr);
        str++;                  // go to next character address
        chr = *str;             // get character from address
    }
}

void BDOS_PrintlnConsole(char* str)
{
    BDOS_PrintConsole(str);
    BDOS_PrintcConsole('\n');
}

void BDOS_PrintDecConsole(word i)
{
    char buffer[11];
    itoa(i, buffer);
    BDOS_PrintConsole(buffer);
}

// Returns command line args
char* BDOS_GetArgs()
{
    char* p = syscall(4);
    return (char*) p[0];
}


// Writes command line argument n into buf
// Arg 0 is the command itself
void BDOS_GetArgN(word n, char* buf)
{
    char* args = BDOS_GetArgs();

    word i = 0;
    word bufi = 0;
    word currentArg = 0;
    char prevChar = 0;
    buf[0] = 0;
    while (args[i] != 0)
    {
        // new argument
        if (args[i] == ' ' && prevChar != ' ')
        {
            currentArg++;
        }

        if (args[i] != ' ')
        {
            if (currentArg == n)
            {
                buf[bufi] = args[i];
                bufi++;
            }
        }

        prevChar = args[i];
        i++;
    }

    buf[bufi] = 0; // terminate
}


// Returns BDOS current path
char* BDOS_GetPath()
{
    word* p = syscall(5);
    return (char*) p[0];
}
#define word char

#include "lib/sys.c"
#include "lib/math.c" 
#include "lib/stdlib.c"
#include "lib/gfx.c"
#include "lib/fs.c"
#include "lib/stdio.c"


int main() 
{

    BDOS_PrintConsole("Testing stdio implementation\n");

    char* file1 = "/test/file1.txt";
    char* file2 = "/test/file4.txt";

    word F1 = fopen(file1, 0);
    word F2 = fopen(file2, 1);

    fputs(F2, "Hello!\nTAKEMA :");

    word c = fgetc(F1);
    BDOS_PrintcConsole(c);
    while(c != EOF)
    {
        c = fgetc(F1);
        if (c == EOF)
            BDOS_PrintConsole("EOF!\n");
        else
            BDOS_PrintcConsole(c);
    }


    fputc(F2, 'D');
    fputc(F2, '\n');

    fclose(F1);
    fclose(F2);
    
    

    F2 = fopen(file2, 0);
    
    c = fgetc(F2);
    BDOS_PrintcConsole(c);
    while(c != EOF)
    {
        c = fgetc(F2);
        if (c == EOF)
            BDOS_PrintConsole("EOF!\n");
        else
            BDOS_PrintcConsole(c);
    }
    fclose(F2);


    

    return 'q';
}

// timer1 interrupt handler
void int1()
{
   timer1Value = 1; // notify ending of timer1
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
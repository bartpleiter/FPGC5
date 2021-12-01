int g(char c) 
{
    //int *p = (int *)0xC0262E;     // fake address of UART TX
    //*p = (int)c;          // fake write char over UART
    int i = 3;
    i += c;
    return 1;
}

int f(char* str)
{
    int i = 0;
    char chr = *str;            // first character of str

    while (chr != 0)            // continue until null value
    {
        i += g(chr);

        str++;                  // go to next character address
        chr = *str;             // get character from address
    }

    return i;
}

int main() 
{
    
    int i = f("StringOf15Chars");
    
    return i; //15
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
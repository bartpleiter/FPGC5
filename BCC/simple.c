char f(char a, char b, char c, char d)
{
    char retval = 0; //4,5,6,7, ret2
    char lmao = 1;
    asm(
        "load32 0 r2\n"
        "add r4 r2 r2\n"
        "add r5 r2 r2\n"
        "add r6 r2 r2\n"
        "add r7 r2 r2\n"
        "write -4 r14 r2 ;write to stack to return");

    return retval;
}

int main() 
{
    char x = f(4,5,6,7);
    return x;
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
// r2 contains the return value, r4 contains the argument
int asmReturn(int x)
{
    int retval = 0;

    asm("load 4 r3\n"
        "add r4 r3 r2    ;adding two regs\n"
        "sub r2 1 r2     ;remove one to get 10\n"
        "write -4 r14 r2 ;write to stack to return");

    return retval;
}

int main() 
{
    int a = asmReturn(7);

    return a; // should now be 10
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
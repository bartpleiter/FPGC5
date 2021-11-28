void f()
{
    int* x = 0xC02723;
    *x = 'X';
}

int main()
{
    f();

    int* x = 0xC02723;
    *x = 'Y';

    return 'Z';
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

int main()
{
    int *p = (int *)0xC01420;

    int i = 0;
    while (1)
    {
        for (int j = 0; j < 512; j++)
        {
            *(p+j) = i;
        }
        
        i++;
    }

    return 65;
}
// timer1 interrupt handler
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
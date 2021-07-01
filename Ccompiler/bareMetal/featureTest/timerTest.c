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

int main()
{


    delay(2000);

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
    int *p = (int *) 0x4C0000; // set address (timer1 state)
   *p = 1; // write value
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
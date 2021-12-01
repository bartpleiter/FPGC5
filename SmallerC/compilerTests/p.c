int main() 
{
    int *p = (int *)65000; // set address
    *p = 0; // write value
    while (*p < 120); // wait 120 frames (two seconds)
    return *p;
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
    // set pointer to manual address
    int *p = (int *)65000;

    // write value at pointer address
    *p += 1;
}
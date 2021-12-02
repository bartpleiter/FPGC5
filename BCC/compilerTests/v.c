void g(char* buf, int s)
{
    buf[s] = s+1;
}

int f(int x)
{
    return x + 2;
}

int main() 
{
    int s = 3;

    char buf[10];

    int x = f(s); //5

    g(buf, x);

    return buf[5]; //6
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
int sum(int x, int y)
{
    return x + y;
}

int g() {
    return sum(1,2);
}

int main() {
    int a = 5;
    int i;
    for (i = 0; i < 3; i++)
    {
        a = sum(a,i); //5, 6, 8
    }

    if (a == 8) //always true
    {
        a = a + g(); //11
    }

    int b = 0;

    while (a >= 9)
    {
        a = a - 1; //10, 9, 8
        b = b + 1; //1, 2, 3
    }

    return a + b; // 8+3=11
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
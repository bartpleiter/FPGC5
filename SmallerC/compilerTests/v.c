//TODO: make a real test for this, with some expected return value

int g(char* buf, int s)
{
	int i = s;

	return i;
}

void f(int s)
{
	int i = 0;
}

int main() 
{
	int s = 3;

	char buf[4];

	f(s);
	g(&buf[0], s);

	buf[s] = 19;

	return 42;
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
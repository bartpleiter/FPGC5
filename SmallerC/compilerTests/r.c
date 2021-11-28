int main() 
{
	int a = 7; // should be put into r1 by the compiler

	// backslashes are needed for the lexer, semicolons are needed to keep track of each line
	// comments can be added before the semicolon using //
	ASM("\
		load 4 r2								;\
		add r1 r2 r3 	//adding two regs		;\
		sub r3 1 r1 	//remove one to get 10 	;\
		");

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
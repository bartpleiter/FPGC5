int main() {

   int a = 60;       //0011 1100 60
   int b = 13;       //0000 1101 13

   int c = a && b;   //1    (logical and)
   int d = a || b;   //1    (logical or)
   int e = a & b;  //0000 1100 12 (bitwise and)
   int f = a | b;    //0011 1101 61 (bitwise or)
   int g = a ^ b;    //0011 0001 49 (bitwise xor)
   g = ~(~g);        //double not == identity

   g = g << b;
   g = g >> b;

   return c+d+e+f+g; // 124
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
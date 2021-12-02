/*
Faster way of usigned positive integer division/modulo
 by using bitshifts instead of substraction
*/
int MATH_divmod(int dividend, int divisor, int mod)
{
    int quotient = 0;
    int remainder = 0;

    if(divisor == 0) 
        return 0;

    int i;
    for(i = 31 ; i >= 0 ; i--)
    {
        quotient = quotient << 1;
        remainder = remainder << 1;
        remainder = remainder | ((dividend & (1 << i)) >> i);

        if(remainder >= divisor)
        {
            remainder = remainder - divisor;
            quotient = quotient | 1;
        }

        if (i == 0)
            if (mod == 1)
                return remainder;
            else
                return quotient;
    }

    return 0;
}

// Unsigned positive integer division
int MATH_div(int dividend, int divisor) 
{
    return MATH_divmod(dividend, divisor, 0);
}

// Unsigned positive integer modulo
int MATH_mod(int dividend, int divisor) 
{
    return MATH_divmod(dividend, divisor, 1);
}
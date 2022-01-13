// Unsigned Division and Modulo without / and %
word MATH_divmodU(word dividend, word divisor, word mod)
{
    word quotient = 0;
    word remainder = 0;

    if(divisor == 0) 
        return 0;

    word i;
    for(i = 31 ; i >= 0 ; i--)
    {
        quotient = quotient << 1;
        remainder = remainder << 1;
        remainder = remainder | ((dividend & (1 << i)) >> i);

        if((unsigned int) remainder >= (unsigned int) divisor)
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
word MATH_divU(word dividend, word divisor) 
{
    return MATH_divmodU(dividend, divisor, 0);
}

// Unsigned positive integer modulo
word MATH_modU(word dividend, word divisor) 
{
    return MATH_divmodU(dividend, divisor, 1);
}
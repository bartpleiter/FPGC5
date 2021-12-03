// Signed Division and Modulo without / and %
int MATH_divmod(int dividend, int divisor, int* rem)
{
    int quotient = 1;

    int neg = 1;
    if ((dividend>0 &&divisor<0)||(dividend<0 && divisor>0))
        neg = -1;

    // Convert to positive
    int tempdividend = (dividend < 0) ? -dividend : dividend;
    int tempdivisor = (divisor < 0) ? -divisor : divisor;

    if (tempdivisor == tempdividend) {
        *rem = 0;
        return 1*neg;
    }
    else if (tempdividend < tempdivisor) {
        if (dividend < 0)
            *rem = tempdividend*neg;
        else
            *rem = tempdividend;
        return 0;
    }
    while (tempdivisor<<1 <= tempdividend)
    {
        tempdivisor = tempdivisor << 1;
        quotient = quotient << 1;
    }

    // Call division recursively
    if(dividend < 0)
        quotient = quotient*neg + MATH_divmod(-(tempdividend-tempdivisor), divisor, rem);
    else
        quotient = quotient*neg + MATH_divmod(tempdividend-tempdivisor, divisor, rem);
     return quotient;
}

int MATH_div(int dividend, int divisor)
{
    int rem = 0;
    return MATH_divmod(dividend, divisor, &rem);
}

int MATH_mod(int dividend, int divisor)
{
    int rem = 0;
    MATH_divmod(dividend, divisor, &rem);
    return rem;
}
/*
* Math library
* Contains functions math operation that are not directly supported by the hardware
*/

// Signed Division and Modulo without / and %
word MATH_divmod(word dividend, word divisor, word* rem)
{
  word quotient = 1;

  word neg = 1;
  if ((dividend>0 &&divisor<0)||(dividend<0 && divisor>0))
    neg = -1;

  // Convert to positive
  word tempdividend = (dividend < 0) ? -dividend : dividend;
  word tempdivisor = (divisor < 0) ? -divisor : divisor;

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

word MATH_div(word dividend, word divisor)
{
  word rem = 0;
  return MATH_divmod(dividend, divisor, &rem);
}

word MATH_mod(word dividend, word divisor)
{
  word rem = 0;
  MATH_divmod(dividend, divisor, &rem);
  return rem;
}


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
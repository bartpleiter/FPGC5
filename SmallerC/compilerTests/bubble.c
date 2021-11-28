int main(){

   int count, temp, i, j, number[30];

   count = 10;
   number[0] = 3;
   number[1] = 2;
   number[2] = 12;
   number[3] = 4;
   number[4] = 14;
   number[5] = 5;
   number[6] = 16;
   number[7] = 1;
   number[8] = 99;
   number[9] = 11;


   /* This is the main logic of bubble sort algorithm
    */
   for(i=count-2;i>=0;i--){
      for(j=0;j<=i;j++){
        if(number[j]>number[j+1]){
           temp=number[j];
           number[j]=number[j+1];
           number[j+1]=temp;
        }
      }
   }

   return 0;
}

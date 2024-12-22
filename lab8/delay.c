#include <math.h>

int get_cords(int input){
  float A = 2.6;
  float w = 0.1;
  int a = sin(input*w)*A;
  return a;
}

int main()
{
    return get_cords(5);
}
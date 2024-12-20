/* delay.c */
#include <unistd.h>
#include <math.h>

void mydelay(int delay){
  usleep(delay);
}

int get_cords(int input){
  int a = sin(input*0.1)*2.6;
  return a;
}

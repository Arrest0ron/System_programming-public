code #include <stdio.h> 
int main() {long N = 4894269367; int rest = 0; while (N) {rest += N%10; N/=10;} printf("%d\n",rest); return 0;}
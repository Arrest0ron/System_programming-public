// 14.c
#include <stdio.h>

int end_test(int n)
{
    int square = n * n;
    while (n)
    {
        if (square%10 == n%10)
        {
            square/=10;
            n/=10;
            continue;
        }
        return 0;
        
    }
    return 1;
}

int main(int argc, char* argv)
{
    int n;
    scanf("%d", &n);
    for (int i = 1; i <= n; i++)
        if (end_test(i))
        {
            printf("%d\n", i);
        }
    return 0;
}
// 5.c
#include <stdio.h>

int main(int argc, char* argv)
{
    int n, result = 0;
    scanf("%d", &n);
    for (int i = 2; i < n; i++)
    {
        if (i%11!=0 && i%5!=0)
        {
            result++;
        }
    }
    printf("%d\n", result);
    return 0;
}
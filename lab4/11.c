#include <stdio.h>
#include <stdlib.h>


int main(int argc, char* argv)
{
    int n, result = 0;
    scanf("%d", &n);
    while (n)
    {
        n--;
        int vote = 0;
        scanf("%d", &vote);
        if (vote)
        {
            result++; 
            continue;
        }
        result--;
    }
    if (!result){printf("tie\n");}
    else if (result>0){printf("1\n");}
    else{printf("0\n");}
    return 0;
}
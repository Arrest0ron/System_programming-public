#include <stdio.h>
#include <stdlib.h> 

int main(int argc, char* argv[]) {
    int number = 2*atoi(argv[1])+ atoi(argv[2]) + 2*atoi(argv[3]); 
    printf("%d\n", number); 
    return 0;
}

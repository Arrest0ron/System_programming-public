#include<stdio.h>

unsigned long * create_array(unsigned long);
void free_memory(unsigned long *, unsigned long);
void out_as_chars(unsigned long *p, unsigned long n);
void out(unsigned long *p, unsigned long n);
void randomize(unsigned long *p, unsigned long n);
void reverse(unsigned long *p, unsigned long n);
unsigned long count_even(unsigned long *p, unsigned long n);
unsigned long count_odd(unsigned long *p, unsigned long n);
unsigned long * return_odd(unsigned long *p, unsigned long n);

int main(){
	unsigned long *p = 0 ,*p2 = 0, n;
	printf("Create array with the size of: ");
	scanf("%ld", &n);
	int size = n*sizeof(*p);


	p = create_array(size);
	
	p[0]= 7;
	p[n-1]= 7;
	out(p, n);
	printf("Filling it with arbitrary values...\n");
	randomize(p, size);

	printf("Done!\n");
	out(p, n);
	unsigned long even = count_even(p, size);
	unsigned long  odd = count_odd(p, size);

	printf("%lu of them are even and %lu are odd\n", even, odd);
	p2 = return_odd(p, size);
	if (p2)
	{
		printf("Let's print all the odd numbers...\n", p2);
		out(p2, odd);
	}
	printf("And reverse initial array:\n");
	reverse(p, size);
	out(p, n);
	free_memory(p, size);
	return 0;
}

void out(unsigned long *p, unsigned long n)
{
	for (int i=0;i!=n;i++)
	{
		printf("%lu;  ", p[i]);
	}
	printf("\n");
}
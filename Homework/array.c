#include<stdio.h>

unsigned long * create_array(unsigned long);
unsigned long * push_end();
unsigned long * free_memory();
void out(unsigned long *p, unsigned long n);

int main(){
	unsigned long *p,*p2, n;
	scanf("%ld", &n);
	p = 0;
	int size = n*sizeof(*p);


	p = create_array(size);
	p[0]= 5;
	p[n-1]= 5;



	push_end(p, size, 8);
	// p[n] = 8;
	out(p,n+1);
	free_memory(0);
	
	return 0;
}

void out(unsigned long *p, unsigned long n)
{
	for (int i=0;i!=n;i++)
	{
		printf("%ld\n", p[i]);
	}
}
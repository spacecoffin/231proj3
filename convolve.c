/* convolve.c ­ Compute convolution of two vectors */

#include <stdio.h>  // implicit

#define N 50        // .equ N,50

int x[N], y[N], z[2*N]; /*  .comm x,N*4,4
                            .comm y,N*4,4
                            .comm z,N*8,4   */
void convolve(int[], int[], int[], int);

int main(void)      /*  .global main
                        main:           */
{
    int i, n;                                   // subl $8, %esp

    printf("Enter vector size (<=%d): ", N);    // szstr
    scanf("%d", &n);                            // scand

    printf("Enter first vector (%d elements):\n", n);   // v1str
    for (i = 0; i < n; i++)
        scanf("%d", &x[i]);

    printf("Enter second vector (%d elements):\n", n);  // v2str
    for (i = 0; i < n; i++)
        scanf("%d", &y[i]);                     // scand

    convolve(x, y, z, n);

    printf("Convolution:\n");                   // cvstr
    for (i = 0; i < 2*n-1; i++)
        printf("%d ", z[i]);                    // printd
    printf("\n");                               // printn

    return 0;
}

void convolve(int x[], int y[], int z[], int n)
{
    int i, j;

    for (i = 0; i < 2*n-1; i++) // fill in unused addys with 0s
        z[i] = 0;

    for (i = 0; i < n; i++)
        for (j = 0; j < n; j++)
            z[i+j] += x[i] * y[j];

    return;
}
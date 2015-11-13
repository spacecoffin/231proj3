/*
 * 1. Push function arguments onto stack, starting from last 
 *    (rightmost) argument.
 * 2. Call the function using call instruction.
 * 3. Restore stack to configuration before the call by 
 *    popping arguments off the stack.
 */

/*************************************/
/* IA32 translation of convolution.c */
/*************************************/

/* initialized global data */
        .data
        .align 4 # is this necessary?
        .equ N,50       # #define N 50
/* uninitialized global data */
        .comm x,N*4,4   # int x[N]
        .comm y,N*4,4   # int y[N]
        .comm z,N*8,4   # int z[2*N]
    # i, n, j which I don't think we'll need here
        #.comm n,4,4     # int n
        #.comm i,4,4     # int i
        #.comm j,4,4     # int j
/* read-only data */
        .section  .rodata # is rodata in data?
    /* printf format strings */
szstr:  .string "Enter vector size (<=%d): " 
v1str:  .string "Enter first vector (%d elements):\n"
v2str:  .string "Enter second vector (%d elements):\n"
cvstr:  .string "Convolution:\n"
scand:  .string "%d"    # string for scanf("%d", _);
printd: .string "%d "   # printf("%d ", z[i]);
printn: .string "\n"    # printf("\n");
/* main function */
        .text
        .global main    # declare "main" as global symbol
main:
    /* Prolog */
        pushl   %ebp        # save old %ebp
        movl    %esp, %ebp  # set new %ebp
    /* Callee-save pushes here */
        pushl   %esi        # save %esi to stack at -4(%ebp)
        pushl   %ebx        # save %ebx to stack at -8(%ebp)
        pushl   %edi        # save %edi to stack at -12(%ebp)
    /* Allocate int i, n on the stack */
        subl    $8, %esp
    /* i is at -16(%ebp), n is at -20(%ebp) */
    /* printf("Enter vector size (<=%d): ", N); */
        pushl   N    # push or need to move to register? what's best here?
        pushl   $szstr      # push address of szstr string onto stack
        call    printf      # call printf library function
        addl    $8, %esp    # pop args to printf (2 longs: N & $szstr) off the stack
    /* scanf("%d", &n); */
        leal    -20(%ebp), %ebx # %ebx = address of n
        pushl   %ebx        # push address of n
        pushl   $scand      # push address of scand string onto stack
        call    scanf       # scanf("%d", &n);
        addl    $8, %esp    # deallocate params to scanf
    /* printf("Enter first vector (%d elements):\n", n); */
        movl    -20(%ebp), %ebx # %ebx = n
        pushl   %ebx        # push value of n
        pushl   $v1str      # push address of v1str string onto stack
        call    printf      # printf("Enter first vector (%d elements):\n", n);
        addl    $8, %esp    # pop args to printf (2 longs: n & $v1str) off the stack
    /* for (i = 0; i < n; i++) */
        movl    $0, %esi    # %esi = i = 0 // break into discrete steps?
        cmpl    %ebx, %esi  # compute (i - n) and set flags
        jge     l1done      # if i >= n, then skip over for loop
        movl    $x, %edi    # %edi = address x
loop1:
        pushl   %edi        # push address of x[i]
        pushl   $scand      # push address of scand string onto stack
        call    scanf       # scanf("%d", &x[i]);
        addl    $8, %esp    # deallocate params to scanf
        addl    $4, %edi    # increase index of x[i]
        incl    %esi        # i++
        cmpl    %ebx, %esi  # compute (i - n) and set flags
        jl      loop1       # if i < n, then loop
l1done:
    /* printf("Enter second vector (%d elements):\n", n); */
        movl    -20(%ebp), %ebx # %ebx = n ALREADY ASSIGNED ABOVE
        pushl   %ebx        # push value of n
        pushl   $v2str      # push address of v1str string onto stack
        call    printf      # printf("Enter first vector (%d elements):\n", n);
        addl    $8, %esp    # pop args to printf (2 longs: n & $v2str) off the stack
    /* for (i = 0; i < n; i++) */
        movl    $0, %esi    # %esi = i = 0 // break into discrete steps?
        cmpl    %ebx, %esi  # compute (i - n) and set flags
        jge     l2done      # if i >= n, then skip over for loop
        movl    $y, %edi    # %edi = address y
loop2:
        pushl   %edi        # push address of y[i]
        pushl   $scand      # push address of scand string onto stack
        call    scanf       # scanf("%d", &y[i]);
        addl    $8, %esp    # deallocate params to scanf
        addl    $4, %edi    # increase index of y[i]
        incl    %esi        # i++
        cmpl    %ebx, %esi  # compute (i - n) and set flags
        jl      loop2       # if i < n, then loop
l2done:
        pushl   %ebx        # push value of n
        pushl   $z          # push address of z
        pushl   $y          # push address of y
        pushl   $x          # push address of x

        #movl    $z, %edi    # %edi = address z[0]
        #pushl   %edi        # push address of z
        #movl    $y, %edi    # %edi = address y[0]
        #pushl   %edi        # push address of y
        #movl    $x, %edi    # %edi = address x[0]
        #pushl   %edi        # push address of x
        call    convolve    # convolve(x, y, z, n);

# RESTORE STATE HERE

postcv:
    /* printf("Convolution:\n");  */
        pushl   $cvstr      # push address of cvstr string onto stack
        call    printf      # call printf library function
        addl    $4, %esp    # pop args to printf ($cvzstr) off the stack
    /* for (i = 0; i < 2*n-1; i++) */
    # YOU ASSUME %ebx STILL CONTAINS 'n'
        addl    %ebx, %ebx  # %ebx = 2n
        subl    $1, %ebx    # %ebx = 2n-1
        movl    $0, %esi    # %esi = i = 0
        cmpl    %ebx, %esi  # compute (i - (2n-1)) and set flags
        jge     l3done      # if i >= (2n-1), then skip over for loop
loop3:
    /* printf("%d ", z[i]); */
        movl    z(,%esi,4), %edi # %edi = z[i]
        pushl   %edi        # push value of z[i]
        pushl   $printd     # push address of printd string onto stack
        call    printf      # call printf library function
        addl    $8, %esp    # pop args to printf (2 longs: N & $szstr) off the stack
        incl    %esi        # i++
        cmpl    %ebx, %esi  # compute (i - (2n-1)) and set flags
        jl      loop3       # if i < (2n-1), then loop
l3done:
    /* printf("\n"); */
        pushl   $printn     # push address of printn string onto stack
        call    printf      # call printf library function
        movl    $0, %eax    # return 0;
        leave
        ret

convolve:
    /* Prolog */
        pushl   %ebp        # save old %ebp
        movl    %esp, %ebp  # set new %ebp
    /* x at 8(%ebp), y at 12(%ebp), z at 16(%ebp), n at 20(%ebp) */
        movl    20(%ebp), %ebx # %ebx = n
        addl    %ebx, %ebx  # %ebx = 2n
        subl    $1, %ebx    # %ebx = 2n-1
    /* for (i = 0; i < 2*n-1; i++) */
        movl    $0, %esi    # %esi = i = 0
        cmpl    %ebx, %esi  # compute (i - (2n-1)) and set flags
        jge     zerodone    # if i >= (2n-1), then skip over for loop
zeroout:
        movl    z(,%esi,4), %ecx # %ecx = address of z[i]
        movl    $0, (%ecx)  # z[i] = 0
        incl    %esi        # i++
        cmpl    %ebx, %esi  # compute (i - (2n-1)) and set flags
        jl      zeroout     # if i < (2n-1), then loop
zerodone:
    /* for (i = 0; i < n; i++) */
    /* Initialization */
        movl    20(%ebp), %ebx # %ebx = n
        movl    $0, %esi    # %esi = i = 0
    /* Test Expression */
        cmpl    %ebx, %esi  # compute (i - n) and set flags
        jge     cvdone      # if i >= n, then skip over for loop
c1loop:
    /* Body Statement */
    /* for (j = 0; j < n; j++) */
    /* Nested Initialization */
        movl    $0, %edi    # %edi = j = 0
    /* Nested Test Expression */
        cmpl    %ebx, %edi  # compute (j - n) and set flags
        jge     kickout     # if j >= n, then kick out of nested for loop
c2loop:
    /* Nested Body Statement */
    /* z[i+j] += x[i] * y[j]; */
        movl    %edi, %eax  # copy value of %edx/j to %eax
        addl    %esi, %eax  # %eax = i+j
        movl    x(,%esi,4), %ecx # %ecx = x[i]
        imull   y(,%edi,4), %ecx # %ecx = x[i] * y[j]
        movl    z(,%eax,4), %edx # %edx = z[i+j]
        addl    %ecx, %edx  # %edx = z[i+j] + (x[i] * y[j])
        leal    z(,%eax,4), %ecx # %ecx = address of z[i+j]
        movl    %edx, (%ecx)     # z[i+j] = z[i+j] + (x[i] * y[j])
    /* Nested Increment then Test */
        incl    %edi        # j++
        cmpl    %ebx, %edi  # compute (j - n) and set flags
        jge     kickout     # if j >= n, then kick out of nested for loop
        jmp     c2loop      # else jump back into nested loop
kickout:
    /* Increment then Test */
        incl    %esi        # i++
        cmpl    %ebx, %esi  # compute (i - n) and set flags
        jge     cvdone      # if i >= n, then end for loop
        jmp     c1loop      # else jump back into loop
cvdone:
        leave
        ret# return;
        




# USE THIS BELOW FOR ITERATING THROUGH LIST?
#  movl    z(,%ebx,4), %esi # %esi = z[i]


    /* callee-save push */
        #pushl   %ebx    # save callee-save registers %ebx and %edi onto stack
        #pushl   %edi

    /*
     #  movl   -[offset](%ebp), %edi # % set edi is n, n @ ebp offset
     #  addl    %edi, %edi # 2n
     #  subl    $1, %edi # 2n-1
     #  movl    $0, %ebx # i = 0
     #  cmpl    %edi, %ebx # compare i:n
     #  jge     done # if i>=n done
     #  movl    z(,%ebx,4), %esi # %esi = z[i]
    #*/
        
        /* Callee-save */
        # pushl   %esi  # Callee-save
        # pushl   %edi
        # pushl   %ebx

        /* Caller-save */
        # pushl   %edx  # Caller-save
        # pushl   %ecx
        # pushl   %eax
        


/* 
put n on stack and access by %ebp offset e.g.

movl -[offset](%ebp), %edi % set edi is n, n @ ebp offset
addl %edi, %edi # 2n
subl $1, %edi # 2n-1
movl $0, %ebx # i = 0
cmpl %edi, %ebx # compare i:n
jge done # if i>=n done
movl z(,%ebx,4), %esi # %esi = z[i]

*/


# create n fresh for each for loop?

/* for loop pseudocode
        init-expr;
        t = test-expr;
        if (!t)
            goto done;
loop:   body-statement;
        update-expr;
        t = test-expr;
        if (t)
            goto loop;
done:
*/

/*
Can translate access to array element A[i] using scaled index 
addressing mode as follows:
* Place base address A of array in register %edx
* Place index i in register %ecx
* A[i] = value stored in effective address (%edx,%ecx,4)
*/
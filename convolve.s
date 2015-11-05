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
        .align 4
        .equ N,50       # #define N 50
/* uninitialized global data */
        .comm x,N*4,4   # int x[N]
        .comm y,N*4,4   # int y[N]
        .comm z,N*8,4   # int z[2*N]
/* read-only data */
        .section  .rodata # is rodata in data?
    /* printf format strings */
szstr:  .string "Enter vector size (<=%d): " 
v1str:  .string "Enter first vector (%d elements):\n"
v2str:  .string "Enter second vector (%d elements):\n"
cvstr:  .string "Convolution:\n"
scand:  .string "%d"    # string for scanf("%d", _);
printd: .string "%d "   # printf("%d ", z[i]);
    # placeholder strings
ln31:   .string "\n"    # printf("\n");
/* main function */
        .text
.global main            # declare "main" as global symbol
main:
        .pushl  %ebp    # Prolog
        .movl   %esp, %ebp
        
        /* Callee-save */
        # pushl   %esi  # Callee-save
        # pushl   %edi
        # pushl   %ebx

        /* Caller-save */
        # pushl   %edx  # Caller-save
        # pushl   %ecx
        # pushl   %eax
        

        leave
        ret

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
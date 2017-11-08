.section .data

int_file_size:
  .space 8                          #64-bit integer

#=================== Strings ===================
string_nl:                          #used for printing new lines to stdout
  .string "\n"                      #2 bytes + nul(0) = 3 bytes

string_file_size:                   #used for printing the file size to stdout
  .string "File size: "             #11 bytes + nul(0) = 12 bytes

string_compares:                    #used for printing the compares to stdout
  .string "Number of compares: "    #20 bytes + nul(0) = 21 bytes

#=================== Strings ===================

buffer:                             #buffer is used for storing the contents of the input file.
  .space 1                          #fix

file_stat:
  .space 144	#Size of the fstat struct, used by the get_file_size function.

.section .text

.global _start #still executes without this function, why is it needed?



_start:


/* Retrieve file name from command line argument */
mov 16(%rsp), %rcx



/* Syscall: open file */
mov $2, %rax
mov %rcx, %rdi 			# address of file name is in register RCX
mov $0, %rsi
mov $2, %rdx			# open in read-write mode
syscall

/* NB: File descriptor for our file is now in %rax */
mov %rax, %rcx      #move the descriptor to rcx?



push %rcx #push the file descriptor in rcx to the stack.

call get_file_size

mov %rax, int_file_size           #store the result in memory variable

pop %rcx #pop the file descriptor in the stack back to rcx

mov $buffer, %rax
call print_rax
#mov int_file_size, buffer

/* Syscall: read n chars from file */
mov $0, %rax
mov %rcx, %rdi 			# %rcx is file descriptor for our file
mov $buffer, %rsi		# we want to save string in "buffer"
mov $53, %rdx			# number of bytes we want to read (8 characters)
syscall

/* Syscall: write string to stdout */
mov $1, %rax
mov $1, %rdi 			# 1 is file descriptor for stdout
mov $buffer, %rsi		# string we want to write is in "buffer"
mov $53, %rdx			# number of bytes we want to write (8 characters)
syscall



/* insertion sort */
call insertion_sort




/* terminate */
jmp terminate






.type insertion_sort, @function
insertion_sort:
push 	%rbp
mov 	%rsp,%rbp 		#Function Prolog

/* push and save our registers on the stack */
push %rax
push %rdi
push %rcx
push %rsi
push %rdx

/*temp variables for testing [5, 3, 7, 2, 0, 8, 1]*/

/* cumbersome
push $1
push $8
push $0
push $2
push $7
push $3
push $5
*/

/* our array, TODO: i want to move them by 2 increments instead of 4, since they're words. but not sure of the consequences yet.*/
movl $5, -48(%rbp) # mov long for now
movl $3, -44(%rbp)
movl $7, -40(%rbp)
movl $2, -36(%rbp)
movl $0, -32(%rbp)
movl $8, -28(%rbp)
movl $1, -24(%rbp)

movl $0, -4(%rbp)        #j variable, should propably be less than 4 bytes long
movl $0, -8(%rbp)        #i variable
movl $0, -12(%rbp)       #key variable

/* rax will be used as key
 * rdi will be used as i
 * rcx will be used as j
 * rsi will hold the length/number of elements in our array
 * rdx not used, good idea to assign this to array start memory address
 */


/* for j = 2 to A.length */
/* j = 2 */
movl $2, -4(%rbp)

for_loop:
cmp $6, %rcx      #6 because we have 6 elements our array. TODO: replace static variable with dynamic.
jg end_for_loop

/* start key = A[j] */
mov -4(%rbp), %eax #i just chose a random long register here
cltq              #convert long to quad, i'm not sure what this does
 /* hope this works lol, move to the start of the mem address of our array into rcx register. actually also think is dereferences the address to get it's value and stores it in rcx */
mov -48(%rbp,%rax,4), %eax
/* cp rcx to key */
mov %eax, -12(%rbp)
/* end key = A[j] */

/* i = j - 1 */
mov -4(%rbp), %rax
sub $1, %rax
mov %eax, -8(%rbp)


/*  while (i > 0 && A[i] > key) */
while_loop_start:
cmpl $0, -8(%rbp)        #i > 0
jle while_loop_end
movl -8(%rbp), %eax      #again i chose a random long register for this operation */
cltq                    #convert long to quad for operation and overflow prevention?
movl -48(%rbp,%rax,4), %eax
cmpl %eax, -12(%rbp)
jge while_loop_end

/* A[i + 1] = A[i] */
movl -8(%rbp), %eax     #put i in eax
leal 1(%rax), %ecx     #get address of i + 1 stored in rax and put in rcx !NP!
movl -8(%rbp), %eax     #store i in rax
cltq
movl -48(%rbp,%rax,4), %edx #put start array in rdx
movslq %ecx, %rax
movl %edx, -48(%rbp,%rax,4)
/* i = i - 1*/
subl $1, -8(%rbp)
jmp while_loop_start

while_loop_end:
/* A[i + 1] = key */
movl -8(%rbp), %eax
addl $1, %eax
cltq
movl -12(%rbp), %edx
movl %edx, -48(%rbp,%rax,4)

jmp increment_for_loop_and_restart

/* end one loop iteration, increment and restart */
increment_for_loop_and_restart:
addl $1, -4(%rbp)
jmp for_loop

end_for_loop:

/* test: print array the lazy way lol */
mov -48(%rbp), %rax
cltq
call print_rax

mov -44(%rbp), %rax
cltq
call print_rax

mov -40(%rbp), %rax
cltq
call print_rax

mov -36(%rbp), %rax
cltq
call print_rax

mov -32(%rbp), %rax
cltq
call print_rax

mov -28(%rbp), %rax
cltq
call print_rax

mov -24(%rbp), %rax
cltq
call print_rax


/* pop and restore our registers from the stack */
pop %rdx
pop %rsi
pop %rcx
pop %rdi
pop %rax

mov		%rbp,%rsp		#Function Epilog
pop 	%rbp
ret







###############################################################################
# This function returns the filesize in rax. It expects the file handler to be
# on the stack.
#
# The function is not register save!
###############################################################################
.type get_file_size, @function
get_file_size:
	push 	%rbp
	mov 	%rsp,%rbp 		#Function Prolog

  /* push and save our registers on the stack */
  push %rax
  push %rdi
  push %rcx
  push %rsi
  push %rdx

	#Get File Size
	mov		$5,%rax			#Syscall fstat
	mov		16(%rbp),%rdi	#File Handler
	mov		$file_stat,%rsi	#Reserved space for the stat struct
	syscall
	mov		$file_stat, %rbx
	mov		48(%rbx),%rax	#Position of size in the struct

  /* pop and restore our registers from the stack */
  pop %rdx
  pop %rsi
  pop %rcx
  pop %rdi
  pop %rax

	mov		%rbp,%rsp		#Function Epilog
	pop 	%rbp
	ret



.type get_string_length, @function
get_string_length:
  /* Dertermines the length of a zero-terminated string. Returns result in %rax.
   * %rax: Address of string.
   */
  push %rbp
  mov %rsp, %rbp

  push %rcx
  push %rbx
  push %rdx
  push %rsi
  push %r11

  xor %rdx, %rdx

  # Get string length
  lengthLoop:
    movb (%rax), %bl    # Read a byte from string
    cmp $0, %bl         # If byte == 0: end loop
  je lengthDone
    inc %rdx
    inc %rax
  jmp lengthLoop
  lengthDone:

  mov %rdx, %rax

  pop %r11
  pop %rsi
  pop %rdx
  pop %rbx
  pop %rcx

  mov %rbp, %rsp
  pop %rbp
  ret



# Syscall calling sys_exit
terminate:
mov $60, %rax           	 # rax: int syscall number
mov $0, %rdi            	 # rdi: int error code
syscall










/* test function */

.type print_rax, @function
print_rax:
  /* Prints the contents of rax. */

  push  %rbp
  mov   %rsp, %rbp        # function prolog

  push  %rax              # saving the registers on the stack
  push  %rcx
  push  %rdx
  push  %rdi
  push  %rsi
  push  %r9

  mov   $6, %r9           # we always print the 6 characters "RAX: \n"
  push  $10               # put '\n' on the stack

  loop1:
  mov   $0, %rdx
  mov   $10, %rcx
  idiv  %rcx              # idiv alwas divides rdx:rax/operand
                          # result is in rax, remainder in rdx
  add   $48, %rdx         # add 48 to remainder to get corresponding ASCII
  push  %rdx              # save our first ASCII sign on the stack
  inc   %r9               # counter
  cmp   $0, %rax
  jne   loop1             # loop until rax = 0

  mov   $0x20, %rax       # ' '
  push  %rax
  mov   $0x3a, %rax       # ':'
  push  %rax
  mov   $0x58, %rax       # 'X'
  push  %rax
  mov   $0x41, %rax       # 'A'
  push  %rax
  mov   $0x52, %rax       # 'R'
  push  %rax

  print_loop:
  mov   $1, %rax          # Here we make a syscall. 1 in rax designates a sys_write
  mov   $1, %rdi          # rdx: int file descriptor (1 is stdout)
  mov   %rsp, %rsi        # rsi: char* buffer (rsp points to the current char to write)
  mov   $1, %rdx          # rdx: size_t count (we write one char at a time)
  syscall                 # instruction making the syscall
  add   $8, %rsp          # set stack pointer to next char
  dec   %r9
  jne   print_loop

  pop   %r9               # restoring the registers
  pop   %rsi
  pop   %rdi
  pop   %rdx
  pop   %rcx
  pop   %rax

  mov   %rbp, %rsp        # function Epilog
  pop   %rbp
  ret





  ###############################################################################
  # This function is our simple and naive memory manager. It expects to
  # receive the number of bytes to be reserved on the stack.
  #
  # The function is not register save!
  #
  # The function returns the beginning of the reserved heap space in rax
  ###############################################################################

  .type alloc_mem, @function
  alloc_mem:
  	push 	%rbp
  	mov 	%rsp,%rbp 		#Function Prolog

  	/* save stack */
  	push	%rax
  	push	%rbx
  	push	%rcx
  	push	%rdx
  	push	%rdi
  	push	%rsi


  	#First, we need to retrieve the current end of our heap
  	mov		$0,%rdi
  	mov		$12,%rax
  	syscall					#The current end is in %rax
  	push	%rax			#We have to save this, this will be the beginning of the cleared field
  	add		16(%rbp),%rax	#Now we add the desired additional space on top of the current end of our heap
  	mov		%rax,%rdi
  	mov		$12,%rax
  	syscall

  	pop		%rax


  	/* restore stack */
  	pop		%rsi
  	pop		%rdi
  	pop		%rdx
  	pop		%rcx
  	pop		%rbx
  	pop		%rax


  	mov		%rbp,%rsp		#Function Epilog
  	pop 	%rbp
  	ret







    ###############################################################################
    # This function returns the amount of numbers in the given buffer in rax. First
    # parameter is the address of the buffer, second parameter is the size of the
    # buffer
    #
    # The function is not register save!
    ###############################################################################

    .type get_number_count, @function
    get_number_count:
    	push 	%rbp
    	mov 	%rsp,%rbp 		#Function Prolog

    	mov		16(%rbp),%rbx	#Address of the buffer
    	mov		$0,%rcx			#Position in buffer
    	mov		$1,%rax			#Number count
    num_count:
    	mov		(%rbx,%rcx),%dl	#load byte
    	inc		%rcx			#increase buffer counter
    	cmp		24(%rbp),%rcx	#Compare to buffer length
    	je		end_counting	#Are we done with the buffer?
    	cmp		$0xA,%dl		#is it the new line sign?
    	jne		num_count		#If not, continue in the buffer
    	inc		%rax			#completed a number
    	jmp		num_count
    end_counting:

    	mov		%rbp,%rsp		#Function Epilog
    	pop 	%rbp
    	ret


    ###############################################################################
    # This function parses the raw data given in a buffer and stores integers
    # in a second buffer. Note, this functions only expects unsigns int and does
    # no validity check at all.
    #
    # Parameters on stack
    # 1. Address of raw data buffer
    # 2. Length of raw data buffer
    # 3. Address of target buffer
    #
    # The function is not register save!
    ###############################################################################

    .type parse_number_buffer, @function
    parse_number_buffer:
    	push 	%rbp
    	mov 	%rsp,%rbp 			#Function Prolog

    	#Now, lets reconstruct the numbers!
    	mov		16(%rbp),%r8		#file buffer
    	xor		%r9,%r9				#file buffer position
    	mov		32(%rbp),%r10		#Number buffer
    	xor		%r11,%r11			#number buffer position
    	xor		%r12,%r12			#current number

    number_parsing_loop:
    	xor		%rax,%rax
    	mov		(%r8,%r9),%al		#read byte
    	cmp		$0xA,%rax			#Is the number finished
    	je		finish_number
    	#No, it isn't, we keep going
    	sub		$48,%rax			#From ascii to actual number
    	imul	$10,%r12			#Make room for the new digit
    	add		%rax,%r12			#Add the new digit
    	jmp		finish_parsing_loop
    finish_number:
    	mov		%r12,(%r10,%r11,8)	#Store the number
    	inc		%r11				#Next number
    	xor		%r12,%r12
    finish_parsing_loop:
    	cmp		%r9,24(%rbp)		#Have we processed the last byte of the buffer?
    	je		store_last_number	#Yes, there is still one last number in %r12
    	inc		%r9
    	jmp		number_parsing_loop

    store_last_number:
    	mov		%r12,(%r10,%r11,8)	#Store the last number
    	mov		%rbp,%rsp			#Function Epilog
    	pop 	%rbp
    	ret

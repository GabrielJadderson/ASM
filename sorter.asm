.section .data

test:
  .space 512

int_file_size:
  .space 8                          #64-bit integer

file_descriptor:
  .space 8

file_readin_pointer:
  .space 8

number_array_pointer:
  .space 8

number_array_size:
  .space 8

number_of_compares:
  .space 8                          #64-bit integer for counting the amount of compares

#=================== Strings ===================
string_nl:                          #used for printing new lines to stdout
  .string "\n"                      #2 bytes + nul(0) = 3 bytes

string_file_size:                   #used for printing the file size to stdout
  .string "File size: \n"             #11 bytes + nul(0) = 12 bytes

string_compares:                    #used for printing the compares to stdout
  .string "Number of compares: \n"    #20 bytes + nul(0) = 21 bytes

#=================== Strings ===================

buffer:                             #buffer is used for storing the contents of the input file.
  .space 53                          #fix

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
mov %rax, file_descriptor      #move the descriptor to memory



push %rcx #push the file descriptor in rcx to the stack.

call get_file_size

#Stolen from get_file_size as the function was made register safe, so rax no longer contains this value after the function call.
  mov		$file_stat, %rbx
  mov		48(%rbx),%rax	#Position of size in the struct

#mov %rax, int_file_size           #store the result in memory variable

#call print_rax

pop %rcx #pop the file descriptor in the stack back to rcx

# Testing memory allocation
mov file_stat+48, %rax # Move the file size into rax.

push %rax
call alloc_mem

mov %rax, file_readin_pointer

# Syscall: read n chars from file
mov $0, %rax
mov file_descriptor, %rdi 			# %rcx is file descriptor for our file
mov file_readin_pointer, %rsi		# we want to save string in "buffer"
mov file_stat+48, %rdx			# number of bytes we want to read (8 characters)
syscall

# Syscall: write string to stdout
/*mov $1, %rax
mov $1, %rdi 			# 1 is file descriptor for stdout
mov (file_readin_pointer), %rsi		# string we want to write is in "buffer"
mov file_stat+48, %rdx			# number of bytes we want to write (8 characters)
syscall

# Syscall: write string to stdout
mov $1, %rax
mov $1, %rdi 			# 1 is file descriptor for stdout
mov $string_nl, %rsi		# string we want to write is in "buffer"
mov $1, %rdx			# number of bytes we want to write (8 characters)
syscall
*/
# Endof: Testing memory allocation

# Get the number of numbers in the file.
mov file_stat+48, %rax
push %rax
mov file_readin_pointer, %rax
push %rax

call get_number_count # Number of numbers is not in %rax
movq %rax, number_array_size

# Now allocate the memory
lea (,%rax,8), %rax

push %rax
call alloc_mem

mov %rax, number_array_pointer

# pop the arguments given to get_number_count.
pop %rax
pop %rax

# Now parse the numbers into the number array.
mov number_array_pointer, %rax
push %rax
mov file_stat+48, %rax
push %rax
mov file_readin_pointer, %rax
push %rax

call parse_number_buffer

pop %rax
pop %rax
pop %rax


/* insertion sort */
call insertion_sort


/* print number of compares out when program is done */
push $string_compares
call print_string
pop string_compares
push %rax
mov number_of_compares, %rax
call print_rax
pop %rax





/* terminate */
jmp terminate



.type insertion_sort, @function
######################
# Insertion Sort
#
######################
insertion_sort:
push 	%rbp
mov 	%rsp,%rbp 		#Function Prolog

/* push and save our registers on the stack */
push %rax
push %rdi
push %rcx
push %rsi
push %rdx
push %r10
push %r11

/* rax will be used as key
 * rdi will be used as i
 * rcx will be used as j
 * rsi will hold the length/number of elements in our array
 * rdx not used, good idea to assign this to array start memory address
 */

# Initialization
xor %rax,%rax
mov $1, %rdi
mov $1, %rcx #Should be set to be = i (rdi) anyway, but eh
mov number_array_size, %rsi
mov number_array_pointer, %rdx

IS2_WHILEI: #while (i < len(arr))
call inc_compares #TODO: remove when testing performace
cmp %rdi, %rsi
je IS2_WHILEIEND
# i < len(arr):

  mov %rdi, %rcx # j = i

  IS2_WHILEJ: #while j > 0 && arr[j-1] > arr[j]
  call inc_compares #TODO: remove when testing performace
  cmp $0, %rcx     # |-> j > 0
  je IS2_WHILEJEND # |

  movq   (%rdx,%rcx,8), %r10
  movq -8(%rdx,%rcx,8), %r11

  call inc_compares #TODO: remove when testing performace
  cmp %r10, %r11    # |-> arr[j-1] > arr[j]
  jle IS2_WHILEJEND # |

  #swap
  mov %r11,   (%rdx,%rcx,8)
  mov %r10, -8(%rdx,%rcx,8)
  #endof: swap

  dec %rcx
  jmp IS2_WHILEJ

  IS2_WHILEJEND:

inc %rdi
jmp IS2_WHILEI

IS2_WHILEIEND:

# jmp IS_ENDFUNCTION #Fall-through

IS_ENDFUNCTION: # Convenient for bypassing things for testing when segfaults happen somewhere.
/* Syscall: write string to stdout */


mov $0,%rbx
mov number_array_pointer, %rsi

IS_resultprintingloop2:
mov (%rsi,%rbx,8), %rcx
mov %rcx, %rax
call print_rax

add $1, %rbx
cmp number_array_size,%rbx
jl IS_resultprintingloop2

/* pop and restore our registers from the stack */
pop %r11
pop %r10
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

  /* mov   $6, %r9           # we always print the 6 characters "RAX: \n" */
  mov   $1, %r9
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

  #mov   $0x20, %rax       # ' '
  #push  %rax
  #mov   $0x3a, %rax       # ':'
  #push  %rax
  #mov   $0x58, %rax       # 'X'
  #push  %rax
  #mov   $0x41, %rax       # 'A'
  #push  %rax
  #mov   $0x52, %rax       # 'R'
  #push  %rax

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




      ###############################################################################
      # This Function increments the compare counter. we want to count how many times
      # the insertion sort algorithm uses the compare instruction.
      # this function only uses the rax register and is only rax safe.
      ###############################################################################

      .type inc_compares, @function
      inc_compares:
      push 	%rbp
      mov 	%rsp,%rbp 			#Function Prolog

      #push %rax

      addq $1, number_of_compares

      #mov number_of_compares, %rax
      #call print_rax

      #pop %rax

      mov		%rbp,%rsp			#Function Epilog
    	pop 	%rbp
      ret


      ###############################################################################
      # This function prints a zero terminated String to the screen. The address of
      # the String is given on the stack
      #
      # The function is register save
      ###############################################################################

      .type print_string, @function
      print_string:
      	push 	%rbp
      	mov 	%rsp,%rbp 		#Function Prolog

      	push	%rax			#Saving the registers
      	push	%rbx
      	push	%rcx
      	push	%rdx
      	push	%rdi
      	push	%rsi
      	push	%r9

      	mov		16(%rbp),%rax	#Address of the String
      	xor		%rcx,%rcx		#Counter
      string_length:
      	movb	(%rax,%rcx), %bl	#Load byte
      	cmp		$0,%bl			#End of String?
      	jz		string_length_finished
      	add		$1,%rcx			#Increase counter
      	jmp		string_length

      string_length_finished:
      	mov 	$1, %rax    	# In "syscall" style 1 means: write
      	mov 	$1, %rdi    	# File descriptor (std out)
      	mov		16(%rbp),%rsi   # Address of the String
      	mov 	%rcx,%rdx    	# Length of the String
      	syscall					#Call the kernel, 64Bit variant

      	pop		%r9				#Restoring the registers
      	pop		%rsi
      	pop		%rdi
      	pop		%rdx
      	pop		%rcx
      	pop		%rbx
      	pop		%rax

      	mov		%rbp,%rsp		#Function Epilog
      	pop 	%rbp
      	ret

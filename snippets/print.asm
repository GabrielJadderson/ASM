###############################################################################
# This function prints a number to std-out. The number is given on the stack
#
# The function is register save/safe
###############################################################################

.type print_number, @function
print_number:
	push 	%rbp
	mov 	%rsp,%rbp 		#Function Prolog

	push	%rax			#Saving the registers
	push	%rbx
	push	%rcx
	push	%rdx
	push	%rdi
	push	%rsi
	push	%r9

	mov		16(%rbp),%rax	#The Number to Print

	mov		$1,%r9			#We always print 6 chars: "\n"
	push	$10				#Put '\n' on the stack
loop1:
	mov 	$0,%rdx
	mov 	$10,%rcx
	idiv 	%rcx     		#Used like that, idiv divides rdx:rax/operand
							#Result is in rax, remainder in rdx
	add		$48,%rdx		#Make the remainder an ASCII code
	push	%rdx			#Save our first ASCII sign on the stack
	inc		%r9				#Counter
	cmp		$0,%rax
	jne		loop1			#Loop until rax = 0


print_loop:
	mov 	$1, %rax    	# In "syscall" style 1 means: write
	mov 	$1, %rdi    	# ... and the first arg. is stored in rdi (not rbx)
	mov		%rsp,%rsi   	# ... and the second arg. is stored in rsi (not rcx)
	mov 	$1,%rdx    		# ... and the third arg. is stored in rdx
	syscall					# Call the kernel, 64Bit vversion
	add		$8,%rsp			# Set stack pointer to next sign
	sub		$1,%r9
	jne		print_loop

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



###############################################################################
# This function prints a zero terminated String to the screen. The address of
# the String is given on the stack
#
# The function is not register save
###############################################################################

.type print_string, @function
print_string:
	push 	%rbp
	mov 	%rsp,%rbp 		#Function Prolog

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

	mov		%rbp,%rsp		#Function Epilog
	pop 	%rbp
	ret

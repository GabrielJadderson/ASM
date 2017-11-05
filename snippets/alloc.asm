.section .text

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

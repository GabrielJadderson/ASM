.section .data
file_stat:	.space 144	#Size of the fstat struct
.section .text


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

	#Get File Size
	mov		$5,%rax			#Syscall fstat
	mov		16(%rbp),%rdi	#File Handler
	mov		$file_stat,%rsi	#Reserved space for the stat struct
	syscall
	mov		$file_stat, %rbx
	mov		48(%rbx),%rax	#Position of size in the struct

	mov		%rbp,%rsp		#Function Epilog
	pop 	%rbp			
	ret

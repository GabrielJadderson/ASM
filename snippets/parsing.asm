.section .text

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
	jne		num_count		7#If not, continue in the buffer
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

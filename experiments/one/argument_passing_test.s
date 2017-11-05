global _start

_start:
mov eax,85       ; syscall number for creat()
mov rdi,[rsp+16] ; argv[1], the file name
mov esi,00644Q   ; rw,r,r
syscall          ; call the kernel
xor edi, edi     ; exit code 0
mov eax, 60      ; syscall number for exit()
syscall

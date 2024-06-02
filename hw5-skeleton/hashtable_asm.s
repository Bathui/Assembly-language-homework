
/*  
 * We are using GCC's assembler for this, which
 * allow C style comments.  GCC defaults to AT&T syntax (op src, dest)
 * but we'd much rather use Intel syntax (op dest, src) because it is
 * more similar to RISC-V and Intel's reference material uses Intel 
 * syntax (naturally).  So we have the following directive.
 *
 * Intel syntax is better because it also automatically infers the types
 * based on the register specifier, eliminating the need to include types
 * in most operations which would otherwise prove tedious and annoying.
 */
.intel_syntax noprefix

/*
 * However, compiler directives remain in the GNU format.
 */
.file "hashtable.s"
.text
.section .rodata

todo:	.string "Need to implement!"

.text
	.globl createHashTable
	.globl insertData
	.globl findData


createHashTable:
	sub rsp, 32
	mov [rsp], r12
	mov [rsp+8], r13
	mov [rsp+16], r14
	mov [rsp+24], r15

	mov r12, rdi
	mov r13, rsi 
	mov r14, rdx

	mov rdi, 32  # sizeof(HashTable)
	call malloc
	mov r15, rax # HashTable *newTable = malloc(sizeof(HashTable));
    
	mov [r15+24], r12d  # newTable->size = size;
	mov edi, 0
	mov [r15+28], edi  # newTable->used = 0;
	
	mov rdi, 8 # sizeof(struct HashBucket *)
	imul rdi, r12 # sizeof(struct HashBucket *) * size;
	call malloc
    mov [r15+16], rax # newTable->data = malloc(sizeof(struct HashBucket *) * size);
	
	# start the loop
	mov r10, 0
	mov r11, 0
	mov rdx, 0
	cmp r10, r12    # compare i with size 
	jb loop1       # jump to the loop
	jmp return1

loop1:
	mov rsi, [r15+16]   # store the data into rsi
	mov [rsi+r11], rdx      # newTable->data[i] = NULL;
	add r11, 8
	add r10, 1     # i++
	cmp r10, r12    # compare i with size 
	jb loop1

return1:
	mov [r15], r13
	mov [r15+8], r14
	mov rax, r15
	mov r12, [rsp]      # start to postamble
	mov r13, [rsp+8]
	mov r14, [rsp+16]
	mov r15, [rsp+24]
	add rsp, 32
	ret

insertData:
	sub rsp, 40   # start to preamble
	mov [rsp], r12
	mov [rsp+8], r13
	mov [rsp+16], r14
	mov [rsp+24], r15
	mov [rsp+32], rbx
    mov r12, rdi
	mov r13, rsi
	mov r14, rdx   # finish preamble

	mov rdi, 24   # sizeof(struct HashBucket)
	call malloc
	mov r15, rax  # struct HashBucket *newBucket =(struct HashBucket *)malloc(sizeof(struct HashBucket));

	mov rdi, r13
	mov r10, [r12]
	call r10       # (table->hashFunction)(key)
	mov rbx, rax      # location  = ((table->hashFunction)(key))
	mov r10d, [r12+24]   # table->size
	xor rdx, rdx     # prepare for the division
	mov rax, rbx 
	div r10
	mov rbx, rdx  # location  = ((table->hashFunction)(key)) % table->size;
    
	mov r10, rbx
	imul r10, 8    # get the real index
	mov r11, [r12+16]  #  **data right now
	mov r11, [r11+r10]   # table->data[location]
	mov [r15+16], r11   # newBucket->next = table->data[location]

	mov [r15+8], r14	 # newBucket->data = data;
	mov [r15], r13		# newBucket->key = key;

    mov r11, [r12+16]  #  **data right now
	mov [r11+r10], r15  # table->data[location] = newBucket;
    
	mov r10d, 1
    add [r12+28], r10d

	mov r12, [rsp]      # start to postamble
	mov r13, [rsp+8]
	mov r14, [rsp+16]
	mov r15, [rsp+24]
	mov rbx, [rsp+32]
	add rsp, 40
	ret

	
findData:
	sub rsp, 24    # start to preamble
	mov [rsp], r12
	mov [rsp+8], r13
	mov [rsp+16], r14

	mov r12, rdi
	mov r13, rsi

	mov rdi, r13
	mov r10, [r12]
	call r10       # (table->hashFunction)(key)
	mov r14, rax      # location  = ((table->hashFunction)(key))
	mov r10d, [r12+24]   # table->size
	xor rdx, rdx     # prepare for the division
	mov rax, r14
	div r10
	mov r14, rdx  # location  = ((table->hashFunction)(key)) % table->size;

	mov r10, r14
	imul r10, 8    # get the real index
	mov r11, [r12+16]  #  **data right now
	mov r11, [r11+r10]   # table->data[location]
	mov r14, r11   	# struct HashBucket *lookAt = table->data[location];

	cmp r14, 0
	je return2

loop2:
	mov rdi, r13
	mov rsi, [r14]
	mov r10, [r12+8]
	call r10      # (table->equalFunction)(key, lookAt->key)
	cmp rax, 0
	jnz return3
	mov r14, [r14+16]
	cmp r14, 0
	jnz loop2

return2:
    mov rax, 0

	mov r12, [rsp]	# start to postamble
	mov r13, [rsp+8]
	mov r14, [rsp+16]
	add rsp, 24
	ret

return3:
	mov rax, [r14+8]

	mov r12, [rsp]	# start to postamble
	mov r13, [rsp+8]
	mov r14, [rsp+16]
	add rsp, 24
	ret

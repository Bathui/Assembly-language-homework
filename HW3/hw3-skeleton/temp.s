# void insertData(HashTable *table, void *key, void *data);
insertData:
	addi sp sp -24  # start preamble
	sw ra 0(sp)
	sw s0 4(sp)
	sw s1 8(sp)
	sw s2 12(sp)
	sw s3 16(sp)
	sw s4 20 (sp)
    mv s0 a0
	mv s1 a1
	mv s2 a2

	mv s3 zero  # unsigned int location  = 0;
	li t0 12   # sizeof(struct HashBucket)
	mv a0 t0  # move size of HashBucket to the argument
	call malloc
	mv s4 a0 # store the pointer to newBucket
   
    mv a0 s1  # load the argument for functor
    jalr ra 0(s0) # might have some mistakes
	lw t1 12(s0)

    div s3 a0 t1 # following is the modulo operation  
	mul t2 s3 t1
	sub s3 a0 t2  # location  = ((table->hashFunction)(key)) % table->size;
    
	lw t0 8(s0) # load data
	li t1 4  # unit of index
	mul t2 s3 t1  # real index
	add t0 t0 t2   # &(data[location])
    lw t3 0(t0)  # table->data[location];
	
	sw t3 8(s4)  # newBucket->next = table->data[location];
	
	sw s2 4(s4)  # newBucket->data = data; 
	sw s1 0(s4)  # newBucket->key = key;
	sw s4 0(t0)	 # table->data[location] = newBucket;
	
	lw t1 16(s0)  # temp = table->used 
	li t1 1      # temp += 1
	sw t1 16(s0)   # table->used = temp
    
	lw ra 0(sp)  # start to postamble
	lw s0 4(sp)
	lw s1 8(sp)
	lw s2 12(sp)
	lw s3 16(sp)
	lw s4 20 (sp)
	addi sp sp 24
	ret

# void *findData(HashTable *table, void *key);
findData:
	addi sp sp -20  # start to preamble
	sw ra 0(sp)
	sw s0 4(sp)
	sw s1 8(sp)
	sw s2 12(sp)
	sw s3 16(sp)
    mv s0 a0
	mv s1 a1

	mv a0 s1  # load the argument for functor
    jalr ra 0(s0) # might have some mistakes
	lw t1 12(s0)

    div s3 a0 t1 # following is the modulo operation  
	mul t2 s3 t1
	sub s3 a0 t2  # location  = ((table->hashFunction)(key)) % table->size;
    
	lw t0 8(s0) # load data
	li t1 4  # unit of index
	mul t2 s3 t1  # real index
	add t0 t0 t2   # &(data[location])
    lw t3 0(t0)  # table->data[location];

	mv s2 t3  # struct HashBucket *lookAt = table->data[location]; 
loop2: 
	beqz s2 loop2_end
	mv a0 s1     # assign key as first argument
	lw t0 0(s2)  # load key from bucket
	mv a1 t0  # assign the second argument

	jalr ra 4(s0)   # (table->equalFunction)(key, lookAt->key)
	mv t1 a0

	beqz t1 else   # table->equalFunction)(key, lookAt->key) == 0
	lw t2 8(s2)    # lookAt->data;
	mv a0 t2
	j loop2_end  # jump to postamble


else:
	lw t2 8(s2)
	mv s2 t2
	j loop2
	mv a0 zero

loop2_end:
	lw ra 0(sp)  # start to post amble
	lw s0 4(sp)
	lw s1 8(sp)
	lw s2 12(sp)
	lw s3 16(sp)
	addi sp sp 20
	ret
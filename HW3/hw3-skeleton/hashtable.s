# Data section messages.
	.data
message:   .asciz "Need To Implement\n"
	
	## Code section
	.text
	.globl createHashTable
	.globl insertData
	.globl findData

#struct HashBucket {
#  void *key;  0
#  void *data;  4
#  struct HashBucket *next; 8
#};


#typedef struct HashTable {
#  unsigned int (*hashFunction)(void *); 0
#  int (*equalFunction)(void *, void *); 4
#  struct HashBucket **data; 8
#  int size; 12
#  int used; 16
#} HashTable;


#HashTable *createHashTable(int size,
#                           unsigned int (*hashFunction)(void *),
#                           int (*equalFunction)(void *, void *));
createHashTable:
	addi sp sp -20
	sw ra 0(sp)
	sw s0 4(sp)
	sw s1 8(sp)
	sw s2 12(sp)
	sw s3 16(sp)

	mv s0 a0
	mv s1 a1
	mv s2 a2     # finish the preamble
    
    li t0 20 # save sizeof(hashtable)

	mv a0 t0 # argument of malloc
	call malloc
	mv s3 a0 # HashTable *newTable = malloc(sizeof(HashTable));
	
	sw s0 12(s3) # newTable->size = size;
	sw zero 16(s3) # newTable->used = 0;

	li t0 4 # sizeof(struct HashBucket *)
	mul a0 t0 s0   # sizeof(struct HashBucket *) * size

	call malloc
	sw a0 8(s3)   # save to newTable->data 
    
	mv t1 zero  # i = 0
 	mv t2 s0   # upper bound for i

	lw t3 8(s3) # load pointer of pointer data
Loop: 
	bge t1 t2 finish_loop
	sw zero 0(t3)
	addi t3 t3 4     # t3 = newTable->data[i+1]
	addi t1 t1 1     # i++ 
	j Loop

finish_loop:
    sw s1 0(s3)  # newTable->hashFunction = hashFunction;
	sw s2 4(s3)  # newTable->equalFunction = equalFunction;

# start to postamble
	mv a0 s3 		# return newTable	
	lw ra 0(sp)
	lw s0 4(sp)
	lw s1 8(sp)
	lw s2 12(sp)
	lw s3 16(sp)
	addi sp sp 20
	ret

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

	li t0 12   # sizeof(struct HashBucket)
	mv a0 t0  # move size of HashBucket to the argument
	call malloc
	mv s4 a0 # store the pointer to struct HashBucket *newBucket
    
	lw t0 0(s0) 
    mv a0 s1  # load the argument for functor
	
    jalr ra 0(t0) # might have some mistakes
	lw t1 12(s0) 

    rem s3 a0 t1  # location  = ((table->hashFunction)(key)) % table->size;
    
	
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
	addi t1 t1 1      # temp += 1
	sw t1 16(s0)   # table->used = temp
    
	li a0 0
	lw ra 0(sp)  # start to postamble
	lw s0 4(sp)
	lw s1 8(sp)
	lw s2 12(sp)
	lw s3 16(sp)
	lw s4 20(sp)
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
	lw t0 0(s0)
    jalr ra 0(t0) # might have some mistakes
	
	lw t1 12(s0)  # get size
	rem s3 a0 t1  # location  = ((table->hashFunction)(key)) % table->size;    
	
	lw t0 8(s0) # load data
	li t1 4  # unit of index
	mul t2 s3 t1  # real index
	add t0 t0 t2   # &(data[location])
    lw t3 0(t0)  # table->data[location];
  # marker right here!!!!! 
	mv s2 t3  # struct HashBucket *lookAt = table->data[location]; 
loop2: 
 	mv a0 zero
	beqz s2 loop2_end
	mv a0 s1     # assign key as first argument
	lw t0 0(s2)  # load key from bucket
	mv a1 t0  # assign the second argument
    
	lw t4 4(s0)
	jalr ra 0(t4)   # (table->equalFunction)(key, lookAt->key)
	mv t1 a0

	beqz t1 else   # table->equalFunction)(key, lookAt->key) == 0
	lw t2 4(s2)    # lookAt->data;
	mv a0 t2
	j loop2_end  # jump to postamble


else:
	lw t2 8(s2)
	mv s2 t2
	mv a0 zero
	j loop2

loop2_end:
	# have some issues here
	lw ra 0(sp)  # start to post amble
	lw s0 4(sp)
	lw s1 8(sp)
	lw s2 12(sp)
	lw s3 16(sp)
	addi sp sp 20
	ret

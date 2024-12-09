.text

# strcmp(String s1, String s2): returns 0 if two strings are the same, -1 otherwise
strcmp:
	lb $t0, ($a0)
	lb $t1, ($a1)
	beqz $t0, strcmp_return_check
	beq $t0, '\n', strcmp_return_check
	bne $t0, $t1, strcmp_notequal
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	j strcmp
strcmp_return_check:
	beqz $t1, strcmp_return
	beq $t1, '\n', strcmp_return
strcmp_notequal:
	blt $t0, $t1, strcmp_issmall
	li $v0, 1
	jr $ra
strcmp_issmall:
	li $v0, -1
	jr $ra
strcmp_return:
	li $v0, 0
	jr $ra




# strlen(String s1): returns the length of the string	
strlen:                 
    li $v0,0        
strlen_nextCh: 
    lb $t0, 0($a0)  
    beqz $t0,strlen_end
    beq $t0, '\n',strlen_end
    addi $v0,$v0,1  
    addi $a0,$a0,1  
    j strlen_nextCh
strlen_end:
    jr $ra
    


toUpper:
	move $t0, $a0
__toUpper_loop:
    lb $t1, 0($t0)
    beqz $t1, __toUpper_done	
    
	li $t7, 122
    bgt $t1, $t7, __toUpper_noChange 
	li $t7, 95
    blt $t1, $t7, __toUpper_noChange
    
    addi $t1, $t1, -32 
    sb $t1, 0($t0)
__toUpper_noChange:
	addi $t0, $t0, 1
	j __toUpper_loop
	
__toUpper_done:
	move $v0, $a0
	jr $ra 


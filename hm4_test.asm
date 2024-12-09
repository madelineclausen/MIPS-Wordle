.include "wordle_dict.asm"
.include "hw4_helpers.asm"
.include "hw4_clausenm.asm"

.globl main
.text

main:
    la $a0, puzzles
    li $a1, 99
    li $a2, 4
    li $a3, 3
    la $t0, w_12030
    la $t1, dict
    la $t2, dictIndex
    addi $sp, $sp, -12
    sw $t2, ($sp)
    sw $t1, 4($sp)
    sw $t0, 8($sp)
    jal playWord
    move $a0, $v0 
    li $v0, 1
    syscall
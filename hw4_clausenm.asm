# Madeline Clausen
# clausenm
#.include "hw4_helpers.asm"
.text
 
### part 1 functions ###
setCell:
    bltz $a0, returnSetCellError
    bgt $a0, 11, returnSetCellError
    bltz $a1, returnSetCellError
    bgt $a1, 6, returnSetCellError
    bltz $a3, returnSetCellError
    bgt $a3, 0x0F, returnSetCellError
    li $t1, 0xFFFF0000
    li $t2, 14
    mul $t3, $a0, $t2 # (row) x (num_cols) x (element_size)
    li $t2, 2
    mul $t2, $t2, $a1 # (col) x (element_size)
    add $t2, $t2, $t3
    add $t2, $t2, $t1 # cell address
    lw $t0, 0($sp) # BG 
    bltz $t0, returnSetCellError
    bgt $t0, 0x0F, returnSetCellError
    bgt $a2, 0x7F, setColors
    sb $a2, 0($t2)
setColors:
    addi $t2, $t2, 1 
    sll $t0, $t0, 4
    or $t0, $a3, $t0
    sb $t0, 0($t2)
    j returnSetCellSuccess
returnSetCellError:
    li $v0, -1
    jr $ra
returnSetCellSuccess:
    li $v0, 0
    jr $ra

getCell:
    bltz $a0, returnGetCellError
    bltz $a1, returnGetCellError
    bgt $a0, 11, returnGetCellError
    bgt $a1, 6, returnGetCellError
    li $t1, 0xFFFF0000
    li $t2, 14
    mul $t3, $a0, $t2 # (row) x (num_cols) x (element_size)
    li $t2, 2
    mul $t2, $t2, $a1 # (col) x (element_size)
    add $t2, $t2, $t3
    add $t2, $t2, $t1 # cell address
    lb $v1, 0($t2)
    addi $t2, $t2, 1
    lb $v0, 0($t2)
    jr $ra
returnGetCellError:
    li $v0, 0xFF
    li $v1, 0xFF
    jr $ra
    
initDisplay:
    # prologue
    addi $sp, $sp, -28
    sw $ra, 0($sp)
    sw $s0, 4($sp) # bg
    sw $s1, 8($sp) # row
    sw $s2, 12($sp) # col
    sw $s3, 16($sp) # base address
    sw $s4, 20($sp) # alphabet char
    sw $s5, 24($sp) # fg
    li $s1, -1 # row
    li $s3, 0xffff0000 # base address
    move $s5, $a0
    move $s0, $a1
    li $s4, 'A'
initDisplayRowLoop:
    addi $s1, $s1, 1
    bgt $s1, 11, initDisplayFinish
    li $s2, -1 # col
initDisplayColLoop:
    addi $s2, $s2, 1
    bgt $s2, 6, initDisplayRowLoop
    beqz $s1, makeCellGrey
    beq $s1, 7, makeCellGrey
    bgt $s1, 7, makeCellWhite
    beqz $s2, makeCellGrey
    beq $s2, 6, makeCellGrey
    move $a0, $s1 # make square blue
    move $a1, $s2
    li $a2, 63
    move $a3, $s5
    addi $sp, $sp, -4
    sw $s0, 0($sp)
    jal setCell
    addi $sp, $sp, 4
    j initDisplayColLoop
makeCellGrey:
    move $a0, $s1
    move $a1, $s2
    li $a2, 0
    li $a3, 0x00
    addi $sp, $sp, -4
    li $t0, 0x7
    sw $t0, 0($sp)
    jal setCell
    addi $sp, $sp, 4
    j initDisplayColLoop
makeCellWhite:
    move $a0, $s1
    move $a1, $s2
    bgt $s4, 'Z', emptyWhiteCell
    move $a2, $s4
    j restMakeCellWhite
emptyWhiteCell:
    li $a2, 0
restMakeCellWhite:
    li $a3, 0x0000
    addi $sp, $sp, -4
    li $t0, 0xf
    sw $t0, 0($sp)
    jal setCell
    addi $sp, $sp, 4
    addi $s4, $s4, 1
    j initDisplayColLoop
initDisplayFinish:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # bg
    lw $s1, 8($sp) # row
    lw $s2, 12($sp) # col
    lw $s3, 16($sp) # base address
    lw $s4, 20($sp) # alphabet char
    lw $s5, 24($sp) # fg
    addi $sp, $sp, 28
    jr $ra



### part 2 functions ###
binarySearch:
    blt $a2, $a1, returnBinarySearchError
    # prologue
    addi $sp, $sp, -28
    sw $ra, 0($sp)
    sw $s0, 4($sp) # dict
    sw $s1, 8($sp) # start
    sw $s2, 12($sp) # end
    sw $s3, 16($sp) # guess
    sw $s4, 20($sp) # mid
    sw $s5, 24($sp) # check
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    sub $t0, $a2, $a1 # (end - start)
    li $t1, 2
    div $t0, $t1 # (end - start) / 2
    mflo $t0
    add $s4, $t0, $a1 # mid
    li $t1, 6
    mul $t0, $t1, $s4
    add $a0, $t0, $s0  
    move $a1, $s3 
    jal strcmp
    move $s5, $v0 # check
    beqz $s5, returnBinarySearchMid
    beq $s5, 1, returnBinarySearchOne
    move $a0, $s0
    addi $a1, $s4, 1
    move $a2, $s2
    move $a3, $s3
    jal binarySearch # binarySearch(dict, mid + 1, end, guess)
    j binarySearchReturn
returnBinarySearchMid:
    move $v0, $s4
    j binarySearchReturn
returnBinarySearchOne:
    move $a0, $s0
    move $a1, $s1
    addi $a2, $s4, -1
    move $a3, $s3
    jal binarySearch # binarySearch(dict, start, mid - 1, guess)
binarySearchReturn:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # dict
    lw $s1, 8($sp) # start
    lw $s2, 12($sp) # end
    lw $s3, 16($sp) # guess
    lw $s4, 20($sp) # mid
    lw $s5, 24($sp) # check
    addi $sp, $sp, 28
    jr $ra
returnBinarySearchError:
    li $v0, -1
    jr $ra

isValid:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp) # dict
    sw $s1, 8($sp) # dictIndex
    sw $s2, 12($sp) # guess
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $a0, $s2
    jal strlen
    bne $v0, 5, returnIsValidError
    move $a0, $s2
    jal toUpper
    move $s2, $v0 # uppercase guess
    lb $t0, 0($s2) # first letter of guess
    li $t1, 65
    sub $t0, $t0, $t1
    sll $t1, $t0, 2
    add $t1, $t1, $s1
    lw $t1, 0($t1) # i
    addi $t0, $t0, 1
    sll $t2, $t0, 2
    add $t2, $t2, $s1
    lw $t2, 0($t2) # j
    move $a0, $s0
    move $a1, $t1
    move $a2, $t2
    move $a3, $s2
    jal binarySearch
    beq $v0, -1, returnIsValidError   
returnIsValidCorrect:
    li $v0, 0
    j returnIsValid
returnIsValidError:
    li $v0, -1
returnIsValid:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # dict
    lw $s1, 8($sp) # dictIndex
    lw $s2, 12($sp) # guess
    addi $sp, $sp, 16
    jr $ra
    
    
### part 3 functions ###
updateGuessPane:
    # prologue
    addi $sp, $sp, -32
    sw $ra, 0($sp)
    sw $s0, 4($sp) # puzzles
    sw $s1, 8($sp) # puzzleSize
    sw $s2, 12($sp) # puzzleNum
    sw $s3, 16($sp) # letter
    sw $s4, 20($sp) # position
    sw $s5, 24($sp) # wordAttempt
    sw $s6, 28($sp) # Wordle word
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    lw $s4, 36($sp)
    lw $s5, 32($sp)
    bge $s2, $s1, returnGuessPaneError
    blt $s3, 0x41, returnGuessPaneError
    bgt $s3, 0x5A, returnGuessPaneError
    bltz $s4, returnGuessPaneError
    bgt $s4, 4, returnGuessPaneError
    blt $s5, 1, returnGuessPaneError
    bgt $s5, 6, returnGuessPaneError
    li $t0, 4
    mul $t0, $t0, $s2
    add $s6, $s0, $t0 # address of Wordle word
    lw $s6, 0($s6)
    li $t0, 0 # counter
guessPaneLoop:
    beq $t0, 6, returnGuessPaneZero
    lb $t1, 0($s6) # Wordle letter
    beq $t1, $s3, guessPaneLettersEqual
    addi $t0, $t0, 1
    addi $s6, $s6, 1
    j guessPaneLoop
guessPaneLettersEqual:
    beq $t0, $s4, returnGuessPaneTwo
    # set cell yellow
    move $a0, $s5
    move $a1, $s4
    addi $a1, $a1, 1
    move $a2, $s3
    li $a3, 0
    addi $sp, $sp, -4
    li $t0, 11
    sw $t0, 0($sp)
    jal setCell
    addi $sp, $sp, 4
    li $v0, 1
    j returnGuessPane
returnGuessPaneError:
    li $v0, -1
    j returnGuessPane
returnGuessPaneZero:
    # set cell grey
    move $a0, $s5
    move $a1, $s4
    addi $a1, $a1, 1
    move $a2, $s3
    li $a3, 15
    addi $sp, $sp, -4
    li $t0, 8
    sw $t0, 0($sp)
    jal setCell
    addi $sp, $sp, 4
    li $v0, 0
    j returnGuessPane
returnGuessPaneTwo:
    # set cell green
    move $a0, $s5
    move $a1, $s4
    addi $a1, $a1, 1
    move $a2, $s3
    li $a3, 15
    addi $sp, $sp, -4
    li $t0, 2
    sw $t0, 0($sp)
    jal setCell
    addi $sp, $sp, 4
    li $v0, 2
returnGuessPane:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # puzzles
    lw $s1, 8($sp) # puzzleSize
    lw $s2, 12($sp) # puzzleNum
    lw $s3, 16($sp) # letter
    lw $s4, 20($sp) # position
    lw $s5, 24($sp) # wordAttempt
    lw $s6, 28($sp) # Wordle word
    addi $sp, $sp, 32
    jr $ra   
    
updateAlphabetPane:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp) # row
    sw $s1, 8($sp) # col
    sw $s2, 12($sp) # status
    sw $s3, 16($sp) # letter
    move $s3, $a0
    move $s2, $a1
    blt $s3, 'H', alphabetPaneOne
    blt $s3, 'O', alphabetPaneTwo
    blt $s3, 'V', alphabetPaneThree
    li $s0, 11
    addi $s1, $s3, -86
    j restOfAlphabetPane
alphabetPaneOne:
    li $s0, 8
    addi $s1, $s3, -65
    j restOfAlphabetPane
alphabetPaneTwo:
    li $s0, 9
    addi $s1, $s3, -72
    j restOfAlphabetPane
alphabetPaneThree:
    li $s0, 10
    addi $s1, $s3, -79
restOfAlphabetPane:
    beqz $s2, statusIsZero
    beq $s2, 1, statusIsOne
    move $a0, $s0
    move $a1, $s1
    move $a2, $s3
    li $a3, 15
    addi $sp, $sp, -4
    li $t0, 2
    sw $t0, 0($sp)
    jal setCell
    addi $sp, $sp, 4
    j returnUpdateAlphabetPane
statusIsOne:
    beq $v0, 0x2F, returnUpdateAlphabetPane
    move $a0, $s0
    move $a1, $s1
    move $a2, $s3
    li $a3, 0
    addi $sp, $sp, -4
    li $t0, 11
    sw $t0, 0($sp)
    jal setCell
    addi $sp, $sp, 4
    j returnUpdateAlphabetPane
statusIsZero:
    beq $v0, 0x2F, returnUpdateAlphabetPane
    beq $v0, 0xB0, returnUpdateAlphabetPane
    move $a0, $s0
    move $a1, $s1
    move $a2, $s3
    li $a3, 15
    addi $sp, $sp, -4
    li $t0, 8
    sw $t0, 0($sp)
    jal setCell
    addi $sp, $sp, 4
    j returnUpdateAlphabetPane
returnUpdateAlphabetPane:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # row
    lw $s1, 8($sp) # col
    lw $s2, 12($sp) # status
    lw $s3, 16($sp) # letter
    addi $sp, $sp, 20
    jr $ra

### part 4 functions ###
playWord:
    # prologue
    addi $sp, $sp, -36
    sw $ra, 0($sp)
    sw $s0, 4($sp) # puzzles
    sw $s1, 8($sp) # puzzleSize
    sw $s2, 12($sp) # puzzleNum
    sw $s3, 16($sp) # wordAttempt
    sw $s4, 20($sp) # guess
    sw $s5, 24($sp) # dict
    sw $s6, 28($sp) # dictIndex
    sw $s7, 32($sp) # position
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    lw $s6, 36($sp)
    lw $s5, 40($sp)
    lw $s4, 44($sp)
    bgt $s2, $s1, returnPlayWordError
    move $a0, $s5
    move $a1, $s6
    move $a2, $s4
    jal isValid
    beq $v0, -1, returnPlayWordError
    li $s7, 0
playWordLoop:
    bge $s7, 5, checkWordWin
    lb $t1, 0($s4) # letter
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $a3, $t1
    addi $sp, $sp, -8
    sw $s3, 0($sp)
    sw $s7, 4($sp)
    jal updateGuessPane
    addi $sp, $sp, 8
    beq $v0, -1, returnPlayWordError
    lb $a0, 0($s4) # letter
    move $a1, $v0
    jal updateAlphabetPane
    addi $s4, $s4, 1
    addi $s7, $s7, 1
    j playWordLoop
checkWordWin:
    lw $a0, 44($sp)
    li $a1, 4
    mul $a1, $a1, $s2
    add $a1, $s0, $a1
    lw $a1, 0($a1) # address of Wordle word
    jal strcmp
    beqz $v0, returnPlayWordOne
    li $v0, 0
    j returnPlayWord
returnPlayWordError:
    li $v0, -1
    j returnPlayWord
returnPlayWordOne:
    li $v0, 1
returnPlayWord:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # puzzles
    lw $s1, 8($sp) # puzzleSize
    lw $s2, 12($sp) # puzzleNum
    lw $s3, 16($sp) # wordAttempt
    lw $s4, 20($sp) # guess
    lw $s5, 24($sp) # dict
    lw $s6, 28($sp) # dictIndex
    lw $s7, 32($sp) # position
    addi $sp, $sp, 36
    jr $ra

.include "hw4_clausenm.asm"
.include "hw4_ec_clausenm.asm"
.include "hw4_helpers.asm"
.include "wordle_dict.asm"

.data
invalid_str: .asciiz "Invalid puzzle number. Try again.\n"
invalid_mode_str: .asciiz "Invalid mode. Try again.\n"
invalid_level_str: .asciiz "Invalid hard mode level. Try again.\n"
Welcome_str: .asciiz "***** Welcome! *****\n"
puzzle_prompt: .asciiz "\nWhich puzzle do you want to play (0-199): "
hardmode_prompt: .asciiz "\n(R)egular Mode or (H)ard Mode: "
hardmode_level_prompt: .asciiz "\nWhich Hard Mode level (1,2,3): "
enter_word_str: .asciiz "Enter 5-letter word: "
game_won_str: .asciiz "***** CONGRATULATIONS! YOU GUESSED THE WORDLE WORD IN "
tries_str: .asciiz " GUESSES *****\n\n"
again_str: .asciiz "Do you want to play again (Y/N)? "
invalid_guess_str: .asciiz "Try Again!\n"
invalid_color_str: .asciiz "\nInvalid color! Try again.\n"
game_lost_str: .asciiz "Sorry, you lose. The Wordle Word was: "
fg_preset_str: .asciiz "\nEnter a number [0-15] for the board foreground color: "
bg_preset_str: .asciiz "\nEnter a number [0-15] for the board background color: "

.globl main
.text
# $a0, string to print
# $v0, return color
__inputColor:
	move $t1, $a0 
	li $v0, 4
	syscall

	li $v0, 5
	syscall

	bltz $v0, __inputColor_err
    li $t0, 15
	bgt $v0, $t0, __inputColor_err
    jr $ra

__inputColor_err:
    li $v0, 4
    la $a0, invalid_color_str
	syscall
	move $a0, $t1
	j __inputColor

main:
	li $s4, 0    # level
	
	# Print out the welcome message
	li $v0, 4
	la $a0, Welcome_str
	syscall

hard_mode_prompt:
	li $v0, 4
	la $a0, hardmode_prompt
	syscall

	# Read in the mode value from user
	li $v0, 12
	syscall
	
	li $t0, 'R'
	li $t1, 'H'
	beq $v0, $t0, print_puzzle_prompt
	bne $v0, $t1, hard_mode_reprompt

hard_mode_level_prompt:
	li $v0, 4
	la $a0, hardmode_level_prompt
	syscall

	# Read in the mode value from user
	li $v0, 5
	syscall

	li $t0, 1
	blt $v0, $t0, hard_mode_level_reprompt
	addi $t0, $t0, 2
	bgt $v0, $t0, hard_mode_level_reprompt
	move $s4, $v0

 print_puzzle_prompt:	
	# Print out the puzzle prompt
	li $v0, 4
	la $a0, puzzle_prompt
	syscall
	
	# Read in the puzzle value from user
	li $v0, 5
	syscall
	
	li $t0, 200
	bltz $v0, puzzle_reprompt
	bgt $v0, $t0, puzzle_reprompt 
	move $s1, $v0
	
	# Valid puzzle number
	# Prompt the user for the initial board colors
	la $a0, fg_preset_str
	jal __inputColor
	move $s3, $v0

	la $a0, bg_preset_str
	jal __inputColor
	move $s2, $v0	

	move $a0, $s3
	move $a1, $s2
	jal initDisplay

	li $s7, 7
	li $s0, 1	    # user's guess number
	addi $sp, $sp, -12  # space for buffer to hold input word
while_game:
	beq $s0, $s7, game_lost
        # Prompt player to enter word
        li $v0, 4
        la $a0, enter_word_str
        syscall	

		# Read in user input
        li $v0, 8
        move $a0, $sp
        li $a1, 12
        syscall	


	la $a0, puzzles
	li $a1, 200
	move $a2, $s1
	move $a3, $s0

	bgtz $s4, playhard_mode   # if hard mode, call EC playWord2 function
	addi $sp, $sp, -12
	addi $t0, $sp, 12
	sw $t0, 8($sp)
	la $t0, dict
	sw $t0, 4($sp)
	la $t0, dictIndex
	sw $t0, 0($sp)
	jal playWord         
	addi $sp, $sp, 12
	j checkResult
playhard_mode:
	addi $sp, $sp, -16
	addi $t0, $sp, 16
	sw $t0, 12($sp)
	la $t0, dict
	sw $t0, 8($sp)
	la $t0, dictIndex
	sw $t0, 4($sp)
	sw $s4, 0($sp)
	jal playWord2         
	addi $sp, $sp, 16

checkResult:
	bltz $v0, invalid_guess
	li $t1, 1
	beq $v0, $t1, game_won
	
	addi $s0, $s0, 1
	j while_game
	
invalid_guess:
	li $v0, 4
	la $a0, invalid_guess_str
	syscall	

	j while_game


game_won:
	li $v0, 4
	la $a0, game_won_str
	syscall
	
	li $v0, 1
	addi $a0, $s0, 1
	syscall

	li $v0, 4
	la $a0, tries_str
	syscall
	
play_again:
	li $v0, 4
	la $a0, again_str
	syscall

	li $v0, 12
	syscall
	
	li $t0, 'Y'
	beq $v0, $t0, print_puzzle_prompt
	li $t0, 'N'
	beq $v0, $t0, end_game
	
	j play_again
	
end_game:
	li $v0, 10
	syscall

hard_mode_reprompt:
	li $v0, 4
	la $a0, invalid_mode_str
	syscall
	j hard_mode_prompt

hard_mode_level_reprompt:
	li $v0, 4
	la $a0, invalid_level_str
	syscall
	j hard_mode_level_prompt

puzzle_reprompt:
	li $v0, 4
	la $a0, invalid_str
	syscall
	j print_puzzle_prompt

game_lost:
	li $v0, 4
	la $a0, game_lost_str
	syscall
	
	la $a0, puzzles
	sll $t0, $s1, 2
	add $a0, $a0, $t0
	lw $a0, 0($a0)
	li $v0, 4
	syscall
	li $v0, 11
	li $a0, '\n'
	syscall
	syscall
	
	j play_again
	

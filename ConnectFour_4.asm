# Author:	Olarewaju Abraham
# Date:		APRIL 28, 2021
# Description:	CONNECT 4

.data

# STRINGS
intro:   .asciiz "\n\nWelcome to Connect 4!!!\n"
instruction: .asciiz "\nIf you want to end the game at any point input 11 as a column number\nInput 22 as a column number if you want to restart the game at any point  \n"
players:  .asciiz "\n\nDecide now who will be  PLAYER 1 and PLAYER 2"
input:   .asciiz "\n\nPlease enter input number: "
p2turn: .asciiz "\n\n					It is PLAYERS 2 turn"
p1turn: .asciiz "\n\n					It is PLAYERS 1 turn"
newNum: .asciiz "\n\nThat number was out of range, try again: "
minute: .asciiz "\n\nPlease enter the current minute of the hour: "
newCol: .asciiz "\n\nThis column is full, please make another input: "
newline: .asciiz "\n"
tabspace: .asciiz "				"
columns: .asciiz "\n\t\t\t\t1 2 3 4 5 6 7"

# SPACES
board:  .space 7
	.space 7          #allocate space for connect 4 grid
	.space 7
	.space 7
	.space 7
	.space 7

# BYTES
p1:  .byte 'X'		# player 1 chip
p2:  .byte 'O'		# player 1 chip
empty: .byte '*'	# empty slot
space: .byte ' '	# space 

# BOARD GRID DATA
size: .word 7		# number of columns in Connect 4 grid
.eqv DATA_SIZE 1        # constant of data size | 1 character = 1 byte	

# SOUND DATA
p: .word 69
b: .word 72
d: .word 95
v: .word 100
i: .word 58

.text
	
	li   $v0, 4	
	la   $a0, intro	         # prints the intro 
	syscall	


main:  # MAIN FUNCTION WITH ALL THE SUBROUTINES

	li   $v0, 4	
	la   $a0, instruction	         # prints instructions 
	syscall	
	
	jal makeboard		# loads the the empty byte '*' into the 2D board grid
	jal printboard		 # prints out the board
	
	li   $v0, 4	
	la   $a0, players	    # ask useers to decide who will be players 1 and player 2
	syscall	
	
	li   $v0, 4			# ask user for minute of hour
	la   $a0, minute
	syscall	
	
	li $v0, 5			# get minute of hour
	syscall
	
	move $a0, $v0			# moves minute of hour to $a0
	div $a0, $a0, 2			# divide the minutes by 2, 
	mfhi $s1			# puts remainder in $a0
	move $a0, $s1
	
	j whoseturn			# jumps to whoseturn


makeboard: # LOADS THE EMPTY SLOT '*' INTO EACH SPOT OF THE BOARD GRID
  
	addi $t1, $zero, 5  	# for(i=5
	
	ILoop3:	# for(i=6; i>0; i--) | outer loop
	
	slti $t2, $t1, 0         #    i >= 0; 
	bne  $t2, $zero, Finish2
	add $t3, $zero, $zero		# (j=0;

	JLoop3: # for(j=0; j<7; j++) | inner loop
	
	slti $t4, $t3, 7         #    j < 7; 
	beq  $t4, $zero, Finish

	#ROW BY MAJOR FORMULA  Base Address + (row index * column size + column index) * DATA SIZE
	la $a2, board		#loads base address
	lw $a1, size		#loads column size
	
	mul $t5, $t1, $a1			#row index * column size
	add $t5, $t5, $t3			#	   + column index
	mul $t5, $t5, DATA_SIZE			#	   * DATA SIZE
	add $t5, $t5, $a2			#	   + base address

	lb $a0, empty				# load byte '*' from memory to register
	sb $a0, 0($t5)				# saves byte from register to memory (board grid)
       
	addi $t3, $t3, 1		# j++)
	j JLoop3
	
	Finish:
	subi $t1, $t1, 1         # decrement i | i--) 
	
	j ILoop3
	Finish2:
	
	jr $ra					#returns subroutine


printboard: # PRINTS OUT COMPLETE BOARD GRID

	addi $t1, $zero, 5  	#for i=5
	
	ILoop: # for(i=5; i>=0; i--) | outer loop
	
	slti $t2, $t1, 0        #    i=>0; 
	bne  $t2, $zero, Done1
	
	li   $v0, 4	
	la   $a0, newline        #prints new line | printf("\n");
	syscall
	
	li   $v0, 4	
	la   $a0, tabspace	 #prints indentation to put board in center of view
	syscall	
	
	add $t3, $zero, $zero		# (j=0;

	JLoop: # for(j=0; j<7; j++) | inner loop
	
	slti $t4, $t3, 7         #    j < 7; 
	beq  $t4, $zero, Done

	# ROW BY MAJOR FORMULA  Base Address + (row index * column size + column index) * DATA SIZE
	la $a2, board
	lw $a1, size
	
	mul $t5, $t1, $a1			#row index * column size
	add $t5, $t5, $t3			#	   + column index
	mul $t5, $t5, DATA_SIZE			#	   * DATA SIZE
	add $t5, $t5, $a2			#	   + base address
	
	lb  $a0, 0($t5)			# loads board[i][j] to $a0
	li $v0, 11			# prints board[i][j]
        syscall
        
	addi $t3, $t3, 1		#j++)
	
	li   $v0, 4	
	la   $a0, space	         	# prints space inbetween each board grid slot
	syscall	

	j JLoop
	
	Done:
	subi, $t1, $t1, 1         # decrement i | i--) 
	
	j ILoop
	Done1:
	
	li   $v0, 4	
	la   $a0, columns         # prints column numbers
	syscall	
		
	jr $ra				# returns subroutine
	

whoseturn:	# ALTERNATES BETWEEN USERS PLACING THEIR CHIPS

	slti $t1, $a0, 1         # random choses a player to start with | if ( move == 0) 
	bnez $t1, P1		 # if ($a0 == 0){ P1 starts first}
				#	Else ( $a0 == 1){ P2 starts first}
				
	P2: 
	lb $t0, p2               # load p2 chip(0) to $t0
	
	li   $v0, 4	
	la   $a0, p2turn	# prints that it's p2 turn
	syscall	
	
	jal playerMove		
	
	addi $a0, $zero, 0       #alternates between users | move = 0
	j whoseturn		# jumps back to whose turn
	
	P1:
	lb $t0, p1		# load p1 chip(1) to $t0
	
	li   $v0, 4	
	la   $a0, p1turn	# prints that it's p1 turn
	syscall	
	
	jal playerMove
	
	addi $a0, $zero, 1        # alternates between users | move = 1
	j whoseturn		 # jumps back to whose turn


playerMove: # ALLOWS PLAYER TO CHOOSE AN APPROPIATE COLUMN

	addi $sp, $sp, -8	 # stack = stack - 8 (stack shifts down 2 registers)
	sw $ra, 4($sp)   	# pushes return location to stack
	sw $a0, 0($sp)           # spushes $a0(whose turns it's) to stack

	li   $v0, 4	
	la   $a0, input		# prompt user enter a column number
	syscall	
	
	li $v0, 5 		# get column number
	syscall 
	
	move $s1, $v0		# moves column number from return register to $s1

	If: # Checks To See If New Number Is In Range
	beq $s1, 11, conclusion 
	beq $s1, 22, main
	slti $t2, $s1, 8			#if $s1(column number) > 7 || $s1(column number < 1
	beq $t2, $zero, Else			#	{ j can_be_placed }
	bge $s1, 1, can_be_placed		#else { j else}
	
	
	Else: # Gets New Column Number
	
	# plays beep sound since user inputed was out of range
	li $v0, 31 		# preset to play sound
	la $a0, p		# loads pitch to register
	la $a1, d 		# loads duration to register
	la $a2, i		# loads instrument to register
	la $a3, v		# loads volume to register
	syscall 

	li   $v0, 4	
	la   $a0, newNum	# asK user new column number
	syscall	
	
	li $v0, 5		# gets user new input value
	syscall
	
	move $s1, $v0		# moves new column number from return register to $s1
	j If			# jumps back to If to see if new numeber is in range


can_be_placed:	# CHECKS THE TOP OF EACH COLUMN TO SEE IF IT IS FULL

	subi $s1, $s1, 1		# column = column - 1 | since program works through columns  0 to 6, not 1 to 7

	li $t1, 5  			# loads row index 5 | the top row of the grid

	lw $a1, size			# loads column size	
	la $a2, board			# loads base address of board
	lb $t2, empty			# loads empty slot '*'
	
	mul $t5, $t1, $a1			#row index * column size
	add $t5, $t5, $s1			#	   + column index
	mul $t5, $t5, DATA_SIZE			#	   * DATA SIZE
	add $t5, $t5, $a2			#	   + base address
	
	lb  $a0, 0($t5)			# loads board[i][j] to $a0
	
	beq $a0, $t2, place_the_piece		# if (loads board[i][j == *) { jump place_the_piece)
						#	else { get new column number }
        li $v0, 31 		# preset to play sound
	la $a0, p		# loads pitch to register
	la $a1, d 		# loads duration to register
	la $a2, i		# loads instrument to register
	la $a3, v		# loads volume to register
	syscall 

	li   $v0, 4	
	la   $a0, newCol	# ask user for new column 
	syscall
	
	li $v0, 5 		# gets new column
	syscall 
	
	move $s1, $v0		# moves new column to $s1

	beq $s1, 11, conclusion 
	beq $s1, 22, main
	
	j can_be_placed		# jumps to see if new column is full


place_the_piece: # PLACES THE USERS CHIP IN THE DESIGNATED COLUMN

	addi $t1, $zero, 0  	#for(i=0
	
	ILoop2:	# for(i=0; i<6; i++) | outer loop 
	
	slti $t2, $t1, 6         #    i >= 0; 
	beq  $t2, $zero, After
	
	add, $t3, $s1, $zero	# i = column

	# ROW BY MAJOR FORMULA  Base Address + (row index * column size + column index) * DATA SIZE
	la $a2, board		# loads base address board grid
	lw $a1, size		# loads column size
	lb $t2, empty		# loads empty slot '*'
	
	mul $t5, $t1, $a1			# row index * column size
	add $t5, $t5, $t3			#	   + column index
	mul $t5, $t5, DATA_SIZE			#	   * DATA SIZE
	add $t5, $t5, $a2			#	   + base address

	lb  $a3, 0($t5)			# puts board[i][j] to $a3
	
	bne $a3, $t2, After		# if(board[i][column] != '*') { j After)
					#	else(  board[j][column] = p1/p2
								
	sb $t0, 0($t5)			# saves players chip to board grid memory
	
	jal printboard			# prints out updated board
	
	j four_in_a_row			# checks of updated board has a winner
	
	After:

	addi $t1, $t1, 1         # decrement i | i++
	
	j ILoop2
	             

four_in_a_row: # CHECKS TO SEE IF THERE ARE FOUR CHIPS IN A ROW
	j After2		# skips over this whole function as there was an issue with the function

	lw $a0, 0($sp)  	# pops $a0 (which user's turn it's) from stack
	addi $sp, $sp, 4
	addi $t0, $a0, 0	# copies $a0 to another register
	addi $sp, $sp, -4	# pushes $a0 back to stack
	sw $a0, 0($sp)  

	bnez $t0, Next2			# if ( $t0 != 0) { load P1 to $t0} 
	lb $t0, p1			# If its P1 turn, load their chip to $t0
	j Next3

	Next2:				# else { load P2 to $t0} 
	lb $t0, p2			# if its p2 turn, load their chip to $t0
	Next3:				

	addi $t1, $zero, 0 	# for(i=0
	addi $t4, $zero, 0	# zero out registers
	addi $t7, $zero, 0	#
	la $a2, board		# load base address of board to register
	lw $a1, size		# loads number of columns to register
	
	ILoop4:	 # (int i = 0; i < 6;i++) | outer loop
	slti $t2, $t1, 6         #    i<6; 
	beq  $t2, $zero, After2
	addi $t3, $zero, 0		# (j=0;	

	JLoop5: # (int j = 0; i < 7;j++)
	slti $t2, $t3, 7         #    j < 7; 
	beq  $t2, $zero, After1
	
	addi $t2, $t1, 0	#$t2 = j | a = i;
	addi $t7, $t3, 0	#$t7 = i | b = j;
	
	lb $t0, empty		# loads '*' to $
	
	add $t5, $zero, $zero	# zero out registers
	add $s1, $zero, $zero	#
	
	Horizontal: # Checks For 4 Chips In A Row Horizontally
	mul $t5, $t2, $a1			#row index * column size
	add $t5, $t5, $t7			#	   + column index
	mul $t5, $t5, DATA_SIZE			#	   * DATA SIZE
	add $t5, $t5, $a2			#	   + base address
	lb $a0, ($t5)	
	
	bne $t0, $a0, Else1	# if board[a][b] !== current user's chip(X/O) { 
				#	break; }
	addi $t7, $t7, 1	# board[a][b] = board[a][b+1] 
	addi $s1, $s1, 1	# winner ++
	bgt $s1, 3, After2	# while (winner < 3)
	j Horizontal
	
	Else1: 
	
	addi $s1, $zero, 0	# winner = 0
	addi $t2, $t1, 0	#$t2 = j | a = i;
	
	Vertical: # Checks For 4 Chips In A Row Veritcally
	mul $t5, $t2, $a1			# row index * column size
	add $t5, $t5, $t7			#	   + column index
	mul $t5, $t5, DATA_SIZE			#	   * DATA SIZE
	add $t5, $t5, $a2			#	   + base address
	lb $a0, ($t5)	
	
	bne $t0, $a0, Else2		#if board[a][b] = current user's chip (X/O)
					#	break; }
	addi $t2, $t2, 1		# board[a][[b] = board[a+1][[b] 
	addi $s1, $s1, 1		# winner ++
	bgt $s1, 3, After2		# while (winner < 3)
	
	j Vertical
	
	Else2:
	
	addi $t2, $t1, 0	# #$t2 = j | a = i;
	addi $s1, $zero, 0	# winner = 0
	addi $t7, $t3, 0	#$t7 = i | b = j;
	
	RightDiagonal: # Checks For 4 Chips In A Right Diagonal
	mul $t5, $t2, $a1			# row index * column size
	add $t5, $t5, $t7			#	   + column index
	mul $t5, $t5, DATA_SIZE			#	   * DATA SIZE
	add $t5, $t5, $a2			#	   + base address
	lb $a0, ($t5)	
	
	bne $t0, $a0, Else3		# if board[a][b] = current user's chip(X/O)

	addi $t2, $t2, 1		# board[a][[b] = board[a+1][[b] 
	addi $t7, $t7, 1		# board[a][b] = board[a][b+1] 
	addi $s1, $s1, 1		# winner ++
	bgt $s1, 3, After2		# while (winner < 3)
	
	j RightDiagonal

	Else3:
	
	addi $t2, $t1, 0	# #$t2 = j | a = i;
	addi $s1, $zero, 0	# winner = 0
	addi $t7, $t3, 0	#$t7 = i | b = j;
	
	LeftDiagonal: # Checks For 4 Chips In A Right Diagonal
	mul $t5, $t2, $a1			# row index * column size
	add $t5, $t5, $t7			#	   + column index
	mul $t5, $t5, DATA_SIZE			#	   * DATA SIZE
	add $t5, $t5, $a2			#	   + base address
	lb $a0, ($t5)	
	
	bne $t0, $a0, Else4		# if board[a][b] = current user's chip(X/O)

	addi $t2, $t2, -1		# board[a][[b] = board[a-1][[b] 
	addi $t7, $t7, -1		# board[a][b] = board[a][b-1] 
	addi $s1, $s1, 1		# winner ++
	bgt $s1, 3, After2		# while (winner < 3)
	
	j LeftDiagonal

	Else4:

	addi $t3, $t3, 1		#j++
	j JLoop5
	
	After1:
	
	addi $t1, $t1, 1         # decrement  | i--) 
	j ILoop4
	
	After2:

	lw $a0, 0($sp)          # return $a0 to from stack ($a0 has which user's turn it's)
	lw $ra, 4($sp)    	# return game location from stack to $t0
	addi $sp, $sp, 8	# stack = stack + 8 | stack returns to its normal state, shifts back up 2 registers

	#bgt $s1, 3, conclusion		# commented out code that would've ended the game once a winner was found
	
	 jr $ra 		# returns back to whoseturn function to alternate to the next users turn

conclusion: # ENDS PROGRAM
	
	li $v0, 10		# system call code for exit = 10
	syscall				# call operating sys



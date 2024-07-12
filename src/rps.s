# vim:sw=2 syntax=asm
.data

.text
  .globl play_game_once

# Play the game once, that is
# (1) compute two moves (RPS) for the two computer players
# (2) Print (W)in (L)oss or (T)ie, whether the first player wins, looses or ties.
#
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, only print either character 'W', 'L', or 'T' to stdout
play_game_once:
  addiu $sp $sp -16
  sw $ra 0($sp)
  sw $s0 8($sp)
  
  jal gen_byte
  
  move $t1 $v0  # move for player1
   sw $t1 4($sp)
  jal gen_byte
  lw $t1 4($sp)
  move $t2 $v0  # move for player2
  beq $t1 0 rock1
  beq $t1 1 paper1
  beq $t1 2 scissors1
  
  
  
rock1:
  beq $t2 2 player1_wins
  beq $t2 1 player1_lost
  beq $t2 $t1 tie
 
paper1:
  beq $t2 0 player1_wins
  beq $t2 2 player1_lost
  beq $t2 $t1 tie
 
scissors1:
   beq $t2 1 player1_wins
   beq $t2 0 player1_lost
   beq $t2 $t1 tie
 
player1_wins:
  # Print 'W' (Player one wins)
  li $v0 0
  li $a0 0
  li $v0 11
  li $a0 87  
  syscall
  j end_rps
   
player1_lost:
  # Print 'L' (Player two wins)
  li $v0 0
   li $a0 0
  li $v0 11
  li $a0 76 
  syscall
  j end_rps
  
tie:
  # Print 'T' (Tie)
  li $v0 0
   li $a0 0
  li $v0 11
  li $a0 84  
  syscall
  

  end_rps:
 
   lw $s0 8($sp)
  lw $ra 0($sp)
 addiu $sp $sp 16
  jr $ra
  




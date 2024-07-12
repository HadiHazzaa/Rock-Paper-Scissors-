# vim:sw=2 syntax=asm
.data 
 newline : .asciiz "\n"

.text

  .globl simulate_automaton, print_tape
  

# Simulate one step of the cellular automaton
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, but updates the tape in memory location 4($a0)
simulate_automaton:
  # TODO
 addiu $sp $sp -4
  sw $ra 0($sp)

  lw $t0 4($a0)      # Load tape address
  lb $t1 8($a0)      # Load tape len
  lb $t4 9($a0)      # Load rule
  
  

    li $t8 0
  andi $t5 $t0 1 # the least bit
  subi $t1 $t1 1 # length -1 7
  srlv $t2 $t0 $t1 #the most bit
  addi $t1 $t1 3 # give the length the one back plus the two adding bit 10
  srlv $t8 $t8 $t1 # 
  or $t0 $t0 $t8
  sll $t0 $t0 1
  or $t0 $t0 $t2
  sub $t1 $t1 1 # 9
  sllv $t5 $t5 $t1
  or $t0 $t0 $t5

  li $t9 0 # zeroing the new tape

  subi $t1 $t1 2 # length -1 6
  srlv $t9 $t9 $t1 # zero the new tape in the same length as the orginal
  addi $t1 $t1 1  # the orginal length
  li $t2 0  # loop counter 
  li $t5 0 # position check
  li $t8 1
  
simulate_loop1:
  beq $t2 $t1 simulate_exit #  exit 
  andi $t3 $t0 7 #take the first 3 call 
  li $t5 0 # Initialize the position checker
find_position:
   
   beq $t3 $t5  position
   add $t5  $t5 1
   j find_position
    

 position: 
  li $t6 0
  
  srlv $t6 $t4 $t5 # get the value in this postion
  andi $t6 $t6 1    # get the value in the least bit
  #beqz $t5 keeptheOne
 # subi $t5 $t5 1 
#keeptheOne:  
  sllv $t6 $t6 $t2
  or $t9 $t9 $t6
  
  addi $t2 $t2 1     # loop counter -1
  sra $t0 $t0 1       #Shift tape to the next cell
  j simulate_loop1      
  
  
  
simulate_exit:

  sw $t9 4($a0) 
 lw $ra 0($sp)    
  addiu $sp $sp 4  

  jr $ra                         #


# Print the tape of the cellular automaton
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return nothing, print the tape as follows:
#   Example:
#       tape: 42 (0b00101010)
#       tape_len: 8
#   Print:  
#       __X_X_X_
print_tape:
  # TODO
 addiu $sp $sp -4
 sw $ra 0($sp)
   
  li $t0 0 
  li $t1 0
  lw $t0 4($a0)  
  lb $t1 8($a0)  
  subiu $t1 $t1 1
 loop:    
 li $t3 0 
 
 bltz $t1 exit 
 srlv  $t3 $t0 $t1
  andi $t3 $t3 1
  
  
 
  beqz $t3  died
    li $v0 11  # life 
  li $a0 88  # print x
  syscall
   j continue  
  died:
   li $v0 11
  li $a0 95  #print _
  syscall
 
  
 
  
continue:
  addiu $t1 $t1 -1
  j loop

exit:
  
  li $v0 4
  la $a0 newline 
  syscall
  lw $ra 0($sp)
  addiu $sp $sp 4

  jr $ra


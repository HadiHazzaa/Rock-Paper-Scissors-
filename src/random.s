# vim:sw=2 syntax=asm
.data

.text
  .globl gen_byte, gen_bit

# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Compute the next valid byte (00, 01, 10) and put into $v0
#  If 11 would be returned, produce two new bits until valid
#
gen_byte:
 addiu $sp $sp -12
  sw $ra 0($sp)
  sw $s0 8($sp)
maker:  
  jal gen_bit
  
  move $t4 $v0
  beqz $t4 label1
  bne $t4 0 label2
   
label1:
  sw $t4 4($sp)
  jal gen_bit
   lw $t4 4($sp)
  
  move $t3 $v0
   sll $t4 $t4 1
 
  or $v0 $t4 $t3
 
  j end_byte 
  
  

label2:
 sw $t4 4($sp)
  jal gen_bit
   lw $t4 4($sp)
  move $t7 $v0
  bne $t7 0 maker
  
    sll $t4 $t4 1
 
   or $v0 $t4 $t7

   j end_byte 
 

 
 end_byte:
 
  
  lw $ra 0($sp) 
  lw $s0 8($sp)   
  addiu $sp $sp 12
  jr $ra

# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Look at the field {eca} and use the associated random number generator to generate one bit.
#  Put the computed bit into $v0
#
gen_bit:
  addiu $sp $sp -32
  sw $ra 0($sp)
  sw $s0 4($sp)
   sw $s1 8($sp)
    sw $s2 12($sp)
     sw $s4 16($sp)
      sw $s5 20($sp)
       sw $s3 24($sp)
       sw $a0 28 ($sp)
  
  li $s3 0
  lb $s3 8($a0) # load the length
  lw $s0 0($a0) # load the eca
  bnez $s0 ECA  #check if eca non-zero
   j gen_random
ECA :
  lb $s1 10($a0) #  load skip
  lb $s2 11($a0) # load the column
loop_skips:
  
  beqz $s1 bit_column  # if skips done
  
  jal simulate_automaton
  sub $s1 $s1 1
  bnez $s1 loop_skips

bit_column: 
  lw $s4 4($a0) # load the tape
  sub $s2 $s3 $s2 # length - skip
  sub $s2 $s2 1 # skip - 1
  srlv $s5 $s4 $s2 # shift right (skip - 1 ) times
  andi $s5 $s5 1  # take the coulmnth value
  move $v0 $s5 
  j exit_bit
  
gen_random:
   li $a0 0  # syscall to generet a random number
  li $v0 41
  syscall 
  andi $v0 $a0 1  # return the least significant bit
exit_bit  :
 
 lw $ra 0($sp) 
    lw $s0 4($sp)
   lw $s1 8($sp)
    lw $s2 12($sp)
     lw $s4 16($sp)
      lw $s5 20($sp) 
       lw $s3 24($sp)  
       lw $a0 28 ($sp)
  addiu $sp $sp 32
  jr $ra

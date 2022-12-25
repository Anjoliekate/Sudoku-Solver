                .global calc_pencil, get_used, clear_used
                .text

# get_used(board, group) -> used
get_used:

#a0: board
#a1: group
#a2: used
#a3: group_index
#a4: board_index
#a5: element
#a6: count
#a7: position
#t6: 9



    # get_used(board, group) -> used
    li a2, 0        #used = 0
    li a3, 0        #group_index = 0;
    li t6, 9
1:
    add t1, a3, a1
    lb a4, (t1)
    slli t1, a4, 1      #board_index = group[group_index]
    add t2, t1, a0  #storing in temp register.
    lh a5, (t2)     #element = board[board_index]
    li a6, 0        #count = 0
    li a7, 1        #position = 1

2:

   li t1, 1         #1<<position
   sll t2, t1, a7
   and t1, a5, t2   #temp = element & mask
   beqz t1, 3f      #if temp is zero: goto 3f
   addi a6, a6, 1   #count+= 1
                    # count the number of set bits in the element as follows:
#inner loop
3:
    addi a7, a7, 1   #position++
    ble a7, t6, 2b   #if position <= 9 goto 2b;
    li t1, 1
    bne a6, t1, 4f   #if count!= 1: goto 4f
    or a2, a2, a5   #used = used or element

#outer loop
4:
    addi a3, a3, 1    #group_index++
    blt a3, t6, 1b  #if group_index < 9 go to 1b otherwise continue;
    mv a0, a2
   # return used
    ret

# clear_used(board, group, used)
clear_used:
#registers:
#a0: board
#a1: group
#a2: used
#a3: element
#a4: group_index
#a5: board_index
#a6: next_elt
#a7: position
#t0: 9
#t2: change_made
#t3: 1
#t5: count

#initialize
    not a2, a2  #flip bits
    li t2, 0    #change_made = 0
    li a4, 0    #group_index = 0
    li t3, 1
    li t0, 9

#outer loop
1:
   add t4, a1, a4
   lb  a5, (t4)
   slli t4, a5, 1   #board_index = group[group_index]
   add t4, t4, a0
   lh a3, (t4)      #element = board[board_index]
   li t5, 0         #count = 0
   li a7, 1         #position = 1
#inner loop
2:
   li t1, 1         #1<<position similair to step 1
   sll t6, t1, a7
   and t1, a3, t6   #temp = element & mask

   addi a7, a7, 1
   beqz t1, 3f
   addi t5, t5, 1   #count += 1


#conditionals
3:
   ble a7, t0, 2b     #position <= 9 goto 2b;
   beq t5, t3, 5f     #if count == 1 goto 5f;
   and a6, a3, a2     #new_elt = element & used

4:
   beq a3, a6, 5f   #if new_element == element goto 5f
   add t4, a1, a4
   lb a5, (t4)      #almost the same as step 4 just with the new elt
   slli t4, a5, 1
   add t4, t4, a0
   sh a6, (t4)
   li t2, 1         #change_made = 1

#ending
5:

   addi a4, a4, 1
   blt a4, t0, 1b   #if group_index < 9 go to 1b:
   mv a0, t2
   ret

# calc_pencil(board, table)
calc_pencil:
#a0: board
#a1: table
#a2: changed
#a3 group_start
#a4 used
#t0: 1
#t1: 81

     addi sp, sp, -28
     sw ra, 24(sp)
     sw s0, 20(sp)
     sw s1, 16(sp)
     sw s2, 12(sp)
     sw s3, 8(sp)
     sw s4, 4(sp)
     sw s5, 0(sp)

    #calc_pencil(board, table) -> 0: no changes, 1: something changed
     li s2, 0   #   changed = 0
     li s3, 0   # group_start = 0;
     mv s0, a0
     mv s1, a1
     j 3f #go to beginning for loop

1:
    #inside for loop
    add s5, s1, s3 #tried to put table+group_start in s5 to put in get_used
    mv a0, s0 #passing in board, and table+group_start to get_used
    mv a1, s5
    call get_used
    mv a2, a0
    mv a0, s0 # tried storing what get_used returns into used:s4 I don't think I did this right.
    mv a1, s5 # passing in board, table+group_start, used to clear_used
    call clear_used
    beqz a0, 2f # if what clear_used returns is == 0 break out of iteration. goto 3f
    li s2, 1 #otherwise changed = 1

2:
    addi s3, s3, 9 #group_start += 9 increment at the end of the loop


3: #for loop
     li t0, 243
     blt s3, t0, 1b # jump to 1b if group_start < 243; #1b goes to whats inside for loop.
     mv a0, s2 # return changed

     lw ra, 24(sp)
     lw s0, 20(sp)
     lw s1, 16(sp)
     lw s2, 12(sp)
     lw s3, 8(sp)
     lw s4, 4(sp)
     lw s5, 0(sp)
     addi sp, sp, 28
     ret

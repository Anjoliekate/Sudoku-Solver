                .global naked_sets, single_pass, count_bits, gather_set, clear_others
                .text

# count_bits(n) -> # of bits set in n (only counting bits 0-9 inclusive)
count_bits:
    #a0:n
    #a1: count
    #a2: i
    #a4: elt
    #t1:9
    #t2: 1

    li a1, 0   #count = 0
    li a2, 0   #i = 0
    li t2, 1
    j 3f   #go to loop

1:
    sll t3, t2, a2 #shifting a4
    and t1, a0, t3
    beqz t1, 2f #if a4 != 1 increment to next iteration
    addi a1, a1, 1 #otherwise count += 1

2:
    addi a2, a2, 1 #increment loop

3:
    li t1, 9
    ble a2, t1, 1b #if i < 9 go to 1
    mv a0, a1 #otherwise return count
    ret



# gather_set(board, group, key) ->
#   set of pencil marks for cells identified by key
gather_set:
    #a0:board
    #a1:group
    #a2:key
    #a3:set
    #a4:index
    #a5:elt

    li a3, 0   #set = 0
    li a4, 0 # i = 0

1:
    li t1, 1
    sll t0, t1, a4 #mask = 1 << index
    and t1, a2, t0 #temp = key & mask
    beqz t1, 2f     #if temp is zero jump to 2f
    add t0, a1, a4  # adding two together group[index]
    lb  t1, (t0)  # storing that value in t1 board_index
    slli t0, t1, 1 #elt = board[board_index]
    add t1, a0, t0
    lh t0, (t1)
    or a3, a3, t0 #set = set | elt
2:
    addi a4, a4, 1 #increment
3:
    li t0, 9
    blt a4, t0, 1b # branch if <= 9
    mv a0, a3   #return set
				
	ret

# clear_others(board, group, key, set) ->
#    0: nothing changed
#    1: something changed
clear_others:
    #a0:board
    #a1:group
    #a2:key
    #a3:set
    #a4:index
    #a5:elt
    #a6:changed
    #a7: board_index
    #t4: elt'

    li a6, 0 # changed = 0
    not a3, a3 #flip set bits
    li a4, 0 # index = 0

1:
    li t5, 1
    sll t0, t5, a4 #mask = 1 << index
    and t1, a2, t0 #temp = key & mask
    bnez t1, 2f     #if temp is not zero jump to 2f

    add t6, a1, a4  # adding two together group[index]
    lb  a7, (t6)  # storing that value in a7 board_index
    slli t6, a7, 1 #board_index = group[index]
    add t3, t6, a0 #elt = board[board_index]
    lh a5, (t3)

    and t4, a5, a3 #elt' = elt & notset

    beq a5, t4, 2f # if elt == elt' break out of iteration
    li a6, 1 #otherwise changed =1

    add t6, t6, a0 # adding board and board_index and storing it in t6
    sh t4, (t6) #storing in elt'

2:
    addi a4, a4, 1
    li t2, 9
    blt a4, t2, 1b # branch if i < 9
    mv a0, a6   #return changed
    ret

# single_pass(board, group) ->
#   0: nothing change
#   1: something changed
single_pass:
#s1: board
#s2: group
#s3: key
#s4: subset_size
#s5: changed
#s6: set
#t0: set_size

    #prelude
    addi sp, sp, -28
    sw ra, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)

    li s5, 0    #changed = 0
    li s3, 1    #key = 1
    mv s1, a0
    mv s2, a1
1:
    mv a0, s3
    call count_bits #subset_size = count_bits(key)
    mv s4, a0
    mv a0, s1
    mv a1, s2
    mv a2, s3
    call gather_set
    mv s6, a0       #set = gather_set(board, group, key)
    mv a0, s6
    call count_bits
    mv t0, a0       #set_size = count_bits(set)
    bne s4, t0, 2f  #if subset_size != set_size go to 2f
    mv a0, s1
    mv a1, s2
    mv a2, s3
    mv a3, s6
    call clear_others   #otherwise val = clear_others(board, group, key, set)
    li t3, 1
    bne a0, t3, 2f         #if val != 1  goto 2f
    li s5, 1            #otherwise changed = 1

2:
    addi s3, s3, 1  # key++
    li t1, 510
    ble s3, t1, 1b  # key <= 510 go to 1b
    mv a0, s5       # otherwise return changed

    #postlude
    lw ra, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    lw s6, 0(sp)
    addi sp, sp, 28
    ret


# naked_sets(board, table) ->
#   0: nothing changed
#   1: something changed
naked_sets:
    # s0: board
    # s1: group
    # s2: key
    # s3: changed
    # s4: count_bits ret value
    # s5: gather_set ret value

    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)

    mv s0, a0
    mv s1, a1
    li s2, 0
    li s3, 0

1:
    mv a0, s0
    add t0, s1, s2
    mv a1, t0
    call single_pass
    beqz a0, 2f
    li s3, 1

2:
    addi s2, s2, 9
    li t0, 243
    blt s2, t0, 1b
    mv a0, s3

    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    lw s6, 0(sp)
    addi sp, sp, 32
    ret

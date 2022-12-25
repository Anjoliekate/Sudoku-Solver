                .global check_board
                .text

# check_board(board) ->
#     -1: board is unsolvable
#     0-80: position of most-constrained cell
#     81: board is solved
check_board:
    #a0: board
    #s0: board
    #s1: most constrained index
    #s2 most constrined count
    #s3: index
    #s4: count_bits ret value
    #s5: 81
    #s6: board[index]

   #prelude
    addi sp, sp, -36
    sw ra, 32(sp)
    sw s0, 28(sp)
    sw s1, 24(sp)
    sw s2, 20(sp)
    sw s3, 16(sp)
    sw s4, 12(sp)
    sw s5, 8(sp)
    sw s6, 4(sp)
    sw s7, 0(sp)

    mv s0, a0
    li s1, 81   #most_constrained_index = 81
    li s2, 10   #most_contrained_count = 10
    li s3, 0    #index = 0
    li s4, 162

1:
    add a0, s0, s3 #add board and index together
    lh a0, (a0)
    call count_bits
    mv t0, a0   #store ret value in s4
    bnez t0, 2f # if the val that count_bits ret != 0 j to 2f
    li a0, -1 #otherwise return -1
    j 5f
2:
    li t1, 1
    bne t0, t1, 3f #if val != 1 go to 3f
    j 4f
3:
    bge t0, s2, 4f #if val >= most_constrained_count go to 3f
    li t2, 2
    div a1, s3, t2
    mv s2, t0   #most_constrained_index = index
    mv s1, a1   # most_contrained_count = value

4:
    addi s3, s3, 2  #index ++
    blt s3, s4, 1b  # if index< 81 goto 1b
    mv a0, s1       #otherwise set ret  most_constrained_index

5:
    lw ra, 32(sp)
    lw s0, 28(sp)
    lw s1, 24(sp)
    lw s2, 20(sp)
    lw s3, 16(sp)
    lw s4, 12(sp)
    lw s5, 8(sp)
    lw s6, 4(sp)
    lw s7, 0(sp)
    addi sp, sp, 36
    ret

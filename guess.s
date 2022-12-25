                .global guess

                .data
msg_guess_1:    .asciz  "\nGuessing "
msg_guess_2:    .asciz  " at position ("
msg_guess_3:    .asciz  ", "
msg_guess_4:    .asciz  ")\n"
                .text

# guess(board, table, position) ->
#     0 -> success
#     1 -> failure
guess:
    
    addi sp, sp, -28
    sw ra, 24(sp)
    sw s5, 20(sp)
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)
    addi sp, sp, -168
    
    addi sp, sp, 168
    lw ra, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 28
    ret

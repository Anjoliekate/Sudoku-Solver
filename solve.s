                .global solve

                .data
msg_naked:      .asciz  "\nBoard after solving naked sets:\n"
msg_back:       .asciz  "\nBoard is unsolvable. Backtracking to change previous guess.\n"
msg_guess:      .asciz  "\nPreparing to guess at position ("
msg_guess_mid:  .asciz  ", "
msg_guess_end:  .asciz  ")\n"
msg_badguess:   .asciz  "\nRan out of guesses. Backtracking.\n"

                .text
# solve(board, table) ->
#     0: solved successfully
#     1: board was unsolvable
solve:
                # prelude
                addi    sp, sp, -24
                sw      ra, 20(sp)
                sw      s0, 16(sp)
                sw      s1, 12(sp)
                sw      s2, 8(sp)
                sw      s3, 4(sp)

                # s0: board
                # s1: table
                # s2: naked sets solver made a change
                # s3: most constained cell
                mv      s0, a0
                mv      s1, a1
                li      s2, 0

                # call check_board
                mv      a0, s0
                call    check_board

                # if the board is unsolvable, backtrack now
                # otherwise continue on to naked sets even
                # if no unsolved squares remain, in case
                # the board is corrupted
                bltz    a0, 2f

                # call naked_sets
1:              mv      a0, s0
                mv      a1, s1
                call    naked_sets
                bnez    a0, 1b

                # print the board
                la      a0, msg_naked
                call    puts
                mv      a0, s0
                call    print_board

                # call check_board
                mv      a0, s0
                call    check_board
                bgez    a0, 3f

                # bad board
2:              la      a0, msg_back
                call    puts

                # return 1
                li      a0, 1
                j       5f

                # solved?
3:              li      t0, 81
                blt     a0, t0, 4f

                # return 0
                li      a0, 0
                j       5f

                # copy most-constrained cell to s3
4:              mv      s3, a0

                # call guess
                mv      a0, s0
                mv      a1, s1
                mv      a2, s3
                la      a4, guess
                call    call_function

                # if it returned zero, we return zero
                beqz    a0, 5f

                # print backtracking message
                la      a0, msg_badguess
                call    puts

                # return 1
                li      a0, 1

                # postlude
5:              lw      ra, 20(sp)
                lw      s0, 16(sp)
                lw      s1, 12(sp)
                lw      s2, 8(sp)
                lw      s3, 4(sp)
                addi    sp, sp, 24
                ret

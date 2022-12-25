                .global read_board
                .global parse_board

                .equ    sys_read, 63
                .equ    stdin, 0

                .data
prompt_msg:     .asciz  "Please enter an 81-character board:\n"
io_error_msg:   .asciz  "Error reading board from stdin\n"
eof_error_msg:  .asciz  "End of file when reading from stdin\n"
len_error_msg:  .asciz  "Board input must be exactly 81 characters plus a newline\n"
too_short_msg:  .asciz  "Board input too short\n"
bad_char_msg:   .asciz  "Board had a bad input character\n"
too_long_msg:   .asciz  "Board input too long\n"

                .text
# read_board(board) ->
#   success: return 0
#   error: print a message and return 1
read_board:
                # prelude
                addi    sp, sp, -8
                sw      ra, 4(sp)
                sw      s0, 0(sp)

                # s0: board
                mv      s0, a0

                # reserve a read buffer on the stack
                addi    sp, sp, -128

                la      a0, prompt_msg
                call    puts

                # read(stdin, sp, 127)
                li      a0, stdin
                mv      a1, sp
                li      a2, 127
                li      a7, sys_read
                ecall
                bgez    a0, 1f
                la      a0, io_error_msg
                call    puts
                li      a0, 1
                j       6f

                # end of file?
1:              bnez    a0, 3f
                la      a0, eof_error_msg
                call    puts
                li      a0, 1
                j       6f

                # wrong input length? should be 82 bytes (last one a newline)
3:              li      t0, 82
                bne     a0, t0, 4f
                addi    t0, sp, 81
                lb      t1, (t0)
                li      t2, '\n'
                beq     t1, t2, 5f

4:              la      a0, len_error_msg
                call    puts
                li      a0, 1
                j       6f

5:              sb      zero, (t0)

                mv      a0, sp
                mv      a1, s0
                call    parse_board

6:              addi    sp, sp, 128

                # postlude
                lw      ra, 4(sp)
                lw      s0, 0(sp)
                addi    sp, sp, 8
                ret

# parse_board(input, board) ->
#   success: return 0
#   error: print a message and return 1
parse_board:
                # prelude
                addi    sp, sp, -8
                sw      ra, 4(sp)

                # a0: input
                # a1: board
                # t0: i
                # t1: ch
                # t2: compare
                li      t0, 0

1:              lb      t1, (a0)

                # if input is zero then the string ended too early
                bnez    t1, 2f
                la      a0, too_short_msg
                call    puts
                li      a0, 1
                j       7f

                # if input is '.' then store a full set of pencil marks
2:              li      t2, '.'
                bne     t1, t2, 3f
                li      t1, 0b1111111110
                sh      t1, (a1)
                j       5f

                # if <'0' or >'9' then input is invalid
3:              li      t2, '0'
                blt     t1, t2, 4f
                li      t2, '9'
                bgt     t1, t2, 4f
                addi    t1, t1, -'0'
                li      t2, 1
                sll     t1, t2, t1
                sh      t1, (a1)
                j       5f

4:              la      a0, bad_char_msg
                call    puts
                li      a0, 1
                j       7f

                # continue loop
5:              addi    t0, t0, 1
                addi    a0, a0, 1
                addi    a1, a1, 2
                li      t2, 81
                blt     t0, t2, 1b

                # there must be a terminating null
                lb      t1, (a0)
                beqz    t1, 6f
                la      a0, too_long_msg
                call    puts
                li      a0, 1
                j       7f

6:              li      a0, 0

7:              lw      ra, 4(sp)
                addi    sp, sp, 8
                ret

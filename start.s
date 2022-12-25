                .global _start
                .equ    sys_exit, 93

                .data
msg_pencil:     .asciz  "\nBoard with up-to-date pencil marks:\n"

                .text
_start:
				.option	push
				.option norelax
				la		gp, __global_pointer$
				.option pop

                # s0: board
                # s1: table

                # reserve stack space for a board
                # 81*2 = 162 so reserve 176
                addi    sp, sp, -176
                mv      s0, sp

                # reserve stack space for the table
                # 27*9 = 243 so reserve 256
                addi    sp, sp, -256
                mv      s1, sp

                # read a board from stdin
1:              mv      a0, s0
                call    read_board
                bnez    a0, 1b

                # generate the lookup table
                mv      a0, s1
                call    make_group_table

                # call calc_pencil
2:              mv      a0, s0
                mv      a1, s1
                call    calc_pencil

                # repeat until no change
                bnez    a0, 2b

                # print the board
                la      a0, msg_pencil
                call    puts
                mv      a0, s0
                call    print_board

                # call the main solver
                mv      a0, s0
                mv      a1, s1
                call    solve

                # clean up stack
                addi    sp, sp, 256
                addi    sp, sp, 176

                # exit
                li      a0, 0
                li      a7, sys_exit
                ecall

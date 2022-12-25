                .global print_board
                .equ    sys_write, 64
                .equ    sys_exit, 93
                .equ    stdout, 1
                .text

                .equ    rowsize, 8*9 + 1 + 1
                .equ    rowcount, 4*9 + 1
                .equ    buffer_size, 2752
                # buffer_size is rowsize*rowsize rounded up to 16

# draw_char(buffer, x, y, ch)
# draw a character in the buffer at the given coordinates
draw_char:
                # a0: buffer
                # a1: x
                # a2: y
                # a3: ch
                # a4: index

                # index = rowsize*y + x
                li      t0, rowsize
                mul     t1, t0, a2
                add     t2, t1, a1
                add     t3, a0, t2
                sb      a3, (t3)
                ret

# print_board(board)
print_board:
                # prelude
                addi    sp, sp, -40
                sw      ra, 36(sp)
                sw      s0, 32(sp)
                sw      s1, 28(sp)
                sw      s2, 24(sp)
                sw      s3, 20(sp)
                sw      s4, 16(sp)
                sw      s5, 12(sp)
                sw      s6, 8(sp)
                sw      s7, 4(sp)
                sw      s8, 0(sp)

                # allocate enough space for the print buffer
                # this is rowssize * rowcount rounded up to a mult of 16
                li      t0, buffer_size
                sub     sp, sp, t0

                # s0: board
                # s1: x
                # s2: y
                # buffer is sp
                # a3: ch
                mv      s0, a0
                li      s2, 0

1:              li      s1, 0

                # if x == rowsize-1: ch = '\n'
2:              li      t0, rowsize-1
                bne     s1, t0, 3f
                li      a3, '\n'
                j       10f

                # else if x%24 == 0 && x%12 == 0: ch = '+'
3:              li      t0, 24
                rem     t0, s1, t0
                bnez    t0, 4f
                li      t0, 12
                rem     t0, s2, t0
                bnez    t0, 4f
                li      a3, '+'
                j       10f

                # else if x%24 == 0: ch = '|'
4:              li      t0, 24
                rem     t0, s1, t0
                bnez    t0, 5f
                li      a3, '|'
                j       10f

                # else if y%12 == 0: ch = '-'
5:              li      t0, 12
                rem     t0, s2, t0
                bnez    t0, 6f
                li      a3, '-'
                j       10f

                # else if x%8 == 0 && y%4 == 0: ch = '+'
6:              li      t0, 8
                rem     t0, s1, t0
                bnez    t0, 7f
                li      t0, 4
                rem     t0, s2, t0
                bnez    t0, 7f
                li      a3, '+'
                j       10f

                # else if x%8 == 0 && y%2 != 0: ch = '|'
7:              li      t0, 8
                rem     t0, s1, t0
                bnez    t0, 8f
                li      t0, 2
                rem     t0, s2, t0
                beqz    t0, 8f
                li      a3, '|'
                j       10f

                # else if x%2 == 0 && y%4 == 0: ch = '-'
8:              li      t0, 2
                rem     t0, s1, t0
                bnez    t0, 9f
                li      t0, 4
                rem     t0, s2, t0
                bnez    t0, 9f
                li      a3, '-'
                j       10f

                # else ch = ' '
9:              li      a3, ' '

                # draw_char(buffer, x, y, ch)
10:             mv      a0, sp
                mv      a1, s1
                mv      a2, s2
                call    draw_char

                addi    s1, s1, 1
                li      t0, rowsize
                blt     s1, t0, 2b

                addi    s2, s2, 1
                li      t0, rowcount
                blt     s2, t0, 1b

                # draw_char(buffer, 0, rowcount, 0)
                mv      a0, sp
                li      a1, 0
                mv      a2, t0
                li      a3, 0
                call    draw_char

                # fill in the squares
                # s0: board
                # s1: x
                # s2: y
                # s3: centerx
                # s4: centery
                # s5: dx
                # s6: dy
                # s7: elt
                # s8: value

                # for y from [0, 9)
                li      s2, 0

                # centery = y*4 + 2
11:             li      t0, 4
                mul     s4, s2, t0
                addi    s4, s4, 2

                # for x from [0, 9)
                li      s1, 0

                # centerx = x*8 + 4
12:             li      t0, 8
                mul     s3, s1, t0
                addi    s3, s3, 4

                # elt = board[x + y*9]
                li      t0, 9
                mul     t0, t0, s2
                add     t0, t0, s1
                add     t0, t0, t0
                add     t0, t0, s0
                lh      s7, (t0)

                # count the set bits
                # t1 = i
                # t2 = count
                # t3 = last hit
                li      t1, 1
                li      t2, 0

13:             li      t0, 1
                sll     t0, t0, t1
                and     t0, s7, t0
                beqz    t0, 14f
                addi    t2, t2, 1
                mv      t3, t1

14:             addi    t1, t1, 1
                li      t0, 9
                ble     t1, t0, 13b

                # if exactly 1 bit is set, draw it in the center
                li      t0, 1
                bne     t2, t0, 15f
                mv      a0, sp
                mv      a1, s3
                mv      a2, s4
                addi    a3, t3, '0'
                call    draw_char
                j       20f

                # print pencil marks
                # value = 1
15:             li      s8, 1

                # for dy in [-1, 0, 1]
                li      s6, -1

                # for dx in [-2, 0, 2]
16:             li      s5, -2

17:             li      a3, '.'
                li      t0, 1
                sll     t0, t0, s8
                and     t0, s7, t0
                beqz    t0, 18f
                addi    a3, s8, '0'

18:             mv      a0, sp
                add     a1, s3, s5
                add     a2, s4, s6
                call    draw_char

                # next dx (and value)
19:             addi    s8, s8, 1
                addi    s5, s5, 2
                li      t0, 2
                ble     s5, t0, 17b

                # next dy
                addi    s6, s6, 1
                li      t0, 1
                ble     s6, t0, 16b

                # next x
20:             addi    s1, s1, 1
                li      t0, 9
                blt     s1, t0, 12b

                # next y
                addi    s2, s2, 1
                li      t0, 9
                blt     s2, t0, 11b

                # print the buffer
                mv      a0, sp
                call    puts

                li      t0, buffer_size
                add     sp, sp, t0

                # postlude
                lw      ra, 36(sp)
                lw      s0, 32(sp)
                lw      s1, 28(sp)
                lw      s2, 24(sp)
                lw      s3, 20(sp)
                lw      s4, 16(sp)
                lw      s5, 12(sp)
                lw      s6, 8(sp)
                lw      s7, 4(sp)
                lw      s8, 0(sp)
                addi    sp, sp, 40
                ret

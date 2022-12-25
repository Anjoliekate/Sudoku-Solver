                .global make_group_table
                .text

# make_group_table(table)
#
# prepares a lookup table with 27 rows of 9 entries each
# each row gives the offset of the 9 elements in
# a single row, column, or 3x3 box within a Sudoku board
make_group_table:
                # a0: table
                # a1: i
                # a2: boxrow
                # a3: boxcol
                # a4: row
                # a5: col
                li      a1, 0

                #
                # build the rows
                #

                # for row in [0, 81) step 9
                li      a4, 0

                # for col in [0, 9)
1:              li      a5, 0

                # table[i++] = row + col
2:              add     t0, a0, a1
                addi    a1, a1, 1
                add     t1, a4, a5
                sb      t1, (t0)

                # next col
                addi    a5, a5, 1
                li      t0, 9
                blt     a5, t0, 2b

                # next row
                addi    a4, a4, 9
                li      t0, 81
                blt     a4, t0, 1b

                #
                # build the columns
                #

                # for col in [0, 9)
                li      a5, 0

                # for row in [0, 81) step 9
1:              li      a4, 0

                # table[i++] = row + col
2:              add     t0, a0, a1
                addi    a1, a1, 1
                add     t1, a4, a5
                sb      t1, (t0)

                # next row
                addi    a4, a4, 9
                li      t0, 81
                blt     a4, t0, 2b

                # next col
                addi    a5, a5, 1
                li      t0, 9
                blt     a5, t0, 1b

                #
                # build the 3x3 boxes
                #

                # for boxrow in (0, 81] step 27
                li      a2, 0

                # for boxcol in (0, 9] step 3
1:              li      a3, 0

                # for row in (0, 27] step 9
2:              li      a4, 0

                # for col in (0, 3]
3:              li      a5, 0

                # table[i++] = boxrow + row + boxcol + col
4:              add     t0, a0, a1
                addi    a1, a1, 1
                add     t1, a2, a4
                add     t2, a3, a5
                add     t1, t1, t2
                sb      t1, (t0)

                # next col
                addi    a5, a5, 1
                li      t0, 3
                blt     a5, t0, 4b

                # next row
                addi    a4, a4, 9
                li      t0, 27
                blt     a4, t0, 3b

                # next boxcol
                addi    a3, a3, 3
                li      t0, 9
                blt     a3, t0, 2b

                # next boxrow
                addi    a2, a2, 27
                li      t0, 81
                blt     a2, t0, 1b

                ret

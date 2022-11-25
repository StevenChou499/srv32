.org 0

.global main

.data
nums:
    .word 0, 1, 2, 3, 4, 5, 6, 7

origin_array:
    .string "The original array is :[%d %d %d %d %d %d %d %d]\n"

converted_array:
    .string "The converted array is :[%d %d %d %d %d %d %d %d]\n"

.text
main:
    # store the return address and s registers into the stack
    addi    sp, sp, -12
    sw      ra, 8(sp)
    sw      s0, 4(sp)
    sw      s1, 0(sp)

    # print the original array elements
    la      a0, origin_array
    la      t0, nums
    lw      a1, 0(t0)
    lw      a2, 4(t0)
    lw      a3, 8(t0)
    lw      a4, 12(t0)
    lw      a5, 16(t0)
    lw      a6, 20(t0)
    lw      a7, 24(t0)
    lw      t1, 28(t0)
    addi    sp, sp, -4
    sw      t1, 0(sp)
    call    printf
    addi    sp, sp, 4

    # call function moveZeros
    la      a0, nums                    # load array base address into register a0
    addi    a1, x0, 8                   # load array size = 5 into register a1

    add     s0, a0, x0                  # store a0 to s0
    add     s1, a1, x0                  # store a1 to s1
    jal     ra, moveZeros               # jump to moveZeros function

    # return from moveZeros function
    # print the converted array elements
    la      a0, converted_array
    la      t0, nums
    lw      a1, 0(t0)
    lw      a2, 4(t0)
    lw      a3, 8(t0)
    lw      a4, 12(t0)
    lw      a5, 16(t0)
    lw      a6, 20(t0)
    lw      a7, 24(t0)
    lw      t1, 28(t0)
    addi    sp, sp, -4
    sw      t1, 0(sp)
    call    printf
    addi    sp, sp, 4

    # pop back the return address and used s registers from stack
    lw      s1, 0(sp)
    lw      s0, 4(sp)
    lw      ra, 8(sp)
    addi    sp, sp, 12

    # return 0 in main function
    addi    a0, x0, 0
    jr      ra                          # ret

moveZeros:
    addi    sp, sp, -4
    sw      ra, 0(sp)
    li      t0, 0                       # next non zero index = 0
    li      t1, 0                       # i = 0

loop:
    # t0: store the next non zero index to store
    # t1: detect next array index
    # t2: the next non zero address
    # t3: the next array address for detection
    bge     t1, a1, exit                # if t1 > num size, return to exit
    slli    t3, t1, 2                   # find the offset word
    add     t3, a0, t3                  # find the offset address
    lw      t4, 0(t3)                   # load the word
    beq     t4, x0, next_iter           # check if the word is 0
    slli    t2, t0, 2                   # find the offset word
    add     t2, t2, a0                  # find the offset address
    sw      t4, 0(t2)                   # store the non zero word
    beq     t0, t1, next_iter_addIndex  # if both addresses are same, we don't need to store zero
    sw      x0, 0(t3)                   # if the addresses aren't same, store 0 to array[i]

next_iter_addIndex:
    addi    t0, t0, 1                   # next_nonzero_index++
    
next_iter:
    addi    t1, t1, 1                   # if the word is zero, add the index by 1
    j       loop

exit:
    lw      ra, 0(sp)
    addi    sp, sp, 4
    jr      ra
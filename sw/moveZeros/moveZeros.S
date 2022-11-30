.org 0

.global main

.data
nums:
    .word 0, 1, 2, 0, 3, 0, 4

origin_array:
    .string "The original array is :[%d %d %d %d %d %d %d]\n"

converted_array:
    .string "The converted array is :[%d %d %d %d %d %d %d]\n"

.macro mvZr
moveZeros:
    add     t0, a0, x0                  # next non zero address
    slli    t1, a1, 2                   # calculate the total offset
    add     a1, a0, t1
    add     t1, a0, x0                  # i = 0

loop:
    # t0: store the next non zero index to store
    # t1: detect next array index
    bge     t1, a1, exit                # if t1 > num size, return to exit
    lw      t2, 0(t1)                   # load the word
    beq     t2, x0, next_iter           # check if the word is 0
    sw      t2, 0(t0)                   # store the non zero word
    beq     t0, t1, next_iter_addIndex  # if both addresses are same, we don't need to store zero
    sw      x0, 0(t1)                   # if the addresses aren't same, store 0 to array[i]

next_iter_addIndex:
    addi    t0, t0, 4                   # next_nonzero_address + 4
    
next_iter:
    addi    t1, t1, 4                   # if the word is zero, add the address by 4
    j       loop

exit:
.endm

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
    call    printf

    # call function moveZeros
    la      a0, nums                    # load array base address into register a0
    addi    a1, x0, 7                   # load array size = 7 into register a1

    add     s0, a0, x0                  # store a0 to s0
    add     s1, a1, x0                  # store a1 to s1
    mvZr                                # using inline function

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
    call    printf

    # pop back the return address and used s registers from stack
    lw      s1, 0(sp)
    lw      s0, 4(sp)
    lw      ra, 8(sp)
    addi    sp, sp, 12

    # return 0 in main function
    addi    a0, x0, 0
    jr      ra                          # ret
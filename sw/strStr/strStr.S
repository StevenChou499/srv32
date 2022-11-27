.org 0

.global main

.data
haystack:   .string "I live my life a quarter mile at a time."
needle:     .string "mile"
answrstr:   .string "The index is %d.\n"

.text
main:
    # saving ra into the stack
    addi    sp, sp, -4
    sw      ra, 0(sp)

    # int strStr(char *haystack, char *needle);
    la      a0, haystack
    la      a1, needle
    jal     ra, strStr
    add     a1, x0, a0      # store the return value in a1
    la      a0, answrstr
    call    printf

    # load ra back from the stack
    lw      ra, 0(sp)
    addi    sp, sp, 4

    # return 0 in a0
    li      a0, 0
    ret

strStr:
    # a0 is the address of haystack
    # a1 is the address of needle
    addi    sp, sp, -4
    sw      ra, 0(sp)
    add     t0, x0, a0      # use t0 to store a0
    add     t1, x0, a1      # use t1 to store a1
    li      t2, 0           # use t2 to store the index

checkbase:
    lb      t3, 0(t0)       # t3 = *base
    bne     t3, x0, start
    lw      ra, 0(sp)
    addi    sp, sp, 4
    li      a0, -1
    ret

start:
    lb      t3, 0(t0)       # t3 = *base
    lb      t4, 0(t1)       # t4 = *tmp
    beq     t4, x0, notsame
    bne     t3, t4, notsame
    addi    t0, t0, 1
    addi    t1, t1, 1
    j       start
    
notsame:
    beq     t4, x0, retindex
    addi    t2, t2, 1       # index++
    addi    a0, a0, 1       # ++haystack
    add     t0, x0, a0      # base = ++haystack
    add     t1, x0, a1      # tmp = needle
    j       checkbase

retindex:
    lw      ra, 0(sp)
    addi    sp, sp, 4
    add     a0, x0, t2
    ret
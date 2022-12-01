.org 0

.global main

.data
haystack:   .string "I live my life a quarter mile at a time."
needle:     .string "mile"
answrstr:   .string "The index is %d.\n"

.macro checkbase_macro
    lb      t3, 0(t0)       # t3 = *base
    beq     t3, x0, notfound
    lb      t4, 0(t1)       # t4 = *tmp
    beq     t3, t4, startcompare
    addi    t2, t2, 1       # index++
    addi    t0, t0, 1       # ++base
.endm

.macro traverse_macro
    lb      t3, 0(t0)       # t3 = *base
    lb      t4, 0(t1)       # t4 = *tmp
    bne     t3, t4, wrong_index
    addi    t0, t0, 1
    addi    t1, t1, 1
.endm

.macro strStr_macro
strStr:
    # a0 is the address of haystack
    # a1 is the address of needle
    add     t0, x0, a0      # use t0 to store a0
    add     t1, x0, a1      # use t1 to store a1
    li      t2, 0           # use t2 to store the index

checkbase:
    checkbase_macro
    checkbase_macro
    checkbase_macro
    checkbase_macro
    checkbase_macro
    checkbase_macro
    checkbase_macro
    checkbase_macro
    j       checkbase

startcompare:
    add     a0, x0, t0      # use a0 register to remember base
    addi    t0, t0, 1       # Because when we jump to this section, the 
    addi    t1, t1, 1       # first byte must be the same, so we skip it.

traverse:
    traverse_macro
    traverse_macro
    traverse_macro
    traverse_macro
    j       traverse

wrong_index:
    beq     t4, x0, retindex
    add     t0, x0, a0      # restore t0 with a0 register
    add     t1, x0, a1      # restore t1 with a1 register
    addi    t0, t0, 1
    addi    t2, t2, 1
    j       checkbase

retindex:
    add     a0, x0, t2
    j       return

notfound:
    li      a0, -1

return:
.endm

.text
main:
    # saving ra into the stack
    addi    sp, sp, -4
    sw      ra, 0(sp)

    # int strStr(char *haystack, char *needle);
    la      a0, haystack
    la      a1, needle
    strStr_macro
    add     a1, x0, a0      # store the return value in a1
    la      a0, answrstr
    call    printf

    # load ra back from the stack
    lw      ra, 0(sp)
    addi    sp, sp, 4

    # return 0 in a0
    li      a0, 0
    ret
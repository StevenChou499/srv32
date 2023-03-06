# SoftCPU

## srv32 CPU pipeline structure
srv32 CPU uses a 3-stage pipeline. First is the Instruction Fetch and Decode stage. Second is the Execution stage, the last is the Memory access and Write Back stage.

![](https://i.imgur.com/sE7x3WF.png)

## choosing a assembly in Assigment 2
For the assigment 2, I choose [王漢祺](https://hackmd.io/@wanghanchi/S1q0aBHQj) problem, which is leetcode [Problem. 283](https://leetcode.com/problems/move-zeroes/)

 * below is the modified assembly in order to run in srv32 : 
```asm
.org 0

.global main

.data
nums:
    .word 0, 1, 2, 0, 3, 0, 4

origin_array:
    .string "The original array is :[%d %d %d %d %d %d %d]\n"

converted_array:
    .string "The converted array is :[%d %d %d %d %d %d %d]\n"

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
    call    printf

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
```

### ISS & RTL Simulation Result
```
The original array is :[0 1 2 0 3 0 4]
The converted array is :[1 2 3 4 0 0 0]

Excuting 9772 instructions, 13340 cycles, 1.365 CPI
Program terminate
- ../rtl/../testbench/testbench.v:434: Verilog $finish

Simulation statistics
=====================
Simulation time  : 0.093 s
Simulation cycles: 13351
Simulation speed : 0.143559 MHz

make[1]: Leaving directory '/home/steven/srv32/sim'
make[1]: Entering directory '/home/steven/srv32/tools'
./rvsim --memsize 128 -l trace.log ../sw/moveZeros/moveZeros.elf
The original array is :[0 1 2 0 3 0 4]
The converted array is :[1 2 3 4 0 0 0]

Excuting 9772 instructions, 13340 cycles, 1.365 CPI
Program terminate

Simulation statistics
=====================
Simulation time  : 0.004 s
Simulation cycles: 13340
Simulation speed : 3.580 MHz

make[1]: Leaving directory '/home/steven/srv32/tools'
Compare the trace between RTL and ISS simulator
=== Simulation passed ===
```

## Waveform analyzation
Now we have the simulation result, we can take a closer look at the generated waveform file `wave.fst` which is inside `srv32/sim` directory.

### PC
program counter decides which instruction is going to execute next. In srv32 simulator, there are 4 main PC-related logic, which is `fetch_pc`, `if_pc`, `ex_pc` and `wb_pc`.

### Control Hazard
When taking a branch, the CPU has to discard all the instruction before execution stage inside the pipeline, and fetch in the correct instruction. This is called control hazard. There are lots of control hazard ocurrs in this program. For example, in the first few lines of the disassembly code, we can see that it uses branch to initialize out the `.bss` section of the program : 

```asm!
00000000 <_start>:
       0:	00010297          	auipc	t0,0x10
       4:	07028293          	addi	t0,t0,112 # 10070 <trap_handler>
       8:	30529073          	.4byte	0x30529073
       c:	3050e073          	.4byte	0x3050e073
      10:	00022297          	auipc	t0,0x22
      14:	85c28293          	addi	t0,t0,-1956 # 2186c <_PathLocale>
      18:	00022317          	auipc	t1,0x22
      1c:	b6430313          	addi	t1,t1,-1180 # 21b7c <_bss_end>

00000020 <_bss_clear>:
      20:	0002a023          	sw	zero,0(t0)
      24:	00428293          	addi	t0,t0,4
      28:	fe62ece3          	bltu	t0,t1,20 <_bss_clear>
      2c:	00040117          	auipc	sp,0x40
      30:	fd410113          	addi	sp,sp,-44 # 40000 <_stack>
      34:	008000ef          	jal	ra,3c <main>
      38:	3441006f          	j	1037c <exit>
```

in the `wave.fst` file, we can also see the pc jumps back and forth in the red section.

![](https://i.imgur.com/26ZAdYd.png)

Also when we see at the blue section, there is a `wb_nop` and `wb_nop_more` turn on in a specific time. These two signals indicate whether the instrction right now in the write back stage will be write back to the data-memory or not. For example, when we decided to take a branch in the execution stage (`ex_pc`) of PC `0x00000028`, we change the `next_pc` to `0x00000020`, but there are still two invalid instruction inside the `fetch_pc` and `if_pc` stage. So in order to correct this problem, the CPU decided to not write back the result when the `fetch_pc` and `if_pc` instruction gets to the write back stage.

## Observing my main assembly code

### PC and Control Hazard

In order to lower the branch penalty, we have to use less branch as possible.

### Using macro to implement inline function

Because in `main` function, we have to call `moveZeros` functions to jump into the real function. I change the function body to a macro and remove the saving and poping return address part of the function.

* Below is the modified version : 

```asm
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
```

* Below is the waveform using the inline function

![](https://i.imgur.com/m1A0uIa.png)

We can see that when we execute the first line of the `moveZeros` function, there are no control hazard happend.

### ISS & RTL Simulation Result
```
The original array is :[0 1 2 0 3 0 4]
The converted array is :[1 2 3 4 0 0 0]

Excuting 9766 instructions, 13330 cycles, 1.364 CPI
Program terminate
- ../rtl/../testbench/testbench.v:434: Verilog $finish

Simulation statistics
=====================
Simulation time  : 0.088 s
Simulation cycles: 13341
Simulation speed : 0.151602 MHz

make[1]: Leaving directory '/home/steven/srv32/sim'
make[1]: Entering directory '/home/steven/srv32/tools'
./rvsim --memsize 128 -l trace.log ../sw/moveZeros/moveZeros.elf
The original array is :[0 1 2 0 3 0 4]
The converted array is :[1 2 3 4 0 0 0]

Excuting 9766 instructions, 13330 cycles, 1.365 CPI
Program terminate

Simulation statistics
=====================
Simulation time  : 0.004 s
Simulation cycles: 13330
Simulation speed : 3.617 MHz

make[1]: Leaving directory '/home/steven/srv32/tools'
Compare the trace between RTL and ISS simulator
=== Simulation passed ===
```

We can see that the total cycles reduces by 10, result in CPI of 1.364.

### Changing the address calculation algorithm

In the previous assembly, we calculate the address by adding the index by 1, and times 4 plus the base address to get the correct address. Now we can just copy the base address in the beginning of the function call, whenever we want to increment the array index by 1, we can just increment the address by 4 and we can get the real address.

* Below is the modified version : 

```asm
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
```

### ISS & RTL Simulation Result
```
The original array is :[0 1 2 0 3 0 4]
The converted array is :[1 2 3 4 0 0 0]

Excuting 9746 instructions, 13310 cycles, 1.365 CPI
Program terminate
- ../rtl/../testbench/testbench.v:434: Verilog $finish

Simulation statistics
=====================
Simulation time  : 0.088 s
Simulation cycles: 13321
Simulation speed : 0.151375 MHz

make[1]: Leaving directory '/home/steven/srv32/sim'
make[1]: Entering directory '/home/steven/srv32/tools'
./rvsim --memsize 128 -l trace.log ../sw/moveZeros/moveZeros.elf
The original array is :[0 1 2 0 3 0 4]
The converted array is :[1 2 3 4 0 0 0]

Excuting 9746 instructions, 13310 cycles, 1.366 CPI
Program terminate

Simulation statistics
=====================
Simulation time  : 0.004 s
Simulation cycles: 13310
Simulation speed : 3.756 MHz

make[1]: Leaving directory '/home/steven/srv32/tools'
Compare the trace between RTL and ISS simulator
=== Simulation passed ===
```

We can see now the cycle counts is reduced by 20 cycles, which is a great improvement.

### Improvement Result

|                | Before Improvement | After Improvement |
|:--------------:|:------------------:|:-----------------:|
|  Instructions  |        9772        |       9746        |
|     Cycles     |       13340        |       13310       |
| Execution Time |       0.093        |       0.088       |
|      CPI       |       1.365        |       1.365       |

## Working with another leetcode problem
I choose [Problem 28](https://leetcode.com/problems/find-the-index-of-the-first-occurrence-in-a-string/) to write my assembly code. In order to write assembly, we need to first write out the C code.

 * Below is the C code implementation : 
```c
#include <stdio.h>

int strStr(char *haystack, char *needle) {
    char *base = haystack;
    char *tmp = needle;
    int index = 0;
    while(*base) {
        while (*tmp && *tmp == *base) {
            tmp++;
            base++;
        }
        if(!*tmp)
            return index;
        index++;
        base = ++haystack;
        tmp = needle;
    }
    return -1;
}

int main(void)
{
    char *haystack = "I live my life a quarter mile at a time.";
    char *needle = "mile";
    int index = strStr(haystack, needle);
    printf("The index is %d.\n", index);
    
    return 0;
}
```

After making sure the C code runs with out any error, we can write our assembly code.

 * Below is my RISC-V assembly code : 
```asm
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
    add     t0, x0, a0      # use t0 to store a0
    add     t1, x0, a1      # use t1 to store a1
    li      t2, 0           # use t2 to store the index

checkbase:
    lb      t3, 0(t0)       # t3 = *base
    bne     t3, x0, start
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
    add     a0, x0, t2
    ret
```

### ISS & RTL Simulation Result
```
The index is 25.

Excuting 3025 instructions, 4269 cycles, 1.411 CPI
Program terminate
- ../rtl/../testbench/testbench.v:434: Verilog $finish

Simulation statistics
=====================
Simulation time  : 0.03 s
Simulation cycles: 4280
Simulation speed : 0.142667 MHz

make[1]: Leaving directory '/home/steven/srv32/sim'
make[1]: Entering directory '/home/steven/srv32/tools'
./rvsim --memsize 128 -l trace.log ../sw/strStr/strStr.elf
The index is 25.

Excuting 3025 instructions, 4269 cycles, 1.411 CPI
Program terminate

Simulation statistics
=====================
Simulation time  : 0.001 s
Simulation cycles: 4269
Simulation speed : 3.348 MHz

make[1]: Leaving directory '/home/steven/srv32/tools'
Compare the trace between RTL and ISS simulator
=== Simulation passed ===
```

## Optimizing Leetcode Problem

Now we have optimized the first problem, we can now focus on the second problem which is from leet code.

### rearranging assembly and branching logic

In the hand written assembly code, we can see that there are many branching inside. So if we can optimize the branching logic, we can have a lower cycle and less branch penalty.

* Below is the modified assembly code : 

```asm!
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
    beq     t3, x0, notfound
    lb      t4, 0(t1)       # t4 = *tmp
    beq     t3, t4, startcompare
    addi    t2, t2, 1       # index++
    addi    t0, t0, 1       # ++base
    j       checkbase

startcompare:
    add     a0, x0, t0      # use a0 register to remember base
    addi    t0, t0, 1       # Because when we jump to this section, the 
    addi    t1, t1, 1       # first byte must be the same, so we skip it.

traverse:
    lb      t3, 0(t0)       # t3 = *base
    lb      t4, 0(t1)       # t4 = *tmp
    bne     t3, t4, wrong_index
    addi    t0, t0, 1
    addi    t1, t1, 1
    j       traverse

wrong_index:
    beq     t4, x0, retindex
    add     t0, x0, a0      # restore t0 with a0 register
    add     t1, x0, a1      # restore t1 with a1 register
    addi    t0, t0, 1
    addi    t2, t2, 1
    j       checkbase

retindex:
    lw      ra, 0(sp)
    addi    sp, sp, 4
    add     a0, x0, t2
    ret

notfound:
    lw      ra, 0(sp)
    addi    sp, sp, 4
    li      a0, -1
    ret
```

The concept behind this new assembly code is that in most of the time we will find out that the first letter is already wrong, so we will take a lot of time traversing the whole string. Becase of that, I predict that the branch `beq     t3, t4, startcompare` won't be taken most of the cycles, only when the both characters are the same, we can jump to another section to start comparing

### ISS & RTL Simulation Result
```
The index is 25.

Excuting 2897 instructions, 4041 cycles, 1.394 CPI
Program terminate
- ../rtl/../testbench/testbench.v:434: Verilog $finish

Simulation statistics
=====================
Simulation time  : 0.021 s
Simulation cycles: 4052
Simulation speed : 0.192952 MHz

make[1]: Leaving directory '/home/steven/srv32/sim'
make[1]: Entering directory '/home/steven/srv32/tools'
./rvsim --memsize 128 -l trace.log ../sw/strStr/strStr.elf
The index is 25.

Excuting 2897 instructions, 4041 cycles, 1.395 CPI
Program terminate

Simulation statistics
=====================
Simulation time  : 0.001 s
Simulation cycles: 4041
Simulation speed : 5.644 MHz

make[1]: Leaving directory '/home/steven/srv32/tools'
Compare the trace between RTL and ISS simulator
=== Simulation passed ===

```

We can see that the total cycle decrease by 228, which is a very large improvement.

### Utilizing Loop Unrolling and Macros

Because the assembly has many loop going repeating running lots of time, it's a great case to implement loop unrolling and macros.

* Below is the modified assembly : 

```asm
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
```

### ISS & RTL Simulation Result
```
The index is 25.

Excuting 2867 instructions, 3959 cycles, 1.380 CPI
Program terminate
- ../rtl/../testbench/testbench.v:434: Verilog $finish

Simulation statistics
=====================
Simulation time  : 0.021 s
Simulation cycles: 3970
Simulation speed : 0.189048 MHz

make[1]: Leaving directory '/home/steven/srv32/sim'
make[1]: Entering directory '/home/steven/srv32/tools'
./rvsim --memsize 128 -l trace.log ../sw/strStr/strStr.elf
The index is 25.

Excuting 2867 instructions, 3959 cycles, 1.381 CPI
Program terminate

Simulation statistics
=====================
Simulation time  : 0.001 s
Simulation cycles: 3959
Simulation speed : 5.122 MHz

make[1]: Leaving directory '/home/steven/srv32/tools'
Compare the trace between RTL and ISS simulator
=== Simulation passed ===
```

Using loop unrolling and `.macro` improve the cycles by 82.

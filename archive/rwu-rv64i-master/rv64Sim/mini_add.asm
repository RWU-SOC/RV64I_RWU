.equ DMEM_BASE,  0x00000000    # Correct DMEM Base
.equ GPIO_BASE,  0x00010000    # Correct GPIO Base from RTL
.equ GPIO_DATA,  4             # GPIO data register offset

.global _start
_start:
    # Perform 9 + 6, expect result = 15 (0x0F)
    li   x3, 9
    li   x4, 6
    add  x5, x3, x4             # x5 = 15

    # Store result at DMEM[0x00000008]
    li   x6, DMEM_BASE + 8
    sd   x5, 0(x6)              # Store double word (64-bit)

    # Write low-byte (0x0F) to GPIO[0x00010004]
    li   x2, GPIO_BASE
    sb   x5, GPIO_DATA(x2)      # Store byte to GPIO register

done:   beq  x2, x2, done      # 50 infinite loop


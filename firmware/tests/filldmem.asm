# RISC-V Assembly              Description
.global _start

_start: addi x2, x0, 0x0       # lower address of D-Mem
	# according memory map, the register contains 8192 (0x2000) double words = 65636 (0x10000) bytes
	#   so, address from 0x0 to 0x10000-8 -> upper address is 0xfff8
	lui  x3, 0xfff8        # sign extended set of bits 12 to 31, lower 12 bits are 0
	srli x3, x3, 12        # shift down to begin of register
	#addi x3, x0, 248       # high  address of D-Mem in double words, 0x10000-8=0xfff8
	addi x4, x0, 8         # Address step
	addi x5, x0, 0         # value to be stored
	addi x6, x0, 0x100     # load GPIO base address
	slli x6, x6, 8         # load GPIO base address
	addi x7, x0, 42        # data for GPIO
	lui  x8, 0xfffff       # sign extended set of bits 12 to 31, lower 12 bits are 0
loop:	sd   x5, 0(x3)         # store data
	sub  x3, x3, x4        # suntract 8 from address
	bne  x3, x2, loop      # if address didn't reach lower address go back to loop
	sd   x5, 0(x3)         # store data (last value)
	sb   x7, 4(x6)         # write 42 to GPIO -> check
        jal  x0, done          # jump to end
done:   beq  x2, x2, done      # 50 infinite loop

# RISC-V Assembly              Description
.global _start


	# GPIO is at address 0x10000 - 0x1001F
	# Our debug output is at 0x0000_0000_0001_0004
_start: lui  x2, 0x00010       # set GPIO address
	# set data
	addi x10, x0, 0x1D     # data is 29
	# print
	sb   x10, 4(x2)
	### done
        jal  x0, done          # jump to end
done:   beq  x2, x2, done      # 50 infinite loop

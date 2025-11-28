# RISC-V Assembly              Description
.global _start

	# GPIO is at address 0x10000 - 0x1000F
	# Our debug output is at 0x0000_0000_0001_000c
_start: addi x2, x0, 0x100     # GPIO ID registers address
	slli x2, x2, 8         # generate GPIO base address x2=0x10000
	# set GPIO direction
	addi x4, x0, 0x80      # bit 7 is input
	sd   x4, 8(x2)         # write content of x4 to GPIO-direction-register
	# get GPIO peripheral ID
	ld   x3, 0(x2)         # load GPIO ID to x3 - ID-Reg-Addr=0x10000
	# print
	sd   x3, 12(x2)        # write LSB of GPIO ID to GPIO - print it
	# get IRQSS
	ld x5, 1(x2)
	# clear IRQ
	addi x6, x0, 8
	sd x6, 3(x2)
	# done
        jal  x0, done          # jump to end
done:   beq  x2, x2, done      # 50 infinite loop

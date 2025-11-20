# RISC-V Assembly              Description
.global _start

_start: addi x2, x0, 0x100     # GPIO ID registers address
	slli x2, x2, 8         # load GPIO base address (shift it one byte left) - x2 = 0x010000
        # shift left logical immediate, 5 bits shift value
	addi x4, x0, 1         # 1 to x4
	slli x6, x4, 2         # shift by 2 bits, x6=4
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
        # print
	sb   x10, 4(x2)        # write LSB of GPIO ID to GPIO
	# shift left logical immediate, 5 bits shift value
	addi x4, x0, 1         # 1 to x4
	slli x6, x4, 31        # shift by 2 bits, x6=0, check in wave
	addi x6, x6, 1         # ... now x6=1
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
        # print
	sb   x10, 4(x2)        # write LSB of GPIO ID to GPIO
	### done
        jal  x0, done          # jump to end
done:   beq  x2, x2, done      # 50 infinite loop

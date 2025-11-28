# RISC-V Assembly              Description
.global _start

_start: addi x2, x0, 0x100     # GPIO ID registers address
	slli x2, x2, 8         # load GPIO base address (shift it one byte left) - x2 = 0x010000
        # add 2 positives without overflow
	addi x4, x0, 0x80      # normal addition - source 1, 128
	addi x6, x4, 2         # immediate addition - result, x6 = 130
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
        # print
	sb   x10, 4(x2)        # write LSB of GPIO ID to GPIO
	# add 128 + (-2)
	addi x4, x0, 128       # normal addition - source 1
	addi x6, x4, -2        # immediate addition - result, x6 = 126
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
        # print
	sb   x10, 4(x2)        # write LSB of GPIO ID to GPIO
	### done
        jal  x0, done          # jump to end
done:   beq  x2, x2, done      # 50 infinite loop

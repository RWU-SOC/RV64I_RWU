# RISC-V Assembly              Description
.global _start

_start: addi x2, x0, 0x100     # GPIO ID registers address
	slli x2, x2, 8         # load GPIO base address
	ld   x3, 0(x2)         # load GPIO ID to x3
	sd   x3, 4(x2)         # write LSB of GPIO ID to GPIO
        jal  x0, done          # jump to end
done:   beq  x2, x2, done      # 50 infinite loop

# RISC-V Assembly              Description
.global _start

_start: addi x2, x0, 0x100     # GPIO ID registers address
	slli x2, x2, 8         # load GPIO base address (shift it one byte left)
	addi x4, x0, 8         # 08 base address in D-Mem
        # calc
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	# set x5 to 0x0807_0605_0403_0201
	addi x5, x0, 0         # clear
	lui x7, 0x08070
	slli x7, x7, 12        # upper 20 bits (shift with 32 doesn't work)
	slli x7, x7, 12        # upper 20 bits
	slli x7, x7, 8         # upper 20 bits
	or x5, x5, x7          # ... to x5
	addi x7, x0, 0         # clear x7
	lui x7, 0x60504
	slli x7, x7, 12        # next 20 bits
	or x5, x5, x7          # ... to x5
	addi x7, x0, 0         # clear x7
	lui x7, 0x04030
	or x5, x5, x7          # next 20 bits
	addi x5, x5, 0x201     # last 12 bits
	# store all to D-Mem
	sd x5, 16(x4)          # store to address 24 (64 bit wide)
	### 1st word read
	lh x6, 24(x0)          # get 1 from address 24 (32 bits only), 1st half in double word
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	# print
	sb   x10, 4(x2)        # write LSB of GPIO ID to GPIO
        ### 2nd word read
	lb x6, 28(x0)          # get 5 from address 28 (32 bits only), 2nd word in double word
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	# print
	sb   x10, 4(x2)        # write LSB of GPIO ID to GPIO
	### done
        jal  x0, done          # jump to end
done:   beq  x2, x2, done      # 50 infinite loop

# RISC-V Assembly              Description
.global _start


	# GPIO is at address 0x10000 - 0x1001F
	# Our debug output is at 0x10004
_start: addi x2, x0, 0x100     # GPIO ID registers address
	slli x2, x2, 8         # load GPIO base address (shift it one byte left), GPIO-addr=0x10000
	# prepare an address in data memory for a 64 bit data double word
	addi x4, x0, 8         # 0x08 is base address in D-Mem
        # clear one register for communication with GPIO (data)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	# set x5 to 0x8007060504030201 (many different bytes for load byte from different positions)
	addi x5, x0, 0         # clear x5
	lui x7, 0x80070        # load upper 20 bit of a 32 bit word, 31:12
	slli x7, x7, 12        # upper 20 bits (shift left 12 bits), 43:24
	slli x7, x7, 12        # upper 20 bits (shift left 12 bits), 55:36
	slli x7, x7, 8         # upper 20 bits (shift left 8 bits),  63:44
	or x5, x5, x7          # ... to x5 (=0x8007_0000_0000_0000)
	addi x7, x0, 0         # clear x7
	lui x7, 0x60504        # load upper 20 bit of a 32 bit word, 31:12 (x7=0x0000_0000_6050_4000)
	slli x7, x7, 12        # next 20 bits (x7=0x0000_0605_0400_0000)
	or x5, x5, x7          # ... to x5 (x5=0x8007_0605_0400_0000)
	addi x7, x0, 0         # clear x7
	lui x7, 0x04030        # x7=0x0000_0000_0403_0000
	or x5, x5, x7          # x5=0x8007_0605_0403_0000
	addi x5, x5, 0x201     # last 12 bits, x5=0x8007_0605_0403_0201
	# store all to D-Mem
	sd x5, 16(x4)          # store to address 8+16=24 (64 bit wide)
	### 1st byte read
	lb x6, 24(x0)          # get 1 from address 24 (8 bits only), 1st byte in double word
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	# print
	sb   x10, 4(x2)        # write LSB of X10 to GPIO
        ### 2nd byte read
	lb x6, 25(x0)          # get 2 from address 25 (8 bits only), 2nd byte in double word
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	# print
	sb   x10, 4(x2)        # write LSB of X10 to GPIO
        ### 3rd byte read
	lb x6, 26(x0)          # get 3 from address 26 (8 bits only), 3rd byte in double word
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	# print
	sb   x10, 4(x2)        # write LSB of X10 to GPIO
        ### 4th byte read
	lb x6, 27(x0)          # get 4 from address 27 (8 bits only), 4th byte in double word
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	# print
	sb   x10, 4(x2)        # write LSB of X10 to GPIO
        ### 5th byte read
	lb x6, 28(x0)          # get 5 from address 28 (8 bits only), 5th byte in double word
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	# print
	sb   x10, 4(x2)        # write LSB of X10 to GPIO
        ### 6th byte read
	lb x6, 29(x0)          # get 6 from address 29 (8 bits only), 6th byte in double word
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	# print
	sb   x10, 4(x2)        # write LSB of X10 to GPIO
        ### 7th byte read
	lb x6, 30(x0)          # get 7 from address 30 (8 bits only), 7th byte in double word
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	# print
	sb   x10, 4(x2)        # write LSB of X10 to GPIO
        ### 8th byte read, check for sign extend
	lb x6, 31(x0)          # get 80 from address 31 (8 bits only), 8th byte in double word
	# prepare print
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	# print
	sb   x10, 4(x2)        # write LSB of X10 to GPIO 
	### done
        jal  x0, done          # jump to end
done:   beq  x2, x2, done      # 50 infinite loop

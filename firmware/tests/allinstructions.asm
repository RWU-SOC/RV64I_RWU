# RISC-V Assembly              Description
.global _start

_start: addi x2, x0, 5         # 00 x2 = 5
        addi x3, x0, 12        # 04 x3 = 12
	addi x4, x0, 8         # 08 base address
	addi x28, x0, 0x100    # load GPIO base address
	slli x28, x28, 8       # load GPIO base address
	# add                  (GPIO = 17)
        add  x5, x2, x3        # 0C x5 = (5 + 12) = 17, Instr. of interest
        sd   x5, 8(x4)         # 10 [16] = 17, (x11)
        ld   x6, 8(x4)        # 14 x6 = [16] = 17
	addi x10, x6, 0        # mov x10, x6 - functions argument
	jal  x1, print         # jump to function
	#sw   x2, 0x104(x0)
	# sub                  (GPIO = 7)
	sub  x5, x3, x2        # = 7
	addi x10, x5, 0        # mov x10, x5 - functions argument
	jal x1, print
	# lb - test 01         (GPIO = 5, 05h), sign extention: MSB=0
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 1280     # value to be stored in memory, a 5 to second byte (0500h)
	sd x5, 16(x4)          # store 500h to address 24 (64 bit wide)
	lb x6, 25(x0)          # get 5 from address 25 (8 bits only)
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	jal x1, print
	# lb - test 01a        (GPIO = 5, 05h), sign extention: MSB=1
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 133      # value to be stored in memory, a 85h to lowest byte (85h)
	slli x5, x5, 8         # shift first byte to second byte
	sd x5, 16(x4)          # store 500h to address 24 (64 bit wide)
	lb x6, 25(x0)          # get 5 from address 25 (8 bits only)
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	jal x1, print
	# lh - test 02         (GPIO = 255, 00FFh)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 255      # value to be stored in memory, a 255 to first byte
	 #addi x7, x0, 128       # generate a 1 at MSB for sign extention test
	 #slli x7, x7, 8         # shift the 1 to MSB of half word
	 #add x5, x5, x7         # result must be 80FFh at lowest half word
	slli x5, x5, 16        # shift first byte to second half word
	sd x5, 16(x4)          # store 255<<16 to address 24 (64 bit wide)
	lh x6, 26(x0)          # get 255 from address 26 (16 bits only)
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	jal x1, print
	# lw - test 03         (GPIO = 254, 000000FEh)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 254      # value to be stored in memory, a 254 to first byte
	slli x5, x5, 16        # shift first byte to the second word 1
	slli x5, x5, 16        # shift first byte to the second word 2
	sd x5, 16(x4)          # store 254<<32 to address 24 (64 bit wide)
	lw x6, 28(x0)          # get 254 from address 28 (upper 32 bits only)
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	jal x1, print
	# lbu - test 04        (GPIO = 253, 000000FDh)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 253      # value to be stored in memory, a 253 to first byte (MSB=1, but it must be zero ext.)
	sd x5, 16(x4)          # store 253 to address 24 (X4 = 8) (64 bit wide)
	lbu x6, 24(x0)         # get 253 from address 24 (lower 8 bits only)
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	jal x1, print
	# lhu - test 05        (GPIO = 252, 000000FCh)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 252      # value to be stored in memory, a 252 to first byte (MSB=1, but it must be zero ext.)
	sd x5, 16(x4)          # store 252 to address 24 (64 bit wide)
	lhu x6, 24(x0)         # get 252 from address 24 (lower 16 bits only)
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	jal x1, print
	# addi - test 06       (GPIO = 251, 000000FBh)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 250      # value to be stored in memory
	addi x5, x5, 1         # x5 = 250 + 1
	sd x5, 16(x4)          # store 251 to address 24 (64 bit wide)
	ld x6, 24(x0)          # get 252 from address 24
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	jal x1, print
	# slli - test 07       (GPIO = 250, 000000FAh)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 125      # value to be stored in memory before shift
	slli x5, x5, 1         # 125 << 2 = 250
	sd x5, 16(x4)          # store 251 to address 24 (64 bit wide)
	ld x6, 24(x0)          # get 252 from address 24
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	jal x1, print
	# slti - test 08       (GPIO = 249, 000000F9h)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , -2       # comparison value
	slti x5, x5, -1        # x5 = (-2 < -1) true
	addi x5, x5, 248       # generate the required 249
	sd x5, 16(x4)          # store 251 to address 24 (64 bit wide)
	ld x6, 24(x0)          # get 252 from address 24
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	jal x1, print
	# sltiu - test 09      (GPIO = 248, 000000F8h)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 125      # comparison value
	sltiu x5, x5, 126      # x5 = (125 < 126) true
	addi x5, x5, 247       # generate the required 249
	sd x5, 16(x4)          # store 251 to address 24 (64 bit wide)
	ld x6, 24(x0)          # get 252 from address 24
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	jal x1, print
	# xori - test 10       (GPIO = 247, 000000F7h = 1111_0111)
	addi x2, x0, 170       # 1010_1010 - 170
	addi x3, x0, 93        # 0101_1101 - 93
	xori x5, x2, 93        # 1111_0111
	addi x10, x5, 0        # mov x10, x5 - functions argument
	jal x1, print
	# srli - test 11       (GPIO = 246, 000000F6h = 1111_0110)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 492      # value to be stored in memory before shift
	srli x5, x5, 1         # 492 >> 2 = 246
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# srai - test12        (GPIO = 245, 000000F5h = 1111_0101)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 490      # value to be stored in memory before shift
	srai x5, x5, 1         # 490 >> 2 = 245
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# ori - test13         (GPIO = 244, 000000F4h = 1111_0100)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x2, x0, 0         # 0000_0000
	addi x3, x0, 244       # 1111_0100
	ori x5, x2, 244        # 1111_0100
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# andi - test14        (GPIO = 243, 000000F3h = 1111_0011)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x2, x0, 255       # 1111_1111
	addi x3, x0, 243       # 1111_0011
	andi x5, x2, 243       # 1111_0011
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# auipc - test15       (GPIO = 188, 000000bch = 1011_1100)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x2, x0, 255       # 1111_1111 - not needed
	addi x3, x0, 243       # 1111_0011 - not needed
	auipc x5, 0            # PC=1bc (=444) -> 1bc = 2^8+188
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# sb - test16          (GPIO = 242, 000000F2h = 1111_0010)
	addi x2, x0, 242       # load x2 with 242
	addi x3, x0, 0         # load x3 with 0
	sd x3, 8(x4)           # erase dmem location 16 (complete row)
	sb x2, 9(x4)           # store byte at location 17 (2nd byte in row)
	lb x5, 9(x4)           # load the byte to register x5
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
        # sh - test17          (GPIO = 241, 000000F1h = 1111_0001)
	addi x2, x0, 241       # load x2 with 241
	addi x3, x0, 0         # load x3 with 0
	sd x3, 8(x4)           # erase dmem location 16 (complete row)
	sh x2, 10(x4)          # store byte at location 18 (3rd byte in row)
	lh x5, 10(x4)          # load the byte to register x5
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# sw - test18          (GPIO = 240, 000000F0h = 1111_0000)
	addi x2, x0, 240       # load x2 with 240
	addi x3, x0, 0         # load x3 with 0
	sd x3, 8(x4)           # erase dmem location 16 (complete row)
	sh x2, 12(x4)          # store byte at location 20 (5th byte in row)
	lh x5, 12(x4)          # load the byte to register x5
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# sll - test 19        (GPIO = 238, 00000EEh = 1110_1110)
        addi x10, x0, 0        # erase x10 (register written to GPIO)
        addi x2, x0, 119       # 119*2=238
	addi x3, x0, 1         # shift 1 = *2
	sll x5, x2, x3         # 119 << 1 = 238
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# slt - test 20        (GPIO = 239, 000000EFh = 1110_1111)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x2, x0, 12        # 12
	addi x3, x0, 13        # 13
	slt x5, x2, x3         # x5 = (12 < 13) true
	addi x5, x5, 238       # generate the required 239
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# sltu - test 21       (GPIO = 237, 000000EDh = 1110_1101)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x2, x0, 12        # 12
	addi x3, x0, 13        # 13
	sltu x5, x2, x3        # x5 = (12 < 13) true
	addi x5, x5, 236       # generate the required 237
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# xor - test 22        (GPIO = 236, 000000ECh = 1110_1100)
	addi x2, x0, 0xff      # 1111_1111
	addi x3, x0, 0x13      # 0001_0011
	xor x5, x2, x3         # 1110_1100
	addi x10, x5, 0        # mov x10, x5 - functions argument
	jal x1, print
	# srl - test 23        (GPIO = 235, 000000EBh = 1110_1011)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x2, x0, 470       # 470/2=235
	addi x3, x0, 1         # 2^1=2	
	srl x5, x2, x3         # 470 >> 1 = 235
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# sra - test 24        (GPIO = 234, 000000EAh = 1110_1010)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
        addi x2, x0, 468       # 468/2=234
	addi x3, x0, 1         # 2^1=2		
	sra  x5, x2, x3        # 468 >> 2 = 234
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# lui - test 25        (GPIO = 233, 000000E9h = 1110_1001)
        lui x5, 233            # x5=E9_000
	srli x5, x5, 12        # remove the 12 lower bits
	addi x10, x5, 0        # mov x10, x5 - functions argument
	jal x1, print
	# beq - test 26        (GPIO = 232, 000000E8h = 1110_1000)
	addi x2, x0, 12        # 
	addi x3, x0, 12        # 
        beq x2, x3, beqtar     # jump to beqtar(get)
beqret:	jal x1, print
	# bne - test 27        (GPIO = 231, 000000E7h = 1110_0111)
	addi x2, x0, 12        # 
	addi x3, x0, 13        # 
        bne x2, x3, bnetar     # jump to bnetar(get)
bneret:	jal x1, print
	# blt - test 28        (GPIO = 230, 000000E6h = 1110_0110)
	addi x2, x0, -3        # 
	addi x3, x0, -2        # 
        blt x2, x3, blttar     # jump to blttar(get)
bltret:	jal x1, print
	# bge - test 29        (GPIO = 229, 000000E5h = 1110_0101)
	addi x2, x0, -1        # 
	addi x3, x0, -2        # 
        bge x2, x3, bgetar     # jump to bgetar(get)
bgeret:	jal x1, print

	# bltu - test 30       (GPIO = 228, 000000E4h = 1110_0100)
	addi x2, x0, 2         # 
	addi x3, x0, 3         # 
        bltu x2, x3, bltutar   # jump to bltutar(get)
blturet: jal x1, print
	# bgeu - test 31       (GPIO = 227, 000000E3h = 1110_0011)
	addi x2, x0, 3         # 
	addi x3, x0, 2         # 
        bgeu x2, x3, bgeutar   # jump to bgeutar(get)
bgeuret: jal x1, print

        # lwu - test 32        (GPIO = 226, 000000E2h = 1110_0010)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 226      # value to be stored in memory, a 226 to first byte (MSB=1, but it must be zero ext.)
	sd x5, 16(x4)          # store 226 to address 24 (64 bit wide)
	lwu x6, 24(x0)         # get 226 from address 24 (lower 16 bits only)
	addi x10, x6, 0        # mov x10, x6 - functions argument -> GPIO
	jal x1, print
	# addiw - test 33      (GPIO = 225, 000000E1h = 1110_0001)
	addi x2, x0, 0         # 0000
	addi x3, x0, 10        # 1010
        addiw x5, x2, 225      # 1110_0001
	addi x10, x5, 0        # mov x10, x5 - functions argument
	jal x1, print
	# slliw - test 34      (GPIO = 224, 000000E0h = 1110_0000)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0, 112       # value to be stored in memory before shift
	slliw x5, x5, 1        # 112 << 2 = 224
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# srliw - test 35      (GPIO = 223, 000000DFh = 1101_1111)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 446      # value to be stored in memory before shift
	srliw x5, x5, 1        # 446 >> 2 = 223
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print
	# sraiw - test 36      (GPIO = 222, 000000DEh = 1101_1110)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x5, x0 , 444      # value to be stored in memory before shift
	sraiw x5, x5, 1        # 444 >> 2 = 222
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print

	# addw - test 37       (GPIO = 221, 000000DDh = 1101_1101)
	addi x10, x0, 0        # erase x10 (register written to GPIO)
	addi x2, x0, 0x100
	ld   x3, 0(x2)
	sb   x3, 4(x2)
	addi x5, x0, 220       # source 1
	addi x6, x0, 1         # source 2
	addw x5, x5, x6        # 220 + 1 = 221
	addi x10, x5, 0        # mov x10, x5 - functions argument -> GPIO
	jal x1, print

	
	
	# or                   (GPIO = 14)
	addi x2, x0, 12        # 1100
	addi x3, x0, 10        # 1010
	or   x5, x2, x3        # 1110 - 14, (xE)
	addi x10, x5, 0        # mov x10, x5 - functions argument
	jal x1, print
	# and                  (GPIO = 8)
	addi x2, x0, 12        # 1100
	addi x3, x0, 10        # 1010
	and  x5, x2, x3        # 1000 - 8
	addi x10, x5, 0        # mov x10, x5 - functions argument
	jal x1, print
	jal  x0, done          # jump to end
print:	sw   x10, 0x4(x28)     # write to GPIO
	jalr x0, x1, 0
beqtar: addi x10, x0, 232      # set x10 here as a proof for the jump
	beq x2, x3, beqret
bnetar: addi x10, x0, 231      # set x10 here as a proof for the jump
	bne x2, x3, bneret
blttar: addi x10, x0, 230      # set x10 here as a proof for the jump
	blt x2, x3, bltret
bgetar: addi x10, x0, 229      # set x10 here as a proof for the jump
	bge x2, x3, bgeret
bltutar: addi x10, x0, 228      # set x10 here as a proof for the jump
	bltu x2, x3, blturet
bgeutar: addi x10, x0, 227      # set x10 here as a proof for the jump
	bgeu x2, x3, bgeuret
done:   beq  x2, x2, done      # 50 infinite loop

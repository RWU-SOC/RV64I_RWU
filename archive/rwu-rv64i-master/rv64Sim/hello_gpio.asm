        # ------------------------------------------------------------
        #   hello_gpio.asm  –  write 0x55 to GPIO address 0x010004
        #   (assumes 0x010000 is GPIO base, addr 4 is data byte lane)
        # ------------------------------------------------------------
        .global _start

_start: addi  x2, x0, 0x100      # x2 = 0x0100
        slli  x2, x2, 8          # x2 = 0x010000  (GPIO base)

        addi  x10, x0, 0x55      # x10 = 0x55 (0101_0101)

        sb    x10, 4(x2)         # store byte to GPIO+4 → checker prints

done:   beq  x2, x2, done      # 50 infinite loop


/* crt0.s -- minimal RISC-V startup
 *
 * Behavior:
 *  - Set sp = __stack_top (from linker)
 *  - Set gp = __global_pointer$ (GP for small-data; harmless if unused)
 *  - Zero .bss region [__bss_start, __bss_end)
 *  - Jump to main()
 *
 * NOTE: This startup intentionally does NOT copy .data from IMEM to DMEM.
 *       Programs must not rely on writable initialized globals unless the
 *       linker + crt0 are changed to perform the copy.
 */

    .section .init
    .option norvc
    .global _start
    .type   _start,@function

_start:
    /* Load stack pointer from linker symbol __stack_top */
    la      sp, __stack_top
    /* Align stack to 16 bytes just in case */
    andi    sp, sp, -16

    /* Zero .bss from __bss_start to __bss_end, 8-bytes at a time */
    la      t0, __bss_start  /* t0 -> start */
    la      t1, __bss_end    /* t1 -> end */
1:
    beq     t0, t1, 2f
    sd      x0, 0(t0)
    addi    t0, t0, 8
    blt     t0, t1, 1b
2:

    /* Call main() */
    call    main

halt:
    /* If main returns, hang here forever */
    j       halt

    .size _start, .-_start

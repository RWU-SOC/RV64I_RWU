OUTPUT_ARCH(riscv)
ENTRY(_start)

IMEM_ORIGIN = 0x00000000;
IMEM_SIZE   = 32K;

DMEM_ORIGIN = 0x00000000;
DMEM_SIZE   = 8K;

/* Memory regions */
MEMORY
{
  IMEM (rx) : ORIGIN = IMEM_ORIGIN, LENGTH = IMEM_SIZE
  DMEM (rw) : ORIGIN = DMEM_ORIGIN, LENGTH = DMEM_SIZE
}

/* Convenience symbols */
PROVIDE(_dmem_origin = ORIGIN(DMEM));
PROVIDE(_dmem_size   = LENGTH(DMEM));

SECTIONS
{
    /* Put text/rodata in IMEM (LMA=VMA=IMEM) */
    . = ORIGIN(IMEM);
    .text : {
        PROVIDE(_text_start = .);
        *(.text*)
        *(.rodata*)
        *(.srodata*)
        PROVIDE(_text_end = .);
    } > IMEM

    /* Put bss at start of DMEM (NOLOAD) */
    . = ORIGIN(DMEM);
    .bss (NOLOAD) : {
        PROVIDE(__bss_start = .);
        *(.sbss*)
        *(.bss*)
        *(COMMON)
        PROVIDE(__bss_end = .);
    } > DMEM

    /* Stack top at end of DMEM */
    PROVIDE(__stack_top = ORIGIN(DMEM) + LENGTH(DMEM));

    /* User DMEM start is immediately after .bss (no reserved gap) */
    PROVIDE(_user_dmem_start = __bss_end);

    /* Discard sections not needed */
    /DISCARD/ : { *(.eh_frame) *(.comment) }
}

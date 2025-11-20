#ifndef RWU_RV64I_H
#define RWU_RV64I_H

/* RWU-RV64I platform header (write-only GPIO support)
 *
 * Key differences for this variant:
 *  - GPIO is write-only in the hardware. Firmware MUST NOT rely on reads.
 *  - This header keeps a software latch (__rwu_gpio_lat) in RAM for
 *    deterministic toggles / set/clear operations.
 *
 * Keep DMEM/IMEM constants in sync with linker.ld and your RTL.
 */

#include <stdint.h>
#include <stddef.h>

/* ----------------- Memory map (tweak if your RTL differs) ---------------- */

#define IMEM_BASE       0x00000000UL
#define IMEM_SIZE       (32 * 1024UL)

#define DMEM_BASE       0x00000000UL
#define DMEM_SIZE       (8 * 1024UL)



/* ----------------- GPIO mapping (must match RTL/TB) --------------------- */
#define GPIO_BASE       0x00010000UL   /* keep in sync with RTL */
#define GPIO_OUT_OFFSET 4              /* TB expects writes at +4 */

/* direct MMIO write location */
#define GPIO_REG_OUT (*(volatile uint8_t *)(GPIO_BASE + GPIO_OUT_OFFSET))

/* ----------------- Linker symbols (provided by linker.ld) ---------------- */
extern char __bss_start[];     /* start of .bss in DMEM */
extern char __bss_end[];       /* end of .bss in DMEM */
extern char __stack_top[];     /* top of stack (end of DMEM) */
extern uint64_t _user_dmem_start[];/* start of user DMEM region (DMEM_BASE + DMEM_RESERVE) */

/* ----------------- DMEM writer (same as before) ------------------------- */

/* TU-local pointer (one per translation unit). It is fine for multiple TUs
   to have their own pointer; they will all point to the same linker-provided
   _user_dmem_start address. */

//GPIO print
static inline void rwu_print(uint8_t value)
{
	GPIO_REG_OUT = value;
}

static volatile uint64_t *__rwu_dmem_next;

static inline void rwu_dmem_reset(void){
	__rwu_dmem_next = _user_dmem_start;
}
/* Store 64-bit value at next slot and advance */
static inline void rwu_store64(uint64_t v)
{
    *__rwu_dmem_next ++ = v;

}


#endif /* RWU_RV64I_H */

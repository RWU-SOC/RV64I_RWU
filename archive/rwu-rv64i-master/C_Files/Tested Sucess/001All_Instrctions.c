#include "rwu-rv64i.h"

int main(void) {
    rwu_dmem_reset();                  // start logging at _user_dmem_start (e.g. 0x100)

    // Pointers for typed, absolute-offset memory tests (SB/SH/SW/SD/LD)
    volatile uint8_t  *b8  = (volatile uint8_t  *)&_user_dmem_start;
    volatile uint16_t *b16 = (volatile uint16_t *)&_user_dmem_start;
    volatile uint32_t *b32 = (volatile uint32_t *)&_user_dmem_start;
    volatile uint64_t *b64 = (volatile uint64_t *)&_user_dmem_start;

    int a = 5, b = 10, c = 0;
    int aw = 0;

    // -------------------
    // U-type
    // -------------------
    {
        // LUI (modeled by placing an immediate constant)
        uint64_t lui_val = 0xDEADB000ULL;
        rwu_store64(lui_val);                 rwu_print(233);

        // AUIPC: take current code label address and add 0x1000
        uint64_t pc_here = (uint64_t)&&auipc_label;
        pc_here += 0x1000ULL;
        rwu_store64(pc_here);                 rwu_print(196);
    auipc_label: ;
    }

    // -------------------
    // I-type
    // -------------------
    c = a + 12;                    rwu_store64(c); rwu_print(251);   // ADDI
    c = a << 2;                    rwu_store64(c); rwu_print(250);   // SLLI
    c = (a < 20) ? 1 : 0;          rwu_store64(c); rwu_print(249);   // SLTI
    c = ((uint32_t)a < (uint32_t)b) ? 1 : 0;
                                   rwu_store64(c); rwu_print(248);   // SLTIU
    c = a ^ 0xF;                   rwu_store64(c); rwu_print(247);   // XORI
    c = ((uint32_t)a) >> 1;        rwu_store64(c); rwu_print(246);   // SRLI
    c = a >> 1;                    rwu_store64(c); rwu_print(245);   // SRAI
    c = a | 0xF0;                  rwu_store64(c); rwu_print(244);   // ORI
    c = a & 0xF0;                  rwu_store64(c); rwu_print(243);   // ANDI

    // -------------------
    // Stores at absolute byte offsets from _user_dmem_start
    // -------------------
    b8 [64]  = 0x42;               rwu_print(242);                   // SB   @ base+64
    b16[66]  = 0xBEEF;             rwu_print(241);                   // SH   @ base+132
    b32[68]  = 0x12345678;         rwu_print(240);                   // SW   @ base+272

    // SD / LD at an absolute 64-bit slot index
    b64[70]  = 0xCAFEBABEDEADBEEFULL;                                // SD   @ base+(70*8)
    c = (int)b64[70];             /* LD (lower 32 bits into int)   */
    rwu_store64((uint64_t)c);      rwu_print(17);                    // log value

    // -------------------
    // R-type + load variants
    // -------------------
    c = b - a;                      rwu_store64(c); rwu_print(7);    // SUB

    b8[80] = 0x05;                  c = (int8_t)b8[80];
                                    rwu_store64(c); rwu_print(5);    // LB (msb=0)
    b8[81] = 0x85;                  c = (int8_t)b8[81];
                                    rwu_store64(c); rwu_print(133);  // LB (msb=1)

    b16[82] = 0xFFFF;               c = (int16_t)b16[82];
                                    rwu_store64(c); rwu_print(255);  // LH (sign-extend)

    b32[84] = 0xDEADBEEF;           c = (int32_t)b32[84];
                                    rwu_store64(c); rwu_print(254);  // LW (sign-extend to 64 via int)

    b8[86] = 0xFF;                  c = (uint8_t)b8[86];
                                    rwu_store64(c); rwu_print(253);  // LBU

    b16[87] = 0xFFFF;               c = (uint16_t)b16[87];
                                    rwu_store64(c); rwu_print(252);  // LHU

    // -------------------
    // More R-type
    // -------------------
    c = a << 1;                     rwu_store64(c); rwu_print(238);  // SLL
    c = (a < b) ? 1 : 0;            rwu_store64(c); rwu_print(239);  // SLT
    c = ((uint32_t)a < (uint32_t)b) ? 1 : 0;
                                    rwu_store64(c); rwu_print(237);  // SLTU
    c = a ^ b;                      rwu_store64(c); rwu_print(236);  // XOR
    c = ((uint32_t)b) >> 2;         rwu_store64(c); rwu_print(235);  // SRL
    c = b >> 2;                     rwu_store64(c); rwu_print(234);  // SRA

    // -------------------
    // Branches (log 1 on true)
    // -------------------
    rwu_store64((a == 5) ? 1 : 0);  rwu_print(232);                  // BEQ
    rwu_store64((a != b) ? 1 : 0);  rwu_print(231);                  // BNE
    rwu_store64((a <  b) ? 1 : 0);  rwu_print(230);                  // BLT
    rwu_store64((b >= a) ? 1 : 0);  rwu_print(229);                  // BGE
    rwu_store64(((uint32_t)a <  (uint32_t)b) ? 1 : 0); rwu_print(228); // BLTU
    rwu_store64(((uint32_t)b >= (uint32_t)a) ? 1 : 0); rwu_print(227); // BGEU

    // -------------------
    // 64-bit + word ops
    // -------------------
    b32[20] = 0xABCDEF12;          /* store a 32-bit value */
    c = (uint32_t)b32[20];          rwu_store64(c); rwu_print(226);  // LWU behavior (zero-extend via uint32_t)

    aw = (int32_t)a + 1;            rwu_store64(aw); rwu_print(225); // ADDIW
    aw = (int32_t)a << 1;           rwu_store64(aw); rwu_print(224); // SLLIW
    aw = ((uint32_t)a) >> 1;        rwu_store64(aw); rwu_print(223); // SRLIW
    aw = ((int32_t)a) >> 1;         rwu_store64(aw); rwu_print(222); // SRAIW
    aw = (int32_t)a + (int32_t)b;   rwu_store64(aw); rwu_print(221); // ADDW

    // OR / AND
    c = a | b;                      rwu_store64(c); rwu_print(14);
    c = a & b;                      rwu_store64(c); rwu_print(8);

    while (1);
}


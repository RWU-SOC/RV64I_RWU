============================================
Chapter 6: Memory Maps and Register Lists
============================================

History / Revision / Change Management
======================================

.. list-table:: Chapter 6 Revision History
   :widths: 10 10 15 20 15 30
   :header-rows: 1

   * - Version
     - Previous Version
     - Author
     - Date
     - Changed Paragraphs
     - Description of Changes
   * - 1.0
     - -
     - Mohamed
     - 2025-11-05
     - All
     - Initial memory map and register definitions draft

Memory Map Overview
===================

*To be defined: System-level memory map and address space allocation strategy.*

System Memory Map
-----------------

.. list-table:: System Memory Map (Example Structure)
   :widths: 30 20 50
   :header-rows: 1

   * - Address Range
     - Size
     - Description
   * - 0x0000_0000 - 0x0000_FFFF
     - TBD
     - Instruction Memory
   * - 0x0001_0000 - 0x0001_FFFF
     - TBD
     - Data Memory
   * - 0x1000_0000 - 0x1FFF_FFFF
     - TBD
     - Peripheral Address Space
   * - 0x8000_0000 - 0xFFFF_FFFF
     - TBD
     - External Memory Interface

Boot Memory
-----------

*To be defined: Boot memory size, organization, and access characteristics.*

Instruction Memory
------------------

*To be defined: Instruction memory configuration and timing.*

Data Memory
-----------

*To be defined: Data memory configuration and access patterns.*

Peripheral Address Space
-------------------------

*To be defined: Peripheral register mapping and access methods.*

Control and Status Registers (CSRs)
====================================

Machine-Mode CSRs
-----------------

*Standard RISC-V CSRs as defined in the RISC-V Privileged Architecture Specification.*

Machine Information Registers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: Machine Information Registers
   :widths: 20 15 15 50
   :header-rows: 1

   * - CSR Name
     - Address
     - Access
     - Description
   * - mvendorid
     - 0xF11
     - RO
     - Vendor ID (to be assigned)
   * - marchid
     - 0xF12
     - RO
     - Architecture ID (to be assigned)
   * - mimpid
     - 0xF13
     - RO
     - Implementation ID (to be assigned)
   * - mhartid
     - 0xF14
     - RO
     - Hardware thread ID

Machine Trap Setup
~~~~~~~~~~~~~~~~~~

.. list-table:: Machine Trap Setup Registers
   :widths: 20 15 15 50
   :header-rows: 1

   * - CSR Name
     - Address
     - Access
     - Description
   * - mstatus
     - 0x300
     - RW
     - Machine status register
   * - misa
     - 0x301
     - RW
     - ISA and extensions
   * - medeleg
     - 0x302
     - RW
     - Machine exception delegation
   * - mideleg
     - 0x303
     - RW
     - Machine interrupt delegation
   * - mie
     - 0x304
     - RW
     - Machine interrupt enable
   * - mtvec
     - 0x305
     - RW
     - Machine trap-handler base address

Machine Trap Handling
~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: Machine Trap Handling Registers
   :widths: 20 15 15 50
   :header-rows: 1

   * - CSR Name
     - Address
     - Access
     - Description
   * - mscratch
     - 0x340
     - RW
     - Machine scratch register
   * - mepc
     - 0x341
     - RW
     - Machine exception program counter
   * - mcause
     - 0x342
     - RW
     - Machine trap cause
   * - mtval
     - 0x343
     - RW
     - Machine bad address or instruction
   * - mip
     - 0x344
     - RW
     - Machine interrupt pending

Physical Memory Protection
~~~~~~~~~~~~~~~~~~~~~~~~~~

*To be defined: PMP configuration and address registers per RISC-V specification.*

Counter/Timers
~~~~~~~~~~~~~~

*To be defined: Machine counter/timer registers (mcycle, minstret, etc.).*

Debug/Trace Registers
~~~~~~~~~~~~~~~~~~~~~

*To be defined: Debug CSRs per RISC-V Debug Specification.*

Detailed CSR Descriptions
==========================

*To be defined: Detailed bit-level descriptions of key CSRs.*

mstatus - Machine Status Register
----------------------------------

*To be defined: MIE, MPIE, MPP fields and their functions.*

mie - Machine Interrupt Enable
-------------------------------

*To be defined: Interrupt enable bits for external and software interrupts.*

mtvec - Machine Trap Vector
----------------------------

*To be defined: Trap vector base address and mode (Direct/Vectored).*

mepc - Machine Exception PC
----------------------------

*To be defined: Exception program counter storage and behavior.*

mcause - Machine Cause Register
--------------------------------

*To be defined: Interrupt and exception code encoding.*

PMP Configuration Registers
----------------------------

*To be defined: Physical memory protection configuration format and access control.*

Debug Registers
===============

*To be defined: Debug module register map and functionality.*

Performance Counters
====================

*To be defined: Performance monitoring counter configuration and usage.*

Register Reset Values
======================

*To be defined: Reset values for all CSRs and system registers.*

Summary
=======

*To be defined: Summary of memory map organization and register access patterns.*

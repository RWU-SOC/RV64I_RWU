==============================
Chapter 1: Document Overview
==============================

History / Revision / Change Management
======================================

.. list-table:: Document Revision History
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
     - Initial specification document created
   * - 0.9
     - -
     - Mohamed
     - 2025-10-28
     - 1-4
     - Draft version for review
   * - 0.5
     - -
     - Mohamed
     - 2025-10-15
     - 1-2
     - Initial outline and structure

Glossary
========

.. glossary::

   ABI
      Application Binary Interface - defines the low-level interface between the application and the operating system or hardware

   ALU
      Arithmetic Logic Unit - performs arithmetic and logical operations

   CSR
      Control and Status Register - special registers for processor configuration and status

   CFSM
      Communicating Finite State Machines

   CPI
      Cycles Per Instruction - average number of clock cycles per instruction

   CPS
      Cyber-Physical Systems

   Debug Module
      Hardware component providing debugging capabilities (breakpoints, single-step, etc.)

   DMI
      Debug Module Interface

   DMA
      Direct Memory Access - allows hardware subsystems to access memory independently of the CPU

   DRAM
      Dynamic Random Access Memory

   DTM
      Debug Transport Module

   ECC
      Error Correction Code

   ES
      Embedded Systems

   Exception
      Synchronous interrupt caused by instruction execution (e.g., illegal instruction, page fault)

   FSM
      Finite State Machine

   GPIO
      General Purpose Input/Output

   Hart
      Hardware Thread - RISC-V term for an execution context (CPU core or hardware thread)

   IEEE
      Institute of Electrical and Electronics Engineers

   Interrupt
      Asynchronous event requiring processor attention

   IoT
      Internet of Things

   ISA
      Instruction Set Architecture - defines the processor's instruction set and register architecture

   JTAG
      Joint Test Action Group - standard for testing and debugging integrated circuits

   MMU
      Memory Management Unit - handles virtual to physical address translation

   MoC
      Model of Computation

   PLIC
      Platform-Level Interrupt Controller

   PMP
      Physical Memory Protection - access control mechanism in RISC-V

   Privilege Levels
      RISC-V defines Machine (M), Supervisor (S), and User (U) privilege modes

   RISC
      Reduced Instruction Set Computer

   RV32
      RISC-V 32-bit base integer instruction set

   RV64
      RISC-V 64-bit base integer instruction set

   SoC
      System on Chip

   SRAM
      Static Random Access Memory

   TLB
      Translation Lookaside Buffer - cache for virtual-to-physical address translations

   UART
      Universal Asynchronous Receiver/Transmitter

   VHDL
      VHSIC Hardware Description Language

   Wishbone
      Open-source hardware bus standard for connecting IP cores in SoC designs

Naming Conventions
==================

Signal Naming
-------------

The following naming conventions are used throughout this specification:

**Clock and Reset Signals:**

- ``clk`` - Clock signal
- ``rst_n`` - Active-low reset signal
- ``arst_n`` - Active-low asynchronous reset
- ``srst`` - Synchronous reset

**Bus Signals:**

- ``*_valid`` - Valid signal for handshaking
- ``*_ready`` - Ready signal for handshaking
- ``*_addr`` - Address signals
- ``*_data`` - Data signals
- ``*_we`` - Write enable
- ``*_re`` - Read enable
- ``*_strb`` - Byte strobe/write strobe

**Active-Low Signals:**

All active-low signals are suffixed with ``_n``

**Multi-bit Signals:**

Multi-bit signals use the notation ``signal[MSB:LSB]``, e.g., ``data[63:0]``

Register Naming
---------------

- **CSRs** - Named according to RISC-V specification (e.g., ``mstatus``, ``mtvec``, ``mepc``)
- **Implementation-specific registers** - Prefixed with ``rv64_``

Abbreviations
-------------

Throughout this document, the following abbreviations are used:

- **RV64I** - RISC-V 64-bit base integer instruction set
- **RV64IM** - RV64I + Integer multiplication and division (M extension)
- **RV64IMA** - RV64IM + Atomic instructions (A extension)
- **RV64IMAC** - RV64IMA + Compressed instructions (C extension)
- **RV64GC** - RV64IMAFDC (General purpose + Compressed)
- **Hart** - Hardware thread
- **PC** - Program Counter
- **GPR** - General Purpose Register
- **XLEN** - Register width in bits (64 for RV64)

Privilege Mode Abbreviations
-----------------------------

- **M-mode** - Machine mode (highest privilege)
- **S-mode** - Supervisor mode
- **U-mode** - User mode (lowest privilege)

Document List
=============

The following documents are referenced and should be consulted alongside this specification:

.. list-table:: Referenced Documents
   :widths: 30 25 15 30
   :header-rows: 1

   * - Document Title
     - Document Number
     - Version
     - Description
   * - The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA
     - 
     - v20191213
     - RISC-V base instruction set and standard extensions
   * - The RISC-V Instruction Set Manual, Volume II: Privileged Architecture
     - 
     - v20211203
     - RISC-V privilege levels, CSRs, exceptions, and interrupts
   * - RISC-V External Debug Support
     - 
     - v0.13.2
     - Debug module specification
   * - Digital Design and Computer Architecture, RISC-V Edition
     - 
     - 1st Edition
     - System design and single-cycle processor architecture
   * - Wishbone Bus Specification
     - 
     - Rev B.4
     - Open-source bus interconnect standard
   * - IEEE Standard for VHDL
     - IEEE 1076-2019
     - 2019
     - VHDL language reference
   * - IEEE Standard for SystemVerilog
     - IEEE 1800-2017
     - 2017
     - SystemVerilog language reference
   * - JEDEC Standard: DDR4 SDRAM
     - JESD79-4
     - -
     - DDR4 memory interface specification

Internal Documents
------------------

.. list-table:: Internal Project Documents
   :widths: 40 60
   :header-rows: 1

   * - Document Title
     - Description
   * - RV64 Core Microarchitecture Document
     - Detailed microarchitecture implementation
   * - RV64 Core Verification Plan
     - Test plan and verification strategy
   * - RV64 Core Design Verification Report
     - Verification results and coverage reports
   * - RV64 Core Synthesis Report
     - Synthesis results, timing, and area reports
   * - RV64 Core User Manual
     - End-user documentation and programming guide

List of Figures
===============

.. list-table:: Figures in this Document
   :widths: 10 70 20
   :header-rows: 1

   * - Figure No.
     - Title
     - Page
   * - 2.1
     - RV64 Processor System Overview
     - Chapter 2
   * - 2.2
     - RV64 Core Block Diagram
     - Chapter 2
   * - 2.3
     - System Integration Example
     - Chapter 2
   * - 3.1
     - Memory Map Overview
     - Chapter 3
   * - 3.2
     - Interrupt Architecture
     - Chapter 3
   * - 3.3
     - Clock Tree Architecture
     - Chapter 3
   * - 4.1
     - Instruction Fetch Unit
     - Chapter 4
   * - 4.2
     - Instruction Decode Pipeline
     - Chapter 4
   * - 4.3
     - Execution Unit Architecture
     - Chapter 4
   * - 4.4
     - Load/Store Unit
     - Chapter 4
   * - 4.5
     - CSR Unit Block Diagram
     - Chapter 4

List of Tables
==============

.. list-table:: Tables in this Document
   :widths: 10 70 20
   :header-rows: 1

   * - Table No.
     - Title
     - Page
   * - 1.1
     - Document Revision History
     - Chapter 1
   * - 1.2
     - Referenced Documents
     - Chapter 1
   * - 2.1
     - Key Features Summary
     - Chapter 2
   * - 2.2
     - Pin List
     - Chapter 2
   * - 3.1
     - Supported RISC-V Extensions
     - Chapter 3
   * - 3.2
     - Interrupt Sources
     - Chapter 3
   * - 3.3
     - Clock Domains
     - Chapter 3
   * - 6.1
     - Memory Map
     - Chapter 6
   * - 6.2
     - CSR Register List
     - Chapter 6
   * - 7.1
     - Absolute Maximum Ratings
     - Chapter 7
   * - 7.2
     - Operating Conditions
     - Chapter 7
   * - 7.3
     - DC Characteristics
     - Chapter 7
   * - 7.4
     - AC Timing Characteristics
     - Chapter 7

Table of Contents Overview
===========================

This specification is organized into the following chapters:

**Chapter 1: Document Overview (this chapter)**
   Provides document history, glossary, naming conventions, and lists of figures and tables.

**Chapter 2: Product Overview**
   High-level overview of the RV64 processor core, including key features, system integration, and architecture concepts.

**Chapter 3: Architecture Concepts**
   Detailed description of architectural concepts including bus architecture, interrupt handling, clock system, and memory management.

**Chapter 4: Description of Design Elements**
   Detailed description of all functional blocks including instruction fetch, decode, execution, load/store, and CSR units.

**Chapter 5: Test and Debug**
   Test strategy, debug features, and JTAG interface description.

**Chapter 6: Memory Maps and Register Lists**
   Complete memory map and detailed CSR register descriptions.

**Chapter 7: Electrical Characteristics**
   Physical and electrical specifications including timing, power, and signal characteristics.

**References**
   Bibliography and cited literature.

Document Purpose
================

This document serves as the complete implementation specification for a RISC-V 64-bit processor core. It is intended for:

1. **Hardware Engineers** - To understand the architecture and implement the design
2. **Verification Engineers** - To develop comprehensive test plans and verification environments
3. **Software Engineers** - To understand the processor's capabilities and programming model
4. **System Integrators** - To integrate the core into larger SoC designs
5. **Project Management** - As a reference for project scope and requirements

The specification follows industry-standard practices and adheres to the RISC-V ISA specification while defining implementation-specific details necessary for a complete processor design.

Scope of this Specification
============================

**In Scope:**

- 64-bit RISC-V processor core architecture
- Support for RV64I base integer instruction set
- M extension (Integer Multiplication and Division)
- A extension (Atomic Instructions)
- C extension (Compressed Instructions)
- Privilege modes: Machine (M-mode) and User (U-mode)
- CSR (Control and Status Registers) implementation
- Exception and interrupt handling
- Debug module interface
- Memory-mapped bus interface (based on Harris & Harris architecture)
- Physical memory protection (PMP)

**Out of Scope:**

- Pipelined execution (single-cycle implementation only)
- Floating-point extensions (F, D)
- Supervisor mode (S-mode) implementation
- Virtual memory management (MMU/TLB)
- Cache coherency protocols
- Specific SoC integration details beyond the processor core
- Software/firmware implementation
- Operating system support

Future Revisions
================

This specification may be updated in future revisions to include:

- Performance optimization details
- Additional RISC-V extensions
- Enhanced debug capabilities
- Power management features
- Supervisor mode support
- Virtual memory support

All changes will be documented in the revision history table at the beginning of this chapter.

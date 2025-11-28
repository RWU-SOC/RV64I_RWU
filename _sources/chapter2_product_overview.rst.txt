============================
Chapter 2: Product Overview
============================

History / Revision / Change Management
======================================

.. list-table:: Chapter 2 Revision History
   :widths: 10 10 15 20 15 30
   :header-rows: 1

   * - Version
     - Previous Version
     - Author
     - Date
     - Changed Paragraphs
     - Description of Changes
   * - 1.0
     - 0.9
     - Mohamed
     - 2025-11-05
     - All
     - Final version with complete product overview
   * - 0.9
     - -
     - Mohamed
     - 2025-10-28
     - 2.1-2.3
     - Added system view and architecture concepts

Top Level View
==============

Introduction
------------

The RV64 Core is a 64-bit RISC-V processor implementation designed for embedded systems, IoT applications, and general-purpose computing. This processor core implements the RISC-V open-source instruction set architecture (ISA), providing a modern, scalable, and extensible processing solution.

The RV64 Core is designed with the following principles:

**Simplicity and Elegance**
   The RISC-V ISA philosophy emphasizes simplicity, enabling efficient implementation while maintaining high performance. The RV64 Core follows this philosophy with a clean, modular architecture.

**Modularity**
   The design is highly modular, allowing for easy customization and extension. Each functional unit is well-defined with clear interfaces, facilitating reuse and verification.

**Industry Standard Compliance**
   Full compliance with the RISC-V ISA specification ensures software compatibility and ecosystem support. The core adheres to the RISC-V Foundation's architectural standards.

**Performance and Efficiency**
   Designed to achieve high performance while maintaining reasonable area and power characteristics. The implementation balances performance with resource efficiency.

The RV64 Core targets applications including:

- Embedded control systems
- IoT edge computing devices
- Real-time processing applications
- Educational and research platforms
- Custom SoC designs requiring a 64-bit processor core

This processor core provides a robust foundation for building complex cyber-physical systems (CPS) where hardware and software must work together seamlessly.

Key Features
------------

The RV64 Core implements the following key features:

.. list-table:: Key Features Summary
   :widths: 30 70
   :header-rows: 1

   * - Feature
     - Description
   * - **ISA Support**
     - RV64IMAC (64-bit base integer, multiplication/division, atomic, compressed)
   * - **Privilege Modes**
     - Machine (M-mode) and User (U-mode)
   * - **Architecture**
     - Single-cycle implementation (one instruction per clock cycle)
   * - **Performance**
     - CPI = 1.0 (one cycle per instruction), target operating frequency varies by technology
   * - **Data Path**
     - 64-bit data path with 64-bit registers
   * - **Register File**
     - 32 × 64-bit general purpose registers (x0-x31)
   * - **CSRs**
     - Full CSR implementation per RISC-V privileged spec
   * - **Interrupts**
     - Machine-mode external and software interrupts
   * - **Exceptions**
     - Full exception support: illegal instruction, misaligned access, breakpoint, etc.
   * - **PMP**
     - 8 Physical Memory Protection regions
   * - **Bus Interface**
     - Wishbone B.4 compliant bus interface for instruction and data memory (Harvard architecture)
   * - **Debug**
     - RISC-V Debug Module compatible with JTAG DTM
   * - **Reset**
     - Asynchronous reset with synchronous release
   * - **Technology**
     - Technology independent RTL, synthesizable to ASIC or FPGA
   * - **Verification**
     - UVM-based verification with RISC-V compliance tests

**Instruction Set Extensions:**

- **RV64I**: 64-bit base integer instruction set with 47 instructions
- **M Extension**: Integer multiplication (MUL, MULH, MULHU, MULHSU) and division (DIV, DIVU, REM, REMU)
- **A Extension**: Atomic memory operations (LR, SC, AMO*)
- **C Extension**: Compressed 16-bit instructions for improved code density

**Performance Characteristics:**

- Architecture: Single-cycle (one instruction completes per clock cycle)
- CPI: 1.0 (Cycles Per Instruction)
- Branch handling: Direct execution, no branch prediction needed
- Forwarding: Not required (single-cycle execution)
- Hazard detection: Not required (no pipeline hazards in single-cycle)
- Multiplication: Combinational (completes in single cycle)
- Division: Combinational or iterative (implementation-dependent)
- Memory access: Single-cycle access (synchronous memory interface)

Functional Block Diagram
-------------------------

The following diagram shows the high-level functional blocks of the RV64 single-cycle core:

.. graphviz::
   :caption: Figure 2.1: RV64 Single-Cycle Core Block Diagram
   :align: center

   digraph RV64_Core {
       graph [splines=ortho, nodesep=1.8, ranksep=1.8];
       rankdir=TB;
       node [shape=box, style="filled,rounded", fillcolor=lightblue, width=1.6, height=0.7, fixedsize=true, fontname="Arial"];
       edge [fontname="Arial", fontsize=11];
       
       // Define nodes with rank grouping
       {rank=same; DBG; JTAG;}
       {rank=same; IFU; CTRL;}
       {rank=same; DEC;}
       {rank=same; RF; CSR;}
       {rank=same; ALU; MUL; DIV;}
       {rank=same; MEM;}
       {rank=same; IBUS; DBUS;}
       
       IFU [label="Instruction\nFetch", fillcolor="#90EE90", width=1.4];
       DEC [label="Decoder", fillcolor="#90EE90", width=1.4];
       RF [label="Register File\n32x64-bit", fillcolor="#FFB6C1", width=1.5];
       ALU [label="ALU", fillcolor="#FFFFE0", width=1.3];
       MUL [label="Multiplier", fillcolor="#FFFFE0", width=1.3];
       DIV [label="Divider", fillcolor="#FFFFE0", width=1.3];
       MEM [label="Memory\nInterface", fillcolor="#E0FFFF", width=1.4];
       CSR [label="CSR Unit", fillcolor="#E0FFFF", width=1.3];
       CTRL [label="Control\nUnit", fillcolor="#D3D3D3", width=1.3];
       DBG [label="Debug", fillcolor="#FFA500", width=1.2];
       
       // Bus Interfaces
       IBUS [label="I-Wishbone", fillcolor="#F5DEB3", width=1.5];
       DBUS [label="D-Wishbone", fillcolor="#F5DEB3", width=1.5];
       JTAG [label="JTAG", fillcolor="#FFD700", width=1.1];
       
       // Main datapath (emphasized)
       IFU -> DEC [label="  instr  ", penwidth=2.5, color="#2E8B57"];
       DEC -> RF [label="  addr  ", penwidth=2];
       
       RF -> ALU [label="  a,b  "];
       RF -> MUL [label="  a,b  "];
       RF -> DIV [label="  a,b  "];
       
       ALU -> MEM [label="  res  "];
       MUL -> MEM [label="  res  "];
       DIV -> MEM [label="  res  "];
       
       MEM -> RF [label="  write  ", dir=back, penwidth=2.5, color="#2E8B57"];
       
       // Control paths (lighter)
       CTRL -> DEC [style=dashed, color="#808080"];
       CSR -> CTRL [style=dashed, label=" trap ", color="#DC143C", penwidth=1.5];
       DEC -> CSR [style=dotted, label=" csr ", color="#9370DB"];
       
       // Bus connections (emphasized)
       IFU -> IBUS [label="  req  ", penwidth=2];
       MEM -> DBUS [label="  req  ", penwidth=2];
       
       // Debug
       JTAG -> DBG [penwidth=1.5];
       DBG -> CTRL [style=dashed, label=" halt ", color="#4169E1"];
   }

The RV64 Core consists of the following major functional blocks:

**Instruction Fetch Unit (IFU)**
   Fetches instructions from memory via the Wishbone instruction bus. Maintains the program counter (PC) and handles branch/jump target calculation. In single-cycle operation, instruction fetch completes within one clock cycle.

**Decoder**
   Decodes fetched instructions and generates control signals for all execution units. Handles instruction expansion for compressed (16-bit) instructions. Generates register file read addresses and control signals for ALU, multiplier, divider, and memory operations.

**ALU (Arithmetic Logic Unit)**
   Performs arithmetic and logical operations combinationally. Executes all computational instructions and calculates branch conditions within a single clock cycle.

**Multiplier**
   Combinational multiplier unit for integer multiplication operations (M extension). Completes multiplication in a single cycle.

**Divider**
   Integer division unit (M extension). May be implemented as combinational or iterative depending on area/timing trade-offs.

**Memory Interface**
   Handles all memory access operations including loads, stores, and atomic memory operations. Interfaces with the Wishbone data bus and implements address generation and alignment checking.

**Register File (RF)**
   32 general-purpose 64-bit registers (x0-x31) with x0 hardwired to zero. Supports two read ports and one write port. All register operations complete within a single clock cycle.

**Control and Status Register Unit (CSR)**
   Implements all required machine-mode CSRs per the RISC-V privileged specification. Handles exception and interrupt processing, privilege level management, and performance counters.

**Control Unit**
   Central pipeline control logic that manages hazards, stalls, flushes, and pipeline progression. Coordinates between all functional units and handles exception processing.

**Debug Module**
   Provides debug support including breakpoints, single-step execution, and register access. Interfaces with external debugger via JTAG.

Package
-------

The RV64 Core is delivered as synthesizable RTL (Register Transfer Level) code, not as a physical packaged device. The core can be integrated into various ASIC or FPGA implementations.

**Deliverable Format:**

- RTL source code (VHDL or SystemVerilog)
- Synthesis scripts for common tools
- Testbench and verification environment
- Documentation (this specification)

**Target Technologies:**

- ASIC: Technology independent, synthesizable to 28nm and below
- FPGA: Xilinx Virtex, Kintex, Artix families; Intel Cyclone, Arria, Stratix families

When integrated into an ASIC, the typical package options would include:

- QFP (Quad Flat Pack): For lower pin-count implementations
- BGA (Ball Grid Array): For higher pin-count and better thermal performance
- LGA (Land Grid Array): For high-reliability applications

The specific package selection depends on the complete SoC design and application requirements.

System View
===========

Application System Description and Use Cases
---------------------------------------------

The RV64 Core is designed for integration into various system architectures. The following use cases illustrate typical applications:

**Use Case 1: Embedded Control System**

An industrial control system requires a 64-bit processor for complex control algorithms while interfacing with various sensors and actuators.

*Requirements:*
   - Real-time interrupt handling
   - Deterministic execution timing
   - Serial communication interface (UART)
   - GPIO for sensor/actuator control

*Solution:*
   The RV64 Core provides machine-mode interrupts with low latency, deterministic single-cycle behavior, and can be integrated with peripheral controllers (UART, GPIO) on the system bus.

**Use Case 2: IoT Edge Computing Device**

An IoT gateway device processes sensor data locally before transmitting to the cloud, requiring both computational power and low power consumption.

*Requirements:*
   - Sufficient performance for signal processing
   - Low power operation
   - Secure boot and execution
   - Wireless communication support

*Solution:*
   RV64 Core's efficient instruction set and physical memory protection provide performance and security. Integration with low-power peripherals enables efficient IoT applications.

**Use Case 3: Educational Platform**

A university research platform for teaching computer architecture and embedded systems.

*Requirements:*
   - Clear, understandable architecture
   - Full debug support
   - Open-source ISA
   - Extensibility for research

*Solution:*
   RISC-V's open nature and the RV64 Core's modular design make it ideal for education. Debug support enables students to understand program execution in detail.

**Use Case 4: Custom SoC Component**

Integration as a processor core in a larger application-specific SoC with custom accelerators.

*Requirements:*
   - Standard bus interface
   - Configurable memory map
   - Interrupt support for accelerators
   - Efficient context switching

*Solution:*
   Memory-mapped Wishbone bus interface enables easy integration. CSR-based configuration and efficient exception handling support heterogeneous computing.

System Description
------------------

A complete system incorporating the RV64 Core typically includes the following components:

.. graphviz::
   :caption: Figure 2.2: RV64 Processor System Overview
   :align: center

   digraph System_Overview {
       graph [splines=ortho, nodesep=1.8, ranksep=2.0];
       rankdir=TB;
       node [shape=box, style="filled,rounded", fontname="Arial", width=1.5, height=0.65, fixedsize=true];
       edge [fontname="Arial", fontsize=11];
       
       // Rank grouping for better layout
       {rank=same; JTAG;}
       {rank=same; CORE; PLIC;}
       {rank=same; BUS;}
       {rank=same; IMEM; DMEM;}
       {rank=same; UART; GPIO;}
       {rank=same; EXT;}
       
       // Core
       CORE [label="RV64\nCore", fillcolor="#87CEEB", width=2.2, height=0.8, fontsize=13];
       
       // Memory subsystem
       subgraph cluster_mem {
           label="Memory Subsystem";
           style="filled,rounded";
           fillcolor="#F5F5F5";
           color="#606060";
           fontname="Arial Bold";
           margin=20;
           
           IMEM [label="Instruction\nMemory", fillcolor="#FFFFE0", width=1.4];
           DMEM [label="Data\nMemory", fillcolor="#FFFFE0", width=1.4];
       }
       
       // Bus infrastructure
       BUS [label="Wishbone Interconnect", fillcolor="#F5DEB3", shape=box, width=3.0, height=0.9, fontsize=12];
       
       // Peripherals
       subgraph cluster_periph {
           label="Peripherals";
           style="filled,rounded";
           fillcolor="#F0FFF0";
           color="#606060";
           fontname="Arial Bold";
           margin=20;
           
           UART [label="UART", fillcolor="#90EE90", width=1.2];
           GPIO [label="GPIO", fillcolor="#90EE90", width=1.2];
       }
       
       // Interrupt controller
       PLIC [label="Interrupt\nController", fillcolor="#FFA500", width=1.5, height=0.7];
       
       // Debug
       JTAG [label="JTAG Debug", fillcolor="#FFB6C1", width=1.4];
       
       // External
       EXT [label="External I/O", fillcolor="#E0FFFF", width=1.5];
       
       // Main connections (emphasized)
       CORE -> BUS [label="  I/D  ", dir=both, penwidth=3, color="#2E8B57"];
       BUS -> IMEM [dir=both, penwidth=2];
       BUS -> DMEM [dir=both, penwidth=2];
       BUS -> UART [dir=both, penwidth=1.5];
       BUS -> GPIO [dir=both, penwidth=1.5];
       
       // Interrupt connections
       PLIC -> CORE [label="  IRQ  ", color="#DC143C", penwidth=2];
       UART -> PLIC [style=dashed, color="#696969", label=" int "];
       GPIO -> PLIC [style=dashed, color="#696969", label=" int "];
       
       // Debug connection
       JTAG -> CORE [label="  debug  ", color="#4169E1", penwidth=1.5];
       
       // External connections
       UART -> EXT [dir=both, label=" TX/RX ", penwidth=1.5];
       GPIO -> EXT [dir=both, label=" pins ", penwidth=1.5];
   }

**System Components:**

1. **RV64 Core**: The central processing unit
2. **Memory Subsystem**: Instruction memory and data memory
3. **Bus Interconnect**: Bus fabric connecting the core to memory and peripherals
4. **Interrupt Controller**: Aggregates and prioritizes interrupt sources
5. **Peripherals**: UART and GPIO for external connectivity
6. **Debug Interface**: JTAG-based debugging support

System Integration and Application Circuit
-------------------------------------------

The RV64 Core integrates into a larger system through its memory-mapped bus interfaces. A typical integration scenario is shown below:

.. graphviz::
   :caption: Figure 2.3: System Integration Example
   :align: center

   digraph Integration {
       graph [splines=ortho, nodesep=2.0, ranksep=3.0];
       rankdir=LR;
       node [shape=box, style="filled,rounded", fontname="Arial", width=1.6, height=0.7, fixedsize=true];
       edge [fontname="Arial", fontsize=11];
       
       // RV64 Core with interfaces
       subgraph cluster_core {
           label="RV64 Core";
           style="filled,rounded";
           fillcolor="#E0F0FF";
           color="#4682B4";
           fontname="Arial Bold";
           penwidth=2;
           margin=25;
           
           CORE [label="Core\nLogic", fillcolor="#90EE90", width=1.4];
           IFACE [label="Wishbone\nInterface", fillcolor="#F5DEB3", width=1.4];
           JTAG_IF [label="JTAG", fillcolor="#FFA500", width=1.1];
           CLK_IF [label="Clock/\nReset", fillcolor="#FFB6C1", width=1.4];
       }
       
       // External connections
       MEM [label="External\nMemory", fillcolor="#FFFFE0", width=1.6];
       PERIPH [label="Peripheral\nBus", fillcolor="#D3D3D3", width=1.6];
       DEBUG [label="Debug\nProbe", fillcolor="#FFA500", width=1.4];
       CLK_GEN [label="Clock\nGenerator", fillcolor="#FFB6C1", width=1.6];
       
       // Connections with better spacing and emphasis
       IFACE -> MEM [dir=both, label="   WB   ", penwidth=2.5, color="#2E8B57"];
       IFACE -> PERIPH [dir=both, label="   WB   ", penwidth=2.5, color="#2E8B57"];
       JTAG_IF -> DEBUG [label="  JTAG  ", color="#4169E1", penwidth=2];
       CLK_IF -> CLK_GEN [label=" clk/rst ", penwidth=2];
       
       CORE -> IFACE [style=bold, penwidth=2];
       CORE -> JTAG_IF [style=bold, penwidth=2];
       CORE -> CLK_IF [style=bold, penwidth=2];
   }

**Integration Considerations:**

- **Clock Domain**: Core operates in a single clock domain; clock domain crossing must be handled externally
- **Reset Strategy**: Asynchronous assert, synchronous de-assert reset recommended
- **Bus Arbitration**: Wishbone interconnect must handle arbitration for multiple masters
- **Memory Map**: Flexible memory mapping configured via interconnect
- **Interrupt Routing**: External interrupt controller aggregates peripheral interrupts

Compliances
-----------

The RV64 Core complies with the following standards and specifications:

.. list-table:: Standards Compliance
   :widths: 40 60
   :header-rows: 1

   * - Standard
     - Description
   * - RISC-V ISA Specification v20191213
     - RV64I base integer instruction set
   * - RISC-V Privileged Specification v20211203
     - Machine and User privilege modes
   * - RISC-V "M" Extension
     - Integer multiplication and division
   * - RISC-V "A" Extension
     - Atomic instructions
   * - RISC-V "C" Extension
     - Compressed instructions
   * - RISC-V Debug Specification v0.13.2
     - Debug module implementation
   * - AMBA AXI4 Specification (ARM IHI 0022E)
     - Bus interface protocol
   * - IEEE 1500 (JTAG)
     - Test access port for debug

The core passes the official RISC-V compliance test suite for RV64IMAC, ensuring compatibility with the RISC-V ecosystem.

Architecture Concepts Overview
===============================

Technology
----------

**RTL Implementation:**

The RV64 Core is implemented in synthesizable RTL (Register Transfer Level) code, providing:

- Technology independence
- Portability across ASIC and FPGA platforms
- Clear separation between functional description and physical implementation

**Target Technologies:**

*ASIC Implementation:*
   - Process nodes: 28nm and below
   - Voltage: 0.9V - 1.2V depending on process
   - Estimated gate count: ~50K-70K gates (without cache)
   - Estimated frequency: 500MHz-1.2GHz depending on process and libraries

*FPGA Implementation:*
   - Xilinx 7-series and beyond
   - Intel Cyclone V and beyond
   - Estimated LUTs: ~15K-25K
   - Estimated frequency: 100MHz-250MHz depending on device and optimization

**Design Methodology:**

- Synchronous design with single clock domain
- Fully synthesizable RTL (no behavioral constructs)
- Linting and CDC (Clock Domain Crossing) clean
- Static timing analysis (STA) constraints provided

System Memory Concept
----------------------

The RV64 Core implements a Harvard architecture with separate instruction and data buses, allowing simultaneous instruction fetch and data access.

**Memory Architecture:**

- **Address Space**: 64-bit physical address space (implementation typically uses subset)
- **Instruction Memory**: Accessed via dedicated AXI4 master interface
- **Data Memory**: Accessed via dedicated AXI4 master interface
- **Unified View**: Software sees unified memory map despite separate physical buses

**Memory Access Characteristics:**

- **Alignment**: Natural alignment required for optimal performance
- **Atomics**: Atomic operations supported via LR/SC and AMO instructions
- **Ordering**: Weak memory ordering model per RISC-V specification
- **Protection**: Physical Memory Protection (PMP) with 8 regions

**Typical Memory Map** (example, configurable):

- 0x0000_0000 - 0x0000_FFFF: Instruction RAM (64 KB)
- 0x0001_0000 - 0x0001_FFFF: Data RAM (64 KB)
- 0x1000_0000 - 0x1FFF_FFFF: Peripheral space (256 MB)
- 0x8000_0000 - 0xFFFF_FFFF: External memory

Physical Memory Protection (PMP) allows configuring access permissions (R/W/X) for up to 8 memory regions in machine mode, enabling protection of critical system areas from user-mode code.

Software Architecture
----------------------

**Privilege Levels:**

The RV64 Core implements two privilege levels:

1. **Machine Mode (M-mode)**: Highest privilege level
   
   - Full access to all hardware resources
   - Handles exceptions and interrupts
   - Manages lower privilege levels
   - Typical use: firmware, bootloader, embedded OS kernel

2. **User Mode (U-mode)**: Lowest privilege level
   
   - Restricted access to hardware
   - Cannot directly access CSRs or protected memory
   - Typical use: application code

**Software Stack:**

.. graphviz::
   :align: center

   digraph Software_Stack {
       graph [splines=ortho, nodesep=0.5, ranksep=0.7];
       rankdir=TB;
       node [shape=box, style="filled,rounded", fontname="Arial", width=3.0, height=0.6, fixedsize=true];
       edge [fontname="Arial"];
       
       APP [label="User Applications", fillcolor="#90EE90"];
       LIB [label="Libraries & Runtime", fillcolor="#FFFFE0"];
       FW [label="Firmware / Monitor", fillcolor="#87CEEB"];
       HW [label="RV64 Core Hardware", fillcolor="#D3D3D3"];
       
       APP -> LIB;
       LIB -> FW;
       FW -> HW;
       
       APP_NOTE [label="U-mode", shape=plaintext, width=1.0];
       FW_NOTE [label="M-mode", shape=plaintext, width=1.0];
       
       {rank=same; APP; APP_NOTE}
       {rank=same; FW; FW_NOTE}
       
       APP_NOTE -> APP [style=dashed, color=gray];
       FW_NOTE -> FW [style=dashed, color=gray];
   }

**ABI Support:**

The core supports the RISC-V LP64 ABI (Application Binary Interface):

- 64-bit pointers and long integers
- Standard calling convention
- Compatible with GCC and LLVM toolchains

**Toolchain Compatibility:**

- GNU GCC RISC-V toolchain
- LLVM/Clang RISC-V backend  
- Standard C/C++ libraries (newlib, glibc)
- Debugging: GDB with OpenOCD

Interprocessor Communication Concept
-------------------------------------

While the RV64 Core is a single-core processor, systems may include multiple cores or other processors. Communication mechanisms include:

**Shared Memory:**

- Multiple cores can access common memory regions via the AXI4 interconnect
- Requires cache coherency protocol (not included in base core)
- Software-based synchronization using atomic instructions

**Memory-Mapped Communication:**

- Dedicated memory regions for inter-processor mailboxes
- Interrupt-driven notification mechanism
- Typical implementation: write to mailbox triggers interrupt to target processor

**Atomic Operations:**

- A extension provides LR/SC (Load-Reserved/Store-Conditional)
- AMO (Atomic Memory Operations) for atomic read-modify-write
- Enables lock-free data structures and synchronization primitives

**Example: Semaphore Implementation:**

Atomic instructions enable efficient semaphore operations:

.. code-block:: asm

   # Acquire semaphore at address a0
   acquire:
       li      t0, 1
   retry:
       amoswap.w.aq t1, t0, (a0)  # Atomic swap with acquire semantics
       bnez    t1, retry           # Retry if already locked
       ret

   # Release semaphore at address a0  
   release:
       amoswap.w.rl zero, zero, (a0)  # Atomic store with release semantics
       ret

Functional Block Overview
==========================

The RV64 Core consists of the following major functional blocks:

**1. Instruction Fetch Unit (IFU)**
   
   Fetches instructions from memory and maintains the program counter. Supports branch prediction and handles control flow changes.

**2. Instruction Decode Unit (IDU)**
   
   Decodes instructions, expands compressed instructions, and generates control signals. Reads register operands and detects pipeline hazards.

**3. Execution Unit (EXU)**
   
   Performs arithmetic, logical, and comparison operations. Includes ALU, multiplier, and divider sub-units.

**4. Load/Store Unit (LSU)**
   
   Handles memory access operations including loads, stores, and atomic memory operations. Performs address calculation and alignment checking.

**5. Control and Status Register Unit (CSR)**
   
   Manages system state through CSRs. Handles exceptions, interrupts, and privilege level transitions.

**6. Register File**
   
   32 general-purpose 64-bit registers with dual read ports and single write port.

**7. Pipeline Control**
   
   Manages pipeline flow, hazard detection, forwarding, and flush operations.

**8. Debug Module**
   
   Provides debugging capabilities including breakpoints, single-step, and register access.

**9. Bus Interface Units**
   
   AXI4 master interfaces for instruction and data memory access.

Detailed descriptions of each block are provided in Chapter 4.

Pin List
========

The RV64 Core interface signals are organized into the following groups:

Clock and Reset
---------------

.. list-table::
   :widths: 20 10 10 60
   :header-rows: 1

   * - Signal Name
     - Direction
     - Width
     - Description
   * - clk
     - Input
     - 1
     - System clock
   * - rst_n
     - Input
     - 1
     - Asynchronous reset, active low

AXI4 Instruction Bus (Master)
------------------------------

.. list-table::
   :widths: 20 10 10 60
   :header-rows: 1

   * - Signal Name
     - Direction
     - Width
     - Description
   * - **Address Read Channel**
     -
     -
     -
   * - i_axi_araddr
     - Output
     - 64
     - Read address
   * - i_axi_arvalid
     - Output
     - 1
     - Read address valid
   * - i_axi_arready
     - Input
     - 1
     - Read address ready
   * - i_axi_arid
     - Output
     - 4
     - Read address ID
   * - i_axi_arlen
     - Output
     - 8
     - Burst length
   * - i_axi_arsize
     - Output
     - 3
     - Burst size
   * - i_axi_arburst
     - Output
     - 2
     - Burst type
   * - **Read Data Channel**
     -
     -
     -
   * - i_axi_rdata
     - Input
     - 64
     - Read data
   * - i_axi_rvalid
     - Input
     - 1
     - Read data valid
   * - i_axi_rready
     - Output
     - 1
     - Read data ready
   * - i_axi_rid
     - Input
     - 4
     - Read data ID
   * - i_axi_rresp
     - Input
     - 2
     - Read response
   * - i_axi_rlast
     - Input
     - 1
     - Read last

AXI4 Data Bus (Master)
----------------------

.. list-table::
   :widths: 20 10 10 60
   :header-rows: 1

   * - Signal Name
     - Direction
     - Width
     - Description
   * - **Address Write Channel**
     -
     -
     -
   * - d_axi_awaddr
     - Output
     - 64
     - Write address
   * - d_axi_awvalid
     - Output
     - 1
     - Write address valid
   * - d_axi_awready
     - Input
     - 1
     - Write address ready
   * - d_axi_awid
     - Output
     - 4
     - Write address ID
   * - d_axi_awlen
     - Output
     - 8
     - Burst length
   * - d_axi_awsize
     - Output
     - 3
     - Burst size
   * - d_axi_awburst
     - Output
     - 2
     - Burst type
   * - **Write Data Channel**
     -
     -
     -
   * - d_axi_wdata
     - Output
     - 64
     - Write data
   * - d_axi_wvalid
     - Output
     - 1
     - Write data valid
   * - d_axi_wready
     - Input
     - 1
     - Write data ready
   * - d_axi_wstrb
     - Output
     - 8
     - Write strobes
   * - d_axi_wlast
     - Output
     - 1
     - Write last
   * - **Write Response Channel**
     -
     -
     -
   * - d_axi_bvalid
     - Input
     - 1
     - Write response valid
   * - d_axi_bready
     - Output
     - 1
     - Write response ready
   * - d_axi_bid
     - Input
     - 4
     - Response ID
   * - d_axi_bresp
     - Input
     - 2
     - Write response
   * - **Address Read Channel**
     -
     -
     -
   * - d_axi_araddr
     - Output
     - 64
     - Read address
   * - d_axi_arvalid
     - Output
     - 1
     - Read address valid
   * - d_axi_arready
     - Input
     - 1
     - Read address ready
   * - d_axi_arid
     - Output
     - 4
     - Read address ID
   * - d_axi_arlen
     - Output
     - 8
     - Burst length
   * - d_axi_arsize
     - Output
     - 3
     - Burst size
   * - d_axi_arburst
     - Output
     - 2
     - Burst type
   * - **Read Data Channel**
     -
     -
     -
   * - d_axi_rdata
     - Input
     - 64
     - Read data
   * - d_axi_rvalid
     - Input
     - 1
     - Read data valid
   * - d_axi_rready
     - Output
     - 1
     - Read data ready
   * - d_axi_rid
     - Input
     - 4
     - Read data ID
   * - d_axi_rresp
     - Input
     - 2
     - Read response
   * - d_axi_rlast
     - Input
     - 1
     - Read last

Interrupt Interface
-------------------

.. list-table::
   :widths: 20 10 10 60
   :header-rows: 1

   * - Signal Name
     - Direction
     - Width
     - Description
   * - m_external_int
     - Input
     - 1
     - Machine-mode external interrupt
   * - m_timer_int
     - Input
     - 1
     - Machine-mode timer interrupt
   * - m_software_int
     - Input
     - 1
     - Machine-mode software interrupt

Debug Interface (JTAG)
----------------------

.. list-table::
   :widths: 20 10 10 60
   :header-rows: 1

   * - Signal Name
     - Direction
     - Width
     - Description
   * - jtag_tck
     - Input
     - 1
     - JTAG test clock
   * - jtag_tms
     - Input
     - 1
     - JTAG test mode select
   * - jtag_tdi
     - Input
     - 1
     - JTAG test data input
   * - jtag_tdo
     - Output
     - 1
     - JTAG test data output
   * - jtag_trst_n
     - Input
     - 1
     - JTAG test reset, active low

**Total Pin Count:** Approximately 350 signals (including all AXI4 signals)

The AXI4 interfaces follow the ARM AMBA AXI4 protocol specification. All signals use positive-edge triggered logic synchronized to the system clock except for asynchronous reset and JTAG (which has its own clock domain).

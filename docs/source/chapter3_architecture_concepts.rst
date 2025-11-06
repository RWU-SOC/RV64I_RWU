===================================
Chapter 3: Architecture Concepts
===================================

History / Revision / Change Management
======================================

.. list-table:: Chapter 3 Revision History
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
     - Final version with complete architecture concepts
   * - 0.9
     - -
     - Mohamed
     - 2025-10-30
     - 3.1-3.5
     - Added bus, interrupt, and clock concepts

Bus Concept
===========

Overview
--------

The RV64 Core uses the Wishbone B.4 bus specification, an open-source hardware bus standard widely used in open-source SoC designs. Wishbone provides a simple, well-documented interface for connecting IP cores with standard handshaking signals and flexible data transfer options.

The core implements two independent Wishbone master interfaces:

1. **Instruction Bus (I-WB)**: Dedicated to instruction fetch operations
2. **Data Bus (D-WB)**: Dedicated to data load/store operations

This Harvard architecture allows simultaneous instruction fetch and data access, improving overall system performance.

Wishbone Protocol Features
---------------------------

The RV64 Core's Wishbone implementation supports the following features:

.. list-table:: Wishbone Protocol Support
   :widths: 30 70
   :header-rows: 1

   * - Feature
     - Description
   * - **Wishbone Revision**
     - B.4 compliant
   * - **Interface Type**
     - Master interface (both instruction and data)
   * - **Address Width**
     - 64 bits (configurable, typically 32-40 bits used)
   * - **Data Width**
     - 64 bits (WISHBONE DATASIZE = 64)
   * - **Granularity**
     - 8-bit (byte-level granularity)
   * - **Transfer Types**
     - Classic single read/write cycles
   * - **Byte Select**
     - SEL_O[7:0] for byte-level write control
   * - **Cycle Types**
     - Standard single cycles (CTI_O = 000 for classic cycles)
   * - **Burst Support**
     - Optional incrementing bursts (CTI_O signals)
   * - **Error Handling**
     - ERR_I signal for bus errors
   * - **Retry Support**
     - RTY_I signal for retry requests
   * - **Endianness**
     - Little-endian (RISC-V standard)

Bus Architecture
----------------

The bus architecture showing the RV64 Core's Wishbone interfaces and their connection to system components:

.. graphviz::
   :caption: Figure 3.1: Wishbone Bus Architecture
   :align: center

   digraph Bus_Architecture {
       graph [splines=ortho, nodesep=2.0, ranksep=3.0];
       rankdir=LR;
       node [shape=box, style="filled,rounded", fontname="Arial", width=1.5, height=0.7, fixedsize=true];
       edge [fontname="Arial", fontsize=11];
       
       // Rank grouping for horizontal alignment
       {rank=same; IFU; MEM;}
       {rank=same; IWB; DWB;}
       {rank=same; INTERCONNECT;}
       {rank=same; IMEM; DMEM; PERIPH; EXT;}
       
       // RV64 Core
       subgraph cluster_core {
           label="RV64 Core";
           style="filled,rounded";
           fillcolor="#E0F0FF";
           color="#4682B4";
           fontname="Arial Bold";
           penwidth=2;
           margin=25;
           
           IFU [label="Instruction\nFetch", fillcolor="#90EE90", width=1.4];
           MEM [label="Memory\nInterface", fillcolor="#90EE90", width=1.4];
       }
       
       // Wishbone Interfaces
       IWB [label="I-WB\nMaster", fillcolor="#F5DEB3", width=1.3];
       DWB [label="D-WB\nMaster", fillcolor="#F5DEB3", width=1.3];
       
       // Interconnect
       INTERCONNECT [label="Wishbone\nInterconnect", fillcolor="#FFA500", width=2.5, height=1.0, fontsize=12];
       
       // Memory slaves
       IMEM [label="Instruction\nMemory", fillcolor="#FFFFE0", width=1.5];
       DMEM [label="Data\nMemory", fillcolor="#FFFFE0", width=1.5];
       PERIPH [label="Peripheral\nBus", fillcolor="#D3D3D3", width=1.5];
       EXT [label="External\nMemory", fillcolor="#E0FFFF", width=1.5];
       
       // Core to master (emphasized)
       IFU -> IWB [label="   req   ", penwidth=2.5, color="#2E8B57"];
       MEM -> DWB [label="   req   ", penwidth=2.5, color="#2E8B57"];
       
       // Master to interconnect (bold)
       IWB -> INTERCONNECT [dir=both, penwidth=3];
       DWB -> INTERCONNECT [dir=both, penwidth=3];
       
       // Interconnect to slaves
       INTERCONNECT -> IMEM [dir=both, label="  s0  ", penwidth=2];
       INTERCONNECT -> DMEM [dir=both, label="  s1  ", penwidth=2];
       INTERCONNECT -> PERIPH [dir=both, label="  s2  ", penwidth=2];
       INTERCONNECT -> EXT [dir=both, label="  s3  ", penwidth=2];
   }

Address Decoding
----------------

The Wishbone interconnect decodes addresses to route transactions to appropriate slave devices. A typical memory map (example):

.. list-table:: Memory Map and Address Decoding
   :widths: 25 25 25 25
   :header-rows: 1

   * - Address Range
     - Size
     - Device
     - Description
   * - 0x0000_0000 - 0x0000_FFFF
     - 64 KB
     - Instruction RAM
     - Instruction memory
   * - 0x0001_0000 - 0x0001_FFFF
     - 64 KB
     - Data RAM
     - Data memory
   * - 0x1000_0000 - 0x1000_0FFF
     - 4 KB
     - UART
     - Serial communication
   * - 0x1000_1000 - 0x1000_1FFF
     - 4 KB
     - GPIO
     - General purpose I/O
   * - 0x8000_0000 - 0xFFFF_FFFF
     - 2 GB
     - External Memory
     - DDR/external SDRAM

Bus Arbitration
---------------

When multiple AXI masters exist in the system (e.g., multiple cores or DMA controllers), the AXI interconnect performs arbitration:

**Arbitration Scheme:**

- **Round-robin**: Fair arbitration for equal priority masters
- **Priority-based**: Higher priority for critical masters
- **Quality of Service (QoS)**: AXI QoS signals can prioritize transactions

**RV64 Core's Bus Behavior:**

- Instruction fetches typically have higher priority than data accesses
- Atomic operations (LR/SC, AMO) require exclusive access
- Burst transactions improve bus utilization for sequential accesses

Transaction Ordering
--------------------

The RISC-V memory model specifies a weak memory ordering, allowing the processor and memory system to reorder transactions for performance. The RV64 Core implements:

**Ordering Rules:**

1. Same-address dependencies are preserved
2. Fence instructions enforce ordering when required
3. I/O device accesses use fence instructions for proper ordering
4. Atomic instructions have implicit acquire/release semantics

**Memory Barriers:**

- ``FENCE``: Orders memory operations before and after
- ``FENCE.I``: Synchronizes instruction and data streams
- Atomic operations with ``.aq`` and ``.rl`` modifiers

Bus Error Handling
------------------

The core handles bus errors reported via AXI4 response signals:

.. list-table:: AXI4 Response Handling
   :widths: 20 80
   :header-rows: 1

   * - Response
     - Handling
   * - OKAY
     - Normal successful completion
   * - EXOKAY
     - Exclusive access success (for atomic operations)
   * - SLVERR
     - Slave error - raises access fault exception
   * - DECERR
     - Decode error - raises access fault exception

**Exception Types:**

- **Instruction Access Fault**: Bus error during instruction fetch
- **Load Access Fault**: Bus error during load operation
- **Store/AMO Access Fault**: Bus error during store or atomic operation

These exceptions are reported to the CSR unit and handled by the machine-mode exception handler.

Interrupt and DMA Concept
==========================

Interrupt Architecture
----------------------

The RV64 Core implements the RISC-V standard interrupt architecture for machine mode. Interrupts are asynchronous events that redirect program execution to handle time-critical events.

.. graphviz::
   :caption: Figure 3.2: Interrupt Architecture
   :align: center

   digraph Interrupt_Arch {
       graph [splines=ortho, nodesep=2.5, ranksep=2.0];
       rankdir=TB;
       node [shape=box, style="filled,rounded", fontname="Arial", width=1.6, height=0.7, fixedsize=true];
       edge [fontname="Arial", fontsize=11];
       
       // Rank grouping for clean layout
       {rank=same; EXT_INT; SW_INT;}
       {rank=same; CSR; CTRL; PC;}
       
       // External sources
       EXT_INT [label="External\nInterrupt\nController", fillcolor="#FFA500", width=1.7];
       SW_INT [label="Software\nInterrupt", fillcolor="#90EE90", width=1.5];
       
       // Core components
       subgraph cluster_core {
           label="RV64 Core";
           style="filled,rounded";
           fillcolor="#E0F0FF";
           color="#4682B4";
           fontname="Arial Bold";
           penwidth=2;
           margin=25;
           
           CSR [label="CSR\nUnit", fillcolor="#E0FFFF", width=1.4];
           CTRL [label="Control\nUnit", fillcolor="#F5DEB3", width=1.4];
           PC [label="Program\nCounter", fillcolor="#FFB6C1", width=1.4];
       }
       
       // Interrupt signals (color-coded and emphasized)
       EXT_INT -> CSR [label="  ext_irq  ", color="#DC143C", penwidth=2.5];
       SW_INT -> CSR [label="  sw_irq  ", color="#228B22", penwidth=2.5];
       
       // Internal flow (emphasized)
       CSR -> CTRL [label="  pending  ", penwidth=2.5];
       CTRL -> PC [label="  trap  ", color="#4169E1", penwidth=2.5];
   }

Interrupt Sources
-----------------

The RV64 Core supports two standard machine-mode interrupt sources:

.. list-table:: Interrupt Sources
   :widths: 25 25 50
   :header-rows: 1

   * - Interrupt Type
     - Signal
     - Description
   * - Machine External Interrupt
     - m_external_int
     - Interrupt from external interrupt controller or peripherals (UART, GPIO)
   * - Machine Software Interrupt
     - m_software_int
     - Software-triggered interrupt for inter-processor communication

**Interrupt Priority** (from highest to lowest):

1. Machine External Interrupt (MEI)
2. Machine Software Interrupt (MSI)

When multiple interrupts are pending, the highest priority interrupt is taken first.

Interrupt Handling Flow
------------------------

The interrupt handling process follows these steps:

**1. Interrupt Detection:**

   - Interrupt signal asserted externally
   - CSR unit detects interrupt in ``mip`` (Machine Interrupt Pending) register
   - Checks if interrupt is enabled in ``mie`` (Machine Interrupt Enable) register
   - Checks global interrupt enable bit in ``mstatus.MIE``

**2. Interrupt Taken:**

   When an enabled interrupt is pending and interrupts are globally enabled:

   a. Current PC saved to ``mepc`` (Machine Exception PC)
   b. Interrupt cause written to ``mcause`` register
   c. ``mstatus.MPIE`` ← ``mstatus.MIE`` (save previous interrupt enable)
   d. ``mstatus.MIE`` ← 0 (disable interrupts)
   e. PC ← ``mtvec`` (Machine Trap Vector)

**3. Handler Execution:**

   - Software interrupt handler executes
   - Handler determines interrupt source from ``mcause``
   - Handler services the interrupt
   - Handler may clear interrupt source

**4. Return from Interrupt:**

   - Execute ``MRET`` instruction
   - PC ← ``mepc`` (return to interrupted code)
   - ``mstatus.MIE`` ← ``mstatus.MPIE`` (restore interrupt enable)
   - ``mstatus.MPIE`` ← 1

Interrupt Latency
-----------------

Interrupt latency is the time from interrupt assertion to first instruction of handler:

**Latency Components:**

1. **Detection**: 1 cycle (CSR monitors interrupt signals)
2. **Pipeline flush**: 0-5 cycles (depends on pipeline state)
3. **CSR updates**: 2 cycles (save state, update mstatus)
4. **Vector fetch**: 1-N cycles (depends on memory latency)

**Typical Latency**: 5-10 clock cycles for best case

**Worst Case**: May be longer if:

- Multi-cycle instruction in execute stage
- Memory operation in progress
- Higher priority interrupt already being processed

Interrupt Vector Table
----------------------

The ``mtvec`` CSR defines the interrupt/exception vector:

**Vectored Mode** (``mtvec[1:0] = 01``):

- Base address: ``mtvec[XLEN-1:2] << 2``
- Exception handler: Base address
- Interrupt handler: Base address + 4 × cause

**Direct Mode** (``mtvec[1:0] = 00``):

- All traps jump to base address
- Software determines cause from ``mcause``

DMA Concept
-----------

The RV64 Core does not include an integrated DMA controller. However, the system can include external DMA masters that share the AXI4 interconnect.

**DMA Integration:**

.. graphviz::
   :align: center

   digraph DMA_Integration {
       graph [splines=ortho, nodesep=0.8, ranksep=1.2];
       rankdir=LR;
       node [shape=box, style="filled,rounded", fontname="Arial", width=1.5, height=0.6, fixedsize=true];
       edge [fontname="Arial", fontsize=10];
       
       CPU [label="RV64 Core\n(AXI Master)", fillcolor="#87CEEB", width=1.6];
       DMA [label="DMA Controller\n(AXI Master)", fillcolor="#90EE90", width=1.8];
       INTERCONNECT [label="AXI4\nInterconnect", fillcolor="#FFA500", width=2.0, height=0.8];
       MEM [label="Memory", fillcolor="#FFFFE0", width=1.4];
       PERIPH [label="Peripherals", fillcolor="#D3D3D3", width=1.4];
       
       CPU -> INTERCONNECT [dir=both];
       DMA -> INTERCONNECT [dir=both];
       INTERCONNECT -> MEM [dir=both];
       INTERCONNECT -> PERIPH [dir=both];
       
       DMA -> CPU [label="interrupt", style=dashed, color=red];
   }

**DMA Operation:**

1. CPU configures DMA controller via memory-mapped registers
2. DMA controller initiates transfers on AXI bus
3. AXI interconnect arbitrates between CPU and DMA
4. DMA completes transfer and interrupts CPU
5. CPU handles completion in interrupt service routine

System Control Concept
=======================

The RV64 Core's system control is managed through Control and Status Registers (CSRs). These registers provide configuration, status monitoring, and exception/interrupt handling.

CSR Architecture
----------------

CSRs are accessed using dedicated instructions:

- ``CSRRW``: Atomic read/write
- ``CSRRS``: Atomic read and set bits
- ``CSRRC``: Atomic read and clear bits
- ``CSRRWI``, ``CSRRSI``, ``CSRRCI``: Immediate variants

**CSR Address Space:**

- 12-bit address space (4096 potential CSRs)
- Upper 2 bits encode privilege level (11 = machine)
- Read/write permissions encoded in address

Key Control Registers
---------------------

.. list-table:: Critical CSRs
   :widths: 20 15 65
   :header-rows: 1

   * - CSR Name
     - Address
     - Function
   * - ``mstatus``
     - 0x300
     - Machine status register (global interrupt enable, privilege mode, etc.)
   * - ``misa``
     - 0x301
     - ISA and extensions supported
   * - ``mie``
     - 0x304
     - Machine interrupt enable register
   * - ``mtvec``
     - 0x305
     - Machine trap vector base address
   * - ``mscratch``
     - 0x340
     - Machine scratch register for trap handlers
   * - ``mepc``
     - 0x341
     - Machine exception program counter
   * - ``mcause``
     - 0x342
     - Machine trap cause
   * - ``mtval``
     - 0x343
     - Machine trap value (bad address or instruction)
   * - ``mip``
     - 0x344
     - Machine interrupt pending
   * - ``pmpcfg0-3``
     - 0x3A0-0x3A3
     - Physical memory protection configuration
   * - ``pmpaddr0-15``
     - 0x3B0-0x3BF
     - Physical memory protection addresses

Exception Handling
------------------

Exceptions are synchronous traps caused by instruction execution. The RV64 Core supports:

.. list-table:: Exception Types
   :widths: 10 30 60
   :header-rows: 1

   * - Code
     - Exception
     - Cause
   * - 0
     - Instruction address misaligned
     - PC not aligned to instruction boundary
   * - 1
     - Instruction access fault
     - Bus error during instruction fetch
   * - 2
     - Illegal instruction
     - Invalid or unsupported instruction
   * - 3
     - Breakpoint
     - EBREAK instruction executed
   * - 4
     - Load address misaligned
     - Misaligned load address
   * - 5
     - Load access fault
     - Bus error during load
   * - 6
     - Store/AMO address misaligned
     - Misaligned store/atomic address
   * - 7
     - Store/AMO access fault
     - Bus error during store/atomic
   * - 8
     - Environment call from U-mode
     - ECALL in user mode
   * - 11
     - Environment call from M-mode
     - ECALL in machine mode

**Exception Priority** (highest to lowest):

1. Instruction address misaligned
2. Instruction access fault
3. Illegal instruction
4. Breakpoint
5. Load/Store address misaligned
6. Load/Store access fault
7. Environment call

Clock System
============

Clock Architecture
------------------

The RV64 Core operates in a single clock domain for simplicity and timing closure. All flip-flops are clocked by the same clock edge.

.. graphviz::
   :caption: Figure 3.3: Clock Architecture
   :align: center

   digraph Clock_System {
       graph [splines=ortho, nodesep=0.7, ranksep=1.0];
       rankdir=TB;
       node [shape=box, style="filled,rounded", fontname="Arial", width=1.5, height=0.6, fixedsize=true];
       edge [fontname="Arial", fontsize=10];
       
       // External clock source
       EXT_CLK [label="External\nClock Source", fillcolor="#FFA500", width=1.6];
       
       // Optional PLL
       PLL [label="PLL/Clock\nGenerator", fillcolor="#FFFFE0", width=1.6];
       
       // Core clock
       CORE_CLK [label="Core Clock\n(clk)", fillcolor="#87CEEB", width=1.5];
       
       // Core components
       subgraph cluster_components {
           label="RV64 Core Components";
           style="filled,rounded";
           fillcolor="#F0F0F0";
           color="#606060";
           fontname="Arial Bold";
           
           IFU [label="IFU", fillcolor="#90EE90", width=0.9];
           IDU [label="IDU", fillcolor="#90EE90", width=0.9];
           EXU [label="EXU", fillcolor="#90EE90", width=0.9];
           LSU [label="LSU", fillcolor="#90EE90", width=0.9];
           CSR [label="CSR", fillcolor="#90EE90", width=0.9];
           RF [label="Reg File", fillcolor="#90EE90", width=0.9];
       }
       
       // Clock distribution
       EXT_CLK -> PLL;
       PLL -> CORE_CLK;
       CORE_CLK -> IFU;
       CORE_CLK -> IDU;
       CORE_CLK -> EXU;
       CORE_CLK -> LSU;
       CORE_CLK -> CSR;
       CORE_CLK -> RF;
   }

Clock Domains
-------------

.. list-table:: Clock Domains
   :widths: 25 25 50
   :header-rows: 1

   * - Domain
     - Frequency
     - Components
   * - Core Clock
     - 100 MHz - 1 GHz
     - All core logic
   * - JTAG Clock
     - 10 MHz (typical)
     - Debug module (separate domain)

**Clock Domain Crossing:**

- Debug module to core: Synchronizers required
- External interrupts: Synchronized to core clock
- AXI interfaces: Same clock as core (or synchronizers required)

Clock Gating
------------

Power optimization can be achieved through clock gating (implementation dependent):

**Potential Clock Gating Points:**

1. **Multiplier Unit**: Gated when no multiply instruction in pipeline
2. **Divider Unit**: Gated when no divide instruction in pipeline
3. **Debug Module**: Gated when not in debug mode
4. **CSR Unit**: Partially gated when no CSR access

Clock gating is typically implemented at synthesis or SoC integration level.

Reset Strategy
--------------

**Reset Types:**

1. **Power-On Reset (POR)**: Initializes all state
2. **System Reset**: Resets core but may preserve debug state

**Reset Behavior:**

- Asynchronous assertion, synchronous de-assertion
- Reset state:
  
  - PC ← Reset vector (typically 0x0000_0000)
  - Privilege mode ← Machine mode
  - All CSRs ← defined reset values
  - Pipeline ← flushed
  - Register file ← undefined (except x0 = 0)

**Reset Sequence:**

1. Assert ``rst_n`` (active low)
2. Hold for minimum reset period (e.g., 10 clock cycles)
3. De-assert synchronously to clock
4. Core begins fetch from reset vector

Power Management Concept
=========================

The RV64 Core supports basic power management techniques. Advanced power management is typically implemented at the SoC level.

Power Domains
-------------

**Core Power Domain:**

- All core logic powered from single supply
- Voltage: Depends on technology (e.g., 0.9V-1.2V)
- Power gating: Optional, implemented at SoC level

**I/O Power Domain:**

- JTAG and other I/O may use different voltage
- Level shifters required if voltages differ

Low-Power States
-----------------

The core can enter low-power states through the WFI (Wait For Interrupt) instruction:

**WFI (Wait For Interrupt):**

When WFI is executed:

1. Pipeline stalls
2. Instruction fetch stops
3. Clock to most logic can be gated (implementation dependent)
4. Core waits for interrupt or debug event

**Exit from WFI:**

- Any enabled interrupt
- Debug request
- NMI (if implemented)

**Power Savings:**

WFI can reduce dynamic power by 50-90% depending on clock gating implementation.

Power Optimization Techniques
------------------------------

**Dynamic Power Reduction:**

1. **Clock Gating**: Disable clocks to unused units
2. **Operand Isolation**: Prevent unnecessary switching
3. **Low-Power Modes**: WFI instruction

**Static Power Reduction:**

1. **Power Gating**: Shut off power to core when not needed
2. **Multi-Threshold Voltage**: Use high-Vt cells for non-critical paths
3. **Substrate Biasing**: Adjust threshold voltages dynamically

**Implementation Notes:**

- Base core provides WFI instruction
- Clock/power gating implemented during synthesis or SoC integration
- Voltage/frequency scaling managed by external power management controller

Performance vs. Power Trade-offs
---------------------------------

.. list-table:: Operating Points
   :widths: 25 25 25 25
   :header-rows: 1

   * - Mode
     - Frequency
     - Voltage
     - Use Case
   * - High Performance
     - 1.0 GHz
     - 1.2 V
     - Compute-intensive tasks
   * - Balanced
     - 500 MHz
     - 1.0 V
     - Normal operation
   * - Low Power
     - 100 MHz
     - 0.9 V
     - Background tasks
   * - Sleep (WFI)
     - Clock gated
     - 0.9 V
     - Waiting for events

External Bus Concept
====================

The RV64 Core uses AXI4 for external memory access. For systems requiring different external interfaces, a bus bridge is needed.

External Memory Interface
--------------------------

**Supported via AXI4-to-X Bridges:**

- DDR3/DDR4 SDRAM controller
- SRAM controller
- Flash memory controller
- External peripheral bus (APB, AHB)

**Example: DDR4 Integration**

.. graphviz::
   :align: center

   digraph DDR_Integration {
       graph [splines=ortho, nodesep=0.8, ranksep=1.2];
       rankdir=LR;
       node [shape=box, style="filled,rounded", fontname="Arial", width=1.5, height=0.6, fixedsize=true];
       edge [fontname="Arial", fontsize=10];
       
       CORE [label="RV64 Core\nAXI4 Master", fillcolor="#87CEEB", width=1.6];
       BRIDGE [label="AXI4-to-DDR4\nController", fillcolor="#90EE90", width=1.8];
       PHY [label="DDR4 PHY", fillcolor="#FFFFE0", width=1.4];
       DRAM [label="DDR4\nSDRAM", fillcolor="#FFB6C1", width=1.4];
       
       CORE -> BRIDGE [dir=both, label="AXI4"];
       BRIDGE -> PHY [label="DDR4\nProtocol"];
       PHY -> DRAM [dir=both, label="DDR4\nSignals"];
   }

The bridge converts AXI4 transactions to DDR4 memory commands, handles refresh, timing, and other DRAM-specific requirements.

Debug Concept
=============

The RV64 Core implements the RISC-V External Debug specification, providing comprehensive debugging capabilities.

Debug Architecture
------------------

.. graphviz::
   :align: center

   digraph Debug_Arch {
       graph [splines=ortho, nodesep=0.8, ranksep=1.0];
       rankdir=TB;
       node [shape=box, style="filled,rounded", fontname="Arial", width=1.5, height=0.6, fixedsize=true];
       edge [fontname="Arial", fontsize=10];
       
       DEBUGGER [label="External\nDebugger (GDB)", fillcolor="#FFA500", width=1.6];
       JTAG [label="JTAG\nInterface", fillcolor="#FFFFE0", width=1.4];
       DTM [label="Debug Transport\nModule", fillcolor="#90EE90", width=1.8];
       DM [label="Debug\nModule", fillcolor="#87CEEB", width=1.4];
       CORE [label="RV64 Core", fillcolor="#E0FFFF", width=1.4];
       
       DEBUGGER -> JTAG [label="JTAG\nProtocol"];
       JTAG -> DTM;
       DTM -> DM [label="DMI"];
       DM -> CORE [label="Debug\nRequests"];
   }

**Debug Components:**

1. **Debug Transport Module (DTM)**: JTAG interface
2. **Debug Module (DM)**: Debug logic and control
3. **Core Debug Support**: Trigger module, debug mode

Debug Features
--------------

.. list-table:: Debug Capabilities
   :widths: 30 70
   :header-rows: 1

   * - Feature
     - Description
   * - Breakpoints
     - Hardware breakpoints on instruction address
   * - Watchpoints
     - Data access breakpoints (load/store address)
   * - Single-Step
     - Execute one instruction at a time
   * - Halt/Resume
     - Stop and restart core execution
   * - Register Access
     - Read/write GPRs and CSRs while halted
   * - Memory Access
     - Read/write memory while halted or running
   * - Reset Control
     - Debug module can reset core

**Trigger Module:**

Implements programmable triggers for breakpoints and watchpoints using trigger CSRs (``tselect``, ``tdata1-3``).

Protection and Security Concept
================================

The RV64 Core implements basic security features through Physical Memory Protection (PMP).

Physical Memory Protection (PMP)
---------------------------------

PMP provides access control for physical memory addresses, allowing machine-mode software to protect memory regions from user-mode access.

**PMP Features:**

- 8 PMP regions (configurable)
- Per-region permissions: Read (R), Write (W), Execute (X)
- Applies to all modes lower than machine mode
- Configured via ``pmpcfg`` and ``pmpaddr`` CSRs

**PMP Region Configuration:**

Each region configured with:

1. **Address**: Top address boundary
2. **Permissions**: R/W/X bits
3. **Address Matching Mode**:
   
   - OFF: Region disabled
   - TOR: Top-of-range (region from previous pmpaddr to this pmpaddr)
   - NA4: 4-byte naturally aligned
   - NAPOT: Naturally aligned power-of-two region

**Use Cases:**

- Protect firmware from user-mode corruption
- Isolate security-critical code/data
- Enforce execute-only memory regions
- Prevent user access to device registers

PMP Configuration Example
--------------------------

.. code-block:: none

   Region 0: 0x00000000 - 0x0000FFFF (64KB)
             Permissions: R-X (Execute-only, for firmware)
   
   Region 1: 0x00010000 - 0x0001FFFF (64KB)  
             Permissions: RWX (Full access for OS)
   
   Region 2: 0x10000000 - 0x1000FFFF (64KB)
             Permissions: RW- (Device registers, no execute)

Security Considerations
-----------------------

**Implemented Security Features:**

1. **Privilege Separation**: M-mode vs U-mode
2. **Memory Protection**: PMP regions
3. **Exception on Violation**: Access violations trap to M-mode

**Not Implemented (Requires Additional Features):**

- Cryptographic acceleration
- Secure boot
- TrustZone-like features
- Side-channel attack countermeasures

**Recommendations for Secure Systems:**

- Implement supervisor mode for OS separation
- Add cryptographic co-processor
- Use memory encryption for sensitive data
- Implement cache partitioning to prevent side channels

Summary
=======

This chapter described the key architectural concepts of the RV64 Core:

- **Bus Architecture**: AXI4-based Harvard architecture with separate I/D buses
- **Interrupt System**: Standard RISC-V machine-mode interrupts with low latency
- **System Control**: CSR-based configuration and exception handling
- **Clock System**: Single clock domain with optional clock gating
- **Power Management**: WFI-based low-power modes
- **Debug Support**: RISC-V debug spec compliant with JTAG interface
- **Security**: Physical Memory Protection for access control

These concepts form the foundation for the detailed design element descriptions in Chapter 4.

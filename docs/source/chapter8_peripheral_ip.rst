==========================================
Chapter 8: Peripheral IP Specifications
==========================================

History / Revision / Change Management
======================================

.. list-table:: Chapter 8 Revision History
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
     - 2025-12-17
     - All
     - Initial version with QSPI IP specification

8.1 Overview
============

This chapter provides detailed specifications for the peripheral IP blocks integrated into the RV64I_RWU System-on-Chip. Each peripheral includes register definitions, functional descriptions, timing characteristics, and integration guidelines.

The following peripheral IP blocks are documented in this chapter:

* **QSPI (Quad Serial Peripheral Interface)** - High-speed serial communication interface supporting standard SPI, Dual SPI, and Quad SPI modes
* **UART (Universal Asynchronous Receiver/Transmitter)** - Standard serial communication interface
* **JTAG (Joint Test Action Group)** - Debug and test access interface
* **GPIO (General Purpose Input/Output)** - Programmable digital I/O interface

8.2 QSPI - Quad Serial Peripheral Interface
===========================================

8.2.1 QSPI Overview
-----------------------

The QSPI peripheral provides a flexible serial communication interface supporting multiple operating modes for interfacing with external SPI-compatible devices such as flash memory, sensors, and other peripherals.

**Key Features:**

* Support for standard SPI (1-bit), Dual SPI (2-bit), and Quad SPI (4-bit) modes
* Configurable clock polarity (CPOL) and phase (CPHA)
* Programmable SPI clock frequency via clock divider
* MSB-first or LSB-first data ordering
* Automatic or manual chip select control
* Interrupt support for transfer completion and error detection
* 32-bit data transfer width
* APB-compatible register interface

8.2.2 QSPI Block Diagram
------------------------

The QSPI peripheral consists of the following major components:

.. code-block:: text

    ┌──────────────────────────────────────────────────────────┐
    │                      QSPI Module                         │
    │                                                          │
    │  ┌────────────────┐    ┌──────────────┐    ┌─────────┐ │
    │  │   Register     │    │   Clock      │    │  QSPI   │ │
    │  │   Interface    │───▶│   Divider    │───▶│ Control │ │
    │  │   (APB-like)   │    │              │    │  Logic  │ │
    │  └────────────────┘    └──────────────┘    └─────────┘ │
    │         │                                        │       │
    │         │                                        │       │
    │         ▼                                        ▼       │
    │  ┌────────────────┐                    ┌──────────────┐ │
    │  │   Interrupt    │                    │  Bidirectional│ │
    │  │   Controller   │                    │  Pin Control │ │
    │  └────────────────┘                    └──────────────┘ │
    │         │                                        │       │
    └─────────┼────────────────────────────────────────┼───────┘
              │                                        │
              ▼                                        ▼
            IRQ_O                              QSPI Pins (CS, SCLK, DATA[3:0])

**Component Descriptions:**

* **Register Interface**: Handles bus transactions and maintains configuration registers
* **Clock Divider**: Generates programmable SPI clock from system clock
* **QSPI Control Logic**: State machine managing data transfers in various modes
* **Interrupt Controller**: Generates interrupts based on configurable events
* **Bidirectional Pin Control**: Manages tristate control for QSPI data pins

8.2.3 QSPI Signal Description
-----------------------------

.. list-table:: QSPI External Signals
   :widths: 15 10 10 45
   :header-rows: 1

   * - Signal Name
     - Direction
     - Width
     - Description
   * - clk_i
     - Input
     - 1
     - System clock input
   * - rst_ni
     - Input
     - 1
     - Active-low asynchronous reset
   * - addr_i
     - Input
     - 32
     - Register address
   * - write_i
     - Input
     - 1
     - Write enable
   * - read_i
     - Input
     - 1
     - Read enable
   * - wdata_i
     - Input
     - 32
     - Write data
   * - rdata_o
     - Output
     - 32
     - Read data
   * - ready_o
     - Output
     - 1
     - Transfer ready signal
   * - error_o
     - Output
     - 1
     - Error response signal
   * - irq_o
     - Output
     - 1
     - Interrupt request output
   * - qspi_cs_no
     - Output
     - 1
     - Chip select (active low)
   * - qspi_sclk_o
     - Output
     - 1
     - SPI clock output
   * - qspi_data_io[3:0]
     - Inout
     - 4
     - Bidirectional data pins (SD0-SD3)

8.2.4 QSPI Register Map
-----------------------

The QSPI peripheral is accessed through a set of memory-mapped registers. All registers are 32-bit wide and aligned on 4-byte boundaries.

.. list-table:: QSPI Register Address Map
   :widths: 15 15 50
   :header-rows: 1

   * - Offset
     - Register Name
     - Description
   * - 0x00
     - QSPI_CTRL
     - Control Register
   * - 0x04
     - QSPI_STATUS
     - Status Register (Read-Only)
   * - 0x08
     - QSPI_DATA
     - Data Register (TX/RX)
   * - 0x0C
     - QSPI_CLKDIV
     - Clock Divider Register
   * - 0x10
     - QSPI_CS
     - Chip Select Control Register
   * - 0x14
     - QSPI_INT_EN
     - Interrupt Enable Register
   * - 0x18
     - QSPI_INT_STATUS
     - Interrupt Status Register
   * - 0x1C
     - QSPI_FIFO_CTRL
     - FIFO Control Register

8.2.4.1 QSPI_CTRL Register (Offset: 0x00)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Control register for configuring QSPI operating modes and parameters.

.. list-table:: QSPI_CTRL Register Bit Fields
   :widths: 10 10 15 45
   :header-rows: 1

   * - Bits
     - Name
     - Access
     - Description
   * - [31:8]
     - RESERVED
     - RO
     - Reserved, reads as 0
   * - [7:6]
     - MODE
     - RW
     - Operating mode: 00=SPI, 01=Dual, 10=Quad, 11=Reserved
   * - [5]
     - CPOL
     - RW
     - Clock polarity: 0=Clock low when idle, 1=Clock high when idle
   * - [4]
     - CPHA
     - RW
     - Clock phase: 0=Sample on first edge, 1=Sample on second edge
   * - [3]
     - LSB_FIRST
     - RW
     - Data order: 0=MSB first, 1=LSB first
   * - [2]
     - CS_MODE
     - RW
     - Chip select mode: 0=Automatic, 1=Manual
   * - [1]
     - TX_ENABLE
     - RW
     - Transmit enable: 0=Disabled, 1=Enabled
   * - [0]
     - RX_ENABLE
     - RW
     - Receive enable: 0=Disabled, 1=Enabled

**Reset Value:** 0x00000000

8.2.4.2 QSPI_STATUS Register (Offset: 0x04)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Read-only status register indicating current QSPI peripheral state.

.. list-table:: QSPI_STATUS Register Bit Fields
   :widths: 10 10 15 45
   :header-rows: 1

   * - Bits
     - Name
     - Access
     - Description
   * - [31:8]
     - RESERVED
     - RO
     - Reserved, reads as 0
   * - [7]
     - TX_FULL
     - RO
     - TX FIFO full flag: 0=Not full, 1=Full
   * - [6]
     - TX_EMPTY
     - RO
     - TX FIFO empty flag: 0=Not empty, 1=Empty
   * - [5]
     - RX_FULL
     - RO
     - RX FIFO full flag: 0=Not full, 1=Full
   * - [4]
     - RX_EMPTY
     - RO
     - RX FIFO empty flag: 0=Not empty, 1=Empty
   * - [3]
     - BUSY
     - RO
     - Transfer in progress: 0=Idle, 1=Busy
   * - [2]
     - ERROR
     - RO
     - Error flag: 0=No error, 1=Error occurred
   * - [1:0]
     - RESERVED
     - RO
     - Reserved, reads as 0

**Reset Value:** 0x00000040 (TX_EMPTY = 1)

8.2.4.3 QSPI_DATA Register (Offset: 0x08)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Data register for transmit and receive operations. Writing to this register initiates a transfer.

.. list-table:: QSPI_DATA Register Bit Fields
   :widths: 10 10 15 45
   :header-rows: 1

   * - Bits
     - Name
     - Access
     - Description
   * - [31:0]
     - DATA
     - RW
     - TX/RX data buffer (32 bits)

**Reset Value:** 0x00000000

**Operation:**
* **Write**: Loads TX data and automatically initiates transfer if enabled
* **Read**: Returns received data from last completed transfer

8.2.4.4 QSPI_CLKDIV Register (Offset: 0x0C)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Clock divider configuration register. SPI clock frequency = System Clock / (2 × (CLKDIV + 1))

.. list-table:: QSPI_CLKDIV Register Bit Fields
   :widths: 10 10 15 45
   :header-rows: 1

   * - Bits
     - Name
     - Access
     - Description
   * - [31:16]
     - RESERVED
     - RO
     - Reserved, reads as 0
   * - [15:0]
     - CLKDIV
     - RW
     - Clock divider value (0-65535)

**Reset Value:** 0x00000010 (Divider = 16)

**Examples:**
* CLKDIV = 0: SPI Clock = System Clock / 2
* CLKDIV = 1: SPI Clock = System Clock / 4
* CLKDIV = 15: SPI Clock = System Clock / 32

8.2.4.5 QSPI_CS Register (Offset: 0x10)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Chip select control register (used in manual CS mode).

.. list-table:: QSPI_CS Register Bit Fields
   :widths: 10 10 15 45
   :header-rows: 1

   * - Bits
     - Name
     - Access
     - Description
   * - [31:1]
     - RESERVED
     - RO
     - Reserved, reads as 0
   * - [0]
     - CS_VALUE
     - RW
     - Chip select value: 0=Assert CS, 1=Deassert CS

**Reset Value:** 0x00000001 (CS deasserted)

8.2.4.6 QSPI_INT_EN Register (Offset: 0x14)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Interrupt enable register for controlling interrupt generation.

.. list-table:: QSPI_INT_EN Register Bit Fields
   :widths: 10 10 15 45
   :header-rows: 1

   * - Bits
     - Name
     - Access
     - Description
   * - [31:4]
     - RESERVED
     - RO
     - Reserved, reads as 0
   * - [3]
     - TX_DONE_EN
     - RW
     - TX complete interrupt enable: 0=Disabled, 1=Enabled
   * - [2]
     - RX_READY_EN
     - RW
     - RX ready interrupt enable: 0=Disabled, 1=Enabled
   * - [1]
     - ERROR_EN
     - RW
     - Error interrupt enable: 0=Disabled, 1=Enabled
   * - [0]
     - CS_CHANGE_EN
     - RW
     - CS change interrupt enable: 0=Disabled, 1=Enabled

**Reset Value:** 0x00000000 (All interrupts disabled)

8.2.4.7 QSPI_INT_STATUS Register (Offset: 0x18)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Interrupt status register. Write 1 to clear individual interrupt flags.

.. list-table:: QSPI_INT_STATUS Register Bit Fields
   :widths: 10 10 15 45
   :header-rows: 1

   * - Bits
     - Name
     - Access
     - Description
   * - [31:4]
     - RESERVED
     - RO
     - Reserved, reads as 0
   * - [3]
     - TX_DONE
     - W1C
     - TX complete interrupt flag
   * - [2]
     - RX_READY
     - W1C
     - RX ready interrupt flag
   * - [1]
     - ERROR
     - W1C
     - Error interrupt flag
   * - [0]
     - CS_CHANGE
     - W1C
     - CS change interrupt flag

**Reset Value:** 0x00000000

**Note:** W1C = Write 1 to Clear

8.2.4.8 QSPI_FIFO_CTRL Register (Offset: 0x1C)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

FIFO threshold configuration register.

.. list-table:: QSPI_FIFO_CTRL Register Bit Fields
   :widths: 10 10 15 45
   :header-rows: 1

   * - Bits
     - Name
     - Access
     - Description
   * - [31:8]
     - RESERVED
     - RO
     - Reserved, reads as 0
   * - [7:4]
     - TX_THRESHOLD
     - RW
     - TX FIFO threshold (0-15)
   * - [3:0]
     - RX_THRESHOLD
     - RW
     - RX FIFO threshold (0-15)

**Reset Value:** 0x00000044 (Both thresholds = 4)

8.2.5 QSPI Operating Modes
--------------------------

8.2.5.1 Standard SPI Mode (MODE = 00)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In standard SPI mode, data is transmitted and received on a single data line (SD0/MOSI for TX, SD1/MISO for RX).

**Configuration:**
* Set MODE[1:0] = 00 in QSPI_CTRL register
* Configure CPOL and CPHA as required by target device
* Set TX_ENABLE and/or RX_ENABLE as needed

**Data Transfer:**
* One bit transferred per SPI clock cycle
* 32 SPI clock cycles for full 32-bit transfer

8.2.5.2 Dual SPI Mode (MODE = 01)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In dual SPI mode, data is transmitted and received on two data lines (SD0 and SD1) simultaneously.

**Configuration:**
* Set MODE[1:0] = 01 in QSPI_CTRL register
* Both SD0 and SD1 are used for bidirectional data transfer

**Data Transfer:**
* Two bits transferred per SPI clock cycle
* 16 SPI clock cycles for full 32-bit transfer
* 2× throughput compared to standard SPI

8.2.5.3 Quad SPI Mode (MODE = 10)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In quad SPI mode, data is transmitted and received on four data lines (SD0-SD3) simultaneously.

**Configuration:**
* Set MODE[1:0] = 10 in QSPI_CTRL register
* All four data lines (SD0-SD3) are used for bidirectional data transfer

**Data Transfer:**
* Four bits transferred per SPI clock cycle
* 8 SPI clock cycles for full 32-bit transfer
* 4× throughput compared to standard SPI

8.2.6 QSPI Clock Modes
-------------------------

The QSPI peripheral supports all four standard SPI clock modes through CPOL and CPHA configuration:

.. list-table:: SPI Clock Modes
   :widths: 15 15 15 55
   :header-rows: 1

   * - Mode
     - CPOL
     - CPHA
     - Description
   * - 0
     - 0
     - 0
     - Clock idle low, sample on rising edge, shift on falling edge
   * - 1
     - 0
     - 1
     - Clock idle low, shift on rising edge, sample on falling edge
   * - 2
     - 1
     - 0
     - Clock idle high, sample on falling edge, shift on rising edge
   * - 3
     - 1
     - 1
     - Clock idle high, shift on falling edge, sample on rising edge

8.2.7 QSPI Programming Guide
----------------------------

8.2.7.1 Initialization Sequence
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. **Configure Clock Divider:**

   .. code-block:: c

      // Set SPI clock to System Clock / 32
      QSPI_CLKDIV = 0x000F;

2. **Configure Control Register:**

   .. code-block:: c

      // Standard SPI mode, CPOL=0, CPHA=0, MSB first, Auto CS
      QSPI_CTRL = 0x03;  // TX_ENABLE | RX_ENABLE

3. **Enable Interrupts (Optional):**

   .. code-block:: c

      // Enable TX done and error interrupts
      QSPI_INT_EN = 0x0A;  // TX_DONE_EN | ERROR_EN

8.2.7.2 Data Transfer (Polling Mode)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: c

   // Function to send and receive 32-bit data via QSPI
   uint32_t qspi_transfer(uint32_t tx_data) {
       // Wait for peripheral to be ready
       while (QSPI_STATUS & 0x08);  // Wait while BUSY
       
       // Write data to initiate transfer
       QSPI_DATA = tx_data;
       
       // Wait for transfer to complete
       while (QSPI_STATUS & 0x08);  // Wait while BUSY
       
       // Read received data
       return QSPI_DATA;
   }

8.2.7.3 Data Transfer (Interrupt Mode)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: c

   volatile uint32_t rx_data;
   volatile uint8_t transfer_done = 0;
   
   void qspi_send(uint32_t tx_data) {
       transfer_done = 0;
       QSPI_DATA = tx_data;
   }
   
   void qspi_irq_handler(void) {
       uint32_t status = QSPI_INT_STATUS;
       
       if (status & 0x08) {  // TX_DONE
           rx_data = QSPI_DATA;
           transfer_done = 1;
           QSPI_INT_STATUS = 0x08;  // Clear interrupt
       }
       
       if (status & 0x02) {  // ERROR
           // Handle error
           QSPI_INT_STATUS = 0x02;  // Clear interrupt
       }
   }

8.2.7.4 Quad SPI Mode Example
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: c

   // Configure for Quad SPI mode
   void qspi_init_quad_mode(void) {
       // Set clock divider
       QSPI_CLKDIV = 0x0007;  // Higher speed for quad mode
       
       // Configure for Quad mode, CPOL=0, CPHA=0
       QSPI_CTRL = 0x83;  // MODE=10, TX_ENABLE | RX_ENABLE
       
       // Enable interrupts
       QSPI_INT_EN = 0x0E;  // All interrupts except CS_CHANGE
   }

8.2.8 QSPI Timing Characteristics
---------------------------------

.. list-table:: QSPI Timing Parameters
   :widths: 25 15 15 15 30
   :header-rows: 1

   * - Parameter
     - Symbol
     - Min
     - Max
     - Units
   * - System Clock Frequency
     - f_sys
     - 1
     - 200
     - MHz
   * - SPI Clock Frequency
     - f_spi
     - 100
     - 50
     - kHz / MHz
   * - CS Setup Time
     - t_css
     - 20
     - -
     - ns
   * - CS Hold Time
     - t_csh
     - 20
     - -
     - ns
   * - Data Setup Time
     - t_su
     - 10
     - -
     - ns
   * - Data Hold Time
     - t_hd
     - 10
     - -
     - ns
   * - SCLK High Time
     - t_ch
     - 50
     - -
     - % duty cycle
   * - SCLK Low Time
     - t_cl
     - 50
     - -
     - % duty cycle

8.2.9 QSPI State Machine
------------------------

The QSPI controller implements a state machine with the following states:

.. code-block:: text

                    ┌──────┐
         ┌─────────▶│ IDLE │◀──────────┐
         │          └──────┘           │
         │             │                │
         │          START               │
         │             │                │
         │             ▼                │
         │          ┌──────┐            │
         │          │ LOAD │            │
         │          └──────┘            │
         │             │                │
         │             ▼                │
         │        ┌──────────┐          │
         │        │ TRANSFER │          │
         │        └──────────┘          │
         │             │                │
         │        BIT_COUNT=0           │
         │             │                │
         │             ▼                │
         │       ┌───────────┐          │
         │       │ WAIT_DONE │          │
         │       └───────────┘          │
         │             │                │
         │        MANUAL_CS=0           │
         │             │                │
         │             ▼                │
         │        ┌─────────┐           │
         └────────│ CS_HOLD │───────────┘
                  └─────────┘

**State Descriptions:**

* **IDLE**: Waiting for transfer request
* **LOAD**: Loading TX data and configuring transfer parameters
* **TRANSFER**: Active data transfer in progress
* **WAIT_DONE**: Transfer complete, waiting for CS handling
* **CS_HOLD**: CS deassert delay before returning to IDLE

8.2.10 QSPI Design Files
----------------------------

The QSPI peripheral implementation consists of the following SystemVerilog files:

.. list-table:: QSPI Design Files
   :widths: 25 55
   :header-rows: 1

   * - File Name
     - Description
   * - as_pack.sv
     - Package file with type definitions, constants, and enumerations
   * - clk_div.sv
     - Configurable clock divider module for SPI clock generation
   * - qspi_ctrl.sv
     - QSPI controller with state machine and transfer logic
   * - qspi.sv
     - Top-level QSPI module with register interface and pin control

**Module Hierarchy:**

.. code-block:: text

   qspi (top-level)
   ├── clk_div (clock divider)
   └── qspi_ctrl (controller)

8.2.11 QSPI Integration Guidelines
---------------------------------------

8.2.11.1 Address Mapping
^^^^^^^^^^^^^^^^^^^^^^^^

The QSPI peripheral should be mapped to a dedicated address range in the system memory map. Recommended base address alignment is 1KB (0x400).

Example mapping:
* Base Address: 0x1000_1000
* Size: 256 bytes (0x100)

8.2.11.2 Interrupt Connection
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Connect the ``irq_o`` output to the system interrupt controller. Recommended interrupt priority: Medium.

8.2.11.3 Clock Requirements
^^^^^^^^^^^^^^^^^^^^^^^^^^^

* System clock (``clk_i``): Must be stable and at least 2× the desired maximum SPI clock frequency
* Reset (``rst_ni``): Active-low asynchronous reset, must be properly synchronized

8.2.11.4 Pin Constraints
^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table:: QSPI Pin Recommendations
   :widths: 20 60
   :header-rows: 1

   * - Signal
     - Recommendation
   * - qspi_sclk_o
     - Assign to high-speed I/O pin with minimal skew
   * - qspi_cs_no
     - Assign to standard I/O pin, add external pull-up if needed
   * - qspi_data_io[3:0]
     - Assign to adjacent pins for matched routing delays

8.2.12 QSPI Verification and Testing
------------------------------------

8.2.12.1 Test Scenarios
^^^^^^^^^^^^^^^^^^^^^^^

The following test scenarios should be executed to verify QSPI functionality:

1. **Register Access Test**: Verify all registers are accessible and reset to correct values
2. **Clock Divider Test**: Verify SPI clock generation at various frequencies
3. **Standard SPI Mode Test**: Transfer data in SPI mode with all clock modes (0-3)
4. **Dual SPI Mode Test**: Transfer data in dual mode and verify 2× throughput
5. **Quad SPI Mode Test**: Transfer data in quad mode and verify 4× throughput
6. **Interrupt Test**: Verify interrupt generation and clearing
7. **CS Control Test**: Verify both automatic and manual CS modes
8. **Error Handling Test**: Verify error detection and reporting

8.2.12.2 Testbench Components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A complete testbench should include:

* **SPI Slave Model**: Simulates external SPI device
* **Bus Functional Model**: Generates register read/write transactions
* **Clock Generator**: Provides system clock
* **Monitor**: Captures and checks SPI protocol compliance
* **Scoreboard**: Verifies data integrity

8.2.13 QSPI Limitations and Known Issues
----------------------------------------

**Current Implementation Limitations:**

1. **FIFO Depth**: Current implementation uses single-entry data register (no deep FIFO)
2. **Bit Count**: Fixed at 32 bits per transfer
3. **Multi-slave**: Single CS output (no multi-slave support)
4. **DMA**: No DMA controller interface

**Future Enhancements:**

* Implement configurable FIFO depth (8-16 entries)
* Add variable bit count support (1-32 bits)
* Support multiple CS outputs for multi-slave configurations
* Add DMA controller interface for high-throughput applications
* Implement hardware-controlled command sequences for flash memory

8.3 UART - Universal Asynchronous Receiver/Transmitter
======================================================

.. note::
   UART peripheral specification is documented separately. Refer to existing UART implementation files in ``rtl/peripherals/uart/``.

8.4 JTAG - Joint Test Action Group Interface
============================================

.. note::
   JTAG peripheral specification is documented separately. Refer to existing JTAG implementation files in ``rtl/peripherals/jtag/``.

8.5 GPIO - General Purpose Input/Output
=======================================

.. note::
   GPIO peripheral specification is documented separately. Refer to existing GPIO implementation files in ``rtl/peripherals/gpio/``.

8.6 Summary
===========

This chapter has provided comprehensive specifications for the peripheral IP blocks in the RV64I_RWU System-on-Chip. Each peripheral includes detailed register definitions, programming guides, timing characteristics, and integration guidelines necessary for successful system integration and software development.

For additional technical details and design files, refer to the RTL implementation in the ``rtl/peripherals/`` directory.

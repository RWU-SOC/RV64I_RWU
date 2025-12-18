# RV64I_RWU — RISC-V 64-bit Processor Core

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()
[![CMake](https://img.shields.io/badge/CMake-3.20+-blue)]()
[![License](https://img.shields.io/badge/license-Apache--2.0-blue)]()

A professional RISC-V 64-bit processor core implementation (RV64I) with modular CMake build system, comprehensive verification framework, and industry-standard project organization.

**Institution**: Hochschule Ravensburg-Weingarten  
**Course**: System on Chip  
**Repository**: https://github.com/RWU-SOC/RV64I_RWU

---

## 🚀 Quick Start

```powershell
# Clone and setup
git clone https://github.com/RWU-SOC/RV64I_RWU.git
cd RV64I_RWU

# Source Vivado (Windows)
# Xilinx branding (2024.2 and earlier):
& "C:\Xilinx\Vivado\2024.2\settings64.bat"
# AMD branding (2025.2 and later):
& "C:\AMDDesignTools\Vivado\2025.2\settings64.bat"

# Configure and build (MinGW Makefiles recommended)
cmake -S . -B build -G "MinGW Makefiles"
cmake --build build

# Build simulation for a specific test
cmake --build build --target fw_asm_instr06addi   # Build firmware
cmake --build build --target sim_instr06addi      # Build simulation

# Run simulation in GUI
cd build/sim/integration/instr06addi
xsim instr06addi_snapshot --gui
```

**📖 Full Documentation**: See `docs/` directory or visit https://rwu-soc.github.io/RV64I_RWU/

---

## 📁 Project Structure

```
RV64I_RWU/
├── rtl/                   # Hardware Design (38 RTL files)
│   ├── core/              # RV64I processor core (23 files)
│   └── peripherals/       # IP blocks (UART, JTAG, GPIO)
├── verification/          # Testbenches (27 files)
│   ├── unit/              # Component tests
│   ├── integration/       # System tests
│   └── ip/                # IP-specific tests
├── firmware/              # Software Tests (20 files)
│   ├── tests/             # Assembly & C programs
│   └── common/            # Runtime support
├── build/                 # Generated Build Artifacts (not in git)
│   ├── firmware/          # Compiled .elf files
│   └── sim/integration/   # XSIM simulation workspaces
├── docs/                  # Documentation (Sphinx)
│   ├── build/html/        # Built HTML docs
│   └── source/            # RST source files
└── cmake/                 # Build System
    └── modules/           # 14 reusable CMake modules
```

---

## 🛠️ Prerequisites

- **CMake** ≥ 3.20
- **MinGW** or **Ninja** build system (recommended on Windows to avoid MSVC conflict)
  - MinGW: Usually comes with Git for Windows
  - Ninja: `choco install ninja` or https://github.com/ninja-build/ninja/releases
- **RISC-V GNU Toolchain** (`riscv64-unknown-elf-*`)
  - Download from: https://github.com/sifive/freedom-tools/releases
- **Vivado** 2022.2+ (for simulation)
  - Xilinx Vivado: `C:\Xilinx\Vivado\2024.2\`
  - AMD Vivado: `C:\AMDDesignTools\Vivado\2025.2\`
- **Python 3** + Sphinx (for documentation)

**Installation guides**: See `docs/getting_started.md`

---

## 🔨 Build System

This project uses a **modular CMake architecture** inspired by Zephyr RTOS with industry-standard directory organization and auto-discovery patterns.

### Key Features

✅ **Auto-Discovery**: New files automatically detected  
✅ **Parallel Testing**: CTest with multi-core support  
✅ **Graceful Degradation**: Missing tools = warnings, not errors  
✅ **Cross-Platform**: Windows, Linux, macOS  
✅ **Modular Design**: 15 CMakeLists.txt files, clean separation of concerns

### Common Commands

```powershell
# Configure (MinGW Makefiles recommended on Windows)
cmake -S . -B build -G "MinGW Makefiles"

# Build firmware
cmake --build build --target fw_asm_instr06addi

# Build simulation
cmake --build build --target sim_instr06addi

# Run simulation (console mode)
cd build/sim/integration/instr06addi
xsim instr06addi_snapshot -runall

# Run simulation (GUI mode)
cd build/sim/integration/instr06addi
xsim instr06addi_snapshot --gui

# Run tests via CTest
cd build
ctest -R integration_instr06addi -V

# Build documentation
cmake --build build --target docs
```

**Build System Tutorial**: See `docs/cmake_tutorial.md`

---

## 🧪 Testing

Comprehensive regression testing with 17+ auto-discovered tests:

| Category | Count | Description |
|----------|-------|-------------|
| Unit | 4 | Component-level testbenches |
| Integration | 15 | System-level testbenches |
| Firmware | 17 | Assembly & C programs |
| IP Tests | 8 | UART & JTAG verification |

```powershell
# Quick regression (~5 min)
ctest --test-dir build -L unit

# Full regression (~30 min)
ctest --test-dir build -j

# Specific test
ctest --test-dir build -R firmware_asm_instr06addi -V
```

**Testing Guide**: See `docs/testing_guide.md`

---

## 📚 Documentation

Documentation is built with Sphinx and published to GitHub Pages.

### Build Locally

```powershell
# HTML
cmake --build build --target docs_html
start build/docs/html/index.html

# PDF
cmake --build build --target docs_pdf
start build/docs/latex/RV64_Specification.pdf
```

### Documentation Structure

- **Getting Started** (`docs/getting_started.md`) - First-time setup
- **CMake Tutorial** (`docs/cmake_tutorial.md`) - Build system deep dive
- **Testing Guide** (`docs/testing_guide.md`) - Regression testing
- **Architecture** (`docs/architecture.md`) - System architecture
- **API Reference** (`docs/source/`) - Sphinx documentation

**Online**: https://rwu-soc.github.io/RV64I_RWU/

---

---

## 👥 Development Workflow

### Branch Strategy

- **`main`**: Stable production branch
- **Component branches**: `ALU`, `Clock`, `Register_File`, `Decoder`, etc.
- **Feature branches**: `feature/your-feature-name`

### Standard Workflow

```powershell
# 1. Start from main
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/alu-implementation

# 3. Make changes and commit
git add .
git commit -m "Add ALU arithmetic operations"

# 4. Push and create PR
git push origin feature/alu-implementation
# Then create Pull Request on GitHub

# 5. After merge, cleanup
git checkout main
git pull origin main
git branch -d feature/alu-implementation
```

---

## 🤝 Contributing

### Component Assignments

| Component | Description | Documentation Chapter |
|-----------|-------------|----------------------|
| **Clock** | Clock generation | Chapter 4 - Design Elements |
| **Register File** | GP registers | Chapter 4 - Design Elements |
| **ALU** | Arithmetic/Logic Unit | Chapter 4 - Design Elements |
| **Decoder** | Instruction decode | Chapter 4 - Design Elements |
| **I-Mem/D-Mem** | Memory interfaces | Chapter 4 & 6 |
| **BUS** | Wishbone interface | Chapter 3 & 4 |
| **GPIO** | Peripherals | Chapter 4 & 6 |
| **IRQ** | Interrupt handling | Chapter 4 & 5 |
| **Toolchain** | Development tools | - |
| **Top-Level** | Integration | Chapter 3 |

### Documentation Workflow

```powershell
# 1. Edit your chapter in docs/source/
cd docs/source
notepad chapter4_design_elements.rst

# 2. Build and preview
cd ../..
cmake -S . -B build
cmake --build build --target docs_html
start build/docs/html/index.html

# 3. Commit and push
git add docs/source/
git commit -m "Update ALU documentation"
git push origin docs/alu-design-elements
```

**Documentation Standards**: See `docs/contributing.md`

---

## 🎓 Learning Resources

### New to CMake?

1. **Start Here**: `docs/cmake_tutorial.md` (comprehensive guide)
2. **Quick Reference**: `docs/cmake_reference.md`
3. **Examples**: Explore existing `CMakeLists.txt` files

### External Resources

- [Official CMake Tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html)
- [Zephyr RTOS CMake](https://docs.zephyrproject.org/latest/build/cmake/index.html)
- [Effective Modern CMake](https://gist.github.com/mbinna/c61dbb39bca0e4fb7d1f73b0d66a4fd1)

**Full resource list**: `docs/cmake_resources.md`

---

## 📊 Project Status

| Component | Status | Tests | Documentation |
|-----------|--------|-------|---------------|
| Core RTL | ✅ Complete | 23 files | ✅ |
| UART IP | ✅ Complete | 5 files | ✅ |
| JTAG IP | ✅ Complete | 10 files | ✅ |
| GPIO IP | 🔄 In Progress | - | 🔄 |
| Verification | ✅ Complete | 27 tests | ✅ |
| Firmware | ✅ Complete | 20 tests | ✅ |
| Documentation | 🔄 In Progress | - | 🔄 |

**Last Updated**: November 28, 2025

---

## 🐛 Troubleshooting

### Common Issues

**"CMake Error: toolchain not found"**
```powershell
# Verify installation
riscv64-unknown-elf-gcc --version

# Or specify manually
cmake -S . -B build -G "MinGW Makefiles" -DRISCV_CC="C:/SysGCC/risc-v/bin/riscv64-unknown-elf-gcc.exe"
```

**"Visual Studio detected instead of RISC-V GCC"**
```powershell
# Use MinGW Makefiles or Ninja generator to avoid MSVC conflict
cmake -S . -B build -G "MinGW Makefiles"

# Alternative with Ninja:
cmake -S . -B build -G Ninja
```

**"Vivado XSIM not found"**
```powershell
# Source Vivado before CMake
# For Vivado 2024.2 and earlier:
& "C:\Xilinx\Vivado\2024.2\settings64.bat"
# For Vivado 2025.2 and later:
& "C:\AMDDesignTools\Vivado\2025.2\settings64.bat"

cmake -S . -B build -G Ninja
```

**Build errors after changes**
```powershell
# Clean and rebuild
Remove-Item -Recurse -Force build
cmake -S . -B build -G "MinGW Makefiles"
cmake --build build
```

**Simulation needs waveform configuration**
```powershell
# Open simulation GUI and manually add signals
cd build/sim/integration/<test_name>
xsim <test_name>_snapshot --gui

# In the GUI:
# 1. Click "Scope" tab to see design hierarchy
# 2. Right-click on signals and select "Add to Wave Window"
# 3. Click "Run All" to execute simulation
```

**More solutions**: See `docs/troubleshooting.md`

---

## 📄 License

This project is licensed under the Apache License 2.0. See `LICENSE` file for details.

---

## 📞 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/RWU-SOC/RV64I_RWU/issues)
- **Pull Requests**: [GitHub PRs](https://github.com/RWU-SOC/RV64I_RWU/pulls)
- **Documentation**: https://rwu-soc.github.io/RV64I_RWU/

---

**Built with ❤️ by the RWU-SOC Team**

# ⚡ Floating Point Multiplier – SystemVerilog

## 📌 Overview
This repository contains a hardware implementation of a **single-precision (32-bit) IEEE-754 Floating Point Multiplier** in **SystemVerilog**.  
The design includes a **pipelined architecture**, **normalization**, **rounding**, and **exception handling** units, along with a complete **verification environment**.  

---

## ⚙️ Design Features
- **IEEE-754 single precision (32-bit) multiplier**  
- **Pipeline stage** after normalization for improved throughput  
- **Four modular components**:
  - **`fp_mult`** – main datapath (sign, exponent, mantissa calculation, bias subtraction, pipeline, rounding, exception handling)  
  - **`normalize_mult`** – normalization of mantissa, guard and sticky bits  
  - **`round_mult`** – rounding logic with support for six rounding modes  
  - **`exception_mult`** – exception handling (NaN, ±Inf, ±0, underflow, overflow)  
- **Top-level wrapper**: `fp_mult_top`  
- **8-bit status output** indicating zero, infinity, NaN, overflow, underflow, inexact, etc.  

---

## 🧪 Verification
- **Testbench**
  - Randomized operand testing using **`$urandom()`**  
  - Deterministic corner-case coverage (**NaN, ±Inf, ±0, normals, denormals**)  

- **SystemVerilog Assertions (SVA)**
  - Immediate and concurrent properties to validate results and status flag consistency  
  - Bound assertion modules integrated into the testbench  

---

## 📂 Repository Structure
```plaintext
├── exercise1/              # Design modules
│   ├── fp_mult.sv
│   ├── normalize_mult.sv
│   ├── round_mult.sv
│   └── exception_mult.sv
│
├── exercise2/              # Testbench
│   └── tb_fp_mult.sv
│
├── exercise3/              # SystemVerilog Assertions
│   ├── test_status_bits.sv
│   └── test_status_z_combinations.sv
│
└── report/                 # Documentation
    └── report.pdf

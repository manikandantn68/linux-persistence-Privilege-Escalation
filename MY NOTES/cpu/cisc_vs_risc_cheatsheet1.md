# CISC vs RISC — Instruction Set Cheat Sheet

## 0. Difference Summary (Quick Reference)

| Category | CISC | RISC |
|---|---|---|
| Instruction count | ~1000+, some do multi-step work (`rep movsb`) | ~50–150, each does one simple thing |
| Instruction length | Variable (1–15 bytes, x86) | Fixed (4 bytes; RISC-V also 2-byte compressed) |
| Memory access | ALU can touch memory directly (`add eax,[ebx]`) | Strict load/store only — ALU works on registers |
| Execution cycles | Multi-cycle, microcoded, complex decode | Mostly 1 cycle/instr, hardwired decode |
| Registers | Few (x86: 8–16 GP) | Many (ARM64: 31, RISC-V: 32) |
| Addressing modes | Many (12+), complex in one instr | Few (3–5), split across instrs |
| Compiler vs hardware | Simple compiler, complex hardware (microcode) | Complex compiler, simple hardware |
| Code density vs speed | Denser code, fewer bytes fetched | More instrs, but pipeline-friendly and fast |
| CISC-only categories | String ops (`movs`,`cmps`,`scas`), port I/O (`in`/`out`), loop counter (`loop`), push/pop, inc/dec, xchg | none — achieved via multiple simple instrs (manual loops, manual SP math) |
| RISC-only categories | none | Load-reserve/store-conditional (`lr`/`sc`) for atomics instead of locked ops |
| Real chips today | x86/x86-64 (CISC ISA, decodes internally to RISC-like µops) | ARM, ARM64, RISC-V, MIPS, PowerPC |

## 1. Core Philosophy

| Aspect | CISC | RISC |
|---|---|---|
| Idea | Fewer lines of asm, complex instructions do more work | Simple instructions, more of them, fast execution |
| Instr. length | Variable (1–15 bytes on x86) | Fixed (4 bytes typical; RISC-V has 16-bit compressed too) |
| Instr. count | Large (~1000+ on x86) | Small (~50–150) |
| Execution | Multi-cycle, microcoded | Mostly 1 cycle/instr (pipelined) |
| Memory access | ALU ops can access memory directly | Only LOAD/STORE touch memory |
| Registers | Few general-purpose (x86: 16) | Many (ARM64: 31, RISC-V: 32) |
| Addressing modes | Many (12+ on x86) | Few (3–5) |
| Decode | Complex, hardware decoder + microcode ROM | Simple, hardwired |
| Compiler role | Simpler compiler, complex hardware | Complex compiler, simple hardware |
| Examples | x86, x86-64, VAX, System/360 | ARM, ARM64, RISC-V, MIPS, PowerPC, SPARC |

## 2. Memory Access Model

- **CISC**: register-to-memory, memory-to-memory ops allowed
  `add eax, [ebx]` — ALU op reads memory directly
- **RISC**: strict Load/Store architecture
  `lw t0, 0(t1)` then `add t2, t0, t3` — separate load, then compute

## 3. Instruction Categories (both ISAs have these — syntax differs)

### A. Data Transfer / Movement
| Purpose | x86 (CISC) | ARM64/RISC-V (RISC) |
|---|---|---|
| Register-register move | `mov eax, ebx` | `mov x0, x1` / `mv t0,t1` |
| Load immediate | `mov eax, 5` | `mov x0, #5` / `li t0, 5` |
| Load from memory | `mov eax, [ebx]` | `ldr x0, [x1]` / `lw t0, 0(t1)` |
| Store to memory | `mov [ebx], eax` | `str x0, [x1]` / `sw t0, 0(t1)` |
| Push/Pop stack | `push eax` / `pop eax` | no direct push/pop (ARM: `str`/`ldr` w/ SP; RISC-V: manual `addi sp`) |
| Exchange | `xchg eax, ebx` | no single instr — needs temp reg |
| Move w/ sign extend | `movsx` | `sxtw` / auto in `lw`/`lwu` |
| Conditional move | `cmovz eax, ebx` | `csel` (ARM64 only) |

### B. Arithmetic
| Purpose | x86 (CISC) | ARM64/RISC-V |
|---|---|---|
| Add | `add eax, ebx` | `add x0, x1, x2` / `add t0,t1,t2` |
| Subtract | `sub eax, ebx` | `sub` |
| Multiply | `imul eax, ebx` | `mul` |
| Divide | `idiv ebx` | `sdiv`/`udiv` (ARM) / `div` (RV) |
| Increment/Decrement | `inc eax` / `dec eax` | `add x0,x0,#1` (no dedicated instr) |
| Negate | `neg eax` | `neg` (ARM) / `sub t0,zero,t1` (RV) |
| Add w/ carry | `adc` | `adcs` (ARM) |
| Multiply-add (FMA-like) | `imul`+`add` (2 instr) | `madd` (single instr, RISC advantage) |

### C. Logical / Bitwise
| Purpose | x86 | ARM64/RISC-V |
|---|---|---|
| AND | `and eax, ebx` | `and` |
| OR | `or eax, ebx` | `orr`(ARM)/`or`(RV) |
| XOR | `xor eax, ebx` | `eor`(ARM)/`xor`(RV) |
| NOT | `not eax` | `mvn`(ARM)/`xori t0,t1,-1`(RV) |
| Test (AND w/o store) | `test eax, ebx` | `tst`(ARM)/`and` w/ discard |

### D. Shift / Rotate
| Purpose | x86 | ARM64/RISC-V |
|---|---|---|
| Shift left | `shl eax, 2` | `lsl`(ARM)/`sll`(RV) |
| Shift right logical | `shr eax, 2` | `lsr`/`srl` |
| Shift right arithmetic | `sar eax, 2` | `asr`/`sra` |
| Rotate | `rol`/`ror` | `ror`(ARM)/no native rotate on base RV |

### E. Comparison
| Purpose | x86 | ARM64/RISC-V |
|---|---|---|
| Compare | `cmp eax, ebx` | `cmp`(ARM, alias of subs)/no cmp — RV uses branch-compare fused |
| Set flags based on result | implicit via flags reg | implicit (ARM) / RV has no flags reg — uses `slt`,`sltu` |

### F. Control Flow / Branch
| Purpose | x86 | ARM64/RISC-V |
|---|---|---|
| Unconditional jump | `jmp label` | `b label`(ARM)/`j label`(RV) |
| Conditional jump | `je`,`jne`,`jg`,`jl`... | `beq`,`bne`,`b.gt`... (ARM) / `beq`,`bne`,`blt`,`bge` (RV, compares directly, no flags) |
| Call function | `call func` | `bl func`(ARM)/`jal ra,func`(RV) |
| Return | `ret` | `ret`(ARM)/`jalr zero,ra,0`(RV) |
| Loop (built-in counter) | `loop label` (uses ECX) | no equivalent — compiler emits branch manually |

### G. Stack Operations
| Purpose | x86 | ARM64/RISC-V |
|---|---|---|
| Push | `push eax` | manual: `str x0,[sp,#-16]!` / `addi sp,sp,-16; sw t0,0(sp)` |
| Pop | `pop eax` | manual: `ldr x0,[sp],#16` / `lw t0,0(sp); addi sp,sp,16` |
| Call frame setup | `enter` (rare use) | manual prologue, no single instr |

### H. String / Memory Block (CISC-heavy category)
| Purpose | x86 | RISC |
|---|---|---|
| Copy string/block | `movs` (`rep movsb`) | no equivalent — loop written manually |
| Compare string | `cmps` (`rep cmpsb`) | manual loop |
| Scan string | `scas` | manual loop |
| Store string | `stos` | manual loop |

### I. I/O (legacy, x86-specific)
| Purpose | x86 | RISC |
|---|---|---|
| Port input | `in al, dx` | memory-mapped I/O only (no port instr) |
| Port output | `out dx, al` | memory-mapped I/O only |

### J. System / Privileged
| Purpose | x86 | ARM64/RISC-V |
|---|---|---|
| Syscall | `syscall`/`int 0x80` | `svc #0`(ARM)/`ecall`(RV) |
| Halt | `hlt` | `wfi`(ARM)/`wfi`(RV) |
| No-op | `nop` | `nop` (both) |
| Read control reg | `mov eax, cr0` | `mrs`(ARM)/`csrr`(RV) |

### K. Floating Point / SIMD
| Purpose | x86 | ARM64/RISC-V |
|---|---|---|
| FP add | `addss`/`addsd` (SSE) | `fadd`(ARM/RV both) |
| Vector ops | SSE/AVX (`vaddps` etc.) | NEON (ARM)/RVV (RISC-V Vector ext.) |

### L. Atomic / Synchronization
| Purpose | x86 | ARM64/RISC-V |
|---|---|---|
| Atomic exchange | `xchg` (implicit lock) | `swp`(ARMv8.1)/`amoswap`(RV) |
| Compare-and-swap | `cmpxchg` | `cas`(ARM)/`lr.w`+`sc.w`(RV, load-reserve/store-conditional) |
| Memory barrier | `mfence`/`lfence`/`sfence` | `dmb`(ARM)/`fence`(RV) |

## 4. Addressing Modes

| Mode | CISC (x86) | RISC (typical) |
|---|---|---|
| Immediate | `mov eax,5` | yes |
| Register | `mov eax,ebx` | yes |
| Direct memory | `mov eax,[0x1000]` | rare, needs 2 instr (load addr, then load) |
| Register indirect | `mov eax,[ebx]` | yes |
| Base + offset | `mov eax,[ebx+4]` | yes |
| Base + index + scale | `mov eax,[ebx+ecx*4+8]` | not native — split into separate add + load |
| PC-relative | `jmp label` | yes (branches only) |

## 5. Quick Decision Table (why RISC vs CISC matters)

| Concern | Winner | Why |
|---|---|---|
| Code density | CISC | complex instr = fewer bytes |
| Decode/pipeline simplicity | RISC | fixed length, easy to pipeline/superscalar |
| Compiler optimization ease | RISC | orthogonal, predictable instr set |
| Power efficiency | RISC | simpler decode logic → less silicon/watt |
| Backward compatibility | CISC | x86 legacy support since 1978 |
| Modern reality | Hybrid | x86 internally translates to RISC-like µops; ARM/RISC-V dominate mobile/embedded/cloud (Graviton, Apple Silicon) |

## 6. Register File Snapshot

| ISA | GP Registers | Notes |
|---|---|---|
| x86 (32-bit) | 8 (eax,ebx,ecx,edx,esi,edi,ebp,esp) | + segment regs, flags |
| x86-64 | 16 (rax–r15) | + XMM/YMM/ZMM for SIMD |
| ARM64 | 31 GP (x0–x30) + SP,PC | zero register absent (uses xzr alias) |
| RISC-V | 32 GP (x0–x31) | x0 hardwired to zero |

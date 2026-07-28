# Linux Memory Management — Full Meaning, Simple Words

*A reference guide to `/proc/vmstat`, `/proc/meminfo`, `vmstat`, `pmap`, `sar -B`, `numastat`, and `sysctl vm.*`*

---

## 1. `/proc/vmstat` — Virtual Memory Statistics

This file shows **counters** — numbers that keep increasing since the computer booted. Think of it like an odometer in a car: it counts total events, not the current speed.

| Field | Full Form / Meaning | Simple Explanation |
|---|---|---|
| `nr_free_pages` | Number of Free Pages | How many 4KB memory blocks are completely empty and ready to use |
| `nr_free_pages_blocks` | Free Page Blocks | Free memory grouped into bigger chunks (used for allocating large pieces at once) |
| `nr_zone_inactive_anon` | Inactive Anonymous Pages (zone) | Memory used by programs (not files) that hasn't been touched recently |
| `nr_zone_active_anon` | Active Anonymous Pages (zone) | Memory used by programs that IS being touched recently |
| `nr_zone_inactive_file` | Inactive File-backed Pages (zone) | File data cached in RAM, not used recently |
| `nr_zone_active_file` | Active File-backed Pages (zone) | File data cached in RAM, used recently |
| `nr_zone_unevictable` | Unevictable Pages | Memory the kernel is NOT allowed to remove (e.g. locked memory) |
| `nr_zone_write_pending` | Write Pending Pages | Data waiting to be written to disk |
| `nr_mlock` | Memory Locked Pages | Pages locked in RAM by a program (`mlock()` system call) so they can never be swapped out |
| `nr_zspages` | Zswap Compressed Pages | Pages compressed and stored in a special swap-like area |
| `nr_free_cma` | Free Contiguous Memory Allocator pages | Free memory reserved for big continuous chunks (used by hardware drivers) |
| `nr_unaccepted` | Unaccepted Pages | Memory not yet "accepted" by the kernel (used in confidential computing/virtual machines) |
| `numa_hit` | NUMA (Non-Uniform Memory Access) Hit | Memory was allocated from the "nearby/local" node — good for speed |
| `numa_miss` | NUMA Miss | Memory had to come from a "far/remote" node — slightly slower |
| `numa_foreign` | NUMA Foreign | Memory meant for a remote node was allocated locally instead |
| `numa_interleave` | NUMA Interleave | Memory spread evenly across all nodes on purpose |
| `numa_local` | NUMA Local | Memory allocated from the CPU's own local node |
| `numa_other` | NUMA Other | Memory allocated from a different node than expected |
| `nr_inactive_anon` / `nr_active_anon` | Inactive/Active Anonymous Pages (system-wide) | Same as zone versions above, but total across the whole system |
| `nr_inactive_file` / `nr_active_file` | Inactive/Active File Pages (system-wide) | Same as above, but for file-cache memory |
| `nr_unevictable` | Unevictable (system-wide) | Total memory that cannot be swapped out |
| `nr_slab_reclaimable` | Reclaimable Slab Memory | Kernel's internal memory (like caches) that CAN be freed if needed |
| `nr_slab_unreclaimable` | Unreclaimable Slab Memory | Kernel's internal memory that CANNOT be freed easily |
| `nr_isolated_anon` / `nr_isolated_file` | Isolated Pages | Pages temporarily set aside during memory cleanup (migration/compaction) |
| `workingset_nodes` | Working Set Tracking Nodes | Internal bookkeeping entries used to detect memory pressure |
| `workingset_refault_anon/file` | Working Set Refault | Counts how often recently-removed memory had to be brought back — a sign of memory shortage |
| `workingset_activate_anon/file` | Working Set Activate | Pages promoted from "inactive" to "active" list |
| `workingset_restore_anon/file` | Working Set Restore | Pages restored after being reclaimed, but they were still useful |
| `workingset_nodereclaim` | Working Set Node Reclaim | Count of internal tracking nodes that were cleaned up |
| `nr_anon_pages` | Anonymous Pages | Total memory used by running programs (not backed by any file) |
| `nr_mapped` | Mapped Pages | Memory pages linked into a program's address space |
| `nr_file_pages` | File Pages | Total memory used to cache file contents |
| `nr_dirty` | Dirty Pages | Pages changed in RAM but not yet saved to disk |
| `nr_writeback` | Writeback Pages | Pages currently being written to disk right now |
| `nr_shmem` | Shared Memory Pages | Memory shared between multiple programs (e.g. `/dev/shm`) |
| `nr_shmem_hugepages` / `nr_shmem_pmdmapped` | Shared Memory Huge Pages | Shared memory using bigger 2MB pages instead of 4KB |
| `nr_file_hugepages` / `nr_file_pmdmapped` | File Huge Pages | File cache using big 2MB pages |
| `nr_anon_transparent_hugepages` | Transparent Huge Pages (Anonymous) | Program memory automatically using big pages for speed |
| `nr_vmscan_write` | Virtual Memory Scan Write | Pages written out to swap during memory-pressure cleanup |
| `nr_vmscan_immediate_reclaim` | Immediate Reclaim | Pages freed immediately instead of waiting |
| `nr_dirtied` / `nr_written` | Total Dirtied / Written Pages | Running total of pages changed / saved to disk since boot |
| `nr_throttled_written` | Throttled Writes | Writes that were slowed down on purpose to protect the disk |
| `nr_kernel_misc_reclaimable` | Kernel Misc Reclaimable | Small extra kernel memory that can be freed if needed |
| `nr_foll_pin_acquired/released` | Follow Pin (get_user_pages pin) | Kernel temporarily "pins" memory so it can't move — count of pins taken/released |
| `nr_kernel_stack` | Kernel Stack Memory | Memory used for each process's kernel-mode stack |
| `nr_page_table_pages` | Page Table Pages | Memory used to store the "map" that translates program addresses to real RAM addresses |
| `nr_sec_page_table_pages` | Secondary Page Table Pages | Extra page tables used for virtual machines |
| `nr_iommu_pages` | IOMMU (Input-Output Memory Management Unit) Pages | Memory reserved for hardware devices talking directly to RAM |
| `nr_swapcached` | Swap Cache Pages | Pages that are in both RAM and swap at the same time |
| `pgdemote_*` | Page Demote | Pages moved to slower/cheaper memory tiers instead of being deleted |
| `nr_hugetlb` | HugeTLB (Huge Translation Lookaside Buffer) Pages | Manually reserved big pages (2MB or 1GB) |
| `nr_balloon_pages` | Balloon Pages | Memory "given back" to the virtual machine host on purpose |
| `nr_kernel_file_pages` | Kernel File Pages | File-backed memory used internally by the kernel |
| `nr_dirty_threshold` | Dirty Threshold | The point where the system starts forcing dirty pages to be saved to disk |
| `nr_dirty_background_threshold` | Background Dirty Threshold | The point where the system starts saving dirty pages quietly in the background |
| `nr_memmap_pages` / `nr_memmap_boot_pages` | Memory Map Pages | Memory used to store the kernel's "map" of all physical RAM |
| `pgpgin` / `pgpgout` | Pages Paged In / Out | Total data read from disk into RAM / written from RAM to disk (in KB blocks) |
| `pswpin` / `pswpout` | Pages Swapped In / Out | Data moved from swap space back to RAM / from RAM to swap space |
| `pgalloc_dma32/normal/movable/device` | Page Allocations by Zone | Where in memory (which "zone") new pages were allocated from |
| `allocstall_*` | Allocation Stall | Times a program had to WAIT because memory wasn't free enough |
| `pgskip_*` | Pages Skipped | Zones skipped during memory scanning |
| `pgfree` | Pages Freed | Total memory pages released since boot |
| `pgactivate` | Pages Activated | Pages moved from "inactive" to "active" list |
| `pgdeactivate` | Pages Deactivated | Pages moved from "active" to "inactive" list |
| `pglazyfree` / `pglazyfreed` | Lazy Free Pages | Memory marked "not needed anymore" but not deleted yet, to save time |
| `pgfault` | Page Faults (Minor) | Times a program asked for memory that had to be set up — but data was already in RAM (fast) |
| `pgmajfault` | Major Page Faults | Times memory had to be fetched from DISK (slow) — a real performance hit |
| `pgrefill` | Page Refill | Pages re-scanned to check if they're still being used |
| `pgreuse` | Page Reuse | An old page was reused instead of creating a fresh one |
| `pgsteal_*` | Pages Stolen | Memory forcibly reclaimed from programs when RAM was low |
| `pgscan_*` | Pages Scanned | Pages checked (but not necessarily taken) during a memory cleanup |
| `zone_reclaim_success/failed` | Zone Reclaim | Whether freeing memory in a NUMA zone worked or not |
| `pginodesteal` / `kswapd_inodesteal` | Inode Steal | Filesystem inode cache entries forcibly freed |
| `slabs_scanned` | Slabs Scanned | Kernel cache entries checked during cleanup |
| `kswapd_low/high_wmark_hit_quickly` | Kswapd Watermark Hit | The background memory-cleaning process (`kswapd`) had to react fast because memory got low quickly |
| `pageoutrun` | Page-out Run | Number of times the background cleaner (`kswapd`) woke up and ran |
| `pgrotated` | Pages Rotated | Pages moved to the back of the "reuse" list |
| `drop_pagecache` / `drop_slab` | Drop Caches | Manual commands used to clear cached memory (`echo 3 > /proc/sys/vm/drop_caches`) |
| `oom_kill` | Out Of Memory Kill | Number of times the kernel killed a program because RAM completely ran out |
| `pgmigrate_success/fail` | Page Migration | Pages successfully/unsuccessfully moved between memory zones or NUMA nodes |
| `thp_*` | Transparent Huge Pages stats | All the ways big 2MB pages were created, split, or failed |
| `compact_*` | Memory Compaction | The kernel rearranging scattered free memory into bigger continuous chunks |
| `htlb_buddy_alloc_success/fail` | HugeTLB Buddy Allocator | Success/failure count when reserving big fixed-size pages |
| `unevictable_pgs_*` | Unevictable Page stats | Tracking of memory that can never be swapped out |
| `swap_ra` / `swap_ra_hit` | Swap Read-Ahead | Kernel pre-loading extra swap pages, guessing they'll be needed soon |
| `swpin_zero` / `swpout_zero` | Swap Zero Pages | Empty (all-zero) pages swapped in/out — handled specially to save space |
| `ksm_swpin_copy` | Kernel Samepage Merging Swap-in Copy | Shared/merged memory pages copied when brought back from swap |
| `cow_ksm` | Copy-On-Write (from KSM) | A shared memory page had to be copied because one program changed it |
| `direct_map_level2/3_splits/collapses` | Direct Map Splits/Collapses | Kernel's internal memory-mapping table being broken into smaller/bigger pieces |
| `nr_unstable` | Unstable NFS Pages | Data sent to a network file system, not yet confirmed saved |

---

## 2. `/proc/meminfo` — Memory Info Summary

This is a **snapshot** (current values), not a running counter.

| Field | Full Form / Meaning | Simple Explanation |
|---|---|---|
| `MemTotal` | Total Memory | Total physical RAM installed |
| `MemFree` | Free Memory | RAM currently completely unused |
| `MemAvailable` | Available Memory | RAM that CAN be given to a new program without swapping (free + easily reclaimable cache) — the most realistic "how much can I use" number |
| `Buffers` | Disk Buffers | Small memory area caching raw disk blocks |
| `Cached` | Page Cache | RAM used to cache file contents so re-reading files is fast |
| `SwapCached` | Swap Cache | Pages that are in swap AND still copied in RAM |
| `Active` / `Inactive` | Active / Inactive Memory | Recently used memory vs. memory not touched in a while (candidate to be freed) |
| `Active(anon)` / `Inactive(anon)` | Anonymous Active/Inactive | Program memory (not file-backed), recently used or not |
| `Active(file)` / `Inactive(file)` | File-backed Active/Inactive | Cached file data, recently used or not |
| `Unevictable` | Unevictable Memory | Memory the kernel refuses to remove (locked pages) |
| `Mlocked` | Memory-Locked Pages | Pages locked by a program using `mlock()` |
| `SwapTotal` / `SwapFree` | Total / Free Swap | Total swap space configured, and how much is still empty |
| `Dirty` | Dirty Memory | Data changed in RAM, waiting to be saved to disk |
| `Writeback` | Writeback | Data currently in the process of being saved to disk |
| `AnonPages` | Anonymous Pages | Memory used directly by running programs (heap, stack, etc.) |
| `Mapped` | Mapped Memory | Files or libraries linked into a program's memory space (e.g. shared libraries) |
| `Shmem` | Shared Memory | Memory shared between processes |
| `KReclaimable` | Kernel Reclaimable Memory | Kernel caches that can be freed under memory pressure |
| `Slab` | Slab Memory | Kernel's internal object cache (for things like file handles, network buffers) |
| `SReclaimable` / `SUnreclaim` | Slab Reclaimable / Unreclaimable | Split of slab memory: freeable vs permanently needed |
| `KernelStack` | Kernel Stack | Memory used for kernel-side execution stack of each process |
| `PageTables` | Page Tables | Memory used to store address-translation tables |
| `SecPageTables` | Secondary Page Tables | Extra page tables used for virtual machines |
| `NFS_Unstable` | Network File System Unstable Pages | Data sent to a network drive, not yet fully confirmed written |
| `Bounce` | Bounce Buffers | Temporary memory used when hardware can't access certain RAM directly |
| `WritebackTmp` | Writeback Temporary | Temporary buffer used during some file-system writebacks (FUSE) |
| `CommitLimit` | Commit Limit | The maximum memory the system will promise to programs, based on RAM + swap and a safety setting |
| `Committed_AS` | Committed Address Space | Total memory currently promised to all running programs (may be more than what's actually used) |
| `VmallocTotal` / `VmallocUsed` / `VmallocChunk` | Virtual Malloc | A special address range the kernel uses for large, non-contiguous memory allocations |
| `Percpu` | Per-CPU Memory | Small memory areas reserved separately for each CPU core |
| `HardwareCorrupted` | Hardware Corrupted Memory | RAM marked bad due to hardware errors |
| `AnonHugePages` | Anonymous Huge Pages | Program memory using big 2MB pages |
| `ShmemHugePages` / `ShmemPmdMapped` | Shared Memory Huge Pages | Shared memory using big pages |
| `FileHugePages` / `FilePmdMapped` | File Huge Pages | Cached file data using big pages |
| `Unaccepted` | Unaccepted Memory | Memory not yet accepted by the kernel (confidential VM feature) |
| `Balloon` | Balloon Memory | Memory temporarily handed back to a virtual machine host |
| `HugePages_Total/Free/Rsvd/Surp` | Huge Pages Total/Free/Reserved/Surplus | Manually configured big-page pool status |
| `Hugepagesize` | Huge Page Size | Size of each big page (commonly 2048 KB = 2MB) |
| `Hugetlb` | HugeTLB Total | Total memory used by the huge page pool |
| `DirectMap4k/2M/1G` | Direct Map | How much of physical RAM the kernel maps using 4KB, 2MB, or 1GB page sizes (bigger = faster access, less overhead) |

---

## 3. `vmstat 1` — Live Virtual Memory Stats (every 1 second)

| Column | Full Form | Meaning |
|---|---|---|
| `r` | Running | Number of processes currently running or waiting for CPU |
| `b` | Blocked | Number of processes waiting (usually for disk I/O) |
| `swpd` | Swap Used | Amount of virtual memory currently in swap |
| `free` | Free Memory | Idle RAM (KB) |
| `buff` | Buffers | RAM used for raw disk block buffers |
| `cache` | Cache | RAM used for file cache |
| `si` | Swap In | KB/sec moved from swap into RAM |
| `so` | Swap Out | KB/sec moved from RAM into swap |
| `bi` | Blocks In | Blocks received from disk (per second) |
| `bo` | Blocks Out | Blocks sent to disk (per second) |
| `in` | Interrupts | Number of hardware interrupts per second |
| `cs` | Context Switches | Number of times the CPU switched between tasks per second |
| `us` | User Time | % CPU time spent running normal programs |
| `sy` | System Time | % CPU time spent running kernel code |
| `id` | Idle Time | % CPU time doing nothing |
| `wa` | I/O Wait | % CPU time waiting for disk/network |
| `st` | Steal Time | % CPU time "stolen" by the virtual machine host (relevant in cloud/VM) |
| `gu` | Guest Time | % CPU time spent running a virtual machine's guest OS |

**Your reading:** `id` stays around 95-98%, so the CPU is mostly idle — the machine is healthy and not under load.

---

## 4. `swapon --show`

Shows active swap space.
- `NAME`: which disk partition is used as swap (`/dev/sdc`)
- `TYPE`: `partition` = a dedicated disk partition (not a swap file)
- `SIZE`: total swap size (2 GB)
- `USED`: how much swap is actually in use (0B — swap is not being used at all, which is good, means enough RAM is free)
- `PRIO`: Priority — order in which multiple swap areas would be used (lower priority number used later)

---

## 5. `pmap $$` — Process Memory Map

`$$` means "the current shell's own Process ID (PID)". This shows every memory segment `bash` has mapped:

| Column | Meaning |
|---|---|
| Address (e.g. `00005e98fa983000`) | Starting virtual memory address of that segment |
| Size (e.g. `192K`) | How much memory that segment takes |
| Permissions (`r---`, `r-x--`, `rw---`) | `r` = Read, `w` = Write, `x` = Execute, `-` = not allowed |
| Name (`bash`, `libc.so.6`, `[ anon ]`, `[ stack ]`) | What that memory is for — the program itself, a shared library, unnamed/anonymous memory, or the stack |

Key items seen:
- `libc.so.6` = the C standard library (shared by almost every Linux program)
- `libtinfo.so.6.4` = terminal info library (controls terminal display)
- `ld-linux-x86-64.so.2` = the dynamic linker (loads shared libraries when a program starts)
- `LC_*` files = Locale (language/region) settings
- `[ stack ]` = the function-call stack for this process
- `total 5236K` = Bash currently uses about 5.1 MB of mapped memory — very light

---

## 6. `sar -B 1` — System Activity Report, Paging Statistics

| Column | Full Form | Meaning |
|---|---|---|
| `pgpgin/s` | Pages Paged In per second | KB read from disk into RAM per second |
| `pgpgout/s` | Pages Paged Out per second | KB written from RAM to disk per second |
| `fault/s` | Page Faults per second | Minor page faults (fast, data already in RAM) |
| `majflt/s` | Major Faults per second | Slow page faults needing a disk read |
| `pgfree/s` | Pages Freed per second | Memory pages released per second |
| `pgscank/s` | Pages Scanned by kswapd per second | Kernel's background cleaner checking pages |
| `pgscand/s` | Pages Scanned Directly per second | A program itself forced to scan for free memory (sign of pressure) |
| `pgsteal/s` | Pages Stolen per second | Memory forcibly reclaimed per second |
| `pgprom/s` | Pages Promoted per second | Pages moved to faster memory tier |
| `pgdem/s` | Pages Demoted per second | Pages moved to slower memory tier |

**Your reading:** `majflt/s` is 0.00 the whole time — no slow disk-based page faults. `pgscank/pgscand/pgsteal` are all 0 — no memory pressure at all.

---

## 7. `numastat` — NUMA (Non-Uniform Memory Access) Statistics

| Field | Meaning |
|---|---|
| `numa_hit` | Memory successfully allocated from the intended (local) node |
| `numa_miss` | Memory allocated from the wrong node because the right one was full |
| `numa_foreign` | Memory meant for another node ended up here instead |
| `interleave_hit` | Memory deliberately spread evenly across nodes, and it worked |
| `local_node` | Allocations served by the CPU's own local memory node |
| `other_node` | Allocations served by a different, remote memory node |

**Your reading:** Only `node0` exists (single NUMA node — normal for most laptops/desktops/WSL). `numa_miss` and `other_node` are 0, meaning there's no cross-node memory penalty.

---

## 8. `sysctl -a | grep vm` — Virtual Memory Kernel Tuning Parameters

| Parameter | Full Form / Meaning | Simple Explanation |
|---|---|---|
| `vm.admin_reserve_kbytes` | Admin Reserve | RAM reserved so the root/admin user can still log in even if memory is nearly full |
| `vm.compact_unevictable_allowed` | Compaction of Unevictable Pages Allowed | Whether locked memory can still be moved around during compaction |
| `vm.compaction_proactiveness` | Compaction Proactiveness | How aggressively the kernel tries to defragment free memory in advance (0-100) |
| `vm.defrag_mode` | Defragmentation Mode | Controls how huge pages are defragmented |
| `vm.dirty_background_ratio` | Dirty Background Ratio | % of RAM that can be "dirty" (unsaved) before background saving starts quietly |
| `vm.dirty_ratio` | Dirty Ratio | % of RAM that can be dirty before the system FORCES saves and slows down programs |
| `vm.dirty_expire_centisecs` | Dirty Expire Time | How old (in 1/100 sec) a dirty page can get before it must be saved |
| `vm.dirty_writeback_centisecs` | Dirty Writeback Interval | How often (in 1/100 sec) the background writer checks for dirty pages |
| `vm.dirtytime_expire_seconds` | Dirty Time Expire | How long "only the timestamp changed" data can wait before being saved |
| `vm.enable_soft_offline` | Soft Offline Enable | Allow the kernel to quietly retire a failing memory page |
| `vm.extfrag_threshold` | External Fragmentation Threshold | How fragmented memory must be before the kernel tries to defragment it |
| `vm.hugetlb_optimize_vmemmap` | HugeTLB Vmemmap Optimization | Saves extra memory bookkeeping space when using huge pages |
| `vm.hugetlb_shm_group` | HugeTLB Shared Memory Group | Which user group is allowed to use huge pages for shared memory |
| `vm.laptop_mode` | Laptop Mode | Special power-saving disk write behavior for laptops |
| `vm.legacy_va_layout` | Legacy Virtual Address Layout | Use the old-style memory layout instead of modern randomized layout |
| `vm.lowmem_reserve_ratio` | Low Memory Reserve Ratio | How much memory each zone reserves so critical low-memory allocations don't fail |
| `vm.max_map_count` | Maximum Memory Map Count | Maximum number of separate memory areas one process can have |
| `vm.memfd_noexec` | Memory File Descriptor No-Execute | Whether anonymous memory files can be marked executable (security setting) |
| `vm.memory_failure_early_kill` | Memory Failure Early Kill | Kill a program immediately if its memory has a hardware error, instead of waiting |
| `vm.memory_failure_recovery` | Memory Failure Recovery | Try to recover from hardware memory errors instead of crashing |
| `vm.min_free_kbytes` | Minimum Free KB | The kernel always tries to keep at least this much RAM free for emergencies |
| `vm.min_slab_ratio` | Minimum Slab Ratio | Minimum % of a zone that must stay as kernel slab cache |
| `vm.min_unmapped_ratio` | Minimum Unmapped Ratio | Minimum % of file cache the kernel keeps before reclaiming it |
| `vm.mmap_min_addr` | Memory Map Minimum Address | Lowest memory address a program is allowed to map (security: blocks null-pointer exploits) |
| `vm.mmap_rnd_bits` / `vm.mmap_rnd_compat_bits` | Memory Map Randomization Bits | How much randomness is added to memory addresses (security: ASLR — Address Space Layout Randomization) |
| `vm.nr_hugepages` | Number of Huge Pages | How many big (2MB) pages are pre-reserved right now |
| `vm.nr_hugepages_mempolicy` | Huge Pages Memory Policy | Which NUMA node huge pages should be allocated from |
| `vm.nr_overcommit_hugepages` | Overcommit Huge Pages | Extra huge pages allowed beyond the normal reserved pool |
| `vm.numa_stat` | NUMA Statistics | Whether NUMA stats collection is turned on |
| `vm.numa_zonelist_order` | NUMA Zone List Order | Order in which memory zones are searched on NUMA systems |
| `vm.oom_dump_tasks` | OOM Dump Tasks | Whether to print a list of all processes when the Out-Of-Memory killer runs |
| `vm.oom_kill_allocating_task` | OOM Kill Allocating Task | Whether to kill the exact program that triggered the out-of-memory event (instead of picking the "worst" one) |
| `vm.overcommit_memory` | Overcommit Memory Mode | Whether the kernel allows promising more memory than physically exists (0 = smart guess, 1 = always allow, 2 = never exceed limit) |
| `vm.overcommit_ratio` | Overcommit Ratio | % of RAM (plus swap) allowed to be promised when overcommit mode is strict |
| `vm.overcommit_kbytes` | Overcommit KB | Same idea as ratio, but as a fixed KB number instead of percentage |
| `vm.page-cluster` | Page Cluster | How many pages are read together at once when swapping in (reduces disk seeks) |
| `vm.page_lock_unfairness` | Page Lock Unfairness | Tuning value for how page locks are shared between competing processes |
| `vm.panic_on_oom` | Panic on Out-Of-Memory | Whether the whole system should crash (panic) instead of killing a process when memory runs out |
| `vm.percpu_pagelist_high_fraction` | Per-CPU Page List High Fraction | Tuning for per-CPU memory allocation caching |
| `vm.stat_interval` | Statistics Interval | How often (seconds) `/proc/vmstat` numbers are refreshed |
| `vm.swappiness` | Swappiness | How eager the kernel is to swap out memory (0 = avoid swap as much as possible, 100 = swap aggressively). Your value is 60 (default, balanced) |
| `vm.unprivileged_userfaultfd` | Unprivileged User Fault FD | Whether normal (non-root) programs can use the user-space page-fault handling feature |
| `vm.user_reserve_kbytes` | User Reserve KB | RAM reserved so normal user programs don't get completely locked out during high memory use |
| `vm.vfs_cache_pressure` | Virtual File System Cache Pressure | How aggressively the kernel reclaims filesystem metadata cache (inodes/dentries) vs. keeping it. 100 = balanced |
| `vm.vfs_cache_pressure_denom` | VFS Cache Pressure Denominator | The scale/denominator used with the pressure value above |
| `vm.watermark_boost_factor` | Watermark Boost Factor | How much extra the kernel raises its "free memory" targets temporarily during fragmentation |
| `vm.watermark_scale_factor` | Watermark Scale Factor | Fine-tunes the gap between "low" and "min" free-memory watermarks |
| `vm.zone_reclaim_mode` | Zone Reclaim Mode | Whether to reclaim memory locally within a NUMA zone before reaching to a remote node (0 = disabled, prefer remote memory over local reclaim) |

---

## Quick Health Check of Your System

- **RAM**: 8 GB total, about 6 GB free/available → plenty of headroom
- **Swap**: 2 GB configured, 0 B used → RAM has never run low enough to need swap
- **Major page faults**: near zero → no slow disk-based memory stalls
- **CPU**: 95-98% idle in `vmstat` → system is calm, not overloaded
- **NUMA**: single node, no misses → no penalty from memory placement
- **Compaction/OOM kill counters**: all 0 → memory has never been fragmented or exhausted enough to need emergency action

Overall: this machine is running light and healthy, well within its memory limits.

---
*Reference notes compiled by m.manikandan*

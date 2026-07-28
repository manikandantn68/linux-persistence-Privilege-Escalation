# Dentry (Directory Entry) on Linux — Full Meaning, Simple Words

*A reference guide to viewing and understanding Dentries — the Linux kernel objects that connect file names to inodes*

---

## What is a Dentry?

**Dentry** = **D**irectory **Entry**

A dentry is NOT the file itself and NOT the inode. It's the small kernel object that sits in between — it links a **name** (like `report.txt`) to the **inode** (the object holding the file's actual metadata: size, permissions, data block locations).

Think of it like this:
- **Inode** = the file's ID card (all its real details, but no name on it)
- **Dentry** = a sticky note that says "this ID card is called `report.txt` and it lives inside this folder"

Every time you type a path like `/home/angel/report.txt`, the kernel walks through a **chain of dentries** — one for `/`, one for `home`, one for `angel`, one for `report.txt` — to find the final inode. This is called **path lookup** or **path walking**.

To make this fast (so the kernel doesn't re-read the disk every time), dentries are kept in memory in a cache called the **dcache** (**D**entry **Cache**).

---

## 1. Check Dentry Cache Statistics

```bash
cat /proc/sys/fs/dentry-state
```

Example output:
```
83214   64500   45  0  0  0
```

| Position | Field | Full Form / Meaning |
|---|---|---|
| 1 | `nr_dentry` | Number of Dentries — total dentry objects currently allocated in memory |
| 2 | `nr_unused` | Number Unused — dentries not currently in active use, sitting idle in cache, reusable/reclaimable |
| 3 | `age_limit` | Age Limit — how many seconds (used historically) before an unused dentry becomes eligible for cleanup |
| 4 | `want_pages` | Want Pages — pages requested to be freed the last time the system ran low on memory (legacy field, usually 0) |
| 5 | `nr_negative` | Number of Negative Dentries — cached "this file does NOT exist" lookups (explained below) |
| 6 | (unused) | Dummy — reserved field, not currently used by the kernel |

**Negative Dentry** — a special dentry that remembers "I already checked, this file name does NOT exist here," so the kernel doesn't waste time checking the disk again next time the same missing file is looked up.

---

## 2. View Dentry Cache Memory Usage (Slab Info)

```bash
cat /proc/slabinfo | grep dentry
```

Example output:
```
dentry   45210   45500   192   21   1 : tunables 0 0 0 : slabdata  2166  2166  0
```

**Slab** = a chunk of memory the kernel pre-slices into equal-sized boxes for one specific type of object (here, dentry objects), so it can create/destroy them quickly without extra overhead.

| Field | Full Form / Meaning |
|---|---|
| `dentry` | Name — the slab cache holding all dentry objects |
| `active_objs` | Active Objects — dentries currently in use |
| `num_objs` | Number of Objects — total dentry objects allocated (used + spare) |
| `objsize` | Object Size — size in bytes of one dentry structure (here, 192 bytes) |
| `objperslab` | Objects Per Slab — how many dentry objects fit in one slab page group |
| `pagesperslab` | Pages Per Slab — how many memory pages make up one slab |
| `slabdata` | Slab Data — 3 numbers: total slabs, total objects, and free objects |

**Note:** `/proc/slabinfo` often needs `sudo` to view fully:
```bash
sudo cat /proc/slabinfo | grep dentry
```

---

## 3. Live View With slabtop

```bash
slabtop
```

`slabtop` shows a live, auto-refreshing, `top`-style view of all kernel slab caches, sorted by size. Look for the `dentry` row.

| Column | Meaning |
|---|---|
| `OBJS` | Total dentry objects right now |
| `ACTIVE` | Objects currently in use |
| `USE` | % of objects active out of total allocated |
| `OBJ SIZE` | Size of one dentry object in bytes |
| `SLABS` | Number of slab groups |
| `CACHE SIZE` | Total memory (bytes) used by this cache |
| `NAME` | Cache name (`dentry`) |

Press `q` to quit.

---

## 4. Control How Aggressively Dentries Get Reclaimed

```bash
sysctl vm.vfs_cache_pressure
```

`VFS` = **V**irtual **F**ile **S**ystem — the common layer inside Linux that all filesystems (ext4, xfs, btrfs, etc.) plug into. This one setting controls reclaim pressure for BOTH dentries and inodes together, since they're closely linked.

| Value | Meaning |
|---|---|
| Below 100 | Kernel prefers to KEEP dentry/inode cache, reclaims them more slowly |
| 100 (default) | Balanced — treat dentry/inode cache reclaim the same as normal page cache reclaim |
| Above 100 | Kernel reclaims dentry/inode cache MORE aggressively, freeing memory faster but slowing down repeated file lookups |

To change it temporarily:
```bash
sudo sysctl -w vm.vfs_cache_pressure=50
```
`-w` = **Write** a new value.

---

## 5. See the Inode Behind a Filename (What a Dentry Points To)

```bash
ls -i filename
```

`-i` = **Inode** — shows the inode number linked to that filename (i.e., what the dentry for this name points to).

Example:
```bash
ls -i report.txt
```
```
1315862 report.txt
```

For full detail:
```bash
stat filename
```

`stat` = **Status** — shows everything about the inode: size, permissions, owner, timestamps, and the inode number, all reached through that file's dentry.

---

## 6. Find a File by Its Inode Number

```bash
find / -inum 1315862
```

`-inum` = **Inode Number** — searches the whole filesystem for whichever dentry/dentries currently point to this exact inode. Useful because **one inode can have multiple dentries** pointing to it — this happens with **hard links** (two different names for the exact same file data).

---

## 7. Drop the Dentry and Inode Caches (Force Cleanup)

```bash
sync; echo 2 | sudo tee /proc/sys/vm/drop_caches
```

`sync` = flush all pending disk writes first (so nothing important is lost).

| Value written | What gets dropped |
|---|---|
| `1` | Page cache only (cached file contents) |
| `2` | Dentries and inodes only |
| `3` | Everything — page cache + dentries + inodes |

This is normally only used for testing/benchmarking — Linux is designed to manage this cache automatically and safely on its own.

---

## 8. Watch Dentry Lookups Happen Live

```bash
strace -e trace=open,openat,stat,lstat ls /home/angel
```

`strace` = **System Call Trace** — shows every low-level request a program makes to the kernel. Each `open`, `openat`, `stat`, or `lstat` call triggers a **path walk**, which means the kernel is checking dentries step-by-step to reach the final file.

---

## 9. Inside the Kernel: What a Dentry Structure Actually Holds

For deeper study, the kernel defines every dentry using the C structure `struct dentry` (found in `include/linux/dcache.h`). Key fields, simplified:

| Field | Full Form / Meaning |
|---|---|
| `d_name` | Dentry Name — the actual filename text this dentry represents |
| `d_inode` | Dentry's Inode — pointer to the real inode this name points to (NULL if it's a negative dentry) |
| `d_parent` | Parent Dentry — pointer to the dentry of the containing folder |
| `d_subdirs` | Subdirectories — list of child dentries inside this one (if it's a directory) |
| `d_child` | Child Entry — this dentry's position in its parent's list of children |
| `d_hash` | Hash List Entry — this dentry's position in the dcache's hash table, for fast lookup |
| `d_lru` | Least Recently Used List | position in the reclaim list — decides which unused dentries get freed first |
| `d_lockref` | Lock + Reference Count | combined lock and usage counter, tracks how many things are currently using this dentry |
| `d_sb` | Superblock | pointer to the filesystem (mounted volume) this dentry belongs to |
| `d_flags` | Dentry Flags | status bits (e.g., is this a negative dentry, is it a mount point, etc.) |
| `d_op` | Dentry Operations | pointer to a set of filesystem-specific functions for comparing/hashing/releasing this dentry |
| `d_fsdata` | Filesystem-specific Data | extra private data a specific filesystem type can attach |

---

## Most Useful Commands (Cheat Sheet)

| Command | What it tells you |
|---|---|
| `cat /proc/sys/fs/dentry-state` | Current dentry cache counts (total, unused, negative) |
| `cat /proc/slabinfo \| grep dentry` | Memory used by the dentry cache |
| `slabtop` | Live view of dentry (and other) kernel memory caches |
| `sysctl vm.vfs_cache_pressure` | How aggressively dentries/inodes get reclaimed |
| `ls -i file` | Inode number behind a file's dentry |
| `stat file` | Full inode details reached via the dentry |
| `find / -inum N` | All filenames (dentries) pointing to inode N (hard links) |
| `strace -e trace=open,stat cmd` | Watch dentry/path lookups happen live |

---

## Quick Summary

- A **Dentry** is the link between a **file name** and its **inode** — it does not store file data itself.
- Dentries are cached in memory (the **dcache**) so repeated path lookups (like opening the same file twice) are fast.
- A **negative dentry** remembers that a name does NOT exist, to avoid repeated failed disk lookups.
- `vm.vfs_cache_pressure` controls how eagerly the kernel throws away old, unused dentries when memory is needed elsewhere.
- One inode can have several dentries (hard links) pointing to it — but each dentry points to exactly one inode.

---
*Reference notes compiled by m.manikandan*

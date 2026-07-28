# Zoned Block Devices on Linux — Full Meaning, Simple Words

*A reference guide to Zoned Storage: SMR disks, ZNS SSDs, zone states, write pointers, and the commands to view them*

---

## What is a Zoned Block Device?

A **Zoned Block Device (ZBD)** is a storage drive that divides its space into **fixed-size regions called zones**, and forces a rule: **inside a zone, you can only write sequentially (in order), from start to end** — you cannot jump back and overwrite the middle of a zone like you can on a normal disk.

This is different from a **normal (non-zoned) block device**, where you can write to any location (any block/sector) at any time, in any order — called **random write** access.

Zoned devices trade away this flexibility to pack in **much higher storage capacity** and better performance for large sequential workloads (video storage, logs, backups, big data).

---

## 1. Why Zones Exist — The Hardware Reason

### SMR = Shingled Magnetic Recording

On a traditional hard disk (**CMR** = **C**onventional **M**agnetic **R**ecording), data tracks are written side-by-side with a small gap, like parallel lines on paper.

**SMR** disks overlap the tracks like **roof shingles** — each new track partially covers the previous one. This packs far more data into the same physical disk space, boosting capacity by 20–30% or more.

**The catch:** because tracks overlap, you can't safely rewrite just one narrow track in the middle without also disturbing (and destroying) the data on the neighboring overlapped track. So the disk is divided into **zones**, and each zone must be written **sequentially, from the beginning**, to avoid this overlap problem.

### ZNS = Zoned Namespaces (for SSDs)

Modern flash **SSDs** (**S**olid **S**tate **D**rives) using **NVMe** (**N**on-**V**olatile **M**emory **E**xpress) can also use zoning — called **ZNS**. Here the goal is different: SSD flash memory wears out faster with random writes and needs extra background cleanup (**garbage collection**). Sequential-only zones reduce that wear and let the SSD manage itself more efficiently, extending its lifespan.

---

## 2. Check If a Device Is Zoned

```bash
cat /sys/block/sda/queue/zoned
```

Example outputs:

| Output | Meaning |
|---|---|
| `none` | Not a zoned device — normal random-write disk |
| `host-aware` | Zoned, but the drive is "polite" — it will still accept random writes if asked, though sequential writes work best |
| `host-managed` | Strictly zoned — the drive will REJECT any write that breaks the sequential-only rule; the operating system MUST cooperate |

Quick overview across all disks:

```bash
lsblk -z
```

`-z` = **Zoned** — adds a column showing which listed devices are zoned block devices.

---

## 3. View a Full Zone Report

```bash
sudo blkzone report /dev/sda
```

`blkzone` = the standard Linux command-line tool for reading and managing zone information. `report` = list every zone on the device with its current details.

Example output line:
```
start: 0x000000000, len 0x080000, cap 0x080000, wptr 0x000000, zcond: 1(em), [type: 2(SEQ_WRITE_REQUIRED)]
```

| Field | Full Form / Meaning |
|---|---|
| `start` | Starting sector (address) of this zone on the disk |
| `len` | Length — total size of the zone, in sectors |
| `cap` | Capacity — usable size within the zone (sometimes slightly smaller than `len`) |
| `wptr` | Write Pointer — the exact position where the NEXT write must land (explained below) |
| `zcond` | Zone Condition — the zone's current state (empty, open, full, etc. — see the table below) |
| `type` | Zone Type — what kind of write rules this zone follows (see the table below) |

---

## 4. The Write Pointer (wptr)

Every sequential zone keeps a single marker called the **Write Pointer** — it always points to the first empty sector in that zone. Every new write must start exactly at the write pointer; you cannot write anywhere else in that zone. After the write finishes, the pointer automatically moves forward by however much data was just written.

This turns each zone into something like a notebook where you can only ever write on the next blank line — never go back and edit an earlier line, and never skip ahead.

---

## 5. Zone Types

| Type | Full Form / Meaning |
|---|---|
| **Conventional Zone** | A zone that still allows normal random writes (like an old-style disk) — usually a small area reserved for filesystem metadata that needs frequent updates |
| **Sequential Write Required (SWR)** | Strict zone — writes MUST happen in order at the write pointer; any out-of-order write is rejected by the drive |
| **Sequential Write Preferred (SWP)** | Softer rule — the drive prefers sequential writes for best performance, but will still allow random writes if forced (used in `host-aware` drives) |

---

## 6. Zone States (Zone Condition)

Every zone is always in exactly one of these states:

| State | Meaning |
|---|---|
| **Empty** | Zone has never been written to — write pointer is at the very start |
| **Implicit Open** | Zone has started receiving writes automatically, without the host explicitly "opening" it first |
| **Explicit Open** | Host application deliberately opened this zone in advance, reserving it for upcoming writes |
| **Closed** | Zone was open but writing has paused; it still holds its place in the write pointer, ready to resume later |
| **Full** | Zone has been completely written, write pointer has reached the end — no more writes allowed until reset |
| **Read-Only** | Zone can still be read, but no more writes are allowed (often due to a detected issue) |
| **Offline** | Zone has failed and cannot be read or written at all |

---

## 7. Reset a Zone (Erase It Back to Empty)

```bash
sudo blkzone reset /dev/sda -o 0 -l 1048576
```

`reset` = wipes a zone's data and moves its write pointer back to the very start, making it **Empty** again — this is the ONLY way to reuse a **Full** zone; you cannot simply overwrite the middle.

| Flag | Full Form / Meaning |
|---|---|
| `-o` | Offset — starting sector of the zone to reset |
| `-l` | Length — how many sectors (i.e., how much of the zone) to reset |

To reset every zone on the whole device at once:
```bash
sudo blkzone reset /dev/sda
```

---

## 8. Check the Zone Size

```bash
cat /sys/block/sda/queue/chunk_sectors
```

`chunk_sectors` — shows the size of each zone, measured in 512-byte sectors. Multiply by 512 to get the zone size in bytes (e.g., `262144` sectors × 512 bytes = 128 MB per zone).

---

## 9. Zoned NVMe SSDs (ZNS) — Extra Commands

For NVMe SSDs using **Zoned Namespaces (ZNS)**, the `nvme-cli` tool provides similar commands:

```bash
sudo nvme zns report-zones /dev/nvme0n1
```

`nvme-cli` = the standard command-line tool for managing NVMe drives. `zns report-zones` = same idea as `blkzone report`, but specifically for NVMe's zoned namespace feature.

```bash
sudo nvme zns id-ctrl /dev/nvme0
```

`id-ctrl` = **Identify Controller** — shows the NVMe controller's zoned-namespace capabilities and limits.

---

## 10. ZoneFS — A Simple Filesystem Built for Zoned Devices

```bash
sudo mkfs.zonefs /dev/sda
sudo mount -t zonefs /dev/sda /mnt/zones
```

**ZoneFS** is a minimal Linux filesystem that exposes each zone on the device as a **single file** — writing to that file automatically respects the zone's sequential write pointer rules. It's mainly used by applications (like databases) that want to manage zones directly themselves, rather than relying on a full general-purpose filesystem.

---

## Most Useful Commands (Cheat Sheet)

| Command | What it tells you |
|---|---|
| `cat /sys/block/sda/queue/zoned` | Whether the device is zoned, and what kind |
| `lsblk -z` | Quick overview of zoned devices on the system |
| `sudo blkzone report /dev/sda` | Full list of every zone: position, capacity, write pointer, state, type |
| `sudo blkzone reset /dev/sda` | Erase zone(s) back to Empty so they can be reused |
| `cat /sys/block/sda/queue/chunk_sectors` | Size of each zone |
| `sudo nvme zns report-zones /dev/nvme0n1` | Zone report for an NVMe ZNS SSD |

---

## Quick Summary

- A **Zoned Block Device** splits storage into fixed-size **zones** that must be written **sequentially**, not randomly.
- **SMR** disks use zoning because their overlapping "shingled" tracks physically can't support safe random writes.
- **ZNS** SSDs use zoning to reduce flash wear and simplify the drive's internal cleanup work.
- Each zone tracks a **Write Pointer** — the only valid place the next write can land.
- Zones move through states: **Empty → Open (implicit/explicit) → Closed/Full**, and must be **reset** to go back to Empty.
- `blkzone` (for SCSI/SATA zoned disks) and `nvme zns` (for NVMe ZNS SSDs) are the two main tools for viewing and managing zones directly from Linux.

---
*Reference notes compiled by m.manikandan*

# Linux I/O Scheduler — Full Meaning, Simple Words

*A reference guide to the Linux Elevator Scheduler, Deadline Scheduler, CFQ, NOOP, Block Multi-Queue, and how to view/change them*

---

## What is an I/O Scheduler?

**I/O** = **I**nput/**O**utput

Every time a program wants to read from or write to a disk, that request goes into a queue first — it isn't done instantly. The **I/O Scheduler** is the part of the kernel that decides **which request in that queue gets sent to the disk next, and in what order**.

Why does order matter? On an old spinning **HDD** (**H**ard **D**isk **D**rive), the read/write head has to physically move across the spinning disk. Jumping randomly between far-apart locations is slow. So the scheduler tries to organize requests smartly to reduce wasted movement — similar to how a building elevator works.

---

## 1. The "Elevator" Analogy — Linux Elevator Scheduler

The Linux I/O scheduling subsystem is nicknamed the **Elevator Scheduler** because of how it behaves, just like a real building elevator:

- An elevator doesn't go to floors in the exact order people press buttons.
- It travels smoothly in one direction (say, upward), stopping at every requested floor along the way, then reverses.
- This avoids wasteful zig-zagging up and down.

Similarly, the disk I/O scheduler often **sorts pending read/write requests by their location on disk**, then serves them in that sorted order — minimizing how far the disk head has to physically travel. This general design is why the kernel folder for these schedulers is literally named `elevator` in older kernels.

---

## 2. Check Which Scheduler Is Active Right Now

```bash
cat /sys/block/sda/queue/scheduler
```

Replace `sda` with your actual disk name (check with `lsblk`).

Example output:
```
[mq-deadline] kyber bfq none
```

- The name inside **`[square brackets]`** is the **currently active** scheduler.
- The other names listed are **available but not selected**.

---

## 3. Change the Active Scheduler

```bash
echo bfq | sudo tee /sys/block/sda/queue/scheduler
```

This writes a new scheduler name into the same file, switching it immediately (until reboot — see the "make it permanent" section below).

---

## 4. The Classic (Legacy) Schedulers

Older Linux kernels (before roughly 2018) let you choose between four classic schedulers. You may still see these names in documentation, exams, or older systems.

### a) NOOP Scheduler

**NOOP** = **N**o **O**p**e**ration

- Does almost nothing — just merges requests that are next to each other on disk, then sends them out in the exact order they arrived (**FIFO**).
- No sorting, no fancy logic.
- Best for **SSDs** (**S**olid **S**tate **D**rives) and **RAID** (**R**edundant **A**rray of **I**ndependent **D**isks) controllers, since there's no physical head movement to optimize for — the hardware itself is already fast and random-access.

### b) Deadline Scheduler

Designed to guarantee that no single request waits forever, by giving every request an **expiry deadline**.

### c) Anticipatory Scheduler

- Adds a short deliberate **pause** after finishing a read request, "anticipating" (guessing) that the same program will ask for the next nearby block very soon.
- Trades a tiny bit of delay for much better overall read performance on slow spinning disks.
- Mostly obsolete now — modern deadline/CFQ-style logic replaced it, since SSDs don't benefit from this kind of guessing.

### d) Completely Fair Queuing (CFQ)

- **CFQ** = **C**ompletely **F**air **Q**ueuing
- Gives each running process its own individual queue, and takes turns serving each queue for a small time-slice — similar to how CPU time-sharing works between processes.
- Goal: no single greedy program can hog the disk; every process gets a "fair" share of I/O time.
- Was the default on many desktop Linux distributions for years, but has since been replaced by **BFQ** (**B**udget **F**air **Q**ueueing), a more advanced fairness-based scheduler.

---

## 5. Deep Dive: How the Deadline Scheduler Works Internally

The Deadline scheduler (and `mq-deadline`, its modern version) organizes requests using several internal queues:

| Queue | Full Form / Meaning |
|---|---|
| **Sorted Queue** | Requests arranged in order of their position on disk (lowest to highest block address), so the disk head moves smoothly in one direction — just like the elevator analogy |
| **Read FIFO Queue** | **F**irst **I**n **F**irst **O**ut queue holding only READ requests, ordered purely by arrival time, each with a deadline (default ~500ms) |
| **Write FIFO Queue** | Same idea, but for WRITE requests, with their own separate deadline (default ~5 seconds — writes are allowed to wait longer since programs rarely block waiting on them) |
| **Dispatch Queue** | The final queue — requests actually about to be sent to the disk hardware right now |

**How it decides what to send next:**
1. Normally, pull the next request from the **Sorted Queue** (efficient, smooth disk movement).
2. BUT, if a request sitting in the **Read FIFO Queue** or **Write FIFO Queue** has reached its deadline, jump it to the front and send it immediately instead — so nothing waits forever, even if it's inconvenient for disk-head movement.

**Why reads get a shorter deadline than writes:** a program usually sits and waits for a read to finish before continuing, but a write can often happen in the background — so reads are treated with more urgency.

### View/Tune These Settings Directly

```bash
ls /sys/block/sda/queue/iosched/
```

Common tunable files inside (names vary slightly between `deadline` and `mq-deadline`):

| File | Meaning |
|---|---|
| `read_expire` | Deadline (in milliseconds) before a waiting read request must be served |
| `write_expire` | Deadline (in milliseconds) before a waiting write request must be served |
| `fifo_batch` | How many requests get pulled from a FIFO queue at once when a deadline expires |
| `writes_starved` | How many batches of reads are allowed to run before writes are forced to get a turn (prevents write starvation) |
| `front_merges` | Whether new requests are allowed to merge onto the front of an existing request in the queue |

---

## 6. Block Multi-Queue (blk-mq) — The Modern Foundation

**blk-mq** = **Block Multi-Queue**

Older schedulers (NOOP, Deadline, CFQ, Anticipatory) were all built around a **single queue** design — one line of requests, handled by one CPU core at a time. This became a bottleneck once fast **NVMe** (**N**on-**V**olatile **M**emory **E**xpress) SSDs arrived, which can handle **thousands** of requests at once, in parallel, across many CPU cores.

**Block Multi-Queue** redesigned this in the kernel to use:
- **One queue per CPU core** (instead of one queue total), so multiple cores can submit I/O requests at the same time without waiting on each other
- Direct mapping to the hardware's own multiple internal queues (which modern SSDs/NVMe drives have built in)

This is why modern kernels no longer offer NOOP/Deadline/CFQ/Anticipatory as options — they've been replaced with **blk-mq-native versions**:

| Old Scheduler | Modern blk-mq Replacement |
|---|---|
| NOOP | `none` (still means "just merge requests, no reordering") |
| Deadline | `mq-deadline` (same deadline logic, redesigned for multi-queue) |
| CFQ | `bfq` (**B**udget **F**air **Q**ueueing — fairness between processes, redesigned) |
| — (new) | `kyber` (a newer, simpler low-latency scheduler tuned for fast SSDs/NVMe) |

---

## 7. Scheduler Selection — Choosing the Right One

| Scheduler | Best For |
|---|---|
| `none` | Fast SSDs/NVMe drives, or hardware/RAID controllers that already do their own optimizing |
| `mq-deadline` | General-purpose default; good balance for both SSDs and HDDs; guarantees no request waits forever |
| `bfq` | Desktop use, HDDs, or workloads where fairness between multiple programs matters more than raw throughput |
| `kyber` | High-speed NVMe SSDs needing very low latency with simple tuning |

### Check what your disk type is (helps decide)

```bash
cat /sys/block/sda/queue/rotational
```
- `1` = spinning **HDD** (rotational disk — benefits most from sorting/deadline logic)
- `0` = **SSD**/NVMe (flash memory, no physical head movement, benefits from `none` or `kyber`)

---

## 8. Make a Scheduler Choice Permanent (Survive Reboot)

The `echo ... > scheduler` method only lasts until the next reboot. To make it permanent, create a **udev** rule (udev = the Linux subsystem that manages device files and can auto-run actions when hardware is detected):

```bash
sudo nano /etc/udev/rules.d/60-scheduler.rules
```

Add a line like:
```
ACTION=="add|change", KERNEL=="sda", ATTR{queue/scheduler}="mq-deadline"
```

This tells the system: whenever device `sda` is detected, automatically set its scheduler to `mq-deadline`.

---

## 9. Watch Live Disk I/O Activity

```bash
iostat -x 1
```

`iostat` = **I/O Statistics**. `-x` = **Extended** stats. `1` = refresh every 1 second.

Key columns:

| Column | Meaning |
|---|---|
| `r/s` , `w/s` | Reads / Writes completed per second |
| `rkB/s` , `wkB/s` | Kilobytes read / written per second |
| `await` | Average time (ms) a request waits before AND during being served — the real-world delay a program feels |
| `%util` | % of time the disk was busy handling at least one request (close to 100% = disk is the bottleneck) |

---

## Most Useful Commands (Cheat Sheet)

| Command | What it does |
|---|---|
| `cat /sys/block/sda/queue/scheduler` | Show current + available schedulers |
| `echo bfq \| sudo tee /sys/block/sda/queue/scheduler` | Switch scheduler immediately |
| `ls /sys/block/sda/queue/iosched/` | List tunable settings for the active scheduler |
| `cat /sys/block/sda/queue/rotational` | Check if the disk is HDD (1) or SSD (0) |
| `iostat -x 1` | Live view of disk request activity and wait times |
| `lsblk -d -o NAME,ROTA,SCHED` | Quick table of disks, HDD/SSD status, and active scheduler (if supported) |

---

## Quick Summary

- The **I/O Scheduler** decides the ORDER disk requests are actually sent to hardware — not just first-come-first-served.
- It's nicknamed the **Elevator Scheduler** because it often sorts requests to move smoothly across the disk, like an elevator visiting floors in order.
- Classic schedulers — **NOOP**, **Deadline**, **Anticipatory**, **CFQ** — were built for a single queue and mostly designed around spinning HDDs.
- The **Deadline Scheduler** balances two goals using a **Sorted Queue** (efficiency) plus separate **Read/Write FIFO Queues** with deadlines (fairness), pulling final choices into a **Dispatch Queue**.
- **Block Multi-Queue (blk-mq)** rebuilt all of this for modern multi-core CPUs and ultra-fast NVMe SSDs, replacing the old schedulers with `none`, `mq-deadline`, `bfq`, and `kyber`.
- Pick `none`/`kyber` for fast SSDs, `mq-deadline` as a safe general default, and `bfq` when fairness between processes matters most.

---
*Reference notes compiled by m.manikandan*

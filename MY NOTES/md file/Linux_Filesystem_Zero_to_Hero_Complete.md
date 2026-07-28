# Linux Filesystem, Inode Table, Hard Link, Soft Link, Directory and Filesystem (Zero to Hero)

This guide uses simple English with technically correct explanations.

---

# 1. Introduction

A Linux filesystem is the method Linux uses to organize and store files on a storage device.

Think of a storage device like a library.

* Disk = Library
* Directory = Bookshelf
* File = Book
* Inode = Book information card
* Filename = Book title

Linux separates:

* File data
* File metadata (inode)

This is one of the biggest differences between Linux and many other operating systems.

---

# 2. /dev (Device Files)

Linux treats almost everything as a file.

Hardware devices appear inside

```text
/dev
```

Examples

```text
/dev/sda
/dev/sda1
/dev/nvme0n1
/dev/tty
/dev/null
/dev/random
```

See devices

```bash
ls /dev
```

---

# 3. Device Types

Linux supports several device types.

| Device           | Purpose                                    |
| ---------------- | ------------------------------------------ |
| Character Device | Reads one character/byte at a time         |
| Block Device     | Reads blocks of data                       |
| Pipe             | Communication between processes            |
| Socket           | Communication over network or local system |

---

# 4. Character Device

Transfers data one byte (character) at a time.

Examples

```text
Keyboard
Mouse
Serial Port
Terminal
```

Check

```bash
ls -l /dev/tty
```

Output

```text
crw-rw-rw-
```

The first letter

```text
c
```

means Character Device.

---

# 5. Block Device

Transfers data in fixed-size blocks.

Examples

```text
SSD
HDD
USB Drive
NVMe
```

Check

```bash
ls -l /dev/sda
```

Output

```text
brw-rw----
```

The

```text
b
```

means Block Device.

---

# 6. Pipe Device

Allows one process to send data directly to another.

Example

```bash
ls | grep txt
```

Pipeline

```text
ls -----> grep
```

No temporary file is created.

---

# 7. Socket Device

Used for communication.

Examples

```text
Web Server
SSH
Docker
Browser
Database
```

Example

```bash
ss -tuln
```

Shows listening sockets.

---

# 8. Device Characterisation

Every device has:

* Major Number
* Minor Number

Example

```bash
ls -l /dev/sda
```

Output

```text
8,0
```

Major number

```text
8
```

Kernel driver

Minor number

```text
0
```

Specific device handled by that driver.

---

# 9. Device Names

Examples

```text
/dev/sda
/dev/sdb
/dev/nvme0n1
/dev/tty0
/dev/null
/dev/random
```

Naming depends on device type.

---

# 10. Pseudo Devices

These are virtual devices.

No physical hardware exists.

Examples

```text
/dev/null
/dev/zero
/dev/random
/dev/urandom
```

---

### /dev/null

Throws away everything.

```bash
echo hello > /dev/null
```

Nothing is stored.

---

### /dev/zero

Produces unlimited zeros.

```bash
cat /dev/zero
```

---

### /dev/random

Produces random numbers using environmental noise.

---

### /dev/urandom

Produces pseudo-random numbers.

Usually faster.

---

# 11. /sys (sysfs)

Directory

```text
/sys
```

Provides information about hardware and kernel objects.

Example

```bash
ls /sys
```

Contains

```text
block
bus
class
devices
kernel
module
```

---

# 12. Filesystem Hierarchy

Linux follows a standard directory layout.

```
/
├── bin
├── boot
├── dev
├── etc
├── home
├── lib
├── media
├── mnt
├── opt
├── proc
├── root
├── run
├── sbin
├── srv
├── sys
├── tmp
├── usr
└── var
```

---

# 13. Filesystem Types

Common Linux filesystems

| Filesystem | Use                      |
| ---------- | ------------------------ |
| ext4       | Default Linux filesystem |
| XFS        | Large servers            |
| btrfs      | Advanced features        |
| FAT32      | USB drives               |
| NTFS       | Windows                  |
| exFAT      | Large USB drives         |
| HFS+       | Older macOS              |

---

# 14. Journaling

A journal records pending filesystem changes before they are fully written.

Benefits:

* Faster recovery after a crash
* Lower chance of filesystem corruption

Examples

```text
ext3
ext4
XFS
btrfs
```

---

# 15. ext4

Most common Linux filesystem.

Features

* Journaling
* Large files
* Large partitions
* Stable
* Fast

Maximum file size

About

```text
16 TB
```

Maximum filesystem

About

```text
1 EB
```

---

# 16. btrfs (Butter/Better Filesystem)

Modern Linux filesystem.

Features

* Snapshots
* Compression
* Checksums
* RAID support
* Subvolumes

---

# 17. XFS

Enterprise filesystem.

Best for

* Large files
* High performance
* Databases
* Video storage

---

# 18. NTFS & FAT

### NTFS

Windows default filesystem.

Supports

* Permissions
* Large files
* Compression
* Encryption

---

### FAT32

Very compatible.

Limitations

Maximum file size

```text
4 GB
```

---

# 19. HFS+

Older Macintosh filesystem.

Used before APFS.

---

# 20. Check Filesystems

```bash
df -T
```

Example

```
Filesystem Type Size Used Avail Mounted on
/dev/sda1 ext4 100G 40G 60G /
```

Type column shows filesystem.

---

# 21. Partition Table

A partition table tells the computer where partitions begin and end on a disk.

Two main types

* MBR
* GPT

---

# 22. MBR Partition Table

Older format.

Features

Maximum disk

```text
2 TB
```

Maximum primary partitions

```text
4
```

Uses BIOS.

---

# 23. GPT Partition Table

Modern format.

Supports

* Very large disks
* Up to 128 partitions (commonly)
* UEFI systems
* Backup partition table

Preferred today.

---

# 24. Filesystem Structure

```
Disk
│
├── Partition Table
│
├── Partition 1
│      │
│      ├── Superblock
│      ├── Block Group
│      ├── Inode Table
│      ├── Data Blocks
│
├── Partition 2
```

---

# 25. View Disk Layout

```bash
sudo parted -l
```

Shows

* Disk size
* Partition table
* Partitions
* Filesystem

---

# 26. Disk Partitioning Tools

Common tools

```text
fdisk
parted
gdisk
cfdisk
gparted
```

---

# 27. /etc/fstab

Permanent mount configuration.

Example

```
UUID=xxxx / ext4 defaults 0 1
```

Fields

```
Device
Mount Point
Filesystem
Options
Dump
Fsck
```

View

```bash
cat /etc/fstab
```

---

# 28. Swap Memory

Swap is disk space used when RAM is full.

Check

```bash
swapon --show
```

or

```bash
free -h
```

---

# 29. df -h

Shows disk space.

```bash
df -h
```

Example

```
Filesystem Size Used Avail
```

---

# 30. du -h

Shows directory size.

```bash
du -sh Downloads
```

---

# 31. Inode Table

The inode table is a special area of the filesystem that stores an inode for every file and directory.

An inode contains metadata, not the filename or file contents.

Stored in an inode:

* File type
* File permissions
* Owner (UID)
* Group (GID)
* File size
* Access time (atime)
* Modify time (mtime)
* Change time (ctime)
* Number of hard links
* Pointers to the file's data blocks

Not stored in an inode:

* Filename
* Parent directory name

The filename is stored in the directory that points to the inode.

---

# 32. When Are Inodes Created?

Inodes are created when a filesystem is created (formatted), not when individual files are created.

For example:

```bash
mkfs.ext4 /dev/sdb1
```

During formatting, ext4 creates:

* Superblock
* Block groups
* Inode tables
* Data blocks

Each new file later uses one available inode from the pre-created inode table.

---

# 33. df -i (Inodes Available?)

Check inode usage:

```bash
df -i
```

Example:

```
Filesystem  Inodes   IUsed   IFree IUse%
/dev/sda1   655360  120000  535360   19%
```

A filesystem can run out of inodes even if it still has free disk space, preventing new files from being created.

---

# 34. Inode Information

Each inode has a unique inode number within its filesystem.

View inode details:

```bash
stat file.txt
```

Example output:

```
Inode: 458912
Size: 1024
Links: 1
Access: rw-r--r--
```

---

# 35. ls -li (Checking Inode Numbers)

Display inode numbers:

```bash
ls -li
```

Example:

```
458912 file1.txt
458913 file2.txt
```

The first column is the inode number.

---

# 36. How Do Inodes Work & Locate a File?

Suppose you run:

```bash
cat report.txt
```

The process is:

1. The kernel reads the current directory.
2. It searches for the filename `report.txt`.
3. The directory entry contains the inode number.
4. The kernel reads that inode from the inode table.
5. The inode contains pointers to the file's data blocks.
6. The kernel reads the data blocks and returns the file contents.

Flow:

```
Filename
     │
     ▼
Directory Entry
     │
     ▼
Inode Number
     │
     ▼
Inode Table
     │
     ▼
Data Block Addresses
     │
     ▼
File Data
```

---

# 37. Directories in Linux

A directory is a special type of file.

It does not store the contents of other files.

Instead, it stores a list of:

* Filename
* Corresponding inode number

Example:

```
Directory

notes.txt  → inode 5001
photo.jpg  → inode 5002
movie.mp4  → inode 5003
```

The actual file data is stored elsewhere in the filesystem.

---

# 38. Hard Links

A hard link is another directory entry that points to the same inode as an existing file.

Create a hard link:

```bash
ln file.txt file_hard.txt
```

Check:

```bash
ls -li
```

Example:

```
458912 file.txt
458912 file_hard.txt
```

Both names have the same inode number.

Characteristics:

* Shares the same inode
* Shares the same file data
* Changes through either name affect the same file
* Deleting one name does not remove the data until all hard links are removed
* Cannot span different filesystems
* Cannot normally be created for directories

Diagram:

```
file.txt
      \
       \
        ---> inode 458912 ---> Data Blocks
       /
file_hard.txt
```

---

# 39. Soft Links (Symbolic Links)

A symbolic link is a special file that stores the path to another file.

Create one:

```bash
ln -s file.txt file_soft.txt
```

View:

```bash
ls -l
```

Example:

```
file_soft.txt -> file.txt
```

Characteristics:

* Has its own inode
* Stores the target path
* Can point to files or directories
* Can cross different filesystems
* Becomes a broken (dangling) link if the target is deleted

Diagram:

```
file_soft.txt
      │
      ▼
"file.txt"
      │
      ▼
inode
      │
      ▼
Data Blocks
```

---

# 40. Hard Link vs Soft Link

| Feature                               | Hard Link                                | Soft Link (Symbolic Link)   |
| ------------------------------------- | ---------------------------------------- | --------------------------- |
| Shares the same inode                 | Yes                                      | No                          |
| Has its own inode                     | No                                       | Yes                         |
| Points to                             | Original inode                           | File path                   |
| Works across filesystems              | No                                       | Yes                         |
| Can link directories                  | Normally no                              | Yes                         |
| Works if original filename is removed | Yes, as long as another hard link exists | No, the link becomes broken |
| Inode number                          | Same as original                         | Different from original     |

---

# Summary

```
Disk
 │
 ▼
Partition Table (MBR/GPT)
 │
 ▼
Partition
 │
 ▼
Filesystem (ext4, XFS, btrfs, ...)
 │
 ├── Superblock
 ├── Inode Table
 ├── Data Blocks
 │
 ▼
Directory
 │
 ├── filename → inode number
 │
 ▼
Inode
 │
 ├── Metadata
 ├── Permissions
 ├── Owner
 ├── Size
 ├── Timestamps
 ├── Link Count
 └── Data Block Pointers
 │
 ▼
Data Blocks
 │
 ▼
Actual File Contents
```

This sequence—**Disk → Partition Table → Partition → Filesystem → Directory → Inode → Data Blocks**—is the core concept behind how Linux stores and retrieves files.

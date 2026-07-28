# Linux Filesystem, Inode Table, Hard Link, Soft Link, Directory and Filesystem (Zero to Hero)

This Markdown document contains the notes from the previous response.

## 1. Introduction

A Linux filesystem is the method Linux uses to organize and store files
on a storage device.

-   Disk = Library
-   Directory = Bookshelf
-   File = Book
-   Inode = Book information card
-   Filename = Book title

Linux separates file data from file metadata (inode).

## 2. /dev (Device Files)

Linux treats almost everything as a file.

``` text
/dev
```

Examples:

``` text
/dev/sda
/dev/sda1
/dev/nvme0n1
/dev/tty
/dev/null
/dev/random
```

## 3. Device Types

-   Character Device
-   Block Device
-   Pipe
-   Socket

## 4. Inode Table

The inode table stores one inode for every file and directory.

An inode contains: - File type - Permissions - Owner - Group - File
size - atime - mtime - ctime - Hard link count - Data block pointers

It does **not** store: - Filename - Parent directory

## 5. Directories

A directory stores filename → inode mappings.

Example:

``` text
notes.txt -> inode 5001
photo.jpg -> inode 5002
```

## 6. Hard Links

Create:

``` bash
ln file.txt file_hard.txt
```

Hard links share the same inode.

## 7. Soft Links

Create:

``` bash
ln -s file.txt file_soft.txt
```

A symbolic link stores the path to another file.

## 8. Hard Link vs Soft Link

  Feature                               Hard Link     Soft Link
  ------------------------------------- ------------- -----------
  Same inode                            Yes           No
  Own inode                             No            Yes
  Cross filesystem                      No            Yes
  Link directories                      Normally No   Yes
  Survives original filename deletion   Yes           No

## 9. Summary

Disk → Partition Table → Partition → Filesystem → Directory → Inode →
Data Blocks → File Data

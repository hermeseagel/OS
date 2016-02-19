#!/bin/bash
# Create a filesystem across four drives (metadata mirrored, linear data allocation)
mkfs.btrfs /dev/sdb /dev/sdc /dev/sdd /dev/sde

# Stripe the data without mirroring
mkfs.btrfs -d raid0 /dev/sdb /dev/sdc

# Use raid10 for both data and metadata
mkfs.btrfs -m raid10 -d raid10 /dev/sdb /dev/sdc /dev/sdd /dev/sde

# Don't duplicate metadata on a single drive (default on single SSDs)
mkfs.btrfs -m single /dev/sdb


#List btrfs filesystem show 
btrfs filesystem show 


#scan device 
btrfs device scan
# Scan a single device
btrfs device scan /dev/sdb
#create mirror disk
mkfs.btrfs -m raid1 -d raid1 /dev/sdb /dev/sdc 
mout /dev/sdb /mnt 
#檢查 檔
btrfs filesystem df /mnt
Data, RAID1: total=204.75MiB, used=128.00KiB
Data, single: total=8.00MiB, used=0.00B
System, RAID1: total=8.00MiB, used=16.00KiB
System, single: total=4.00MiB, used=0.00B
Metadata, RAID1: total=204.75MiB, used=112.00KiB
Metadata, single: total=8.00MiB, used=0.00B
GlobalReserve, single: total=16.00MiB, used=0.00B
#清除btrfs  
dd if=/dev/zero of=/dev/sdc bs=1M

#強迫轉成 raid0
btrfs balance start --force -mconvert=raid0 /mnt

root@py2-3:~# mount /dev/sdc /mnt
root@py2-3:~# btrfs subvolume create /mnt/test
Create subvolume '/mnt/test'

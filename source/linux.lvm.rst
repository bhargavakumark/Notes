Linux : LVM
===========

.. contents::

Features
--------

The LVM can:

* Resize volume groups online by absorbing new physical volumes (PV) or ejecting existing ones.
* Resize logical volumes (LV) online by concatenating extents onto them or truncating extents from them.
* Create read-only snapshots of logical volumes (LVM1).
* Create read-write snapshots of logical volumes (LVM2).
* Stripe whole or parts of logical volumes across multiple PVs, in a fashion similar to RAID 0.
* Mirror whole or parts of logical volumes, in a fashion similar to RAID 1.
* Move online logical volumes between PVs.
* Split or merge volume groups in situ (as long as no logical volumes span the split). This can be useful when migrating whole logical volumes to or from offline storage.

Introduction
------------

LVM keeps a metadata header at the start of every physical volume, each of which is uniquely identified by a UUID. Each PV's header is a complete copy of the entire volume group's layout, including the UUIDs of all other PVs, the UUIDs of all logical volumes and an allocation map of PEs to LEs. This simplifies data recovery in the event of PV loss.

In the 2.6-series of the Linux Kernel, the LVM is implemented in terms of the device mapper, a simple block-level scheme for creating virtual block devices and mapping their contents onto other block devices. This minimizes the amount of relatively hard-to-debug kernel code needed to implement the LVM. It also allows its I/O redirection services to be shared with other volume managers (such as EVMS). Any LVM-specific code is pushed out into its user-space tools, which merely manipulate these mappings and reconstruct their state from on-disk metadata upon each invocation.

To bring a volume group online, the "vgchange" tool:

* Searches for PVs in all available block devices.
* Parses the metadata header in each PV found.
* Computes the layouts of all visible volume groups.
* Loops over each logical volume in the volume group to be brought online and:

    * Checks if the logical volume to be brought online has all its PVs visible.
    * Creates a new, empty device mapping.
    * Maps it (with the "linear" target) onto the data areas of the PVs the logical volume belongs to.

To move an online logical volume between PVs on the same Volume Group, use the "pvmove" tool:

* Creates a new, empty device mapping for the destination.
* Applies the "mirror" target to the original and destination maps. The kernel will start the mirror in "degraded" mode and begin copying data from the original to the destination to bring it into sync.
* Replaces the original mapping with the destination when the mirror comes into sync, then destroys the original.

These device mapper operations take place transparently, without applications or filesystems being aware that their underlying storage is moving.

Operations
----------

=============================================
Create a partition for LVM and mark it as LVM
=============================================

::
    
    fdisk /dev/sdb

    Command (m for help): <-- n
    Command action
       e   extended
       p   primary partition (1-4)
    <-- p
    Partition number (1-4): <-- 1
    First cylinder (1-10443, default 1): <-- <ENTER>
    Using default value 1
    Last cylinder or +size or +sizeM or +sizeK (1-10443, default 10443): <-- +25000M

    Command (m for help): <-- t
    Selected partition 1
    Hex code (type L to list codes):
    Hex code (type L to list codes): <-- 8e
    Changed system type of partition 1 to 8e (Linux LVM)

==========================
Physical volume operations
==========================

Basic operations

::

    pvcreate /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1

    pvremove /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1

    pvdisplay

=======================
Volume group operations
=======================

Basic operations

::

    vgcreate fileserver /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1

    vgdisplay

    vgrename fileserver data

    vgscan
        Reading all physical volumes.  This may take a while...
        Found volume group "data" using metadata type lvm2

    vgremove data

=========================
Logical Volume operations
=========================

Basic operations

::
    
    lvcreate --name media --size 1G fileserver

    lvdisplay

    lvscan

    lvrename fileserver media films

    lvremove /dev/fileserver/films

    lvextend -L1.5G /dev/fileserver/media
        Extending logical volume media to 1.50 GB
        Logical volume media successfully resized

    lvreduce -L1G /dev/fileserver/media
        WARNING: Reducing active logical volume to 1.00 GB
        THIS MAY DESTROY YOUR DATA (filesystem etc.)
        Do you really want to reduce media? [y/n]: <-- y
        Reducing logical volume media to 1.00 GB
        Logical volume media successfully resized  

    mkfs.xfs /dev/fileserver/backup

    After system reboot the path might change based on
    dev mapper as 

    df -h
    Filesystem            Size  Used Avail Use% Mounted on
    /dev/sda2              19G  665M   17G   4% /
    tmpfs                  78M     0   78M   0% /lib/init/rw
    udev                   10M   88K   10M   1% /dev
    tmpfs                  78M     0   78M   0% /dev/shm
    /dev/sda1             137M   17M  114M  13% /boot
    /dev/mapper/fileserver-share
                           40G  177M   38G   1% /var/share
    /dev/mapper/fileserver-backup
                           5.0G  144K  5.0G   1% /var/backup
    /dev/mapper/fileserver-media
                           1.0G   33M  992M   4% /var/media



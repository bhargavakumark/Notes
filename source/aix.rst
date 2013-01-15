AIX
===

.. contents::

System Information
------------------

======
kernel
======

::

    ls -l /unix 

    /unix -> /usr/lib/boot/unix_up      # 32 bit uniprocessor kernel 
    /unix -> /usr/lib/boot/unix_mp      # 32 bit multiprocessor kernel
    /unix -> /usr/lib/boot/unix_64      # 64 bit multiprocessor kernel       

=====
uname
=====

::

    uname -p    Displays the chip type of the system. For example, PowerPC.
    uname -r    Displays the release number of the operating system.
    uname -s    Displays the system name. For example, AIX.
    uname -n    Displays the name of the node.
    uname -a    Displays the system name, nodename, version, machine ID.
    uname -M    Displays the system model name. For example, IBM, 9114-275.
    uname -v    Displays the operating system version.
    uname -m    Displays the machine ID number of the hardware running the system.
    uname -u    Displays the system ID number. 

=====
lscfg
=====

::

    lscfg
    lscfg | grep proc   # Processor information

=======
prtconf
=======

::

    $ prtconf

======
Memory
======

::

    lsattr -El sys0 -a realmem 

Logs
----

::

    # alog -L
    boot
    bosinst
    nim
    console
    cfg
    lvmcfg
    lvmt
    dumpsymp

    # alog -o -t console

Devices
-------

========
HBA WWNs
========

::

    lsdev -Cc adapter | grep FC

    lscfg -vp -l fcs0 | grep "Network Address"

========
Adapters
========

List adapters

::

    lsdev -C | grep scsi

    lscfg -l vscsi0
       vscsi0           U9111.520.0001234-V11-C37-T1  Virtual SCSI Client Adapter

==========================
lsattr : Device attributes
==========================

To list the current values of the attributes for the tape device, rmt0, type:

::

    lsattr -l rmt0 -E

To list the default values of the attributes for the tape device, rmt0, type:

::

    lsattr -l rmt0 -D


To list the possible values of the login attribute for the TTY device, tty0, type:

::
    
    lsattr -l tty0 -a login -R

To display system level attributes, type:

::

    lsattr -E -l sys0

=========
List LUNs
=========

::

    lsdev -Cc disk

==========
Remove LUN
==========

::

    rmdev -dl hdisk14

================
LUN/Device State
================

* **Defined** : Its defined in the OMD but not seen after reboot or any longer.
When a new device is detected it is added to OMD and updated in the kernel.
When that device is no longer physically visible then that is device goes 
into define state.

* **Avaiable** : The device is detected and available for use

::

    rmdev -l hdisk3     # puts the device in defined state
    rmdev -dl hdisk3    # completes removes the device and its OMD record

Volume Group
------------

::

    $ lsvg
    rootvg

    $ lspv
    hdisk0          00f270b5fd158ea1                    rootvg          active      
    hdisk1          00f270b5c1262497                    rootvg          active      
    hdisk2          00f6d7e7d7d7d810                    None                        
    hdisk4          none                                None                        
    hdisk5          none                                None                        
    hdisk6          none                                None                        
    hdisk7          00f6d7e7dbc4f180                    None                        
    hdisk8          none                                None                        
    hdisk9          none                                None                        
    hdisk10         00f6d7e7dbc4f180                    None                        
    hdisk11         none                                None                        
    hdisk12         none                                None                        
    hdisk13         00f6d7e7d7d8299f                    None                        
    hdisk3          00f6d7e7d7d828c1                    None                        
    hdisk14         none                                None                       


    $ lspv -l hdisk0
    hdisk0:
    LV NAME               LPs     PPs     DISTRIBUTION          MOUNT POINT
    hd2                   60      60      00..00..20..40..00    /usr
    hd4                   3       3       00..00..03..00..00    /
    hd8                   1       1       00..00..01..00..00    N/A
    hd6                   32      32      00..32..00..00..00    N/A
    hd10opt               52      52      00..00..52..00..00    /opt
    hd1                   1       1       00..00..01..00..00    /home
    hd3                   16      16      00..00..16..00..00    /tmp
    hd9var                1       1       00..00..01..00..00    /var
    hd5                   1       1       01..00..00..00..00    N/A
    fwdump                3       3       00..03..00..00..00    /var/adm/ras/platform
    lg_dumplv             4       4       00..04..00..00..00    N/A
    livedump              1       1       00..01..00..00..00    /var/adm/ras/livedump
    hd11admin             1       1       00..00..01..00..00    /admin

Multipath
---------

List current paths for disks

::

    $ lspath

    $ lspath -F "name,status,parent,connection" -l hdisk0
    hdisk0,Enabled,vscsi0,810000000000
    hdisk0,Enabled,vscsi1,810000000000



JFS
---

Create FS

::

    mkfs -V jfs2 -o log=INLINE /dev/hdisk13

Mount FS

::

    mount -V jfs2 -o log=INLINE /dev/hdisk13 /mnt/hdisk13

    mount -V jfs2 -o log=NULL /dev/hdisk13 /mnt/hdisk13

Create Log volume

::

    mklv -t jfs2log -y <yournewloglv>datavg vg 1

    # logform /dev/<yournewloglv>

    # chfs -a log=<yournewloglv> <filesystemname>

LVM
---

==========
varyon/off
==========
The vary-on process is one of the mechanisms that the LVM uses to ensure that a volume group is ready to use and contains the most up-to-date data.

The **varyonvg** and **varyoffvg** commands activate or deactivate (make available or unavailable for use) a volume group that you have defined to the system. The volume group must be varied on before the system can access it. During the vary-on process, the LVM reads management data from the physical volumes defined in the volume group. This management data, which includes a volume group descriptor area (VGDA) and a volume group status area (VGSA), is stored on each physical volume of the volume group.

The VGDA contains information that describes the mapping of physical partitions to logical partitions for each logical volume in the volume group, as well as other vital information, including a time stamp. The VGSA contains information such as which physical partitions are stale and which physical volumes are missing (that is, not available or active) when a vary-on operation is attempted on a volume group.

======
Quorum
======

A quorum is a vote of the number of Volume Group Descriptor Areas and Volume Group Status Areas (VGDA/VGSA) that are active. A quorum ensures data integrity of the VGDA/VGSA areas in the event of a disk failure. Each physical disk in a volume group has at least one VGDA/VGSA. When a volume group is created onto a single disk, it initially has two VGDA/VGSA areas residing on the disk. If a volume group consists of two disks, one disk still has two VGDA/VGSA areas, but the other disk has one VGDA/VGSA. When the volume group is made up of three or more disks, then each disk is allocated just one VGDA/VGSA.

A quorum is lost when at least half of the disks (meaning their VGDA/VGSA areas) are unreadable by LVM. In a two-disk volume group, if the disk with only one VGDA/VGSA is lost, a quorum still exists because two of the three VGDA/VGSA areas still are reachable. If the disk with two VGDA/VGSA areas is lost, this statement is no longer true. The more disks that make up a volume group, the lower the chances of quorum being lost when one disk fails.

When a quorum is lost, the volume group varies itself off so that the disks are no longer accessible by the LVM. This prevents further disk I/O to that volume group so that data is not lost or assumed to be written when physical problems occur. Additionally, as a result of the vary-off, the user is notified in the error log that a hardware error has occurred and service must be performed.

The Logical Volume Manager (LVM) automatically deactivates the volume group when it lacks a quorum of Volume Group Descriptor Areas (VGDAs) or Volume Group Status Areas (VGSAs). However, you can choose an option that allows the group to stay online as long as there is one VGDA/VGSA pair intact. This option produces a nonquorum volume group.

The LVM requires access to all of the disks in nonquorum volume groups before allowing reactivation. This ensures that the VGDA and VGSA are up-to-date.

========================
LVM Maintenance Commands
========================

* http://pic.dhe.ibm.com/infocenter/aix/v7r1/index.jsp?topic=%2Fcom.ibm.aix.baseadmn%2Fdoc%2Fbaseadmndita%2Fdm_mpio.htm

Package management Commands
---------------------------

To show bos.acct contains /usr/bin/vmstat, type:

::

    lslpp -w /usr/bin/vmstat


Or to show bos.perf.tools contains /usr/bin/svmon, type:

::

    which_fileset svmon


How do I display information about installed filesets on my system?  Type the following:

::

    lslpp -l            
            
How do I determine if all filesets of maintenance levels are installed on my system?  Type the following:

::

    instfix -i | grep ML


How do I determine if a fix is installed on my system?  To determine if IY24043 is installed, type:

::

    instfix -ik IY24043

How do I install an individual fix by APAR?  To install APAR IY73748 from /dev/cd0, for example, enter the command:

::

    instfix -k IY73748 -d /dev/cd0




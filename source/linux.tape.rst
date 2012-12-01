Linux : Tape
============

References
----------

* http://downloads.quantum.com/dlt2000/6464215011.pdf 



Load tape module

::

        # modprobe st
        # lsmod | grep st
        st                     40827  0 

Tape module info

::
        
        # modinfo st
        filename:       /lib/modules/2.6.32.43-0.4-default/kernel/drivers/scsi/st.ko
        alias:          scsi:t-0x01*
        alias:          char-major-9-*
        license:        GPL
        description:    SCSI tape (st) driver
        author:         Kai Makisara
        srcversion:     A1BA559B0A0A9AFF7B39936
        depends:        scsi_mod
        supported:      yes
        vermagic:       2.6.32.43-0.4-default SMP mod_unload modversions 
        parm:           buffer_kbs:Default driver buffer size for fixed block mode (KB; 32) (int)
        parm:           max_sg_segs:Maximum number of scatter/gather segments to use (256) (int)
        parm:           try_direct_io:Try direct I/O between user buffer and tape drive (1) (int)
        parm:           try_rdio:Try direct read i/o when possible (int)
        parm:           try_wdio:Try direct write i/o when possible (int)

Sample kernel log 

::

        Attached scsi tape st0 at scsi0, channel 0, id 3, lun 0
        st0: try direct i/o: yes (alignment 512 B), max page reachable by HBA 1048575
        st: Version 20040318, fixed bufsize 32768, s/g segs 256

Sample output of /proc/scsi/scsi for tape drives

::

        Attached devices:
        Host: scsi0 Channel: 00 Id: 03 Lun: 00
          Vendor: QUANTUM Model: SDLT320        Rev: 5252
          Type: Sequential-Access       ANSI SCSI revision: 02
        Host: scsi1 Channel: 00 Id: 03 Lun: 00
          Vendor: SEAGATE Model: ST336607LC     Rev: DS04
          Type: Direct-Access           ANSI SCSI revision: 03

Correpsonding to each device in cat /proc/scsi/scsi there will be a device node
created in /dev/sg* 

::

        # cat /proc/scsi/scsi | grep -i '^Host' | wc -l
        53
        # ls /dev/sg*  | wc -l
        53


Each tape device corresponds to eight device nodes (four auto-rewind nodes
and four no-rewind nodes).

Device files

::

        Auto-rewind 
        
        crw-rw---- 1 root disk 9, 0 Sep 15 2003 st0
        crw-rw---- 1 root disk 9, 96 Sep 15 2003 st0a
        crw-rw---- 1 root disk 9, 32 Sep 15 2003 st0l
        crw-rw---- 1 root disk 9, 64 Sep 15 2003 st0m

        No-rewind

        crw-rw---- 1 root disk 9, 128 Sep 15 2003 nst0
        crw-rw---- 1 root disk 9, 224 Sep 15 2003 nst0a
        crw-rw---- 1 root disk 9, 160 Sep 15 2003 nst0l
        crw-rw---- 1 root disk 9, 192 Sep 15 2003 nst0m

Linux supports up to 32 tape devices [(n)st0* through (n)st31*)


====================    ====    ============
Mode                    char    minor number
====================    ====    ============
Mode 1 (Auto-Rewind)    none    0
Mode 2 (Auto-Rewind)    l       32
Mode 3 (Auto-Rewind)    m       64
Mode 4 (Auto-Rewind)    a       96
Mode 1 (No-Rewind)      none    128
Mode 2 (No-Rewind)      l       160
Mode 3 (No-Rewind)      m       192
Mode 4 (No-Rewind)      a       224
====================    ====    ============

Manually create device nodes for tape devices

::

        # mknod -m 666 /dev/st0 c 9 0
        # mknod -m 666 /dev/st1 c 9 1
        # mknod -m 666 /dev/st0l c 9 32
        # mknod -m 666 /dev/st1l c 9 33
        # mknod -m 666 /dev/st0m c 9 64
        # mknod -m 666 /dev/st1m c 9 65
        # mknod -m 666 /dev/st0a c 9 96
        # mknod -m 666 /dev/st1a c 9 97

RPMs required for sles11

::

        mt_st-0.9b-97.1.50.x86_64.rpm
        mtx-1.3.11-48.22.x86_64.rpm

Man pages

* man st
* man stinit
* man mtst
* man mt
* man mtx
* /usr/share/doc/packages/mt_st/README
* /usr/share/doc/packages/mt_st/README.stinit
* /usr/share/doc/packages/mt_st/stinit.def.examples

Kernel documentation

* drivers/scsi/README.st
* Documentation/scsi/st.txt

Linux commands

* mt
* stinit
* mtst
* mtx


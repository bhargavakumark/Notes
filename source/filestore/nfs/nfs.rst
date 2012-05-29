NFS
===

.. contents::

NLM Implementation
------------------

========
NLMGroup
========

This VCS group defines the NLM master server. The node on which this group is online is considered the NLM lock master and it will accept lock requests from other nodes in the cluster.

This group has two resources

*    nlmmasterIP
*    nlmmasterNIC 

nlmmaterNIC defines the NIC on which forwarding would take place. The device that is used as per current design is 'priveth0'. If there is only one private device, then that same device will be used as high priority LLT device, NLM forwarding device and ssh traffic device.

nlmmasterIP resource defines the IP on which requests are to be received. This IP will always have suffix '.2' chosen from the subnet on that device.

===================
NLMGroup postonline
===================

When this group comes online on any node, then

#.    remove self iptables rules if any
#.    restart NFS service in grace period mode
#.    sm-notify clients of restart of NFS
#.    Reset existing NAT connections
#.    We go to other nodes and make sure that iptables rules are added on those nodes. 

In step 3, we manually remove the files in /var/lib/nfs/sm as /var/lib/nfs/sm is a filesystem and sm-notify will try to rename those files into /var/lib/nfs/sm.bak which will fail as they are part of different filesytems.

In step 3, we also add an entry into /etc/hosts for the nlmmonitorname which is the name used by server to tell clients of nfs server restart as 0.0.0.0. By default when we call sm-notify, with that name it will lookup the name to an ip and will try to send the packets from that ip. When we have multiple subnets, we could be getting any ip and we may or may not be able to send packets to the clients from the lookedup ip for nlmmonitorname. So, in this case the lookup will return 0.0.0.0 causing the bind to fail, and the source ip will be decided by the routing table.

Step 4, refer NLMConnectionResets 

NLM Connection Resets
---------------------

==============================
NLM Connection Reset on Source
==============================
Previouly when a node was NLM master it could be having connections to clients, which cannot be NATed by the new iptables rules, hence would require to be reset. We use sfs_tcp_reset from TCPUtils to reset those existing connections.

========================================
NLM Connection Reset on Dest (NAT reset)
========================================
Before becoming NLM master the node could have been NLM slave, and could have been having forwarding rules. If there are existing NATed connections to a node, before the node became NLM master then iptables -t nat -F will only be effective for new connections, already existing NAT connections would still continue to be NATed. For resetting those NATed connections, we use sfs_tcp_reset_ether utility from TCPUtils to reset existing NAT connections, which send ethernet level packets to do a TCP reset. We can't use sfs_tcp_reset to send ip level packets, as they would undergo NAT and won't reach the client correctly. There are some limitations to sfs_tcp_reset_ether in that it will only try to guess the sequence number only once. In this case if the reset fails, then after some time the connection would automatically get reset by TCP retries, and lock requests would recover. The list of these existing NATed connections are picked up from /proc/net/ip_conntrack.

NLM Internal Shares
-------------------

=======
Problem
=======
In NLM we forward requests from slave to master, these requests from the slave private ip to the master. The RPC layer at the master makes verification whether the client has enough permissions for this operation or not. Unfortunately this check is done based on the ip in the incoming packet and not the HOST field in the NLM payload. Below describes the scenario where the forwarded request is denied by the RPC layter, because the client (nasgw12_02) does not have access to the filesystem on which it has forwarded the lock request.

::

        nasgw12.NFS> share show
        /vx/fs_str        ngsfdellpe-04.vxindia.veritas.com (rw,root_squash)
        /vx/fs_str        ngsfdellpe-07.vxindia.veritas.com (rw,root_squash)
        nasgw12.NFS> exit
        nasgw12> network
        Entering network mode...
        nasgw12.Network> ip addr show

        IP              Netmask         Device     Node            Type     Status
        --              -------         ------     ----            ----     ------
        10.209.105.75   255.255.252.0   pubeth0    nasgw12_01      Physical
        10.209.105.76   255.255.252.0   pubeth1    nasgw12_01      Physical
        10.209.105.77   255.255.252.0   pubeth0    nasgw12_02      Physical
        10.209.105.78   255.255.252.0   pubeth1    nasgw12_02      Physical
        10.209.105.83   255.255.252.0   pubeth0    nasgw12_01      Virtual  ONLINE (Con IP)
        10.209.105.79   255.255.252.0   pubeth0    nasgw12_02      Virtual  ONLINE
        10.209.105.80   255.255.252.0   pubeth0    nasgw12_01      Virtual  ONLINE
        10.209.105.81   255.255.252.0   pubeth1    nasgw12_02      Virtual  ONLINE
        10.209.105.82   255.255.252.0   pubeth1    nasgw12_01      Virtual  ONLINE
        10.209.106.17   255.255.252.0   pubeth0    nasgw12_02      Virtual  ONLINE
        10.209.105.133  255.255.252.0   pubeth0    nasgw12_01      Virtual  ONLINE
        (Replication IP)

        nasgw12.Network>  

        [root@ngsfdellpe-07 ~]# df -h
        Filesystem            Size  Used Avail Use% Mounted on
        /dev/sda1             225G  164G   50G  77% /
        none                  3.9G     0  3.9G   0% /dev/shm
        /dev/sdb1             229G  137G   81G  63% /root/vmware2
        /dev/sdc1             181G   92M  172G   1% /iscsi
        10.209.105.79:/vx/fs_str
                               60G  645M   56G   2% /mnt/fs_str
        [root@ngsfdellpe-07 ~]#
        [root@ngsfdellpe-07 ~]# ./lockfile -f /mnt/fs_str/testfile
        30526: can't set shared lock on /mnt/fs_str/testfile : Permission denied
        [root@ngsfdellpe-07 ~]# ./lockfile -f /mnt/fs_str/testfile
        32661: can't set shared lock on /mnt/fs_str/testfile : Permission denied
        [root@ngsfdellpe-07 ~]#
        tethereal: Promiscuous mode not supported on the "any" device.
        Capturing on Pseudo-device that captures on all interfaces


        1   0.000000 10.209.106.18 -> 10.209.105.79 NLM V4 LOCK Call FH:0xf6a8e266 svid:32755 pos:0-0
        2   0.005003 172.26.114.82 -> 172.26.114.2 NLM V4 LOCK Call FH:0xf6a8e266 svid:32755 pos:0-0
        3   0.000126 172.26.114.2 -> 172.26.114.82 NLM V4 LOCK Reply (Call In 2)
        4   0.000133 10.209.105.79 -> 10.209.106.18 NLM V4 LOCK Reply (Call In 1)
        5   0.000276 10.209.106.18 -> 10.209.105.79 TCP 798 > npp [ACK] Seq=284 Ack=24 Win=183 Len=0
        6   0.000281 172.26.114.82 -> 172.26.114.2 TCP 798 > npp [ACK] Seq=284 Ack=24 Win=183 Len=0
        7   0.000325 10.209.106.18 -> 10.209.105.79 NLM [RPC retransmission of #1]V4 LOCK Call (Reply In 4) FH:0xf6a8e266 svid:32755 pos:0-0
        8   0.000329 172.26.114.82 -> 172.26.114.2 NLM [RPC retransmission of #2]V4 LOCK Call (Reply In 3) FH:0xf6a8e266 svid:32755 pos:0-0
        9   0.000413 172.26.114.2 -> 172.26.114.82 NLM [RPC duplicate of #3]V4 LOCK Reply (Call In 2)
        10   0.000417 10.209.105.79 -> 10.209.106.18 NLM [RPC duplicate of #4]V4 LOCK Reply (Call In 1)
        11   0.000574 10.209.106.18 -> 10.209.105.79 NLM [RPC retransmission of #1]V4 LOCK Call (Reply In 4) FH:0xf6a8e266 svid:32755 pos:0-0
        12   0.000578 172.26.114.82 -> 172.26.114.2 NLM [RPC retransmission of #2]V4 LOCK Call (Reply In 3) FH:0xf6a8e266 svid:32755 pos:0-0
        13   0.000667 172.26.114.2 -> 172.26.114.82 NLM [RPC duplicate of #3]V4 LOCK Reply (Call In 2)
        14   0.000670 10.209.105.79 -> 10.209.106.18 NLM [RPC duplicate of #4]V4 LOCK Reply (Call In 1)
        15   0.040660 10.209.106.18 -> 10.209.105.79 TCP 798 > npp [ACK] Seq=852 Ack=72 Win=183 Len=0
        16   0.040669 172.26.114.82 -> 172.26.114.2 TCP 798 > npp [ACK] Seq=852 Ack=72 Win=183 Len=0

This problem would not happen if the share were exported to '*' as the client nasgw12_02 would also come under this list and lock requests would be accepted by nasgw12_01. Ethereal will not tell directly that the reply contains rejected reply, only looking at the full packet trace using wireshark would tell that the reply contains AUTH_ERROR with bad credential (seal broken). With linux client it would try a couple of times, other clients may not. On the client from the tool which is being used to acquire the lock, you should permission denied error.

===================
Internal NFS shares
===================
To avoid the problem described we create internal nfs shares for all the filesystem exported using NFS to all hosts in the cluster. We do this by exporting all those filesystems to the private ip subnet that is present on priveth0. These internal shares are created when a filesystem is shared first and deleted when the last share for that filesystem is deleted. Internal shares are created with name ishare and behave the same way as other shares, they are restricted from being visible from clish.

::

        Share ishare_100 (
                        PathName = "/vx/fs_mirr"
                        Client = "172.26.114.81/24"
                        Options = "rw,no_root_squash"
                        )

The internal shares are always exported with the options rw,no_root_squash. This does not creates problems even if the actual shares are exported as read-only, even if we have added permissions for NLM clients to take rw locks, the lock request would pass the RPC layer but get denied at the NLM layer which will use the HOST name filed in the NLM payload. Based on similar testing no problems were observed with no_root_squash even if the original shares were exported as root_squash. 

NLM Connection Tracking
-----------------------

=======
Problem
=======

When multiple clients are connected to NLM slave of filestore and try to acquire locks only the hostname of the first client which acquired the lock is stored in /var/lib/nfs/sm. This can be easily reproduced 5.5, by using 2 linux clients which connect to NLM slave, when the first client acquires the lock you should see an entry for that client in /var/lib/nfs/sm but when the second client acquires the lock no entry will be added in /var/lib/nfs/sm for the second client. This does not cause any problem in steady state locking, but fails to recover lock information for second client as the client information is not stored in /var/lib/nfs/sm

The part of the code that affects this

::

        123         hlist_for_each_entry(host, pos, chain, h_hash) {
        124                 if (!nlm_cmp_addr(&host->h_addr, sin)) { 
        125                         printk("lockd: nlm_lookup_host cmp_addr (%u.%u.%u.%u, %u.%u.%u.%u)\n",
        126                                 NIPQUAD(host->h_addr.sin_addr.s_addr), NIPQUAD(sin->sin_addr.s_addr));
        127                         continue;
        128                 }
        129
        130                 /* See if we have an NSM handle for this client */
        131                 if (!nsm) {
        132                         printk("lockd: nlm_lookup_host nlm handle invalid\n");
        133                         nsm = host->h_nsmhandle;
        134                 }
        135
        136                 if (host->h_proto != proto)
        137                         continue;
        138                 if (host->h_version != version)
        139                         continue;
        140                 if (host->h_server != server)
        141                         continue;
        142
        143                 /* Move to head of hash chain. */
        144                 hlist_del(&host->h_hash);
        145                 hlist_add_head(&host->h_hash, chain);
        146
        147                 nlm_get_host(host);
        148                 goto out;
        149         }
        150         if (nsm) {
        151                 printk("lockd: nlm_lookup_host nsm valid\n");
        152                 atomic_inc(&nsm->sm_count);
        153         }
        154
        155         host = NULL;
        156
        157         /* Sadly, the host isn't in our hash table yet. See if
        158          * we have an NSM handle for it. If not, create one.
        159          */
        160         if (!nsm && !(nsm = nsm_find(sin, hostname, hostname_len)))
        161                 goto out;
        162
        163         if (!(host = (struct nlm_host *) kmalloc(sizeof(*host), GFP_KERNEL))) {
        164                 nsm_release(nsm);
        165                 goto out;

At line 124, lockd host lookup compares the source ip address of the incoming packet and sees the same private ip over priveth0 on slave, and assumes it is the same client and uses an existing nlm_host structure which was created for first client. As it has an existing nsm handle that it derived from nlm_host of the first client, it will not call nsm_find on line 160, so statd does not know about the new client, so entry for second client is not created in /var/lib/nfs/sm.

During initial testing we have modified 124 to compare hostnames in the nlm packet instead of ip address that seems to have resolved the issue, but as kernel changes would void support from suse we will not be changing any kernel modules.

==============================
NLM Manual Connection Tracking
==============================

To fix the problem described above manual tracking of all connections over port 4045 has been done. We already have an existing TCPConnTrack? to track incoming connections over any port, this has been utilised to track NLM connections.

::

        Track incoming connections over port 4045
        If (new connection on port 4045)
                if (nlm_slave)
                      sleep for 10 seconds and give the NLM master time to automatically create hostname entry for this client. 
                       reverse_lookup remote server ip to find the hostname
                       if (hostname available)
                               create file for hostname 
                       else
                               create file for ip
                       fi
                fi
        fi

==========================================
Turn on/off NLM Manual connection tracking
==========================================

/opt/VRTSnasgw/conf/network_options.conf has 2 attributes which control the behaviour of this.

*    NLM_TRACK_CONN - can take values of 0/1, '1' will enable this features any other value will disable this
*    NLM_TRACK_CONN_USE_ONLY_HOSTNAMES - can take values 0/1, '1'' will disable use of ips if reverse-name lookup does not work, any other value will enable use of ips 

/proc/locks
-----------
Reference : http://www.centos.org/docs/5/html/Deployment_Guide-en-US/s1-proc-topfiles.html

This file displays the files currently locked by the kernel. The contents of this file contain internal kernel debugging data and can vary tremendously, depending on the use of the system. A sample /proc/locks file for a lightly loaded system looks similar to the following:

::

        1: POSIX  ADVISORY  WRITE 3568 fd:00:2531452 0 EOF 
        2: FLOCK  ADVISORY  WRITE 3517 fd:00:2531448 0 EOF 
        3: POSIX  ADVISORY  WRITE 3452 fd:00:2531442 0 EOF 
        4: POSIX  ADVISORY  WRITE 3443 fd:00:2531440 0 EOF 
        5: POSIX  ADVISORY  WRITE 3326 fd:00:2531430 0 EOF 
        6: POSIX  ADVISORY  WRITE 3175 fd:00:2531425 0 EOF 
        7: POSIX  ADVISORY  WRITE 3056 fd:00:2548663 0 EOF

Each lock has its own line which starts with a unique number. The second column refers to the class of lock used, with FLOCK signifying the older-style UNIX file locks from a flock system call and POSIX representing the newer POSIX locks from the lockf system call.

The third column can have two values: ADVISORY or MANDATORY. ADVISORY means that the lock does not prevent other people from accessing the data; it only prevents other attempts to lock it. MANDATORY means that no other access to the data is permitted while the lock is held. The fourth column reveals whether the lock is allowing the holder READ or WRITE access to the file. The fifth column shows the ID of the process holding the lock. The sixth column shows the ID of the file being locked, in the format of MAJOR-DEVICE:MINOR-DEVICE:INODE-NUMBER. The seventh and eighth column shows the start and end of the file's locked region. 

NFS Internal FSID
-----------------

=======
Problem
=======
#. Create share fs01.
#. Mount on client.
#. Destroy fs01(including delete share, but don't unmount from client)
#. Create fs02 and share it.
#. The mount point on client is now available automatically as fs01. 

This happens because NFS root handle only contains major/minor/root-inode numbers. As VxVM? reuses minor numbers and all FS have root inode as 2, the filehandle that the client sends to server is considered and is considered as pointing to fs02 and server would accept.

Due to this we have a fsid assigned to each share, which is not resued (unless all fsid exhausted)

==========
FSID space
==========
FSID ranges from 1 to 2147483647, which has splitted into 2 ranges

*    1 to 1073741823 is public fsid, can be used by customers
*    1073741824 to 2147483647 is private fsid range, which is used automatic assignment of fsid 

NFS Cache Consistency
---------------------

=========================================
Synchronous Operations and Stable storage
=========================================

Orig : NFS Illustrated by Brent Callaghan

Data modifying operations in NFS must be synchronous. When the server replies to the client, the client can assume that the operation has completed and any data associated with the request are now on stable storage.

Server itself may buffer the changes in the memory, but to be considered stable storage, the memory must be protected against power failures or crash and reboot of the server's operating system. After a server reboot the server must be able to locate and account for all data in the protected memory.

=============================
NFS read-ahead and write-back
=============================

Orig : NFS Illustrated by Brent Callaghan

When a multi-threaded NFS client detects sequential I/O on a file, it can assing NFS READ or WRITE calls to individiual threads. Each of these threads can issue an RPC call to the server independently and in parallel. On a client these were called biod processes. Each biod process would make a single, nontreturning system call that would block and proivde the kernel with an execution thread in the form of a process context.

On the server the number of threads depend very much on the server's configuration, setting up too many nfsd threads could make the server accept more NFS requests that it had the I/O bandwidth to handle and too few could result in excess I/O bandwidth inaccessible to clients.

NFS write-behind has a secondary effect of delaying write errors. Because the write operation is no longer synchronous with the application thread, an error that results from an asynchronous write cannot be reported in the result of an application write call. In most client implementations, if a biod process gets a write (perhaps because the disk is full), the error will be posted against the file so that it can be reported in the result of a subsequent write or close call. If the application that is doing the writing is dilligent in checking the results of write and close calls, then it can detect the error and take some recovery action.

===============
Write gathering
===============

Orig : NFS Illustrated by Brent Callaghan

The server may be capable of writing up to 64 KB of data in a single I/O request to the disk. Write gathering allows the server to accumulate a sequence of smaller 8-KB WRITE requests into a single block of data that can be written with the overhead of a write to the disk.

On receiving the first WRITE request, a server thread sleeps for some optimal number of milliseconds in case of contigous write to the same file follows. If no further writes are received during this sleep period, the accumulated writes are writtend to the disk in a single I/O. If a contigous write sis received, then it is accumulated with previously received WRITE requests. The sleep period for additional writes can negatively affect throughtput if the writes are random or if the client is single-threaded and does not use write-behing.

An alternative write-gathering algorithm is used in the solaris server. Instead of delaying the write thread while waiting for additional writes, it allows the first write to go synchronously to the disk. If the additional writes for the file arrive while the synchronous write is pending, they are accumulated. When the initial synchronous write is completed, the accumulated WRITEs are written. Although slightly less data are accumulated in the I/O, the effect on random I/O or nonwrite-behind clients is less serious.

===============================
Close-to-open cache consistency
===============================

The NFS standard requires clients to maintain close-to-open cache coherency when multiple clients access the same files. This means flushing all file data and metadata changes when a client closes a file, and immediately and unconditionally retrieving a file's attributes when it is opened via the open() system call API. In this way, changes made by one client appear as soon as a file is opened on any other client.

Orig : http://sawaal.ibibo.com/computers-and-accessories/what-closetoopen-cache-consistency-622005.html

Perfect cache coherency among disparate NFS clients is very expensive to achieve, so NFS settles for something weaker that satisfies the requirements of most everyday types of file sharing. Everyday file sharing is most often completely sequential: first client A opens a file, writes something to it, then closes it; then client B opens the same file, and reads the changes.

So, when an application opens a file stored in NFS, the NFS client checks that it still exists on the server, and is permitted to the opener, by sending a GETATTR or ACCESS operation. When the application closes the file, the NFS client writes back any pending changes to the file so that the next opener can view the changes. This also gives the NFS client an opportunity to report any server write errors to the application via the return code from close(). This behavior is referred to as close-to-open cache consistency.

Linux implements close-to-open cache consistency by comparing the results of a GETATTR operation done just after the file is closed to the results of a GETATTR operation done when the file is next opened. If the results are the same, the client will assume its data cache is still valid; otherwise, the cache is purged.

Close-to-open cache consistency was introduced to the Linux NFS client in 2.4.20. If for some reason you have applications that depend on the old behavior, you can disable close-to-open support by using the "nocto" mount option.

There are still opportunities for a client's data cache to contain stale data. The NFS version 3 protocol introduced "weak cache consistency" (also known as WCC) which provides a way of checking a file's attributes before and after an operation to allow a client to identify changes that could have been made by other clients. Unfortunately when a client is using many concurrent operations that update the same file at the same time, it is impossible to tell whether it was that client's updates or some other client's updates that changed the file.

For this reason, some versions of the Linux 2.6 NFS client abandon WCC checking entirely, and simply trust their own data cache. On these versions, the client can maintain a cache full of stale file data if a file is opened for write. In this case, using file locking is the best way to ensure that all clients see the latest version of a file's data.

A system administrator can try using the "noac" mount option to achieve attribute cache coherency among multiple clients. Almost every client operation checks file attribute information. Usually the client keeps this information cached for a period of time to reduce network and server load. When "noac" is in effect, a client's file attribute cache is disabled, so each operation that needs to check a file's attributes is forced to go back to the server. This permits a client to see changes to a file very quickly, at the cost of many extra network operations.

Be careful not to confuse "noac" with "no data caching." The "noac" mount option will keep file attributes up-to-date with the server, but there are still races that may result in data incoherency between client and server. If you need absolute cache coherency among clients, applications can use file locking, where a client purges file data when a file is locked, and flushes changes back to the server before unlocking a file; or applications can open their files with the O_DIRECT flag to disable data caching entirely.

============
Disk Caching
============

Orig : NFS Illustrated by Brent Callaghan

On some UNIX clients the CacheFS? is a disk cache that interposes itself between an application and its access to an NFS mounted filesystem. Data read from the server are cached in client memory and written to the disk cache, forming a cache hierarchy. First the memory cache is checked for cached data followed by the disk cache and finally a call to the server. The use of disk cache must not weaken the cache consistency of the memory cache. The disk cache must use the same cache times as memory cache.

A write-back disk cache allows whole files to be written to the disk before being written to the server. Write-back is the most beneficial if the file is removed soon after it is written, as is common with temporary files written by some applications like compilers. The file creation and deletion can be managed entirely on the client with no communication with the server at all. The utility of write-back caching is limited by the implications for error handling if the writes to the server fail due to lack of disk availability or other I/O problems. If the errors cannot be returned to the application that wrote the data, then the client is stuck with data that it cannot dispose of and errors that cannot be reported reliably to the end user. Consequently, the solaris cacheFS uses write-through caching: data are written to the server first, then to the cache, if the server writes succeed.

=====
Links
=====

close-to-open cache consistency and cifs
        http://lists.samba.org/archive/linux-cifs-client/2008-December/003914.html

Should we expect close-to-open consistency on directories? 
        http://www.spinics.net/lists/linux-nfs/msg12341.html

NFS Share Options
-----------------

===============================
NFS options related source code
===============================

::

        include/linux/nfsd/export.h

        29 #define NFSEXP_READONLY        0x0001
        30 #define NFSEXP_INSECURE_PORT   0x0002
        31 #define NFSEXP_ROOTSQUASH      0x0004
        32 #define NFSEXP_ALLSQUASH       0x0008
        33 #define NFSEXP_ASYNC           0x0010
        34 #define NFSEXP_GATHERED_WRITES 0x0020
        35 /* 40 80 100 currently unused */
        36 #define NFSEXP_NOHIDE          0x0200
        37 #define NFSEXP_NOSUBTREECHECK  0x0400
        38 #define NFSEXP_NOAUTHNLM       0x0800         /* Don't authenticate NLM requests - just trust */
        39 #define NFSEXP_MSNFS           0x1000 /* do silly things that MS clients expect */
        40 #define NFSEXP_FSID            0x2000
        41 #define NFSEXP_CROSSMOUNT      0x4000
        42 #define NFSEXP_NOACL           0x8000 /* reserved for possible ACL related use */
        43 #define NFSEXP_ALLFLAGS        0xFE3F

======
secure
======

This option requires that requests originate on an Internet port less than IPPORT_RESERVED (1024). This option is on by default. To turn it off, specify insecure. Soruce code defined variable is NFSEXP_INSECURE_PORT. Most HP/AIX systems use ports above 1024, hence require insecure option set. secure is the default.

::

        /*
         * Perform sanity checks on the dentry in a client's file handle.
         *
         * Note that the file handle dentry may need to be freed even after
         * an error return.
         *
         * This is only called at the start of an nfsproc call, so fhp points to
         * a svc_fh which is all 0 except for the over-the-wire file handle. */
        u32
        fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, int type, int access)
        ........

        184                /* Check if the request originated from a secure port. */ 
        185                error = nfserr_perm; 
        186                if (!rqstp->rq_secure && EX_SECURE(exp)) { 
        187                        printk(KERN_WARNING 
        188                               "nfsd: request from insecure port (%u.%u.%u.%u:%d)!\n", 
        189                               NIPQUAD(rqstp->rq_addr.sin_addr.s_addr), 
        190                               ntohs(rqstp->rq_addr.sin_port)); 
        191                        goto out; 
        192                } 
        193 

=======================
secure_locks (auth_nlm)
=======================

This option tells the NFS server not to require authentication of locking requests (i.e. requests which use the NLM protocol). Normally the NFS server will require a lock request to hold a credential for a user who has read access to the file. With this flag no access checks will be performed. Early NFS client implementations did not send credentials with lock requests, and many current NFS clients still exist which are based on the old implementations. Use this flag if you find that you can only lock files which are world readable. Again HP/AIX systems seem to require insecure_locks(no_auth_nlm) for lock requests to work

::

        1791 /* 
        1792 * Check for a user's access permissions to this inode. 
        1793 */ 
        1794 int 
        1795 nfsd_permission(struct svc_export *exp, struct dentry *dentry, int acc) 
        1796 {
        ......

        1834        if (acc & MAY_LOCK) {
        1835                /* If we cannot rely on authentication in NLM requests,
        1836                 * just allow locks, otherwise require read permission, or
        1837                 * ownership
        1838                 */
        1839                if (exp->ex_flags & NFSEXP_NOAUTHNLM)
        1840                        return 0;
        1841                else
        1842                        acc = MAY_READ | MAY_OWNER_OVERRIDE;
        1843        }
        1844        /*

======
wdelay
======

Refer to **Write Gathering**

The NFS server will normally delay committing a write request to disc slightly if it suspects that another related write request may be in progress or may arrive soon. This allows multiple write requests to be committed to disc with the one operation which can improve performance. If an NFS server received mainly small unrelated requests, this behaviour could actually reduce performance, so no_wdelay is available to turn it off. The default can be explicitly requested with the wdelay option.

::

         905 
         906 static int
         907 nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
         908                                loff_t offset, struct kvec *vec, int vlen,
         909                                unsigned long cnt, int *stablep)
         910 {
         .......

         946        if (stable && !EX_WGATHER(exp))
         947                file->f_flags |= O_SYNC;
         948 
         949        /* Support HSMs -- see comment in nfsd_setattr() */
         950        if (rqstp->rq_vers >= 3)
         951                file->f_flags |= O_NONBLOCK;
         952 
         953        /* Write the data. */
         954        oldfs = get_fs(); set_fs(KERNEL_DS);
         955        err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);
         956        set_fs(oldfs);
         957        if (err >= 0) {
         958                nfsdstats.io_write += cnt;
         959                fsnotify_modify(file->f_dentry);
         960        }
         961
         962         /* clear setuid/setgid flag after write */
         963         if (err >= 0 && (inode->i_mode & (S_ISUID | S_ISGID)))
         964                 kill_suid(dentry, file->f_vfsmnt);
         965 
         966         if (err >= 0 && stable) {
         967                 static ino_t    last_ino;
         968                 static dev_t    last_dev;
         969 
         970                 /*
         971                  * Gathered writes: If another process is currently
         972                  * writing to the file, there's a high chance
         973                  * this is another nfsd (triggered by a bulk write
         974                  * from a client's biod). Rather than syncing the
         975                  * file with each write request, we sleep for 10 msec.
         976                  *
         977                  * I don't know if this roughly approximates
         978                  * C. Juszak's idea of gathered writes, but it's a
         979                  * nice and simple solution (IMHO), and it seems to
         980                  * work:-)
         981                  */
         982                 if (EX_WGATHER(exp)) {
         983                         if (atomic_read(&inode->i_writecount) > 1
         984                             || (last_ino == inode->i_ino && last_dev == inode->i_sb->s_dev)) {
         985                                 dprintk("nfsd: write defer %d\n", current->pid);
         986                                 msleep(10);
         987                                 dprintk("nfsd: write resume %d\n", current->pid);
         988                         }
         989 
         990                         if (inode->i_state & I_DIRTY) {
         991                                 dprintk("nfsd: write sync %d\n", current->pid);
         992                                 err=nfsd_sync(file);
         993                         }
         994 #if 0
         995                         wake_up(&inode->i_wait);
         996 #endif
         997                 }
         998                 last_ino = inode->i_ino;
         999                 last_dev = inode->i_sb->s_dev;

Line 946-947 handles the case where wdelay and sync are specified. If sync is specified and wdelay isn't then we set O_SYNC flag for the file and call vfs_write. If sync is specified and also wdelay, do not set O_SYNC flag for file, wait for other writes to arrive on line 985, and then call a sync for that inode on line 992. sync(file) will only be called if the inode is dirty so all the threads don't have to call sync.

====
sync
====
Refer to NFSCacheConsistency#NFSStableStorage

Reply to requests only after the changes have been committed to stable storage. sync is the default, and async must be explicitly requested if needed.

::

        238 int
         239 nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
         240              int check_guard, time_t guardtime)
         .....
         370         if (!err)
         371                 if (EX_ISSYNC(fhp->fh_export))
         372                         write_inode_now(inode, 1);
        ..... 
        1119 int
        1120 nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
        1121                 char *fname, int flen, struct iattr *iap,
        1122                 int type, dev_t rdev, struct svc_fh *resfhp)
        .....
        1212         if (EX_ISSYNC(exp)) {
        1213                 err = nfserrno(nfsd_sync_dir(dentry));
        1214                 write_inode_now(dchild->d_inode, 1);
        1215         }
        1216 

        1247 int
        1248 nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
        1249                 char *fname, int flen, struct iattr *iap,
        1250                 struct svc_fh *resfhp, int createmode, u32 *verifier,
        1251                 int *truncp)
        1252 {
        .......
        1345         if (EX_ISSYNC(fhp->fh_export)) {
        1346                 err = nfserrno(nfsd_sync_dir(dentry));
        1347                 /* setattr will sync the child (or not) */
        1348         }


        1443 int
        1444 nfsd_symlink(struct svc_rqst *rqstp, struct svc_fh *fhp,
        1445                                 char *fname, int flen,
        1446                                 char *path,  int plen,
        1447                                 struct svc_fh *resfhp,
        1448                                 struct iattr *iap)
        .........
        1493         if (!err)
        1494                 if (EX_ISSYNC(exp))
        1495                         err = nfsd_sync_dir(dentry);


        1515 int
        1516 nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
        1517                                 char *name, int len, struct svc_fh *tfhp)
        1518 {
        ..............
        1551         if (!err) {
        1552                 if (EX_ISSYNC(ffhp->fh_export)) {
        1553                         err = nfserrno(nfsd_sync_dir(ddir));
        1554                         write_inode_now(dest, 1);
        1555                 }
        1556         } else {


        1577 int
        1578 nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
        1579                             struct svc_fh *tfhp, char *tname, int tlen)
        1580 {
        ............
        1642         if (!err && EX_ISSYNC(tfhp->fh_export)) {
        1643                 err = nfsd_sync_dir(tdentry);
        1644                 if (!err)
        1645                         err = nfsd_sync_dir(fdentry);
        1646         }


        1673 int
        1674 nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
        1675                                 char *fname, int flen)
        1676 {
        ...........
        1722         if (err == 0 &&
        1723             EX_ISSYNC(exp))
        1724                         err = nfsd_sync_dir(dentry);
        1725 


        1086 int
        1087 nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
        1088                loff_t offset, unsigned long count)
        ............
        1098         if (EX_ISSYNC(fhp->fh_export)) {
        1099                 if (file->f_op && file->f_op->fsync) {
        1100                         err = nfserrno(nfsd_sync(file));
        1101                 } else {
        1102                         err = nfserr_notsupp;
        1103                 }
        1104         }


        906 static int
        907 nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
        908                                 loff_t offset, struct kvec *vec, int vlen,
        909                                 unsigned long cnt, int *stablep)
        ...........
        944         if (!EX_ISSYNC(exp))
        945                 stable = 0;

No operation is guaranteed to be have done on stable storage when async is used.

================
no_subtree_check
================

This option disables subtree checking, which has mild security implications, but can improve reliability in some circumstances.

If a subdirectory of a filesystem is exported, but the whole filesystem isn't then whenever a NFS request arrives, the server must check not only that the accessed file is in the appropriate filesystem (which is easy) but also that it is in the exported tree (which is harder). This check is called the subtree_check.

In order to perform this check, the server must include some information about the location of the file in the "filehandle" that is given to the client. This can cause problems with accessing files that are renamed while a client has them open (though in many simple cases it will still work).

subtree checking is also used to make sure that files inside directories to which only root has access can only be accessed if the filesystem is exported with no_root_squash (see below), even if the file itself allows more general access.

As a general guide, a home directory filesystem, which is normally exported at the root and may see lots of file renames, should be exported with subtree checking disabled. A filesystem which is mostly readonly, and at least doesn't see many file renames (e.g. /usr or /var) and for which subdirectories may be exported, should probably be exported with subtree checks enabled.

The default of having subtree checks enabled, can be explicitly requested with subtree_check.

::

         38 /*
         39  * our acceptability function.
         40  * if NOSUBTREECHECK, accept anything
         41  * if not, require that we can walk up to exp->ex_dentry
         42  * doing some checks on the 'x' bits
         43  */
         44 static int nfsd_acceptable(void *expv, struct dentry *dentry)
         45 {
         46         struct svc_export *exp = expv;
         47         int rv;
         48         struct dentry *tdentry;
         49         struct dentry *parent;
         50 
         51         if (exp->ex_flags & NFSEXP_NOSUBTREECHECK)
         52                 return 1;
         53 
         54         tdentry = dget(dentry);
         55         while (tdentry != exp->ex_dentry && ! IS_ROOT(tdentry)) {
         56                 /* make sure parents give x permission to user */
         57                 int err;
         58                 parent = dget_parent(tdentry);
         59                 err = permission(parent->d_inode, MAY_EXEC, NULL);
         60                 if (err < 0) {
         61                         dput(parent);
         62                         break;
         63                 }
         64                 dput(tdentry);
         65                 tdentry = parent;
         66         }
         67         if (tdentry != exp->ex_dentry)
         68                 dprintk("nfsd_acceptable failed at %p %s\n", tdentry, tdentry->d_name.name);
         69         rv = (tdentry == exp->ex_dentry);
         70         dput(tdentry);
         71         return rv;
         72 }
         73 

====
fsid
====

This option forces the filesystem identification portion of the file handle and file attributes used on the wire to be num instead of a number derived from the major and minor number of the block device on which the filesystem is mounted. Any 32 bit number can be used, but it must be unique amongst all the exported filesystems.

This can be useful for NFS failover, to ensure that both servers of the failover pair use the same NFS file handles for the shared filesystem thus avoiding stale file handles after failover.

::

        /nfs4exports 192.168.18.129/26(ro,sync,insecure,no_root_squash,no_subtree_check,fsid=0)
        /nfs4exports/vmware-data 192.168.18.129/26(rw,nohide,sync,insecure,no_root_squash,no_subtree_check,fsid=1)
        /nfs4exports/xen-config 192.168.18.129/26(rw,nohide,sync,insecure,no_root_squash,no_subtree_check,fsid=2)

fsid=0 has magic properties in NFSv4. For NFSv4, there is a distinguished filesystem which is the root of all exported filesystem. This is specified with fsid=root or fsid=0 both of which mean exactly the same thing.

NFS Ack Storm Handling
----------------------

=========
Ack Storm
=========

When a vip is removed a interfaces any existing connections that were made to that ip stay intact, i.e un-plumbing of an ip does not automatically close any sockets that are using that IP. When a vip moves from node_01 to node_02, the connections on node_01 for that vip still remains intact. When client re-connects to node_02, his connection gets reset and he will start a new connection, with a new sequence number and ack number. If the vip again moves from node_02 to node_01, as there is an existing connection already for that client, that is not closed yet, the server will think its the same connection. Both the server and client will try to send/receive data, but the sequence and ack number is unlikely to match, as client would be using the seq/ack no that he negotiated with node_02 which is not valid on node_01. When receiving an unacceptable packet the server/client acknowledges it by sending the expected sequence number and using its own sequence number. This packet is itself unacceptable to the other side and will generate an acknowledgement packet which in turn will generate an acknowledgement packet, thereby creating a supposedly endless loop for every data packet sent. The mismatch in SEQ/ACK numbers results in excess network traffic with both the server and target trying to verify the right sequence.

=============================================
Traditional VCS design for avoiding ack storm
=============================================

Traditional VCS design has NFSRestart doing the job of fixing ACK storm. In single node NFS configuration VCS configuration is done as NFS -> ip -> NFSRestart, NFS starts up first, then ip and then NFSRestart, when moving the group from one node to other node VCS offline order is NFSRestart -> ip -> NFS, the job of NFSRestart agent is to restart NFS so that the sockets are closed. Whether VCS would succeed in closing the connection completely would depend on the reason for failover.

#.  NIC failure,

   *    then restarting NFS will get the socket to FIN_WAIT1 state but does not ensure that the socket is closed completely.
   *    If the ip moves back again in the short period of time before the socket comes out of FIN_WAIT1 state, then it is still possible to get into ack-storm (sockets in FIN_WAIT1 can also enter into ack-storm if ack number does not match) 

#.  Manual failover

   *    During manual failover, when restarting NFS the NIC would be fine, and connection can be closed gracefully 

=====================================
Filestore ack-storm for clustered NFS
=====================================

With filestore design of VIPgroups and NFS, it is not possible to maintain the resource hierarchy as done in traditional single-node NFS. Filestore design does not restart NFS during failover of vip, but restarts NFS when failing backup the ip. When an ip tries to come online on a node, during its preonline we check if there are NFS connections on that IP. This IP is not plumbed on the device, still if there is a connection listed in netstat, then it is likely that the ip was online on this node before and clients were connected to this ip during that time.

#.  If the ip has never failed over any other node, but was only went through offline/online on the same, then the sequence number would not have changed and there is no danger of entering ack-storm
#   If the ip has moved to another and came back again.

   *    When it moved to the other node, if the client has not tried to access nfs, then the connection would not have been reset and ack number would not have changed, and we are not going to enter ack-storm
   *    When it moved to the other node, if the client has tried to access nfs, then its connection would have reset and would be using a new ack number, and if we plumb this ip then we are likely to enter ack-storm
   *    When it moved to the other node, if the client has tried to access nfs, then its connection would have reset and would be using a new ack number, in a very unlikely scenario both the client and server might end up with seq/ack combination as was on the original node. If we plumb this ip here, we are not going to enter ack-storm, but we would corrupt the data. 

As its not possible to disinguish the above cases from one-another, we always restart NFS if we see a connection already existing for NFS on that ip. This results in the socket going into FIN_WAIT1, but the socket cannot be closed as the ip is not plumbed, kernel would be attempting to send FIN packet to the client which fails. Steps in closing the connection these connections

#.  Preonline:

   *    Restart NFS, if there are exising connections
   *    Note down these connections that would enter FIN_WAIT1 stage
   *    Proceed with onliing the ip 

#.  Postonline:

   #.   For all those connections that existing in preonline which would have gone into FIN_WAIT1 stage and into ack-storm, send a tickle-ack and RST packet to close the connection. The socket will stay in ack-storm till we force closing of this connection using RST which is also a very unlikely event as client would have already backed-off when its previous packets were lost

       *    Send a tickle ack, to remote machine
       *    Remote machine sends a ACK packet with correct ack/seq no
       *    Use the ack/seq no sent by remote machine to send a reset 

In most of the cases its not even required to restart NFS in preonline, as we are going to reset the connections in postonline, but if during postonline we are not able to RST the connection either due to client not responding at that time or some other reason, then the restart of NFS which has forced the socket into FIN_WAIT1 would cause the socket to be closed after some time.

=========
FIN_WAIT1
=========
A socket enters the FIN_WAIT_1 state when one side of a connection calls close() on an open socket (causing a FIN to be transmitted to the other end). It stays in this state whilst waiting for the other end to respond with an ACK to the FIN that was transmitted to it. The remote (should) automatically send the ACK, causing the client to enter the FIN_WAIT_2 state (This is done by the kernel). It remains in this state until the remote sends LAST_ACK. This happens when the other side calls close() on it's end of the socket. At that point it will enter the TIME_WAIT state where it will stay for the 2MSL timeout (30, 60 or 180 seconds typically, linux == 60).

http://copilotco.com/mail-archives/beowulf.1998/msg01618.html

=====
Links
=====

Ack-storm faced in RHCS and possible solutions suggested on the forum 
    https://bugzilla.redhat.com/show_bug.cgi?id=369991

Hijacking a connection causing it to enter a ack-storm 
    http://fullgames4ever.blogspot.com/2010/10/hacking-tips_18.html

NFS Development
---------------

=================
NFS Kernel module
=================

Compiling NFS modules

::

        obj-m = nfsd.ko
        KVERSION = $(shell uname -r)
        all:
                make -C /lib/modules/$(KVERSION)/build M=$(PWD) modules
        clean:
                make -C /lib/modules/$(KVERSION)/build M=$(PWD) clean


NFS Troubleshooting
-------------------

=======================
NFS Stale handle errors
=======================

Possible Causes
    A file or directory that was opened by NFS client is removed, renamed or replaced 

To reproduce this issue 

*   On client 1 :

   *    dd if=/dev/zero of=/mnt/nfs_fs/a/outfile count=256 bs=1024K

*   On client 2 :

   *    rm /mnt/nfs_fs/a/outfile remove the outfile from another client while the file is being accessed from the first client. 

Sometimes the error could be 'input/output error' returned by dd. Verify the actual error returned by capturing ethereal traces for NFS.a

===================
FS fsid has changed
===================

    Could happen if the underlying FS has changed its fsid, because either it was unmounted or a different fs is mounted at the same place.
        IP failover happened to another node, and CFS is not mounted on that node

=================================
How to get out stale handle state
=================================

Depending on how you have reached the state, you need to follow different steps to get out.

*    If the file was removed or deleted, doing 'ls' would cause a new getattr request and that should refresh the client cache.
*    If the fsid has changed, then from the client you will have remount the fs


===============================
gzip complains with Broken pipe
===============================

::

        gunzip < file.tar.gz | tar xvf -
        gunzip < file.tgz    | tar xvf -


If you use the commands described above to extract a tar.gz file, gzip sometimes emits a Broken pipe error message. This can safely be ignored if tar extracted all files without any other error message.

The reason for this error message is that tar stops reading at the logical end of the tar file (a block of zeroes) which is not always the same as its physical end. gzip then is no longer able to write the rest of the tar file into the pipe which has been closed.

This problem occurs only with some shells, mainly bash. These shells report the SIGPIPE signal to the user, but most others (such as tcsh) silently ignore the pipe error.

You can easily reproduce the same error message with programs other than gzip and tar, for example:

::

          cat /dev/zero | dd bs=1 count=1

=================
NFS Lock problems
=================

*   Lock request fails for clients conencted to non NLMGroup hosts, but succeeds for host with NLMGroup online on it

   *    NLM slaves require shares in their names. This is fixed in 5.5SP1RP1 and internal shares are created automatically.

       *    Fix is to create a share with private subnet of priveth0

::

            /vx/fs_src_1    172.26.114.81/24(rw,wdelay,no_root_squash)
            /vx/fs_str      172.26.114.81/24(rw,wdelay,no_root_squash)

*   Lock request fails for clients connected to NLMGroup master from HP/AIX systems. If the lock request succeeds by adding world read permission, then export the share with insecure_locks

::

    # /opt/VRTSsfmh/bin/statlog --newdb data 3
    # /opt/VRTSsfmh/bin/statlog --setprop data rate 1
    cannot lock file:
    cannot open database for --setprop
    # chmod +r data*
    # /opt/VRTSsfmh/bin/statlog --setprop data rate 1

========
NFS ACLs
========
NFS server only supports posix acls, i.e, system.posix_acl_access and system.posix_acl_default. Other extended attributes are not supported through NFS server. There is strict checking in NFS that only these 2 ACLs can be set/get.

::

        2220 int    
        2221 nfsd_set_posix_acl(struct svc_fh *fhp, int type, struct posix_acl *acl)
        2222 {      
        2223         struct inode *inode = fhp->fh_dentry->d_inode;
        2224         char *name;
        2225         void *value = NULL;
        2226         size_t size;
        2227         int error;
        2228        
        2229         if (!IS_POSIXACL(inode) ||
        2230             !inode->i_op->setxattr || !inode->i_op->removexattr)
        2231                 return -EOPNOTSUPP;
        2232         switch(type) {
        2233                 case ACL_TYPE_ACCESS:
        2234                         name = POSIX_ACL_XATTR_ACCESS;
        2235                         break;
        2236                 case ACL_TYPE_DEFAULT:
        2237                         name = POSIX_ACL_XATTR_DEFAULT;
        2238                         break;
        2239                 default:
        2240                         return -EOPNOTSUPP;
        2241         } 
        2242        

=======================================
Enable NFS Debugging in /proc variables
=======================================

To enable logging of all operations being received by NFS server

::
	
	echo 16 > /proc/sys/sunrpc/nfsd_debug

To enable logging of all RPCs being queued and how they are being transmitted

::

	echo 3 > /proc/sys/sunrpc/rpc_debug

	


NFS Ethereal
------------
ethereal has 2 types of filters.

*   Capture filter specified using -f. Capture filter defines the packets which have to be captured, and then display filter will be applied on it.

   *    Display filter specified using -R. Display filter defines which of the captures packets have to be shown. If using '-w' to capture packets, using display filter will not work. All the packets matching -f would be written to trace file, even if -R specified some criteria


Examples

::

        Capture all NFS traffic 
        # tethereal -t a -n -i any -f 'port 2049' 
        Capture all NFS traffic expcept loopback
        # tethereal -t a -n -i any -f 'port 2049 and host not 127.0.0.1'
        To capture all NFS unlink calls
        # tethereal -t a -n -i any -f 'port 2049' -R "nfs and (rpc.procedure == 12)"
        To capture error returns for nfs requests
        # tethereal -t a -n -i any -f 'port 2049' -R "nfs and (nfs.nfsstat3 != NFS3_OK)"


Display filter reference for NFS

* http://www.wireshark.org/docs/dfref/n/nfs.html
* http://ethereal.sourcearchive.com/documentation/0.99.0-1ubuntu1/packet-nfs_8c-source.html
* http://docstore.mik.ua/orelly/networking_2ndEd/nfs/ch13_05.htm
* http://wiki.wireshark.org/NFS_Preferences
* http://docstore.mik.ua/orelly/networking_2ndEd/nfs/ch15_04.htm
* https://bugzilla.redhat.com/show_bug.cgi?id=201211

NFS handle format
-----------------

http://www.fsl.cs.sunysb.edu/docs/nfscrack-tr/index.html


======  =====   ===================     =====================================   ==============================
Length  Bytes   Field Name              Meaning                                 Typical Values
======  =====   ===================     =====================================   ==============================
1       1       fb_version              NFS version                             Always 1
1       2       fb_auth_type            Authentication method                   Always 0
1       3       fb_fsid_type            File system ID encoding method          Always 0
1       4       fb_fileid_type          File ID encoding method                 Always either 0, 1, or 2
4       5-8     xdev                    Major/Minor number of exported device   Major number 3 (IDE), 8 (SCSI)
4       9-12    xino                    Export inode number                     Almost always 2
4       13-16   ino                     Inode number                            2 for /, 19 for /home/foo
4       17-20   gen_no                  Generation number                       0xFF16DDF1, 0x3F6AE3C0
4       21-24   par_ino_no              Parent's inode number                   2 for /, 19 for /home
8       25-32   Padding for NFSv2                                               Always 0
32      33-64   Unused by Linux
======  =====   ===================     =====================================   ==============================

If value of fsid_type is 0 then fsid length is 8 ....

.. code-block:: c

        194 static inline int key_len(int type)
        195 {
        196         switch(type) {
        197         case 0: return 8;
        198         case 1: return 4;
        199         case 2: return 12;
        200         case 3: return 8;
        201         default: return 0;
        202         }
        203 }

Complete definition of file handle in linux

::

        27 /*
         28  * This is the old "dentry style" Linux NFSv2 file handle.
         29  *
         30  * The xino and xdev fields are currently used to transport the
         31  * ino/dev of the exported inode.
         32  */
         33 struct nfs_fhbase_old {
         34         __u32           fb_dcookie;     /* dentry cookie - always 0xfeebbaca */
         35         __u32           fb_ino;         /* our inode number */
         36         __u32           fb_dirino;      /* dir inode number, 0 for directories */
         37         __u32           fb_dev;         /* our device */
         38         __u32           fb_xdev;
         39         __u32           fb_xino;
         40         __u32           fb_generation;
         41 };
         42 
         43 /*
         44  * This is the new flexible, extensible style NFSv2/v3 file handle.
         45  * by Neil Brown <neilb@cse.unsw.edu.au> - March 2000
         46  *
         47  * The file handle is seens as a list of 4byte words.
         48  * The first word contains a version number (1) and four descriptor bytes
         49  * that tell how the remaining 3 variable length fields should be handled.
         50  * These three bytes are auth_type, fsid_type and fileid_type.
         51  *
         52  * All 4byte values are in host-byte-order.
         53  *
         54  * The auth_type field specifies how the filehandle can be authenticated
         55  * This might allow a file to be confirmed to be in a writable part of a
         56  * filetree without checking the path from it upto the root.
         57  * Current values:
         58  *     0  - No authentication.  fb_auth is 0 bytes long
         59  * Possible future values:
         60  *     1  - 4 bytes taken from MD5 hash of the remainer of the file handle
         61  *          prefixed by a secret and with the important export flags.
         62  *
         63  * The fsid_type identifies how the filesystem (or export point) is
         64  *    encoded.
         65  *  Current values:
         66  *     0  - 4 byte device id (ms-2-bytes major, ls-2-bytes minor), 4byte inode number
         67  *        NOTE: we cannot use the kdev_t device id value, because kdev_t.h
         68  *              says we mustn't.  We must break it up and reassemble.
         69  *     1  - 4 byte user specified identifier
         70  *     2  - 4 byte major, 4 byte minor, 4 byte inode number - DEPRECATED
         71  *     3  - 4 byte device id, encoded for user-space, 4 byte inode number
         72  *
         73  * The fileid_type identified how the file within the filesystem is encoded.
         74  * This is (will be) passed to, and set by, the underlying filesystem if it supports
         75  * filehandle operations.  The filesystem must not use the value '0' or '0xff' and may
         76  * only use the values 1 and 2 as defined below:
         77  *  Current values:
         78  *    0   - The root, or export point, of the filesystem.  fb_fileid is 0 bytes.
         79  *    1   - 32bit inode number, 32 bit generation number.
         80  *    2   - 32bit inode number, 32 bit generation number, 32 bit parent directory inode number.
         81  *
         82  */
         83 struct nfs_fhbase_new {
         84         __u8            fb_version;     /* == 1, even => nfs_fhbase_old */
         85         __u8            fb_auth_type;
         86         __u8            fb_fsid_type;
         87         __u8            fb_fileid_type;
         88         __u32           fb_auth[1];
         89 /*      __u32           fb_fsid[0]; floating */
         90 /*      __u32           fb_fileid[0]; floating */
         91 };
         92 
         93 struct knfsd_fh {
         94         unsigned int    fh_size;        /* significant for NFSv3.
         95                                          * Points to the current size while building
         96                                          * a new file handle
         97                                          */
         98         union {
         99                 struct nfs_fhbase_old   fh_old;
        100                 __u32                   fh_pad[NFS4_FHSIZE/4];
        101                 struct nfs_fhbase_new   fh_new;
        102         } fh_base;
        103 };
        104 
        105 #define ofh_dcookie             fh_base.fh_old.fb_dcookie
        106 #define ofh_ino                 fh_base.fh_old.fb_ino
        107 #define ofh_dirino              fh_base.fh_old.fb_dirino
        108 #define ofh_dev                 fh_base.fh_old.fb_dev
        109 #define ofh_xdev                fh_base.fh_old.fb_xdev
        110 #define ofh_xino                fh_base.fh_old.fb_xino
        111 #define ofh_generation          fh_base.fh_old.fb_generation
        112 
        113 #define fh_version              fh_base.fh_new.fb_version
        114 #define fh_fsid_type            fh_base.fh_new.fb_fsid_type
        115 #define fh_auth_type            fh_base.fh_new.fb_auth_type
        116 #define fh_fileid_type          fh_base.fh_new.fb_fileid_type
        117 #define fh_auth                 fh_base.fh_new.fb_auth
        118 #define fh_fsid                 fh_base.fh_new.fb_auth
        119 


Example :
File Handle collected from ethereal trace : 01 00 00 00 00 c7 00 09 02 00 00 00

::

        01 - fb_version
        00 - fb_auth_type
        00 - fb_fsid_type (default fsid type, automatically generated)
        00 - fb_fileid_type (root inode)
        {
        00 c7 - major number - 199
        00 09 - minor number - 9
        02 00 00 00 - root inode of exported share '2'
        }


Example :
File Handle collected from ethereal trace : 01 00 00 00 00 c7 00 23 04 00 00 00

::

        01 - fb_version
        00 - fb_auth_type
        00 - fb_fsid_type (default fsid type, automatically generated)
        00 - fb_fileid_type (root inode)
        {
        00 c7 - major number - 199
        00 23 - minor number - 35
        04 00 00 00 - root inode of exported share '4'
        }


Example :
File Handle collected from ethereal trace : 01 00 01 00 0a 00 00 00

::

        01 - fb_version
        00 - fb_auth_type
        01 - fb_fsid_type (user has explicitly requested a fsid)
        00 - fb_fileid_type (root inode)
        {
        0a 00 00 00 - fsid 10 chosen by using 'fsid=' exportfs option
        }


Example :
File Handle collected from ethereal trace : 01 00 01 01 0a 00 00 00 04 00 00 00 2c 2a 86 77

::

        01 - fb_version
        00 - fb_auth_type
        01 - fb_fsid_type (user has explicitly requested a fsid)
        01 - fb_fileid_type (32-bit inode 32-bit gencount)
        {
        0a 00 00 00 - fsid 10 chosen by using 'fsid=' exportfs option
        }
        04 00 00 00 - inode number 4
        2c 2a 86 77 -(host format inside packet and not network format) (77 86 2a 2c - gencount 2005281324)

===============
NFS inode limit
===============
NFS handles have 32-bit inode number, where as filesystems would have 64-bit inodes. Which means any files with inode number greater than 2^32 cannot be used. 2^32 is a lot of files, 4-billion files, which we are unlikely to touch and since inode numbers are reused it is not a problem.



NFS Performance Tuning
----------------------

=============================================
Tuning the number of nfsd daemons on a server
=============================================

Tuning NFS performance
        http://osr507doc.sco.com/en/PERFORM/NFS_tuning.html
Server tuning: Manaaging NFS and NIS second edition
        http://docstore.mik.ua/orelly/networking_2ndEd/nfs/ch16_05.htm


Like biods, nfsd daemons provide processes for the scheduler to control -- the bulk of the work dealing with requests from clients is performed inside the kernel. Each nfsd is available to service an incoming request unless it is already occupied. The more nfsds that are running, the faster the incoming requests can be satisfied. There is little context switching overhead with running several nfsds as only one sleeping daemon is woken when a request needs to be served. 

If you run more nfsds than necessary, the main overhead is the pages of memory that each process needs for its u-area, data, and stack (program text is shared). Unused nfsd processes will sleep; they will be candidates for being paged or swapped out should the system need to obtain memory. 

If too few nfsds are running on the server, or its other subsystems, such as the hard disk, cannot respond fast enough, it will not be able to keep up with the demand from clients. You may see this on clients if several requests time out but the server can still service other requests. If you run the command nfsstat -c on the clients, its output provides some information about the server's performance as perceived by the client:

::

   Client rpc:
   calls    badcalls retrans  badxid   timeout  wait      newcred
   336033   50       413      418      299      0         0
   ...

If badxid is non-zero and roughly equal to retrans, as is the case in this example, the server is not keeping up with the clients' requests.

If you run too few nfsds on a server, the number of messages on the request queue builds up inside the upstream networking protocol stac

The CPU speed of a pure NFS server is rarely a constraining factor. Once the nfsd thread gets scheduled, and has read and decoded an RPC request, it doesn't do much more within the NFS protocol that requires CPU cycles. Other parts of the system, such as the Unix filesystem and cache management code, may use CPU cycles to perform work given to them by NFS requests. NFS usually poses a light load on a server that is providing pure NFS service.

There are two aspects to CPU loading: increased nfsd thread scheduling latency, and decreased performance of server-resident, CPU-bound processes. Normally, the nfsd threads will run as soon as a request arrives, because they are running with a kernel process priority that is higher than that of all user processes. However, if there are other processes doing I/O, or running in the kernel (doing system calls) the latency to schedule the nfsd threads is increased.

Instead of getting the CPU as soon as a request arrives, the nfsd thread must wait until the next context switch, when the process with the CPU uses up its time slice or goes to sleep. Running an excessive number of interactive processes on an NFS server will generate enough I/O activity to impact NFS performance. These loads affect a server's ability to schedule its nfsd threads; latency in scheduling the threads translates into decreased NFS request handling capacity since the nfsd threads cannot accept incoming requests as quickly.

The two major costs associated with a context switch are loading the address translation cache and resuming the newly scheduled task on the CPU. In the case of NFS server threads, both of these costs are near zero. All of the NFS server code lives in the kernel, and therefore has no user-level address translations loaded in the memory management unit. In addition, the task-to-task switch code in most kernels is on the order of a few hundred instructions. Systems can context switch much faster than the network can deliver NFS requests.

NFS server threads don't impose the "usual" context switching load on a system because all of the NFS server code is in the kernel. Instead of using a per-process context descriptor or a user-level process "slot" in the memory management unit, the nfsd threads use the kernel's address space mappings. This eliminates the address translation loading cost of a context switch.

=======================================
/proc/sys/sunrpc/tcp_slot_table_entries
=======================================

**tcp_slot_table_entries** sets the maximum number of (TCP) RPC requests that can be in flight. The default value is 16. You can increase the value, but that will also tie up more threads on the server.

Managing NFS and NIS, 2nd Edition.  By Hal Stern, Mike Eisler and Ricardo Labiaga
        **18.5. NFS async thread tuning.**
        ...
        If you are running eight NFS async threads on an NFS client, then the client
        will generate eight NFS write requests at once when it is performing
        a sequential write to a large file. The eight requests are handled by the NFS
        async threads. ... when a Solaris process issues a new write requests while
        all the NFS async threads are blocked waiting for a reply from the server,
        the write request is queued in the kernel and the requesting process returns
        successfully without blocking. The requesting process does not issue an RPC to
        the NFS server itself, only the NFS async threads do. When an NFS async thread
        RPC call completes, it proceeds to grab the next request from the queue and
        sends a new RPC to the server. It may be necessary to reduce the number of NFS
        requests if a server cannot keep pace with the incoming NFS write requests.

When a client mounts a NFS share, a sunrpc xprt socket is established. Both the client and server initialise their sunrpc xprt socket, with **tcp_slot_table_entries**. Once a xprt socket is established, changing the proc variables does not affect any already mounted shares. Once the value of **tcp_slot_table_entries** has been changed, the nfs share should be unmounted/mounted again.

Similar behaviour is expected for **udp_slot_table_entries**

==================================
NFS Tuning for 10G ethernet (10Ge)
==================================

::

        sunrpc.tcp_slot_table_entries = 128
        net.core.rmem_default = 4194304
        net.core.wmem_default = 4194304
        net.core.rmem_max = 4194304
        net.core.wmem_max = 4194304
        net.ipv4.tcp_rmem = 4096 1048576 4194304
        net.ipv4.tcp_wmem = 4096 1048576 4194304
        net.ipv4.tcp_timestamps = 0
        net.ipv4.tcp_syncookies = 1
        net.core.netdev_max_backlog = 300000

**cpuspeed** and **irqbalance** disabled

**Jumbo frames**

**Client Options** as **rsize=1048576,wsize=1048576**

NFS IPv6 Support
----------------
SLES11 does not include a separate nfs-utils package. It has nfs-utils related stuff in **nfs-kernel-server** package. The version in include upto 5.7P2 is 1.2.1-2.6.6 which does not have full IPv6 support. 5.7P2 package has IPv6 support in lockd, but not in mountd/nfsd

By default 5.7P2 install will disable **ipv6 in /etc/modprobe.conf**. Remove the line for disabling ipv6 and then load the modules. **/etc/netconfig** controls the protocols which will be allowed for RPC services.

::
       
        # rpcinfo -s
           program version(s) netid(s)                         service     owner
            100000  2,3,4     local,udp,tcp                    portmapper  superuser
            100005  3,2,1     tcp,udp                          mountd      superuser
            100024  1         tcp,udp                          status      superuser
            100021  4,3,1     tcp6,udp6,tcp,udp                nlockmgr    unknown
            100003  3,2       udp,tcp                          nfs         unknown
 
From the sample output, lockd starts IPv6 but not rpcbind/nfsd/mountd. Rebooting the node after enabling IPv6 will bring rpcbind/nfsd up with IPv6 support

::

        rpcinfo -s
           program version(s) netid(s)                         service     owner
            100000  2,3,4     local,udp,tcp,udp6,tcp6          portmapper  superuser
            100021  4,3,1     tcp6,udp6,tcp,udp                nlockmgr    unknown
            100003  3,2       udp,tcp                          nfs         unknown
            100005  3,2,1     tcp,udp                          mountd      superuser
            100024  1         tcp,udp                          status      superuser


        netstat -an | grep -E '4045|2049|4001|111'
        tcp        0      0 0.0.0.0:4045            0.0.0.0:*               LISTEN      
        tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      
        tcp        0      0 0.0.0.0:4001            0.0.0.0:*               LISTEN      
        tcp        0      0 0.0.0.0:2049            0.0.0.0:*               LISTEN      
        tcp        0      0 127.0.0.1:912           127.0.0.1:111           TIME_WAIT   
        tcp        0      0 :::4045                 :::*                    LISTEN      
        tcp        0      0 :::111                  :::*                    LISTEN      
        tcp        0      0 :::2049                 :::*                    LISTEN      
        udp        0      0 0.0.0.0:111             0.0.0.0:*                           
        udp        0      0 0.0.0.0:2049            0.0.0.0:*                           
        udp        0      0 0.0.0.0:4001            0.0.0.0:*                           
        udp        0      0 0.0.0.0:4045            0.0.0.0:*                           
        udp        0      0 :::111                  :::*                                
        udp        0      0 :::2049                 :::*                                
        udp        0      0 :::4045                 :::*                         

NFS Known Issues
----------------

==================================
ls -l hangs when writing to a file
==================================

.. code-block:: c

        /*
         * Flush out writes to the server in order to update c/mtime.
         *
         * Hold the i_mutex to suspend application writes temporarily;
         * this prevents long-running writing applications from blocking
         * nfs_wb_nocommit.
         * /
        if (S_ISREG(inode->i_mode)) {
                mutex_lock(&inode->i_mutex);
                nfs_wb_nocommit(inode);
                mutex_unlock(&inode->i_mutex);
        }

As the comment says the getattr request is blocked until all writes are completed for the file. This is to ensure that once we do getattr we get the final time that should be seen by the user. Typically if a long dd ran then there would be pages in memory that have not been flushed. In case of local filesystem the inode has already been updated once the last write was done by the user (even though not flused to the disk yet). In case of NFS when even user has done his writes if he has not closed the file, then any request for getattr will wait till all write's are completed. If we return with a specific time now and when the writes get flushed then we would have a different mtime, which conflicts with the expected behaviour that once writes are completed the time reflected should be correct. Whether this is strictly required is questionable. 

https://bugzilla.redhat.com/show_bug.cgi?id=469848

It was fixed in some kernels to not wait for the writes to complete but seems to have been reverted back.




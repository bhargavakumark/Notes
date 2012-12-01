
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



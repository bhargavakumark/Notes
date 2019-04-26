Networking : NIS
================

.. contents::

nis
---
consists of a client-server directory service protocol for distributing system configuration data such as user and host names between computers on a computer network.

NIS and NIS+ are only similar in their purpose and name; otherwise, they have completely different implementations. NIS+ differs from NIS in the following ways:

* NIS+ is hierarchical.
* NIS+ is based around Secure RPC (servers must authenticate clients and vice-versa).
* NIS+ may be replicated (replicas are read-only).
* NIS+ implements permissions on directories, tables, columns and rows.
* NIS+ also implements permissions on operations, such as being able to use nisping to transfer changed data from a master to a replication

The information accessed in NIS is housed in files called maps. In addition to the central master server, where all maps are maintained, and the clients that access them, slave servers exist. These slaves can handle client requests for map access, but no changes to the maps are made on the slaves. Changes are made only at the master server, and then distributed through the master (see Figure 2).

::

        --------Master---------
          |     |       |  
        Slave   |       Slave
          |     |       |  
        Client  Client  Client


NFS utilizes the AUTH_UNIX method of authentication, which implicitly trusts the UID (user ID) and GIDs (group ID) that the NFS client presents to the server. Root access to a file system explicitly exported by root can also be easily compromised if an intruder can gain root access. Further, programs can easily be developed that set the UID and GID value to any given number. This allows access to any user's file on an NFS server. [1] At times, the NFS daemons have also been known to be vulnerable to buffer overflows

use Yast to configure NIS server.
If you want to refresh data from /etc/netgroup to NIS server, restart using Yast.

Netgroups
---------

::

        netgroup  (host,user,domain)  (host,user,domain) ..

Links
-----
http://www.linuxtopia.org/online_books/opensuse_guides/opensuse11.1_reference_guide/sec_nis_server.html
http://www.server-world.info/en/note?os=SUSE_Linux_Enterprise_Server_11&p=nis&f=2
http://www.server-world.info/en/note?os=SUSE_Linux_Enterprise_Server_11&p=nis

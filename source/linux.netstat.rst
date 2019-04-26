Linux : netstat
===============

netstat
-------

One of the most common uses of the netstat utility is to determine 
the state of sockets on a machine. There are many questions that 
netstat can answer with the right set of options. Here's a list of 
some of the things different things we can learn.

*     which services are listening on which sockets
*     what process (and controlling PID) is listening on a given socket
*     whether data is waiting to be read on a socket
*     what connections are currently established to which sockets 


By invoking netstat without any options, you are asking for a list 
of all currently open connections to and from the networking stack 
on the local machine. This means IP network connections, unix domain 
sockets, IPX sockets and Appletalk sockets among others.

A convenient feature of netstat is its ability to differentiate 
between two different sorts of name lookup. Normally the -n 
specifies no name lookup, but this is ambiguous when there are 
hostnames, port names, and user names. Fortunately, netstat offers 
the following options to differentiate the different forms of 
lookup and suppress only the [un-]desired lookup.

*     --numeric-hosts
*     --numeric-ports
*     --numeric-users


The option -n, suppress all hostname, port name and username lookup, 
and is a synonym for --numeric. I'll reiterate that hostnames and 
DNS in particular can be confusing, or worse, misleading when trying 
to diagnose or debug a networking related issue, so it is wise to 
suppress hostname lookups in these sorts of situations.

Displaying IP socket status with netstat
----------------------------------------

::

        [root@morgan]# netstat --inet -n
        Active Internet connections (w/o servers)
        Proto Recv-Q Send-Q Local Address           Foreign Address         State
        tcp        0    192 192.168.98.82:22        192.168.99.35:40991     ESTABLISHED
        tcp        0      0 192.168.98.82:42929     192.168.100.17:993      ESTABLISHED
        tcp       96      0 127.0.0.1:40863         127.0.0.1:6010          ESTABLISHED
        tcp        0      0 127.0.0.1:6010          127.0.0.1:40863         ESTABLISHED
        tcp        0      0 127.0.0.1:38502         127.0.0.1:6010          ESTABLISHED
        tcp        0      0 127.0.0.1:6010          127.0.0.1:38502         ESTABLISHED
        tcp        0      0 192.168.98.82:53733     209.10.26.51:80         SYN_SENT
        tcp        0      0 192.168.98.82:44468     192.168.100.17:993      ESTABLISHED
        tcp        0      0 192.168.98.82:44320     192.168.100.17:139      TIME_WAIT
        [root@morgan]# netstat --inet --numeric-hosts
        Active Internet connections (w/o servers)
        Proto Recv-Q Send-Q Local Address           Foreign Address         State
        tcp        0      0 192.168.98.82:ssh       192.168.99.35:40991     ESTABLISHED
        tcp        0      0 192.168.98.82:42929     192.168.100.17:imaps    ESTABLISHED
        tcp        0      0 127.0.0.1:40863         127.0.0.:x11-ssh-offset ESTABLISHED
        tcp        0      0 127.0.0.:x11-ssh-offset 127.0.0.1:40863         ESTABLISHED
        tcp        0      0 127.0.0.1:38502         127.0.0.:x11-ssh-offset ESTABLISHED
        tcp        0      0 127.0.0.:x11-ssh-offset 127.0.0.1:38502         ESTABLISHED
        tcp        0      0 192.168.98.82:53733     209.10.26.51:http       SYN_SENT
        tcp        0      0 192.168.98.82:44468     192.168.100.17:imaps    ESTABLISHED
        tcp        0      0 192.168.98.82:44320     192.168.100:netbios-ssn ~TIME_WAIT


netstat abbreviates the IP endpoint in order to reproduce the entire 
string retrieved from the port lookup (in /etc/services). Also 
interestingly, this line conveys to us (in the first output) that the 
kernel is waiting for the remote endpoint to acknowledge the 192 bytes 
which are still in the Send-Q buffer.

The first line describes a TCP connection to the IP locally hosted on 
morgan's Ethernet interface. The connection was initiated from an 
ephemeral port (40991) on tristan to a service running on port 22. 
The service normally running on this well-known port is sshd, so 
we can conclude that somebody on tristan has connected to the 
morgan's ssh server. The second line describes a TCP session open 
to port 993 on isolde, which probably means that the user on morgan 
has an open connection to an IMAP over SSL server.

The final line of our netstatoutput shows a connection in the 
TIME_WAIT state, which means that the TCP sessions have been 
terminated, but the kernel is waiting for any packets which may 
still be left on the network for this session. It is not at all 
abnormal for sockets to be in a TIME_WAIT state for a short period 
of time after a TCP session has ended.

Displaying IP socket status details with netstat
------------------------------------------------

::

        [root@masq-gw]# netstat -p -e --inet --numeric-hosts
        Proto Recv-Q Send-Q Local Address           Foreign Address         State       User       Inode      PID/Program name   
        tcp        0      0 192.168.100.254:ssh     192.168.100.17:49796    ESTABLISHED root       25453      6326/sshd
        tcp        0    240 192.168.99.254:ssh      192.168.99.35:42948     ESTABLISHED root       171748     31535/sshd


Possible Session States in netstat output
-----------------------------------------

+-----------------+------------------------------------------------------------------------------------------------------------+
| State           | Description                                                                                                |
+=================+============================================================================================================+
| LISTEN          | accepting connections                                                                                      |
+-----------------+------------------------------------------------------------------------------------------------------------+
| ESTABLISHED     | connection up and passing data                                                                             |
+-----------------+------------------------------------------------------------------------------------------------------------+
| SYN_SENT        | TCP; session has been requested by us; waiting for reply from remote endpoint                              |
+-----------------+------------------------------------------------------------------------------------------------------------+
| SYN_RECV        | TCP; session has been requested by a remote endpoint for a socket on which we were listening               |
+-----------------+------------------------------------------------------------------------------------------------------------+
| LAST_ACK        | TCP; our socket is closed; remote endpoint has also shut down; we are waiting for a final acknowledgement  |
+-----------------+------------------------------------------------------------------------------------------------------------+
| CLOSE_WAIT      | TCP; remote endpoint has shut down; the kernel is waiting for the application to close the socket          |
+-----------------+------------------------------------------------------------------------------------------------------------+
| TIME_WAIT       | TCP; socket is waiting after closing for any packets left on the network                                   |
+-----------------+------------------------------------------------------------------------------------------------------------+
| CLOSED          | socket is not being used                                                                                   |
+-----------------+------------------------------------------------------------------------------------------------------------+
| CLOSING         | TCP; our socket is shut down; remote endpoint is shut down; not all data has been sent                     |
+-----------------+------------------------------------------------------------------------------------------------------------+
| FIN_WAIT1       | TCP; our socket has closed; we are in the process of tearing down the connection                           |
+-----------------+------------------------------------------------------------------------------------------------------------+
| FIN_WAIT2       | TCP; the connection has been closed; our socket is waiting for the remote endpoint to shut down            |
+-----------------+------------------------------------------------------------------------------------------------------------+

TCPUtils
========

.. contents::

This page describes the utilities available in nasgw/src/linux/common/tcputils

Related Info :

* http://monkey.org/~dugsong/dsniff/
* http://www.tcpdump.org/pcap.htm

sfs_tcp_reset
-------------
This program helps in sending a TCP reset to any connection that exists on the local node. The connection can be over any device, on virtual and physical ip. Usage syntax as on 23rd Feb 2010 is

::

        Usage: tcp_reset device localip port remoteip port

The device argument specifies the device on which the connection has been established. Currently we do not automatically find out the device on which the localip is online. The localip should be plumbed on the device, no checks are made to verify this.

Steps during reset of the Connection

#.    Create a filter to capture incoming packets for this connection (localip:port -> remoteip:port). We do this before sending out any packets, as we don't want to miss the ack that would be send immedieately after we send a tickle. If we create a filter after we send out a tickle, the reply from client could reach us before we start our capturing.
#.    Open a libnet handle to send packets out, with type RAW4 socket.
#.    Send a tickle for this connection, so the remote side on receiving this packet will send out a packet with seq no (ack no). We are only interested in the seq no. The packets that we send out are verified for correct seq no by the remote side, if the seq no does not match with the expected seq no on the remote side, the remote side will discard it.
#.    Capture the first return packet for this connection, and use that seq no to send a reset. This will work if the seq no has not changed since we captures and sent a reset. If this connection is used heavily, then it might be possible that between the time we capture a packet and use its seq no, the seq no might have changed due to other content being exchanged between both parties. We only make only attempt and do not verify that the RST is acknowledged correctly. So this might have worked or might have failed. We also wait infinitely for the reply from remote side, if the remote side does not reply or is dead, its upto the caller to terminate this process.
#.    Send a tickle again, so that the remote site will send a RST back to the server and the server also clears the connections in its cache. 

Enhancements

*    Automatically detect the device to be used for the given local ip
*    Accept a timeout value as an argument and wait only for that time for reply from remote side 

sfs_tcp_reset_ether
-------------------
This program is similar to sfs_tcp_reset except that is sends ethernet level packets instead of IP level packets. Usage syntax as on 23rd Feb 2010 is

::

        Usage: tcp_reset_ether device remote_mac remoteip port localip port

The device argument specifies the device on which the connection has been established. The remote_mac is the mac address of the remote ip, this mac address could be either be the mac address of the remote host or any gateway(if the remote host can only be reached from a gateway). Similar restrictions to device exists as in sfs_tcp_reset.

Steps during reset of the Connection

#.    Create a filter to capture incoming packets for this connection (localip:port -> remoteip:port). We do this before sending out any packets, as we don't want to miss the ack that would be send immedieately after we send a tickle. If we create a filter after we send out a tickle, the reply from client could reach us before we start our capturing.
#.    Open a libnet handle to send packets out, with type LINK socket. This allows us to add even ethernet header. For a RAW4 socket we can only add IP headers and not ethernet headers. This can be used to reset NAT connections, whose traffic cannot be captured correctly by pcap.
#.    Send a tickle for this connection, so the remote side on receiving this packet will send out a packet with seq no (ack no). We are only interested in the seq no. The packets that we send out are verified for correct seq no by the remote side, if the seq no does not match with the expected seq no on the remote side, the remote side will discard it.
#.    Capture the first return packet for this connection, and use that seq no to send a reset. This will work if the seq no has not changed since we captures and sent a reset. If this connection is used heavily, then it might be possible that between the time we capture a packet and use its seq no, the seq no might have changed due to other content being exchanged between both parties. We only make only attempt and do not verify that the RST is acknowledged correctly. So this might have worked or might have failed. We also wait infinitely for the reply from remote side, if the remote side does not reply or is dead, its upto the caller to terminate this process. Fortunately, pcap can capture incoming packets of a NAT and not outgoing packets. So for NAT connections, we use ethernet level packets to send tickles and a normal pcap filter to captures the replies for seq no. 



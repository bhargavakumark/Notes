Networking : NAT
================

.. contents::

NAT
---
network address translation (NAT) is the process of modifying network address information in datagram packet headers while in transit across a traffic routing device for the purpose of remapping a given address space into another.

Most often today, NAT is used in conjunction with network masquerading (or IP masquerading) which is a technique that hides an entire address space, usually consisting of private network addresses (RFC 1918), behind a single IP address in another, often public address space.

This mechanism is implemented in a routing device that uses stateful translation tables to map the "hidden" addresses into a single address and then rewrites the outgoing Internet Protocol (IP) packets on exit so that they appear to originate from the router. In the reverse communications path, responses are mapped back to the originating IP address using the rules ("state") stored in the translation tables. The translation table rules established in this fashion are flushed after a short period without new traffic refreshing their state.

"static NAT" or port forwarding and allows traffic originating in the 'outside' network to reach designated hosts in the masqueraded network.

Network address translation involves re-writing the source and/or destination IP addresses and usually also the TCP/UDP port numbers of IP packets as they pass through the NAT. Checksums (both IP and TCP/UDP) must also be rewritten to take account of the changes.

Working
-------
In a typical configuration, a local network uses one of the designated "private" IP address subnets (the RFC 1918 Private Network Addresses are 192.168.x.x, 172.16.x.x through 172.31.x.x, and 10.x.x.x (or using CIDR notation, 192.168/16, 172.16/12, and 10/8), and a router on that network has a private address (such as 192.168.0.1) in that address space. The router is also connected to the Internet with a single "public" address (known as "overloaded" NAT) or multiple "public" addresses assigned by an ISP. As traffic passes from the local network to the Internet, the source address in each packet is translated on the fly from the private addresses to the public address(es). The router tracks basic data about each active connection (particularly the destination address and port). When a reply returns to the router, it uses the connection tracking data it stored during the outbound phase to determine where on the internal network to forward the reply; the TCP or UDP client port numbers are used to demultiplex the packets in the case of overloaded NAT, or IP address and port number when multiple public addresses are available, on packet return. To a system on the Internet, the router itself appears to be the source/destination for this traffic.

NAT which involves translation of the source IP address and/or source port is called source NAT or SNAT. This re-writes the IP address and/or port number of the computer which originated the packet.
NAT which involves translation of the destination IP address and/or destination port number is called destination NAT or DNAT. This re-writes the IP address and/or port number corresponding to the destination computer.
SNAT and DNAT may be applied simultaneously to internet packets.

Types of NAT
------------
Full cone NAT
Once an internal address (iAddr:port1) is mapped to an external address (eAddr:port2), any packets from iAddr:port1 will be sent through eAddr:port2. Any external host can send packets to iAddr:port1 by sending packets to eAddr:port2.

-------------------
Restricted cone NAT
-------------------
Once an internal address (iAddr:port1) is mapped to an external address (eAddr:port2), any packets from iAddr:port1 will be sent through eAddr:port2. An external host (hostAddr:any) can send packets to iAddr:port1 by sending packets to eAddr:port2 only if iAddr:port1 had previously sent a packet to hostAddr:any. "any" means the port number doesn't matter.

------------------------
Port restricted cone NAT
------------------------
Like a restricted cone NAT, but the restriction includes port numbers.
Once an internal address (iAddr:port1) is mapped to an external address (eAddr:port2), any packets from iAddr:port1 will be sent through eAddr:port2. An external host (hostAddr:port3) can send packets to iAddr:port1 by sending packets to eAddr:port2 only if iAddr:port1 had previously sent a packet to hostAddr:port3.

-------------
symmetric NAT
-------------
Each request from the same internal IP address and port to a specific destination IP address and port is mapped to a unique external source IP address and port.

*    If the same internal host sends a packet even with the same source address and port but to a different destination, a different mapping is used.

Only an external host that receives a packet from an internal host can send a packet back.

NAT and TCP/UDP
---------------
The major transport layer protocols, TCP and UDP, have a checksum that covers all the data they carry, as well as the TCP/UDP header, plus a "pseudo-header" that contains the source and destination IP addresses of the packet carrying the TCP/UDP header. For an originating NAT to successfully pass TCP or UDP, it must recompute the TCP/UDP header checksum based on the translated IP addresses, not the original ones, and put that checksum into the TCP/UDP header of the first packet of the fragmented set of packets. The receiving NAT must recompute the IP checksum on every packet it passes to the destination host, and also recognize and recompute the TCP/UDP header using the retranslated addresses and pseudo-header. This is not a completely solved problem. One solution is for the receiving NAT to reassemble the entire segment and then recompute a checksum calculated across all packets.

NAT Traversal
-------------
NAT traversal is a general term for techniques that establish and maintain TCP/IP network connections traversing network address translation (NAT) gateways.

NAT traversal techniques are typically required for client-to-client networking applications, especially peer-to-peer and Voice-over-IP (VoIP) deployments. Many techniques exist, but no single method works in every situation since NAT behavior is not standardized. Many techniques require assistance from a computer server at a publicly-routable IP address. Some methods use the server only when establishing the connection (such as STUN), while others are based on relaying all data through it (such as TURN), which adds bandwidth costs and increases latency, detrimental to real-time voice and video communications.

In order for IPsec to work through a NAT, the following protocols need to be allowed on the firewall:

*    Internet Key Exchange (IKE) - User Datagram Protocol (UDP) port 500
*    Encapsulating Security Payload (ESP) - Internet Protocol (IP) 50

or, in case of NAT-T:

*    IPsec NAT-T - UDP port 4500

Often this is accomplished on home routers by enabling "IPsec Passthrough".

UDP Hole Punching
-----------------
NAT traversal through UDP hole punching is a method for establishing bidirectional UDP connections between Internet hosts in private networks using NAT. It does not work with all types of NATs as their behavior is not standardized.

The basic idea is to have each host behind the NAT contact a third well-known server (usually a STUN server) in the public address space and then, once the NAT devices have established UDP state information, to switch to direct communication hoping that the NAT devices will keep the states despite the fact that packets are coming from a different host.

UDP hole punching will not work with a Symmetric NAT (also known as bi-directional NAT) which tend to be found inside large corporate networks. With Symmetric NAT, the IP address of the well known server is different from that of the endpoint, and therefore the NAT mapping the well known server sees is different from the mapping that the endpoint would use to send packets through to the client. For details on the different types of NAT, see network address translation.

The technique is widely used in P2P software and VoIP telephony. It is one of the methods used in Skype to bypass firewalls and NAT devices. It can also be used to establish VPNs (using, e.g., OpenVPN, strongSwan).

Algorithm
---------
Let A and B be the two hosts, each in its own private network; N1 and N2 are the two NAT devices; S is a public server with a well-known globally reachable IP address.

*     A and B each begin a UDP conversation with S; the NAT devices N1 and N2 create UDP translation states and assign temporary external port numbers
*     S relays these port numbers back to A and B
*     A and B contact each others' NAT devices directly on the translated ports; the NAT devices use the previously created translation states and send the packets to A and B


STUN
----
Simple Traversal of User Datagram Protocol through Network Address Translators (NATs) (abbreviated STUN), is a standards-based IP protocol used as one of the methods of NAT traversal in applications of real-time voice, video, messaging, and other interactive IP communications. The original specification in RFC 3489 has been obsoleted by newer methods published as RFC 5389 with the title Session Traversal Utilities for NAT.

The protocol allows applications operating through a NAT to discover the presence and specific type of NAT, and obtain the mapped (public) IP address (NAT address) and port number that the NAT has allocated for the application's User Datagram Protocol (UDP) connections to remote hosts. The protocol requires assistance from a 3rd-party network server (STUN server) located on the opposing public site of the NAT, usually the public Internet.

The client, operating inside the NAT masqueraded network, initiates a short sequence of requests to a STUN protocol server listening at two IP addresses in the network on the public side of the NAT, traversing the NAT. The server responds with the results, which are the mapped IP address and port on the 'outside' of the NAT for each request to its two listeners. From the results of several different types of requests, the client application can learn the operating method of the network address translator, including the live-time of the NAT's port bindings.

The standard STUN server listening port is 3478.

Once a client has discovered its external addresses, it can communicate with its peers. If the NAT is the full cone type then either side can initiate communication. If it is restricted cone or restricted port cone type both sides must start transmitting together.

NAT Usage
---------
NAT is the technique of rewriting addresses on a packet as it passes through a routing device.

DNAT translates the address on an inbound packet and creates an entry in the connection tracking state table.
NAT always transforms the layer 3 contents of a packet. Port redirection operates at layer 4.

*   server NAT IP, NAT IP
      *    The IP address to which packets are addressed. This is the address on the packet before the device performing NAT manipulates it. This is frequently also described as the public IP, although any given application of NAT knows no distinction between public and private address ranges. 
*   real IP, server IP, hidden IP, private IP, internal IP
      *    The IP address after the NAT device has performed its transformation. Frequently, this is described as the private IP, although any given application of NAT knows no distinction between public and private address ranges. 
*   client IP
      *    The source address of the initial packet. The client IP in a NAT transformation does not change; this IP is the source IP address on any inbound packets both before and after the translation. It is also the destination address on the outbound packet. 

Stateless NAT with iproute2
---------------------------

It involves rewriting addresses passing through a routing device: inbound packets will undergo destination address rewriting and outbound packets will undergo source address rewriting. Creating an iproute2 NAT mapping has the side effect of causing the kernel to answer ARP requests for the NAT IP. The nat entry in the local routing table causes the kernel to reply for ARP requests to the NAT IP.

NAT with iproute2 can be used in conjunction with the routing policy database (cf. RPDB) to support conditional NAT, e.g. only perform NAT if the source IP falls within a certain range.

::

        root@masq-gw]# tcpdump -qnn
        19:30:17.824853 eth1 < 64.70.12.210.35131 > 205.254.211.17.25: tcp 0 (DF)  1
        19:30:17.824976 eth0 > 64.70.12.210.35131 > 192.168.100.17.25: tcp 0 (DF)  2
        19:30:17.825400 eth0 < 192.168.100.17.25 > 64.70.12.210.35131: tcp 0 (DF)  3
        19:30:17.825568 eth1 > 205.254.211.17.25 > 64.70.12.210.35131: tcp 0 (DF)  4


#.    The first packet comes in on eth1, masq-gw's outside interface. The packet is addressed to the NAT IP, 205.254.211.17 on tcp/25. This is the IP/port pair on which which our service runs. This is a snapshot of the packet before it has been handled by the NAT code.
#.    The next line is the "same" packet leaving eth0, masq-gw's inside interface, bound for the internal network. The NAT code has substituted the real IP of the server, 192.168.100.17. This rewriting is handled by the nat entry in the local routing table (ip route).
#.    The SMTP server then sends a return packet which arrives on eth0. This is the packet before the NAT code on masq-gw has rewritten the outbound packet. This rewriting is handled by the RPDB entry (ip rule).
#.    Finally, the return packet is transmitted on eth1 after having been rewritten. The source IP address on the packet is now the public IP on which the service is published.


Enabling Stateless NAT
----------------------

::

        [root@masq-gw]# ip route add nat 205.254.211.17 via 192.168.100.17  1
        [root@masq-gw]# ip rule add nat 205.254.211.17 from 192.168.100.17  2
        [root@masq-gw]# ip route flush cache                                3
        [root@masq-gw]# ip route show table all | grep ^nat                 4
        nat 205.254.211.17 via 192.168.100.17  table local  scope host
        [root@masq-gw]# ip rule show                                        5
        0:      from all lookup local 
        32765:  from 192.168.100.17 lookup main map-to 205.254.211.17 
        32766:  from all lookup main 
        32767:  from all lookup 253


#.    This command tells the kernel to perform network address translation on any packet bound for 205.254.211.17. The parameter via tells the NAT code to rewrite the packet bound for 205.254.211.17 with the new destination address 192.168.100.17. Note, that this only handles inbound packets; that is, packets whose destination address contains 205.254.211.17.
#.    This command enters the corresponding rule for the outbound traffic into the RPDB (kernel 2.2 and up). This rule will cause the kernel rewrite any packet from 192.168.100.17 with the specified source address (205.254.211.17). Any packet originating from 192.168.100.17 which passes through this router will trigger this rule. In short, this command rewrites the source address of outbound packets so that they appear to originate from the NAT IP.
#.    The kernel maintains a routing cache to handle routing decisions more quickly. After making changes to the routing tables on a system, it is good practice to empty the routing cache with ip route flush cache. Once the cache is empty, the kernel is guaranteed to consult the routing tables again instead of the routing cache.
#.    These two commands allow the user to inspect the routing policy database and the local routing table to determine if the NAT routes and rules were added correctly.

NAT using Netfilter for a single host (iptables)
------------------------------------------------

::

        [root@real-server]# iptables -t nat -A PREROUTING -d 205.254.211.17 -j DNAT {{{--to-destination }}} 192.168.100.17
        [root@real-server]# iptables -t nat -A POSTROUTING -s 192.168.100.17 -j SNAT {{{--to-destination }}}205.254.211.17


Differences Between SNAT and Masquerading
-----------------------------------------

Though SNAT and masquerading perform the same fundamental function, mapping one address space into another one, the details differ slighly. Most noticeably, masquerading chooses the source IP address for the outbound packet from the IP bound to the interface through which the packet will exit.


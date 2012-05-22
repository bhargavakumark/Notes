Linux : ip
==========

.. contents::

.. highlight:: bash   

ip addr
-------

.. contents::

================================================
show : Displaying IP information with ip address
================================================

::

        [root@tristan]# ip address show
        1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue 
            link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
            inet 127.0.0.1/8 brd 127.255.255.255 scope host lo
        2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
            inet 192.168.99.35/24 brd 192.168.99.255 scope global eth0
        [root@tristan]# ip address show dev eth0
            2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
            inet 192.168.99.35/24 brd 192.168.99.255 scope global eth0
        [root@wan-gw]# ip address show wan0
            8: wan0: <POINTOPOINT,NOARP,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ppp 01:f4 peer 00:00
            inet 205.254.209.73 peer 205.254.209.74/32 scope global wan0
        [root@real-example]# ip address show ppp0
            5: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP> mtu 1492 qdisc htb qlen 3
            link/ppp 
            inet 67.38.163.197 peer 67.38.163.254/32 scope global ppp0

=================================
scope : IP Scope under ip address
=================================

+---------+----------------------------------------+
| Scope   | Description                            |
+=========+========================================+
| global  | valid everywhere                       |
+---------+----------------------------------------+
| site    | valid only within this site (IPv6)     |
+---------+----------------------------------------+
| link    | valid only on this device              |
+---------+----------------------------------------+
| host    | valid only inside this host (machine)  |
+---------+----------------------------------------+

=========================================================
add : Adding IP addresses to an interface with ip address
=========================================================

::

        [root@tristan]# ip address add 192.168.99.37/24 brd + dev eth0
        [root@tristan]# ip address show dev eth0
        2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
            inet 192.168.99.35/24 brd 192.168.99.255 scope global eth0
            inet 192.168.99.37/24 brd 192.168.99.255 scope global secondary eth0

There are a few items of note. You can use ip address add even if the link layer on the device is down. This means that you can readdress an interface without bringing it up. When you add an address within the same CIDR network as another address on the same interface, the second address becomes a secondary address, meaning that if the first address is removed, the second address will also be purged from the interface.

In order to support compatibility with ifconfig the ip address command allows the user to specify a label on every hosted address on a given device. After adding an address to an interface as we did in Example C.7, “Adding IP addresses to an interface with ip address”, ifconfig will not report that the new IP 192.168.99.37 is hosted on the same device as the primary IP 192.168.99.35. In order to prevent this sort of confusion or apparently contradictory output, you should get in the habit of using the label option to identify each IP hosted on a device. Let's take a look at how to remove the 192.168.99.37 IP from eth0 and add it back so that ifconfig will report the presence of another IP on the eth0 device.

==============================================================
remove : Removing IP addresses from interfaces with ip address
==============================================================

::

        [root@tristan]# ip address del 192.168.99.37/24 brd + dev eth0
        [root@tristan]# ip address add 192.168.99.37/24 brd + dev eth0 label eth0:0
        [root@tristan]# ip address show dev eth0
        2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
            inet 192.168.99.35/24 brd 192.168.99.255 scope global eth0
            inet 192.168.99.37/24 brd 192.168.99.255 scope global secondary eth0:0
        [root@tristan]# ifconfig
        eth0      Link encap:Ethernet  HWaddr 00:80:C8:F8:4A:51
                  inet addr:192.168.99.35  Bcast:192.168.99.255  Mask:255.255.255.0
                  UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
                  RX packets:190312 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:86955 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:100 
                  RX bytes:30701229 (29.2 Mb)  TX bytes:7878951 (7.5 Mb)
                  Interrupt:9 Base address:0x5000 

        eth0:0    Link encap:Ethernet  HWaddr 00:80:C8:F8:4A:51  
                  inet addr:10.10.20.10  Bcast:10.10.20.255  Mask:255.255.255.0
                  UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
                  Interrupt:9 Base address:0x1000

        lo        Link encap:Local Loopback  
                  inet addr:127.0.0.1  Mask:255.0.0.0
                  UP LOOPBACK RUNNING  MTU:16436  Metric:1
                  RX packets:306 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:306 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:0 
                  RX bytes:29504 (28.8 Kb)  TX bytes:29504 (28.8 Kb)

==============================================================
flush : Removing all IPs on an interface with ip address flush
==============================================================

::

        [root@tristan]# ip address show dev eth0
        2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
            inet 192.168.99.35/24 brd 192.168.99.255 scope global eth0
            inet 192.168.99.37/24 brd 192.168.99.255 scope global secondary eth0:0
        [root@tristan]# ip address flush
        Flush requires arguments.
        [root@tristan]# ip address flush dev eth0
        [root@tristan]# ip address show dev eth0
        2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
                          
ip addr v6
----------

==========
References
==========
http://tldp.org/HOWTO/Linux+IPv6-HOWTO/chapter-configuration-address.html

=================
Show IPv6 address
=================

::

        # ip -6 addr show dev <interface>
        2: eth0: <BROADCAST,MULTICAST,UP&gt; mtu 1500 qdisc pfifo_ fast qlen 100
        inet6 fe80::210:a4ff:fee3:9566/10 scope link
        inet6 2001:0db8:0:f101::1/64 scope global
        inet6 fec0:0:0:f101::1/64 scope site 

======================
Adding an IPv6 address
======================

::

        # ip -6 addr add <ipv6address>/<prefixlength> dev <interface> 

        # ip -6 addr add 2001:0db8:0:f101::1/64 dev eth0 

========================
Deleting an IPv6 address
========================

::

        # /sbin/ip -6 addr del <ipv6address>/<prefixlength> dev <interface> 

        # /sbin/ip -6 addr del 2001:0db8:0:f101::1/64 dev eth0 

ip link
-------

::

        # Using ip link show
        [root@tristan]# ip link show
        1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue 
            link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff

Line one summarizes the current name of the device, the flags set on the device, the maximum transmission unit (MTU) the active queueing mechanism (if any), and the queue size if there is a queue present. The second line will always indicate the type of link layer in use on the device, and link layer specific information.

::
    
        # Using ip link set to change device flags                
        [root@tristan]# ip link set dev eth0 promisc on
        [root@tristan]# ip link show dev eth0
        2: eth0: <BROADCAST,MULTICAST,PROMISC,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
            [root@tristan]# ip link set dev eth0 multicast off promisc off
            [root@tristan]# ip link show dev eth0
        2: eth0: <BROADCAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
        [root@tristan]# ip link set arp off
        Not enough of information: "dev" argument is required.
        [root@tristan]# ip link set arp off dev eth0
        [root@tristan]# ip link show dev eth0
        2: eth0: <BROADCAST,NOARP,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
            [root@enclitic root]# ip link set dev eth0 arp on 
            [root@tristan root]# ip link show dev eth0
        2: eth0: <BROADCAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff


        # Deactivating a link layer device with ip link set
        [root@tristan]# ip link show dev eth0
        2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
            [root@tristan]# ip route show
            192.168.99.0/24 dev eth0  proto kernel  scope link  src 192.168.99.35
            127.0.0.0/8 dev lo  scope link 
            default via 192.168.99.254 dev eth0
        [root@tristan]# ip link set dev eth0 down
        [root@tristan]# ip address show dev eth0
        2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
            inet 192.168.99.35/24 brd 192.168.99.255 scope global eth0
        [root@tristan]# ip route show
        127.0.0.0/8 dev lo  scope link


        # Activating a link layer device with ip link set
        [root@tristan]# ip link show dev eth0
        2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
            [root@tristan]# arping -D -I eth0 192.168.99.35
            Interface "eth0" is down
        [root@tristan]# ip link set dev eth0 up
        [root@tristan]# ip address show dev eth0
        2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
            inet 192.168.99.35/24 brd 192.168.99.255 scope global eth0
            [root@tristan]# ip route show
            192.168.99.0/24 dev eth0  proto kernel  scope link  src 192.168.99.35
            127.0.0.0/8 dev lo  scope link


        # Using ip link set to change device flags
        [root@tristan]# ip link show dev eth0
        2: eth0: <BROADCAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
        [root@tristan]# # ip link set dev eth0 mtu 1412
        [root@tristan]# ip link show dev eth0
        2: eth0: <BROADCAST,UP> mtu 1412 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff


        # Changing the device name with ip link set
        [root@tristan]# ip link set dev eth0 mtu 1500
        [root@tristan]# ip link set dev eth0 name inside
        [root@tristan]# ip link show dev inside
        2: inside: <BROADCAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff


        # Changing broadcast and hardware addresses with ip link set
        [root@tristan]# ip link set dev inside name eth0
        [root@tristan]# ip link set dev eth0 address 00:80:c8:f8:be:ef
        [root@tristan]# ip link show dev eth0
        2: eth0: <BROADCAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:be:ef brd ff:ff:ff:ff:ff:ff
        [root@tristan]# ip link set dev eth0 broadcast ff:ff:88:ff:ff:88
        [root@tristan]# ip link show dev eth0
        2: eth0: <BROADCAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:be:ef brd ff:ff:88:ff:ff:88
            [root@tristan]# ping -c 1 -n 192.168.99.254 >/dev/null 2>&1 &
            [root@tristan]# tcpdump -nnqtei eth0
            tcpdump: listening on eth0
            0:80:c8:f8:be:ef ff:ff:88:ff:ff:88 42: arp who-has 192.168.99.254 tell 192.168.99.35
            0:80:c8:f8:be:ef ff:ff:88:ff:ff:88 42: arp who-has 192.168.99.254 tell 192.168.99.35

ip neigh
--------

.. contents::

============================
ARP tables using ip neighbor
============================

::

        #  Displaying the ARP cache with ip neighbor show
        [root@tristan]# ip neighbor show
        192.168.99.254 dev eth0 lladdr 00:80:c8:f8:5c:73 nud reachable


        # Displaying the ARP cache on an interface with ip neighbor show
        [root@wan-gw]# ip neighbor show dev eth0
        205.254.211.39 lladdr 00:02:b3:a1:b8:df nud delay
        205.254.211.54 lladdr 00:d0:b7:80:ce:ce nud delay
        205.254.211.179 lladdr 00:80:c8:f8:5c:72 nud reachable


        # Displaying the ARP cache for a particular network with ip neighbor show
        [root@masq-gw]# ip neighbor show 192.168.100.0/24
        192.168.100.1 dev eth3 lladdr 00:c0:7b:7d:00:c8 nud stale
        192.168.100.17 dev eth0 lladdr 00:80:c8:e8:4b:8e nud reachable


        # Entering a permanent entry into the ARP cache with ip neighbor add
        [root@masq-gw]# ip neighbor add 192.168.100.1 lladdr 00:c0:7b:7d:00:c8 dev eth3 nud permanent


        # Entering a proxy ARP entry with ip neighbor add proxy
        # -- this is deprecated; use arp or kernel proxy_arp instead --#
        [root@masq-gw]# ip neighbor add proxy 192.168.100.1 dev eth0
        # -- this is deprecated; use arp or kernel proxy_arp instead --#


        # Altering an entry in the ARP cache with ip neighbor change
        [root@tristan]# ip neighbor add 192.168.99.254 lladdr 00:80:c8:27:69:2d dev eth3
        RTNETLINK answers: File exists
        [root@tristan]# ip neighbor show 192.168.99.254
        192.168.99.254 dev eth0 lladdr 00:80:c8:f8:5c:73 nud reachable
        [root@tristan]# ip neighbor change 192.168.99.254 lladdr 00:80:c8:27:69:2d dev eth3
        [root@tristan]# ip neighbor show 192.168.99.254
        192.168.99.254 dev eth0 lladdr 00:80:c8:27:69:2d nud permanent


        # Removing an entry from the ARP cache with ip neighbor del
        [root@masq-gw]# ip neighbor del 192.168.100.1 dev eth3
        [root@masq-gw]# ip neighbor show dev eth3
        192.168.100.1  nud failed


        # Removing learned entries from the ARP cache with ip neighbor flush
        [root@tristan]# ip neighbor flush dev eth3

ip route
--------

======================================================
route show : Viewing a simple routing table with route
======================================================

::

        [root@tristan]# route -n
        Kernel IP routing table
        Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
        192.168.99.0    0.0.0.0         255.255.255.0   U     0      0        0 eth0
        127.0.0.0       0.0.0.0         255.0.0.0       U     0      0        0 lo
        0.0.0.0         192.168.99.254  0.0.0.0         UG    0      0        0 eth0
        [root@tristan]# ip route show
        192.168.99.0/24 dev eth0  scope link 
        127.0.0.0/8 dev lo  scope link 
        default via 192.168.99.254 dev eth0

=======================================================
route show cache : Viewing the routing cache with route
=======================================================

::

        [root@tristan]# route -Cen
        Kernel IP routing cache
        Source          Destination     Gateway         Flags   MSS Window  irtt Iface
        194.52.197.133  192.168.99.35   192.168.99.35     l      40 0          0 lo
        192.168.99.35   194.52.197.133  192.168.99.254         1500 0         29 eth0
        192.168.99.35   192.168.99.254  192.168.99.254         1500 0          0 eth0
        192.168.99.254  192.168.99.35   192.168.99.35     il     40 0          0 lo
        192.168.99.35   192.168.99.35   192.168.99.35     l   16436 0          0 lo
        192.168.99.35   194.52.197.133  192.168.99.254         1500 0          0 eth0
        192.168.99.35   192.168.99.254  192.168.99.254         1500 0          0 eth0
          
===========================================================================
show local : Viewing the local routing table with ip route show table local
===========================================================================

::

        [root@tristan]# ip route show table local
        local 192.168.99.35 dev eth0  proto kernel  scope host  src 192.168.99.35 
        broadcast 127.255.255.255 dev lo  proto kernel  scope link  src 127.0.0.1 
        broadcast 192.168.99.255 dev eth0  proto kernel  scope link  src 192.168.99.35 
        broadcast 127.0.0.0 dev lo  proto kernel  scope link  src 127.0.0.1 
        local 127.0.0.1 dev lo  proto kernel  scope host  src 127.0.0.1 
        local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1


The first field in this output tells us whether the route is for a broadcast address or an IP address or range locally hosted on this machine. Subsequent fields inform us through which device the destination is reachable, and notably (in this table) that the kernel has added these routes as part of bringing up the IP layer interfaces.

For each IP hosted on the machine, it makes sense that the machine should restrict accessiblity to that IP or IP range to itself only. This explains why, in Example D.12, Viewing the local routing table with ip route show table local, 192.168.99.35 has a host scope. Because tristan hosts this IP, there's no reason for the packet to be routed off the box. Similarly, a destination of localhost (127.0.0.1) does not need to be forwarded off this machine. In each of these cases, the scope has been set to host.

For broadcast addresses, which are intended for any listeners who happen to share the IP network, the destination only makes sense as for a scope of devices connected to the same link layer [49].

=============================================================
show table : Viewing a routing table with ip route show table
=============================================================

::

        [root@tristan]# ip route show table special
        Error: argument "special" is wrong: table id value is invalid

        [root@tristan]# echo 7 special >> /etc/iproute2/rt_tables
        [root@tristan]# ip route show table special
        [root@tristan]# ip route add table special default via 192.168.99.254
        [root@tristan]# ip route show table special
        default via 192.168.99.254 dev eth0
 
==================================================================
show cache : Displaying the routing cache with ip route show cache
==================================================================

::

        [root@tristan]# ip route show cache 192.168.100.17
        192.168.100.17 from 192.168.99.35 via 192.168.99.254 dev eth0 
            cache  mtu 1500 rtt 18ms rttvar 15ms cwnd 15 advmss 1460
        192.168.100.17 via 192.168.99.254 dev eth0  src 192.168.99.35 
            cache  mtu 1500 advmss 1460

=====================================================================================
show stats : Displaying statistics from the routing cache with ip -s route show cache
=====================================================================================

::

        [root@tristan]# ip -s route show cache 192.168.100.17
        192.168.100.17 from 192.168.99.35 via 192.168.99.254 dev eth0 
            cache  users 1 used 326 age 12sec mtu 1500 rtt 72ms rttvar 22ms cwnd 2 advmss 1460
        192.168.100.17 via 192.168.99.254 dev eth0  src 192.168.99.35 
            cache  users 1 used 326 age 12sec mtu 1500 advmss 1460

With this output, you'll get just a bit more information about the routes. The most interesting datum is usually the "used" field, which indicates the number of times this route has been accessed in the routing cache. This can give you a very good idea of how many times a particular route has been used. The age field is used by the kernel to decide when to expire a cache entry. The age is reset every time the route is accessed

==============================================================
add static : Adding a static route to a network with route add
==============================================================

::

        [root@masq-gw]# ip route add 10.38.0.0/16 via 192.168.100.1

=====================================================
add prohibit : Adding a prohibit route with route add
=====================================================

::

        [root@masq-gw]# ip route add prohibit 209.10.26.51
        [root@tristan]# ssh 209.10.26.51
        ssh: connect to address 209.10.26.51 port 22: No route to host
        [root@masq-gw]# tcpdump -nnq -i eth2
        tcpdump: listening on eth2
        22:13:13.740406 192.168.99.35.51973 > 209.10.26.51.22: tcp 0 (DF)
        22:13:13.740714 192.168.99.254 > 192.168.99.35: icmp: host 209.10.26.51 unreachable - admin prohibited filter [tos 0xc0]

==================================================================
add prohibit from : Using from in a routing command with route add
==================================================================
::

        [root@masq-gw]# ip route add prohibit 209.10.26.51 from 192.168.99.3

=================================================================
add default : Setting the default route with ip route add default
=================================================================

::

        [root@tristan]# ip route add default via 192.168.99.254

=======================================================
add src : Using src in a routing command with route add
=======================================================

::

        [root@masq-gw]# ip route add default via 205.254.211.254 src 205.254.211.198 table 7

====================================================================
add nat : Creating a NAT route for a single IP with ip route add nat
====================================================================

::

        [root@masq-gw]# ip route add nat 205.254.211.17 via 192.168.100.17
        [root@masq-gw]# ip route show table local | grep ^nat
        nat 205.254.211.17 via 192.168.100.17  scope host

        # Creating a NAT route for an entire network with ip route add nat

        [root@masq-gw]# ip route add nat 205.254.211.32/29 via 192.168.100.32
        [root@masq-gw]# ip route show table local | grep ^nat
        nat 205.254.211.32/29 via 192.168.100.32  scope host
          

=======================================
del : Removing routes with ip route del
=======================================

::

        [root@masq-gw]# ip route show
        192.168.100.0/30 dev eth3  scope link
        205.254.211.0/24 dev eth1  scope link
        192.168.100.0/24 dev eth0  scope link
        192.168.99.0/24 dev eth0  scope link
        192.168.98.0/24 via 192.168.99.1 dev eth0
        10.38.0.0/16 via 192.168.100.1 dev eth3
        127.0.0.0/8 dev lo  scope link 
        default via 205.254.211.254 dev eth1
        [root@masq-gw]# ip route del 10.38.0.0/16 via 192.168.100.1 dev eth3
          

======================================================
change : Altering existing routes with ip route change
======================================================

::

        [root@tristan]# ip route change default via 192.168.99.113 dev eth0
        [root@tristan]# ip route show
        192.168.99.0/24 dev eth0  scope link 
        127.0.0.0/8 dev lo  scope link 
        default via 192.168.99.113 dev eth0


==============================================
get : Testing routing tables with ip route get
==============================================

ip route get simulates a request for the specified destination, ip route get causes the routing selection algorithm to be run. When this is complete, it prints out the resulting path to the destination. In one sense, this is almost equivalent to sending an ICMP echo request packet and then using ip route show cache.

::

        # Testing routing tables with ip route get

        [root@tristan]# ip -s route get 127.0.0.1/32
        ip -s route get 127.0.0.1/32
        local 127.0.0.1 dev lo  src 127.0.0.1 
            cache <local>  users 1 used 1 mtu 16436 advmss 16396
        [root@tristan]# ip -s route get 127.0.0.1/32
        local 127.0.0.1 dev lo  src 127.0.0.1 
            cache <local>  users 1 used 2 mtu 16436 advmss 16396


==================================================================================
flush : Removing a specific route and emptying a routing table with ip route flush
==================================================================================

The flush option, when used with ip route empties a routing table or removes the route for a particular destination

::

        [root@masq-gw]# ip route flush
        "ip route flush" requires arguments
        [root@masq-gw]# ip route flush 10.38
        Nothing to flush.
        [root@masq-gw]# ip route flush 10.38.0.0/16
        [root@masq-gw]# ip route show
        192.168.100.0/30 dev eth3  scope link
        205.254.211.0/24 dev eth1  scope link
        192.168.100.0/24 dev eth0  scope link
        192.168.99.0/24 dev eth0  scope link
        192.168.98.0/24 via 192.168.99.1 dev eth0
        127.0.0.0/8 dev lo  scope link 
        default via 205.254.211.254 dev eth1
        [root@masq-gw]# ip route flush table main
        [root@masq-gw]# ip route show
        [root@masq-gw]# 
 
==================================================================
flush cache : Emptying the routing cache with ip route flush cache
==================================================================

::

        [root@tristan]# ip route show cache
        local 127.0.0.1 from 127.0.0.1 tos 0x10 dev lo 
            cache <local>  mtu 16436 advmss 16396
        local 127.0.0.1 from 127.0.0.1 dev lo 
            cache <local>  mtu 16436 advmss 16396
        192.168.100.17 from 192.168.99.35 via 192.168.99.254 dev eth0 
            cache  mtu 1500 rtt 18ms rttvar 15ms cwnd 15 advmss 1460
        192.168.100.17 via 192.168.99.254 dev eth0  src 192.168.99.35 
            cache  mtu 1500 advmss 1460
        [root@tristan]# ip route flush cache
        [root@tristan]# ip route show cache
        [root@tristan]# ip route show cache
        local 127.0.0.1 from 127.0.0.1 tos 0x10 dev lo 
            cache <local>  mtu 16436 advmss 16396
        local 127.0.0.1 from 127.0.0.1 dev lo 
            cache <local>  mtu 16436 advmss 16396


ip rule
-------

============================================
show : Displaying the RPDB with ip rule show
============================================

::

        [root@isolde]# ip rule show
        0:      from all lookup local 
        32766:  from all lookup main 
        32767:  from all lookup 253

==========================================================
add : Creating a simple entry in the RPDB with ip rule add
==========================================================

::

        [root@masq-gw]# ip route add default via 205.254.211.254 table 8
        [root@masq-gw]# ip rule add tos 0x08 table 8
        [root@masq-gw]# ip route flush cache
        [root@masq-gw]# ip rule show
        0:      from all lookup local 
        32765:  from all tos 0x08 lookup 8 
        32766:  from all lookup main 
        32767:  from all lookup 253


================================================================
add from : Creating a complex entry in the RPDB with ip rule add
================================================================

::

        [root@masq-gw]# ip rule add from 192.168.100.17 tos 0x08 fwmark 4 table 7
          
==================================================
add nat : Creating a NAT rule with ip rule add nat
==================================================

::

        [root@masq-gw]# ip rule add nat 205.254.211.17 from 192.168.100.17
        [root@masq-gw]# ip rule show
        0:      from all lookup local 
        32765:  from 192.168.100.17 lookup main map-to 205.254.211.17
        32766:  from all lookup main 
        32767:  from all lookup 253

===============================================================================
add nat subnet : Creating a NAT rule for an entire network with ip rule add nat
===============================================================================

::

        [root@masq-gw]# ip rule add nat 205.254.211.32 from 192.168.100.32/29
        [root@masq-gw]# ip rule show
        0:      from all lookup local 
        32765:  from 192.168.100.32/29 lookup main map-to 205.254.211.32
        32766:  from all lookup main 
        32767:  from all lookup 253
          
========================================================================
del nat : Removing a NAT rule for an entire network with ip rule del nat
========================================================================

::

        [root@masq-gw]# ip rule del nat 205.254.211.32 from 192.168.100.32/29
        [root@masq-gw]# ip rule show
        0:      from all lookup local 
        32766:  from all lookup main 
        32767:  from all lookup 253


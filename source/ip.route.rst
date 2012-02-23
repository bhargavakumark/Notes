ip route
========

.. contents::

route show : Viewing a simple routing table with route
------------------------------------------------------

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

route show cache : Viewing the routing cache with route
-------------------------------------------------------

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
          

show local : Viewing the local routing table with ip route show table local
---------------------------------------------------------------------------

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

show table : Viewing a routing table with ip route show table
-------------------------------------------------------------

::

        [root@tristan]# ip route show table special
        Error: argument "special" is wrong: table id value is invalid

        [root@tristan]# echo 7 special >> /etc/iproute2/rt_tables
        [root@tristan]# ip route show table special
        [root@tristan]# ip route add table special default via 192.168.99.254
        [root@tristan]# ip route show table special
        default via 192.168.99.254 dev eth0
 

show cache : Displaying the routing cache with ip route show cache
------------------------------------------------------------------

::

        [root@tristan]# ip route show cache 192.168.100.17
        192.168.100.17 from 192.168.99.35 via 192.168.99.254 dev eth0 
            cache  mtu 1500 rtt 18ms rttvar 15ms cwnd 15 advmss 1460
        192.168.100.17 via 192.168.99.254 dev eth0  src 192.168.99.35 
            cache  mtu 1500 advmss 1460

show stats : Displaying statistics from the routing cache with ip -s route show cache
-------------------------------------------------------------------------------------

::

        [root@tristan]# ip -s route show cache 192.168.100.17
        192.168.100.17 from 192.168.99.35 via 192.168.99.254 dev eth0 
            cache  users 1 used 326 age 12sec mtu 1500 rtt 72ms rttvar 22ms cwnd 2 advmss 1460
        192.168.100.17 via 192.168.99.254 dev eth0  src 192.168.99.35 
            cache  users 1 used 326 age 12sec mtu 1500 advmss 1460

With this output, you'll get just a bit more information about the routes. The most interesting datum is usually the "used" field, which indicates the number of times this route has been accessed in the routing cache. This can give you a very good idea of how many times a particular route has been used. The age field is used by the kernel to decide when to expire a cache entry. The age is reset every time the route is accessed

add static : Adding a static route to a network with route add
--------------------------------------------------------------

::

        [root@masq-gw]# ip route add 10.38.0.0/16 via 192.168.100.1


add prohibit : Adding a prohibit route with route add
-----------------------------------------------------

::

        [root@masq-gw]# ip route add prohibit 209.10.26.51
        [root@tristan]# ssh 209.10.26.51
        ssh: connect to address 209.10.26.51 port 22: No route to host
        [root@masq-gw]# tcpdump -nnq -i eth2
        tcpdump: listening on eth2
        22:13:13.740406 192.168.99.35.51973 > 209.10.26.51.22: tcp 0 (DF)
        22:13:13.740714 192.168.99.254 > 192.168.99.35: icmp: host 209.10.26.51 unreachable - admin prohibited filter [tos 0xc0]


add prohibit from : Using from in a routing command with route add
------------------------------------------------------------------
::

        [root@masq-gw]# ip route add prohibit 209.10.26.51 from 192.168.99.3

add default : Setting the default route with ip route add default
-----------------------------------------------------------------

::

        [root@tristan]# ip route add default via 192.168.99.254


add src : Using src in a routing command with route add
-------------------------------------------------------

::

        [root@masq-gw]# ip route add default via 205.254.211.254 src 205.254.211.198 table 7


add nat : Creating a NAT route for a single IP with ip route add nat
--------------------------------------------------------------------

::

        [root@masq-gw]# ip route add nat 205.254.211.17 via 192.168.100.17
        [root@masq-gw]# ip route show table local | grep ^nat
        nat 205.254.211.17 via 192.168.100.17  scope host

        # Creating a NAT route for an entire network with ip route add nat

        [root@masq-gw]# ip route add nat 205.254.211.32/29 via 192.168.100.32
        [root@masq-gw]# ip route show table local | grep ^nat
        nat 205.254.211.32/29 via 192.168.100.32  scope host
          

del : Removing routes with ip route del
---------------------------------------

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
          


change : Altering existing routes with ip route change
------------------------------------------------------

::

        [root@tristan]# ip route change default via 192.168.99.113 dev eth0
        [root@tristan]# ip route show
        192.168.99.0/24 dev eth0  scope link 
        127.0.0.0/8 dev lo  scope link 
        default via 192.168.99.113 dev eth0


get : Testing routing tables with ip route get
----------------------------------------------

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



flush : Removing a specific route and emptying a routing table with ip route flush
----------------------------------------------------------------------------------

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
 

flush cache : Emptying the routing cache with ip route flush cache
------------------------------------------------------------------

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



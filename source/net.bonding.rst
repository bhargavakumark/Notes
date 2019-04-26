Networking : Bonding (Link Aggregation)
=======================================

.. contents::

Link Aggregation or Bonding
---------------------------
Bonding for link aggregation must be supported by both endpoints. Two linux machines connected via crossover cables can take advantage of link aggregation. A single machine connected with two physical cables to a switch which supports port trunking can use link aggregation to the switch. Any conventional switch will become ineffably confused by a hardware address appearing on multiple ports simultaneously.

Load balancing mode
-------------------

::

        [root@real-server root]# modprobe  bonding
        [root@real-server root]# ip addr add 192.168.100.33/24 brd + dev bond0
        [root@real-server root]# ip link set dev bond0 up
        [root@real-server root]# ifenslave  bond0 eth2 eth3
        master has no hw address assigned; getting one from slave!
        The interface eth2 is up, shutting it down it to enslave it.
        The interface eth3 is up, shutting it down it to enslave it.
        [root@real-server root]# ifenslave  bond0 eth2 eth3
        [root@real-server root]# cat /proc/net/bond0/info
        Bonding Mode: load balancing (round-robin)
        MII Status: up
        MII Polling Interval (ms): 0
        Up Delay (ms): 0
        Down Delay (ms): 0

        Slave Interface: eth2
        MII Status: up
        Link Failure Count: 0

        Slave Interface: eth3
        MII Status: up
        Link Failure Count: 0

High Availability mode
----------------------

::

        [root@real-server root]# modprobe bonding mode=1 miimon=100 downdelay=200 updelay=200
        [root@real-server root]# ip link set dev bond0 addr 00:80:c8:e7:ab:5c
        [root@real-server root]# ip addr add 192.168.100.33/24 brd + dev bond0
        [root@real-server root]# ip link set dev bond0 up
        [root@real-server root]# ifenslave  bond0 eth2 eth3
        The interface eth2 is up, shutting it down it to enslave it.
        The interface eth3 is up, shutting it down it to enslave it.
        [root@real-server root]# ip link show eth2 ; ip link show eth3 ; ip link show bond0
        4: eth2: <BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 100
          link/ether 00:80:c8:e7:ab:5c brd ff:ff:ff:ff:ff:ff
        5: eth3: <BROADCAST,MULTICAST,NOARP,SLAVE,DEBUG,AUTOMEDIA,PORTSEL,NOTRAILERS,UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 100
          link/ether 00:80:c8:e7:ab:5c brd ff:ff:ff:ff:ff:ff
        58: bond0: <BROADCAST,MULTICAST,MASTER,UP> mtu 1500 qdisc noqueue
          link/ether 00:80:c8:e7:ab:5c brd ff:ff:ff:ff:ff:ff


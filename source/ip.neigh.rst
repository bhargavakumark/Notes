ip neigh
========

.. contents::

ARP tables using ip neighbor
----------------------------

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



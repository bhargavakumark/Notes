ip link
=======

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



Linux : ping
============

.. contents::

number of packets to send
-------------------------
::

        [root@morgan]# ping -c 10 -n 192.168.100.17


stress a network
----------------
::

        [root@morgan]# ping -c 400 -f -n 192.168.99.254
        PING 192.168.99.254 (192.168.99.254) from 192.168.98.82 : 56(84) bytes of data.
        ............
        --- 192.168.99.254 ping statistics ---
        411 packets transmitted, 400 packets received, 2% packet loss
        round-trip min/avg/max/mdev = 37.840/62.234/97.807/12.946 ms
 

stress a network with large packets
-----------------------------------
::

        [root@morgan]# ping -s 512 -c 400 -f -n 192.168.99.254
        PING 192.168.99.254 (192.168.99.254) from 192.168.98.82 : 512(540) bytes of data.
        ............................................................................
        ................................................................
        --- 192.168.99.254 ping statistics ---
        551 packets transmitted, 400 packets received, 27% packet loss
        round-trip min/avg/max/mdev = 47.854/295.711/649.595/153.345 ms

Recording a network route
-------------------------
::

        [root@morgan]# ping -c 2 -n -R 192.168.99.35
        PING 192.168.99.35 (192.168.99.35) from 192.168.98.82 : 56(124) bytes of data.
        64 bytes from 192.168.99.35: icmp_seq=0 ttl=253 time=56.311 msec
        RR:     192.168.98.82
                192.168.98.254
                192.168.99.1
                192.168.99.35
                192.168.99.35
                192.168.99.1
                192.168.98.254
                192.168.98.82

        64 bytes from 192.168.99.35: icmp_seq=1 ttl=253 time=47.893 msec  (same route)

        --- 192.168.99.35 ping statistics ---
        2 packets transmitted, 2 packets received, 0% packet loss
        round-trip min/avg/max/mdev = 47.893/52.102/56.311/4.209 ms

Setting the TTL
---------------
::

        [root@morgan]# ping -c 1 -n -t 4 192.168.99.35
        tcpdump: listening on eth0
        02:02:04.679152 192.168.98.82 > 192.168.99.35: icmp: echo request (DF)
        02:02:04.711474 192.168.99.35 > 192.168.98.82: icmp: echo reply
        [root@morgan]# ping -c 1 -n -t 3 192.168.99.35
        tcpdump: listening on eth0
        02:01:50.810567 192.168.98.82 > 192.168.99.35: icmp: echo request (DF)
        02:01:50.841917 192.168.99.1 > 192.168.98.82: icmp: time exceeded in-transit
          

Setting ToS
-----------
::

        [root@wan-gw]# ping -c 2 -Q 8 -n 195.73.22.45
        PING 195.73.22.45 (195.73.22.45) from 205.254.209.73 : 56(84) bytes of data.
        64 bytes from 195.73.22.45: icmp_seq=0 ttl=252 time=51.633 msec
        64 bytes from 195.73.22.45: icmp_seq=1 ttl=252 time=36.323 msec

        --- 195.73.22.45 ping statistics ---
        2 packets transmitted, 2 packets received, 0% packet loss
        round-trip min/avg/max/mdev = 36.323/43.978/51.633/7.655 ms
        [root@wan-gw]# tcpdump -nni wan0 icmp
        tcpdump: listening on wan0
        21:55:37.983149 10.10.14.2 > 10.10.22.254: icmp: echo request (DF) [tos 0x8] 
        21:55:38.034770 10.10.22.254 > 10.10.14.2: icmp: echo reply [tos 0x8] 
        21:55:38.982277 10.10.14.2 > 10.10.22.254: icmp: echo request (DF) [tos 0x8] 
        21:55:39.018588 10.10.22.254 > 10.10.14.2: icmp: echo reply [tos 0x8]
          

source address for ping
-----------------------
::

        [root@masq-gw]# ping -c 2 -n -I 192.168.99.254 192.168.70.254
        PING 192.168.70.254 (192.168.70.254) from 192.168.99.254 : 56(84) bytes of data.
        64 bytes from 192.168.70.254: icmp_seq=0 ttl=254 time=69.285 msec
        64 bytes from 192.168.70.254: icmp_seq=1 ttl=254 time=53.976 msec

        --- 192.168.70.254 ping statistics ---
        2 packets transmitted, 2 packets received, 0% packet loss
        round-trip min/avg/max/mdev = 53.976/61.630/69.285/7.658 ms
         

find the IPs of machines in a subnet
------------------------------------
::

        bhargava@bhargava:~$ ifconfig
        eth0      Link encap:Ethernet  HWaddr 00:13:72:20:00:ba
                  inet addr:10.216.50.132  Bcast:10.216.55.255  Mask:255.255.248.0
                  inet6 addr: fe80::213:72ff:fe20:ba/64 Scope:Link
                  UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
                  RX packets:787855 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:564986 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:1000
                  RX bytes:645937667 (616.0 MB)  TX bytes:95729588 (91.2 MB)
                  Interrupt:16
        bhargava@bhargava:~$ ping -b -I eth0 10.216.55.255
        WARNING: pinging broadcast address
        PING 10.216.55.255 (10.216.55.255) from 10.216.50.132 eth0: 56(84) bytes of data.
        64 bytes from 10.216.48.3: icmp_seq=1 ttl=255 time=3.31 ms
        64 bytes from 10.216.48.2: icmp_seq=1 ttl=255 time=3.33 ms (DUP!)
        64 bytes from 10.216.48.200: icmp_seq=1 ttl=64 time=22.6 ms (DUP!)
        64 bytes from 10.216.50.1: icmp_seq=1 ttl=64 time=25.5 ms (DUP!)
        64 bytes from 10.216.50.213: icmp_seq=1 ttl=64 time=27.3 ms (DUP!)
        64 bytes from 10.216.51.130: icmp_seq=1 ttl=64 time=29.1 ms (DUP!)
        64 bytes from 10.216.50.103: icmp_seq=1 ttl=64 time=29.8 ms (DUP!)
        64 bytes from 10.216.51.121: icmp_seq=1 ttl=64 time=31.6 ms (DUP!)
        64 bytes from 10.216.50.25: icmp_seq=1 ttl=64 time=33.2 ms (DUP!)
        64 bytes from 10.216.50.149: icmp_seq=1 ttl=64 time=34.3 ms (DUP!)
        64 bytes from 10.216.48.168: icmp_seq=1 ttl=64 time=34.8 ms (DUP!)
        64 bytes from 10.216.48.10: icmp_seq=1 ttl=255 time=59.0 ms (DUP!)

        --- 10.216.55.255 ping statistics ---
        1 packets transmitted, 1 received, +11 duplicates, 0% packet loss, time 0ms
        rtt min/avg/max/mdev = 3.317/27.866/59.061/13.996 ms
        bhargava@bhargava:$ 


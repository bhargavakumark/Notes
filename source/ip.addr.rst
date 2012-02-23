ip addr
=======

.. contents::

show : Displaying IP information with ip address
------------------------------------------------

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

scope : IP Scope under ip address
---------------------------------

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

add : Adding IP addresses to an interface with ip address
---------------------------------------------------------

::

        [root@tristan]# ip address add 192.168.99.37/24 brd + dev eth0
        [root@tristan]# ip address show dev eth0
        2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
            link/ether 00:80:c8:f8:4a:51 brd ff:ff:ff:ff:ff:ff
            inet 192.168.99.35/24 brd 192.168.99.255 scope global eth0
            inet 192.168.99.37/24 brd 192.168.99.255 scope global secondary eth0

There are a few items of note. You can use ip address add even if the link layer on the device is down. This means that you can readdress an interface without bringing it up. When you add an address within the same CIDR network as another address on the same interface, the second address becomes a secondary address, meaning that if the first address is removed, the second address will also be purged from the interface.

In order to support compatibility with ifconfig the ip address command allows the user to specify a label on every hosted address on a given device. After adding an address to an interface as we did in Example C.7, “Adding IP addresses to an interface with ip address”, ifconfig will not report that the new IP 192.168.99.37 is hosted on the same device as the primary IP 192.168.99.35. In order to prevent this sort of confusion or apparently contradictory output, you should get in the habit of using the label option to identify each IP hosted on a device. Let's take a look at how to remove the 192.168.99.37 IP from eth0 and add it back so that ifconfig will report the presence of another IP on the eth0 device.

remove : Removing IP addresses from interfaces with ip address
--------------------------------------------------------------

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

flush : Removing all IPs on an interface with ip address flush
--------------------------------------------------------------

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
                          


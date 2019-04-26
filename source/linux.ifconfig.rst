Linux : ifconfig
================

.. contents::

Interface Flags
---------------

+---------------+----------------------------------------------------+
| Flag          | Description                                        |
+===============+====================================================+
| UP            | device is functioning                              |
+---------------+----------------------------------------------------+
| BROADCAST     | device can send traffic to all hosts on the link   |
+---------------+----------------------------------------------------+
| RUNNING       | cable connection can be detected                   |
+---------------+----------------------------------------------------+
| MULTICAST     | device can perform and receive multicast packets   |
+---------------+----------------------------------------------------+
| ALLMULTI      | device receives all multicast packets on the link  |
+---------------+----------------------------------------------------+
| PROMISC       | device receives all traffic on the link            |
+---------------+----------------------------------------------------+

Bringing down an interface with ifconfig
----------------------------------------

::

        [root@tristan]# ifconfig eth0 down
        [root@tristan]# ifconfig
        lo        Link encap:Local Loopback  
                  inet addr:127.0.0.1  Mask:255.0.0.0
                  UP LOOPBACK RUNNING  MTU:16436  Metric:1
                  RX packets:306 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:306 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:0 
                  RX bytes:29504 (28.8 Kb)  TX bytes:29504 (28.8 Kb)

Bringing up an interface with ifconfig
--------------------------------------

::

        [root@tristan]# ifconfig eth0 192.168.99.35 netmask 255.255.255.0 up
        [root@tristan]# ifconfig
        eth0      Link encap:Ethernet  HWaddr 00:80:C8:F8:4A:51
                  inet addr:192.168.99.35  Bcast:192.168.99.255  Mask:255.255.255.0
                  UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
                  RX packets:190312 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:86955 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:100 
                  RX bytes:30701229 (29.2 Mb)  TX bytes:7878951 (7.5 Mb)
                  Interrupt:9 Base address:0x5000 

        lo        Link encap:Local Loopback  
                  inet addr:127.0.0.1  Mask:255.0.0.0
                  UP LOOPBACK RUNNING  MTU:16436  Metric:1
                  RX packets:306 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:306 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:0 
                  RX bytes:29504 (28.8 Kb)  TX bytes:29504 (28.8 Kb)

Changing MTU with ifconfig
--------------------------

::

        [root@tristan]# ifconfig eth0 mtu 1412
        [root@tristan]# ifconfig eth0
        eth0      Link encap:Ethernet  HWaddr 00:80:C8:F8:4A:51
                  inet addr:192.168.99.35  Bcast:192.168.99.255  Mask:255.255.255.0
                  UP BROADCAST RUNNING MULTICAST  MTU:1412  Metric:1
                  RX packets:190312 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:86955 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:100 
                  RX bytes:30701229 (29.2 Mb)  TX bytes:7878951 (7.5 Mb)
                  Interrupt:9 Base address:0x5000


Setting interface flags with ifconfig
-------------------------------------

::

        [root@tristan]# ifconfig eth0 promisc
        [root@tristan]# ifconfig eth0
        eth0      Link encap:Ethernet  HWaddr 00:80:C8:F8:4A:51
                  inet addr:192.168.99.35  Bcast:192.168.99.255  Mask:255.255.255.0
                  UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1412  Metric:1
                  RX packets:190312 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:86955 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:100 
                  RX bytes:30701229 (29.2 Mb)  TX bytes:7878951 (7.5 Mb)
                  Interrupt:9 Base address:0x5000
        [root@tristan]# ifconfig eth0 -promisc
        [root@tristan]# ifconfig eth0 -arp
        [root@tristan]# ifconfig eth0
        eth0      Link encap:Ethernet  HWaddr 00:80:C8:F8:4A:51
                  inet addr:192.168.99.35  Bcast:192.168.99.255  Mask:255.255.255.0
                  UP BROADCAST RUNNING NOARP MULTICAST  MTU:1412  Metric:1
                  RX packets:190312 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:86955 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:100 
                  RX bytes:30701229 (29.2 Mb)  TX bytes:7878951 (7.5 Mb)
                  Interrupt:9 Base address:0x5000



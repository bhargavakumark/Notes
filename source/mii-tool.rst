mii-tool
========

.. contents::

mii-tool
--------

Ethernet Port Speed Abbreviations

+--------------+--------------------------+
| Port Speed   | Description              |
+==============+==========================+
| 10baseT-HD   | 10 megabit half duplex   |
+--------------+--------------------------+
| 10baseT-FD   | 10 megabit full duplex   |
+--------------+--------------------------+
| 100baseTx-HD | 100 megabit half duplex  |
+--------------+--------------------------+
| 100baseTx-FD | 100 megabit full duplex  |
+--------------+--------------------------+

The raw number indicates the number of bits which can be exchanged between two Ethernet devices over the wire. So 10 megabit Ethernet can support the transmission of ten million bits per second. The suffix to each identifier indicates whether both hosts can send and receive simultaneously or not. Half duplex means that each device can either send or receive in the same instant. Full duplex means that both devices can send and receive simultaneously.

::

        # Detecting link layer status with mii-tool
        [root@tristan]# mii-tool
        eth0: negotiated 100baseTx-FD, link ok
        [root@tristan]# mii-tool -v
        eth0: negotiated 100baseTx-FD, link ok
          product info: vendor 08:00:17, model 1 rev 0
          basic mode:   autonegotiation enabled
          basic status: autonegotiation complete, link ok
          capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
          advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
          link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control


        # Specifying Ethernet port speeds with mii-tool --advertise
        [root@tristan]# mii-tool mii-tool --advertise 10baseT-HD,10baseT-FD
        restarting autonegotiation...
        [root@tristan]# mii-tool
        eth0: negotiated 10baseT-FD, link ok


        # Forcing Ethernet port speed with mii-tool --force
        [root@tristan]# mii-tool --force 10baseT-FD
        [root@tristan]# mii-tool
        eth0: 10 Mbit, full duplex, link ok
        [root@tristan]# mii-tool --restart
        restarting autonegotiation...
        [root@tristan]# mii-tool
        eth0: negotiated 100baseTx-FD, link ok



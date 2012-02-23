ip rule
=======

.. contents::

show : Displaying the RPDB with ip rule show
--------------------------------------------
::

        [root@isolde]# ip rule show
        0:      from all lookup local 
        32766:  from all lookup main 
        32767:  from all lookup 253
          
add : Creating a simple entry in the RPDB with ip rule add
----------------------------------------------------------
::

        [root@masq-gw]# ip route add default via 205.254.211.254 table 8
        [root@masq-gw]# ip rule add tos 0x08 table 8
        [root@masq-gw]# ip route flush cache
        [root@masq-gw]# ip rule show
        0:      from all lookup local 
        32765:  from all tos 0x08 lookup 8 
        32766:  from all lookup main 
        32767:  from all lookup 253



add from : Creating a complex entry in the RPDB with ip rule add
----------------------------------------------------------------
::

        [root@masq-gw]# ip rule add from 192.168.100.17 tos 0x08 fwmark 4 table 7
          

add nat : Creating a NAT rule with ip rule add nat
--------------------------------------------------
::

        [root@masq-gw]# ip rule add nat 205.254.211.17 from 192.168.100.17
        [root@masq-gw]# ip rule show
        0:      from all lookup local 
        32765:  from 192.168.100.17 lookup main map-to 205.254.211.17
        32766:  from all lookup main 
        32767:  from all lookup 253


add nat subnet : Creating a NAT rule for an entire network with ip rule add nat
-------------------------------------------------------------------------------
::

        [root@masq-gw]# ip rule add nat 205.254.211.32 from 192.168.100.32/29
        [root@masq-gw]# ip rule show
        0:      from all lookup local 
        32765:  from 192.168.100.32/29 lookup main map-to 205.254.211.32
        32766:  from all lookup main 
        32767:  from all lookup 253
          

del nat : Removing a NAT rule for an entire network with ip rule del nat
------------------------------------------------------------------------
::

        [root@masq-gw]# ip rule del nat 205.254.211.32 from 192.168.100.32/29
        [root@masq-gw]# ip rule show
        0:      from all lookup local 
        32766:  from all lookup main 
        32767:  from all lookup 253


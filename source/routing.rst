Routing
=======

.. contents::

Routing Policy Database (RPDB)
------------------------------
The routing policy database (RPDB) controls the order in which the kernel searches through the routing tables. Each rule has a priority, and rules are examined sequentially from rule 0 through rule 32767.

When a new packet arrives for routing (assuming the routing cache is empty), the kernel begins at the highest priority rule in the RPDB--rule 0. The kernel iterates over each rule in turn until the packet to be routed matches a rule. When this happens the kernel follows the instructions in that rule. Typically, this causes the kernel to perform a route lookup in a specified routing table. If a matching route is found in the routing table, the kernel uses that route. If no such route is found, the kernel returns to traverse the RPDB again, until every option has been exhausted.

unicast
-------
A unicast rule entry is the most common rule type. This rule type simple causes the kernel to refer to the specified routing table in the search for a route. If no rule type is specified on the command line, the rule is assumed to be a unicast rule.

::

        ip rule add unicast from 192.168.100.17 table 5
        ip rule add unicast iif eth7 table 5
        ip rule add unicast fwmark 4 table 4

nat
---
The nat rule type is required for correct operation of stateless NAT. This rule is typically coupled with a corresponding nat route entry. The RPDB nat entry causes the kernel to rewrite the source address of an outbound packet.

::

        ip rule add nat 193.7.255.184 from 172.16.82.184
        ip rule add nat 10.40.0.0 from 172.40.0.0/16

unreachable
-----------
Any route lookup matching a rule entry with an unreachable rule type will cause the kernel to generate an ICMP unreachable to the source address of the packet.

::

        ip rule add unreachable iif eth2 tos 0xc0
        ip rule add unreachable iif wan0 fwmark 5
        ip rule add unreachable from 192.168.7.0/25

prohibit
--------
Any route lookup matching a rule entry with a prohibit rule type will cause the kernel to generate an ICMP prohibited to the source address of the packet.

::

        ip rule add prohibit from 209.10.26.51
        ip rule add prohibit to 64.65.64.0/18
        ip rule add prohibit fwmark 7

blackhole
---------
While traversing the RPDB, any route lookup which matches a rule with the blackhole rule type will cause the packet to be dropped. No ICMP will be sent and no packet will be forwarded.

::

        ip rule add blackhole from 209.10.26.51
        ip rule add blackhole from 172.19.40.0/24
        ip rule add blackhole to 10.182.17.64/28


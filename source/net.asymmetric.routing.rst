Networking : Asymmetric Routing
===============================

.. highlight:: bash

**Asymmetric TCP/IP routing** causes a common performance problem on servers that have more than one network connection. The atypical network on the example server, interface eth0 is bound to address 192.168.16.20 and interface eth1 is bound to 192.168.16.21. Each routing policy has an associated priority. Policies with a lower priority number take precedence over policies that also may match the candidate packet but have a higher priority value. The priority is an unsigned 32-bit number, so there is never a problem finding enough priority levels to express any algorithm in great detail.

At start-up time, the kernel creates several default rules to control the normal routing for the server. These rules have priorities 0, 32766 and 32767. The rule at priority 0 is a special rule for controlling intra-box traffic and does not affect us. However, we do want our new rules to take precedence over the other default rules, so they should use priority numbers less than 32766. These two default rules also may be deleted if you are sure your replacement routes never need to fall back on the default behavior of the server.

The new policy rules are added using the ip rule add command. The from attribute is used to generate source address-based routing policies.

::

        #ip rule add from 192.168.16.20/32 tab 1 priority 500
        #ip rule add from 192.168.16.21/32 tab 2 priority 600

Under this setup, outgoing packets first are checked for source address 192.168.16.20. If that matches they use routing table 1, which sends all traffic out eth0. Otherwise the packets are checked for source addresses that match 192.168.16.21. Matches to that rule would use table 2, which sends all traffic out eth1. Any other packets would use the default system rules detailed by rules 32766 and 32767.

::

        #ip rule show
        0:      from all lookup local 
        500:  from 192.168.16.20 lookup 1
        600:  from 192.168.16.21 lookup 2 
        32766:  from all lookup main 
        32767:  from all lookup 253 

Changes made to the policy database do not take effect dynamically. To tell the kernel that it needs to re-parse the policy database, issue the ip route flush cache command:

::

        #ip route flush cache


Networking : WAN Optimisation
=============================

.. contents::

WAN optimization is a type of Congestion Control technology.  It’s like a network filter driver that dynamically shapes network throughput to minimize TCP connection failures due to network congestion, and allowing for better WAN utilization and throughput.  This is great for customers with remote sites.

NetBackup WAN Optimisation
--------------------------

The technology is entirely heuristic-based, so there is no tuning or configuration of the function – it’s either enabled or disabled.

This feature optimizes outbound TCP traffic for each TCP connection.  Where traffic can’t be optimized, the heuristic logic disengages so that this function will not degrade network performance. 

WAN optimization will improve throughput when:

*  Latency is greater than 20 msecs
*  Packet loss is greater than 0.01% (1 in 10,000 packets) for metro area networks (networks > 100 Mb/sec)
*  Packet loss is greater than 0.1% (1 in 1,000 packets) for wide area networks (networks < 100 Mb/sec)



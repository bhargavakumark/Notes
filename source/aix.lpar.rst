AIX : LPAR
==========

.. contents::

References
----------

* http://www.redbooks.ibm.com/abstracts/sg247039.html?Open

Physical partition
One or more building blocks linked together by a high-speed interconnect.
Generally, the interconnect is used to form a single, coherent memory
address space. In a system that is only capable of physical partitioning, a
partition is a group of one or more building blocks that is configured to support
an operating system image. Other vendors may refer to physical partitions as
domains or nPartitions. The maximum number of physical processors in a
POWER5TM system at the time of the writing of this book is 64.
Logical partition
A subset of logical resources that are capable of supporting an operating
system. A logical partition consists of CPUs, memory, and I/O slots that are a
subset of the pool of available resources within a system.


High availability
-----------------
You should place redundant devices of a partition in separate I/O drawers, where
possible, for highest availability. For example, if two Fibre Channel adapters
support multipath I/O to one logical unit number, and if one path fails, the device
driver chooses another path using another adapter in another I/O drawer
automatically.
Some PCI adapters do not have enhanced error handling capabilities built in to
their device drivers. If these devices fail, the PCI host bridge in which they are
placed and the other adapters in this PCI host bridge are affected. Therefore, it is
strongly recommended that you place all adapters without enhanced error
52
Partitioning Implementations for IBM Eserver p5 Servers
handling capabilities on their own PCI host bridge and that you do not assign
these adapters on the same PCI host bridge to different partitions.


Perfromance
===========

.. contents::

Performance : Switch
--------------------

===================================
Measuring Switch switching capacity
===================================

MPPS stands for million packets per second and Cisco prefers to refer throughput in MPPS. For a layer-3 switch an MPPS value is shared one. For some of the higher-end Cisco routers the routing is "distributed" between multiple line-cards, in which case the PPS numbers are based on the number of line cards, bit for non-distributed architectures (Catalyst switches) the numbers are based on the routing engine, so it is the maximum number of Packets per Second that the box can route.

For example, 2960-48PST-S is 13.3 Mpps.

The figure MPPS expresses the maximum number of frames per second that can be processed by the device. It is not dependent on frame size but clearly small frames require higher packet rates.

smallest frames in Ethernet are 64 bytes in size, taking in account the preamble (8 bytes) and the minimum inter-frame gap (the last two counts roughly for 20.2 bytes) to fill a GE port in one direction you need 1484560 frame per second.

10^9 / [(64+20.2)*8] where 8 is bits/byte.

So a number of 13.3 MPPS is equivalent to [((13.3 M * (64+20.2) * 8)) / 10^9 = 8.95 / 2=4.47] 4.47 GE ports filled with smallest frames bidirectional.

On the other hand frames of max size 1518 bytes require 81264 fps to fill a GE port in one direction.

So this number expresses the forwarding capability of the device.

A non blocking device with 48 GE ports would require 2 * 1484560 * 48 as MPPS or higher.

Therefore the performance of a device will be determined by combination of number of packets per sec and the size of the packet.


Benchamarking Tools
-------------------

=======
VDBench
=======

VDBench  supports both raw and filesystem I/O using
blocking reads on many threads. It has a flexible configuration
scheme and reports many useful statistics, including IOPS,
throughput, and average latency.

===
Fio
===
Fio supports both raw and filesystem I/O using block-
ing reads, Posix AIO, or Linux Native AIO (libaio), using one
or more processes. It reports similar statistics to VDBench.

=======================
Trace-Driven Benchmarks
=======================

Trace-driven benchmarking is making a recording of I/O ac-
tivity on one system configuration, then replaying that activity
on another system configuration. The promise of trace-driven
benchmarks is that it allows for the evaluation of application
I/O performance on a system without having access to the
original application (or its data)

However, I/O traces fail to preserve the serialization or de-
pendencies between operations; it is not possible to reconstruct
whether two operations could have proceeded in parallel on
the target system if they did not do so on the traced system.
When evaluating the performance of a drive that has different
performance characteristics from the drives that precede it,
especially with respect to support for parallel operations, trace-
driven benchmarks are of questionable value.




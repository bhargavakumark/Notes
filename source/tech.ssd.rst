Tech : Solid State Drives (SSD)
===============================

.. contents::

References
----------

High Performance of Solid State on Linux, paper by Seppanen

Intro
-----

NAND flash memory has
an inherent limitation that its data must be erased in bulk
before being overwritten, which is called erase-before-write.
To hide this unfavorable difference with traditional storage
devices, Flash Translation Layer (FTL) schemes have been
devised.

FTL provides a block device interface to the host
by managing logical-to-physical address mapping information.
The performance of SSDs heavily depends on FTL algorithms

If the
mapping granularity of FTL is more fine-grained, the FTL can
achieve better performance, but it needs larger memory space.

SSDs usually adopt an internal device cache, such as DRAM
or SDRAM, which is used for two purposes [6]–[8]. First,
it provides data buffering to absorb frequent read and write
requests. Second, it caches address mapping information for
FTL.

It is known to be more effective to use the data
buffer only for write caching, not for read caching, because
write latency is longer than read latency and writes involve
erase operations in SSDs 

To handle the erase-
before-write feature of NAND flash memory, most FTLs
assign write requests to previously-erased pages by keeping
track of the logical-to-physical mapping information in an
out-of-place manner. 

NAND flash devices have large (at least 128KB) block sizes,
and blocks must be erased as a unit before fresh data can
be written

While the write operation is performed by the unit of a
page, the flash memory is erased by the unit of a block that
is a bundle of several sequential pages.

The typical access latencies for read, write, and
erase operations are 25 microseconds, 200 microseconds, and
1500 microseconds, respectively [4]. In addition, before an
erase operation is being done on a block, the live (i.e., not over-
written) sectors from that block need to be moved to pre-erased
blocks. Thus, an erase operation incurs lot of sectors read
and write operations, which makes it a performance critical
operation.

However, not all
flash-based storage devices use FTL [5], [15]. For these
devices, flash driver can provide the internal flash information.
In some cases, operating system provides FTL functionality.
For example, Windows Mobile emulates FTL in software

applications
are designed (or modified) based on generic FTL behavior.
Although this is adequate for the applications designed for
the general computing environment, but for the environments
(i.e., high end servers or supercomputers) running a fixed
set of applications (i.e., database management systems), huge
performance gain could be obtained by using customized
flash-based storages designed with application specific FTL

Garbage collection performance is largely determined by the 
erasure time. NOR erases very slowly and thus an effective 
NOR garbage collection strategy is relatively complex and 
limits the design options. In comparison NAND erases very 
quickly; thus these limitations don't apply.


Write Amplicfication
--------------------
NAND flash bits also have a limited lifespan, sometimes
as short as 10,000 write/erase cycles. Because a solid-state
drive must present the apparent ability to write any part of
the drive indefinitely, the flash manager must also implement
a wear-leveling scheme that tracks the number of times each
block has been erased, shifting new writes to less-used areas.
This frequently displaces otherwise stable data, which forces
additional writes. This phenomenon, where writes by the host
cause the flash manager to issue additional writes, is known
as write amplification


Demand-based FTL
----------------

the size of mapping
information increases in proportion to the capacity of SSDs.

The large mem-
ory consumption is a major obstacle for large-capacity SSDs.
To alleviate such a problem, the **Demand-based FTL scheme**

DFTL maintains all logical-to-physical mapping informa-
tion in the translation pages of NAND flash memory. A
translation page consists of an array of mapping entries in
sequential order in terms of LPN.

Basically, to update logical-
to-physical mapping, DFTL writes a new translation page that
includes the new mapping entries after reading the existing
translation page. Then, DFTL modifies the Global Translation
Directory (GTD) that tracks all of the valid translation pages.
GTD is always maintained in the device cache since its size
is very small.

DFTL keeps only frequently-accessed logical-to-physical
mapping entries in the device cache, which is called the
Cached Mapping Table (CMT).

Hybrid Mapping Schemes
----------------------

Hybrid Mapping Schemes: To balance the advantages of
page-level and block-level mapping schemes, hybrid mapping
schemes have been devised. Basically, such schemes are based
on the block-level mapping scheme where all the pages in a
block must be fully and sequentially written to preserve their
relative offsets in the block. The hybrid mapping schemes offer
block-level mapping for all data blocks, but they also support
page-level mapping for a small fixed number of blocks called
log blocks to handle write updates

Many hybrid mapping schemes have been developed [12],
[16]–[18]. One of them, Fully Associative Sector Translation
(FAST) [12], has been widely used in research and industrial
areas. FAST uses two types of log blocks, RW and SW
log blocks. The RW log blocks are used to handle random
writes, while the SW log block is dedicated to accommodate
sequential writes. FAST allocates only one SW log block for
sequential writes, and all the other log blocks are used as RW
log blocks. In FAST, all random updates for data blocks can
be located in any RW log blocks.

Power Failure Recovery
----------------------
Buffered data and mapping information that are maintained
in the volatile device cache can be lost by unexpected power
failures. Simple approaches to prevent the loss of the important
data in the device cache are to employ either (1) non-volatile
memory devices [19] such as phase change RAM (PRAM)
[20] and ferroelectric RAM (FRAM) [21], (2) traditional
battery-backed DRAMs, or (3) a super cap that provides
enough power to flush all of the dirty data in the device cache
to NAND flash memory.
The Lightweight Time-shift Flash Translation Layer
(LTFTL) is an example of software-based approach that aims
at maintaining FTL consistency in case of abnormal shutdown
[22].

NAND Flash Memory
-----------------

NAND flash memory is comprised of an array of blocks,
each of which contains a fixed number of pages. NAND
flash memory offers three basic operations: read, write (or
program), and erase. A page is the unit of read and write
operations, and a block is the unit of erase operations.
An
erase operation sets all data bits of a block to 1s.

There are two types of NAND flash memory. Single Level
Cell (SLC) NAND [13] stores one bit per cell, whereas Multi
Level Cell (MLC) NAND [14] provides two or more bits per
cell for larger capacity.

Linux IO Scheduler
------------------

SSDs, not having seek time penalties, do not benefit from this function.
There does exist a non-reordering scheduler called the “noop”
scheduler, but it must be specifically turned on by a system
administrator; there is no method for a device driver to request
use of the noop scheduler.

When new requests enter the request queue, the request
queue scheduler attempts to merge them with other requests
already in the queue. Merged requests can share the overhead
of drive latency (which for a disk may be high in the case
of a seek), at the cost of the CPU time needed to search the
queue for mergeable requests. This optimization assumes that
seek penalties and/or lack of parallelism in the drive make the
extra CPU time worthwhile.

The request queue design also has a disk-friendly feature
called queue plugging. When the queue becomes empty, it
goes into a “plugged” state where new requests are allowed in
but none are allowed to be serviced by the device until a timer
has expired or a number of additional commands have arrived.
This is a strategy to improve the performance of disk drives
by delaying commands until they are able to be intelligently
scheduled among the requests that are likely to follow.

Some of these policies are becoming more flexible with new
kernel releases. For example, queue plugging may be disabled
in newer kernels. However, these improvements have not yet
filtered down to the kernels shipped by vendors for use in
production “enterprise” systems.

Linux systems support AIO in two ways. Posix AIO is
emulated in userspace using threads to parallelize operations.
The task-scheduling overhead of the additional threads makes
this a less attractive option. Linux native AIO, known by the
interfacing library “libaio,” has much lower overhead in theory
because it truly allows multiple outstanding I/O requests for a
single thread or process

TRIM
----
New operating systems and drives support TRIM [12], a
drive command which notifies the drive that a block of data is
no longer needed by the operating system or application. This
can make write operations on an SSD faster because it may
free up sections of flash media, allowing them to be re-used
with lessened data relocation costs.



Performance Barriers
--------------------

While disk specifications
report average latency in the three to six millisecond range,
SSDs can deliver data in less than a hundred microseconds,
roughly 50 times faster.

Interface bandwidth depends on the architecture of the drive;
most SSDs use the SATA interface with a 3.0Gbps serial link
having a maximum bandwidth of 300 megabytes per second.
The PCI Express bus is built up from a number of individual
serial links, such that a PCIe 1.0 x8 device has maximum
bandwidth of 2 gigabytes per second.

Individual disk drives have no inherent parallelism; access
latency is always serialized. SSDs, however, may support
multiple banks of independent flash devices, allowing many
parallel accesses to take place.

SSDs are unpredictable
in several new ways, because there are background processes
performing flash management processes such as wear-leveling
and garbage collection [1], and these can cause very large
performance drops after many seconds, or even minutes or
hours of deceptively steady performance.

If we presume a device that can complete a small (4KB
or less) read in 100 microseconds, we can easily calculate
a maximum throughput of 10,000 IOPS (I/O operations per
second). While this would be impressive by itself, a device
with 2-way parallelism could achieve 20,000 IOPS; 4-way
40,000 IOPS, etc. Such latency is quite realistic for SSDs built
using current technology; flash memory devices commonly
specify read times lower that 100 microseconds.

There are two specific areas where disk-centric design
decisions cause problems. First, there are in some areas un-
necessary layers of abstraction; for example, SCSI emulation
for ATA drives. This allows sharing of kernel code and a
uniform presentation of drive functions to higher operating
system functions but adds CPU load and delay to command
processing.

Second, request queue management functions have their
own overhead in added CPU load and added delay. Queue
schedulers, also known as elevators, are standard for all mass
storage devices, and the only way to avoid their use is to elim-
inate the request queue entirely by intercepting requests before
they enter the queue using the kernel’s make_request
function. While there are useful functions in the scheduler,
such as providing fair access to I/O to multiple users or
applications, it is not possible for device driver software to
selectively use only these functions

A typical Linux mass storage device and driver has a single
system interrupt per device or host-bus adapter; the Linux
kernel takes care of routing that device to a single CPU. By
default, the CPU that receives a particular device interrupt
is not fixed; it may be moved to another CPU by an IRQ-
balancing daemon. System administrators can also set a per-
IRQ CPU affinity mask that restricts which CPU is selected.


Achieving the lowest latency and best overall performance
for small I/O workloads requires that the device interrupt be
delivered to the same CPU as the application thread that sent
the I/O request. However, as application load increases and
needs to spread to other CPUs, this becomes impossible. The
next best thing is for application threads to stay on CPUs
that are close neighbors to the CPU receiving the interrupt.
(Neighbors, in this context, means CPUs that share some cache
hierarchy with one another.)
Sending the interrupt to the CPU that started the I/O request
(or a close neighbor) improves latency because there are
memory data structures related to that I/O that are handled
by code that starts the request as well as by code that retires
the request. If both blocks of code execute on the same CPU or
a cache-sharing neighbor the cache hits allow faster response.

There is also a worst-case scenario, where I/O requests are
originating at a CPU or set of CPUs that share no caches
with the CPU that is receiving device interrupts. Unfortunately,
the existing IRQ balancing daemon seems to seek out this
configuration, possibly because it is attempting to balance the
overall processing load across CPUs. Sending a heavy IRQ
load to an already busy CPU might seem counter-intuitive to
a systems software designer, but in this case doing so improves
I/O performance.

=================
Multiple Channels
=================

To enhance I/O bandwidth, current flash memory SSDs
access multiple flash chips with multi-channel and multi-
way architecture [2], [6], where the multiple channels can
be operated simultaneously and each channel can access
multiple flash chips at interleaved manner. Two flash chips
using different channels can be operated independently
and therefore the page transfer times (from the NAND
controller to the flash chip) and page program times for
different chips can overlap. For two flash chips sharing
a same channel, the data transfer times cannot overlap
but the page program times can overlap. To utilize such
parallel architectures, sequential data are distributed across
multiple flash chips. Therefore, the parallel architecture can
provide a high bandwidth for sequential requests. However,
random I/O performances are poor compared to sequential
I/O performances.


Benchamarking Tools
-------------------

VDBench [15] supports both raw and filesystem I/O using
blocking reads on many threads. It has a flexible configuration
scheme and reports many useful statistics, including IOPS,
throughput, and average latency.
Fio [16] supports both raw and filesystem I/O using block-
ing reads, Posix AIO, or Linux Native AIO (libaio), using one
or more processes. It reports similar statistics to VDBench.

ECC (Error Correcting Codes)
----------------------------

Current NAND flash products ensure reliability by em-
ploying error-correcting codes (ECC). Traditionally, SLC
flash memory uses single-bit ECC, such as Hamming codes.
However, MLC flash memory shows a much higher bit-
error rate (BER) than single-bit error-correcting codes can
cover. As a result, codes with strong error-correction capa-
bilities, like BCH or Reed-Solomon (RS) codes, are used.

YAFFS
-----

YAFFS is the only file system, under any operating system, that has 
been designed specifically for use with NAND flash. YAFFS is thus 
designed to work within the constraints of, and exploit the features 
of, NAND flash to maximise performance. YAFFS uses journaling, error 
correction and verification techniques tuned to the way NAND 
typically fails, to enhance robustness. The result is a file system 
that exploits low-cost NAND chips and is both fast and robust. YAFFS 
is highly portable and runs under Linux, ucLinux and Windows CE. 
YAFFS is an open source project.

The lead-up to YAFFS started with an investigation into modifying 
the JFFS2 flash file system to work with NAND flash (**) for some 
Aleph One customers. It seemed reasonable that the best way to get a 
file system for NAND flash would be just "tweaking" an existing flash 
file system. On deeper investigation, it became apparent that 
designing a new file system specifically for NAND might have some 
benefits.



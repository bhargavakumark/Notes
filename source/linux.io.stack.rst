Linux : I/O Stack
=================

.. contents::

References
----------

High Performance of Solid State on Linux, paper by Seppanen

Intro
-----

Applications generally access storage through standard
system calls requesting access to the filesystem. The kernel
forwards these requests through the virtual filesystem (VFS)
layer, which interfaces filesystem-agnostic calls to filesystem-
specific code. Filesystem code is aware of the exact (logical)
layout of data and metadata on the storage medium; it performs
reads and writes to the block layer on behalf of applications.
The block layer provides an abstract interface which con-
ceals the differences between different mass storage devices.
Block requests typically travel through a SCSI layer, which is
emulated if an ATA device driver is present, and after passing
through a request queue finally arrive at a device driver which
understands how to move data to and from the hardware. More
detail on this design can be found in [9].

The traditional Linux storage architecture is designed to in-
terface to disk drives. One way in which this is manifested is in
request queue scheduler algorithms, also known as elevators.
There are four standard scheduler algorithms available in the
Linux kernel, and three use different techniques to optimize
request ordering so that seeks are minimized.


Linux systems support AIO in two ways. Posix AIO is
emulated in userspace using threads to parallelize operations.
The task-scheduling overhead of the additional threads makes
this a less attractive option. Linux native AIO, known by the
interfacing library “libaio,” has much lower overhead in theory
because it truly allows multiple outstanding I/O requests for a
single thread or process

Parallelism is easier to achieve for I/O writes, because it is
already accepted that the operating system will buffer writes,
reporting success immediately to the application. Any further
writes can be submitted almost instantly afterwards, because
the latency of a system call and a buffer copy is very low. The
impending writes, now buffered, can be handled in parallel.
Therefore, the serialization of writes by an application has
very little effect, and at the device driver and device level the
writes can be handled in parallel.

Applications can request non-buffered I/O using the
O_DIRECT option when opening files, but this option is not
always supported by filesystems. Some filesystems fail to
support O_DIRECT and some support it in a way that is prone
to unpredictable performance.

There is another way for applications to communicate to the
kernel about the desired caching/buffering behavior of their
file I/O. The posix fadvise system call allows applications
to deliver hints that they will be, for example, performing
sequential I/O (which might suggest to the kernel or filesystem
code that read-ahead would be beneficial) or random I/O.
There is even a hint suggesting that the application will never
re-use any data. Though this would provide an alternative to
O_DIRECT, the hint is ignored by the kernel.


Raw I/O
Linux allows applications to directly access mass storage
devices without using a filesystem to manage data; we refer
to this as “raw” I/O.

Typically,
raw device access is used with the O_DIRECT option, which
bypasses the kernel’s buffer cache. This allows applications
that provide their own cache to achieve optimal performance.
Raw device mode is the only time that uncached I/O is reliably
available under Linux.



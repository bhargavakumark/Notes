Linux : iostat - I/O performance testing
========================================

.. contents::

Fields in iostat output
------------------------

------
rrqm/s
------
The number of read requests merged per second that were queued to the device.

------
wrqm/s
------
The number of write requests merged per second that were queued to the device.

---
r/s
---
The number of read requests that were issued to the device per second.

---
w/s
---
The number of write requests that were issued to the device per second.

------
rsec/s
------
The number of sectors read from the device per second.

------
wsec/s
------
The number of sectors written to the device per second.

-----
rkB/s
-----
The number of kilobytes read from the device per second.

-----
wkB/s
-----
The number of kilobytes written to the device per second.

-----
rMB/s
-----
The number of megabytes read from the device per second.

-----
wMB/s
-----
The number of megabytes written to the device per second.

--------
avgrq-sz
--------
The average size (in sectors) of the requests that were issued to the 
device. (for both reads and writes). ie (rsec + wsec) / (r + w)

--------
avgqu-sz
--------
The average queue length of the requests that were issued to the device.

-----
await
-----
The average time (in milliseconds) for I/O requests issued to the 
device to be served. This includes the time spent by the requests 
in queue and the time spent servicing them.

-----
svctm
-----
The average service time (in milliseconds) for I/O requests that 
were issued to the device.

Note: await includes svctim. Infact await (average time taken for 
each IO Request to complete) = the average time that each request 
was in queue (lets call it queuetime) PLUS the average time each 
request took to process (svctm)

-----
%util
-----
Percentage of CPU time during which I/O requests were issued to 
the device (bandwidth utilization for the device). Device 
saturation occurs when this value is close to 100%.


Interpreting iostat values
--------------------------
Lets take the above example

::

        Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
        dm-0              0.00     0.00  611.40  414.23 20286.60  1656.93 42.79    17.50   17.33   0.96  98.57

*	avg time that each request spent in queue 
	(qtime) = await – svctime = 17.33 – 0.96 => 16.37 ms

*	avg time tha each request spent being serviced = 0.96 ms

*	so averagely each IO request spent 17.33ms to et processed 
	of which 16.37 ms were spent just waiting in queue

*	%util can be calculated as (r/s + w/s) * svctim / 1000ms * 100 => 1025*0.96/1000 * 100 => 98.5%
*	This simple means that in a 1 second interval, 1025 requests 
	were sent to disk, each of which took 0.96ms for the disk 
	to process resulting in 984 ms of disk utilization time in a 
	period of 1 s (or 1000 ms). This means the disk is greater 
	than 98% utilized


On this disk subsystem, it is clear that the disk cannot process more 
IO requests than what it is getting

http://bhavin.directi.com/iostat-and-disk-utilization-monitoring-nirvana/

On every Linux box the following should be graphed at 5 minute averages

*   %util: When this figure is consistently approaching above 80% you will need to take any of the following actions -

   *	increasing RAM so dependence on disk reduces
   *	increasing RAID controller cache so disk dependence decreases
   *    increasing number of disks so disk throughput increases 
	(more spindles working parallely)
   *    horizontal partitioning

*   (await-svctim)/await*100: The percentage of time that IO 
    operations spent waiting in queue in comparison to actually 
    being serviced. If this figure goes above 50% then each IO 
    request is spending more time waiting in queue than being 
    processed. If this ratio skews heavily upwards (in the >75% 
    range) you know that your disk subsystem is not being able to 
    keep up with the IO requests and most IO requests are spending 
    a lot of time waiting in queue. In this scenario you will 
    again need to take any of the actions above

*   %iowait: This number shows the % of time the CPU is wasting in 
    waiting for IO. A part of this number can result from network 
    IO, which can be avoided by using an Async IO library. The rest 
    of it is simply an indication of how IO-bound your application is. 
    You can reduce this number by ensuring that disk IO operations 
    take less time, more data is available in RAM, increasing disk 
    throughput by increasing number of disks in a RAID array, using 
    SSD (Check my post on Solid State drives vs Hard Drives) for 
    portions of the data or all of the data etc

hdparm
------

::

        [root@hawk ~]# cat /sys/block/hda/queue/read_ahead_kb;hdparm -t /dev/hda{,,}
        128

        /dev/hda:
        Timing buffered disk reads: 70 MB in 3.05 seconds = 22.92 MB/sec

        /dev/hda:
        Timing buffered disk reads: 72 MB in 3.02 seconds = 23.84 MB/sec

        /dev/hda:
        Timing buffered disk reads: 68 MB in 3.03 seconds = 22.44 MB/se



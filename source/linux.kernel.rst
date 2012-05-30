Linux : Kernel
==============

.. contents::

Processor Affinity
------------------

Lots of context switches
        http://www.linuxquestions.org/questions/linux-kernel-70/lots-of-context-switches-sorry-best-i-could-do-856311/

PLPA is dead; please only use hwloc. :-)

Optimizing for maximum performance is a very tricky thing; there are 
many, many reasons for getting the performance that you're seeing. 

Here's a few suggestions:

*	Using hwloc to bind your processes to individual cores (or 
	hardware threads a) if your hardware has them, and b) if your 
	processes are I/O bound) can help stop Linux migrating them 
	around and therefore reduce overhead

*	Unless your processes are I/O bound (e.g., blocking waiting 
	writing or reading to I/O), don't oversubscribe. Meaning: 
	don't bind more than one process to a hardware thread or 
	core. YMMV with your particular application, of course.

*	If you have a NUMA architecture, where you bind your process 
	can make a major difference. If it's doing all network 
	activity, you might want to bind it to a location "near" 
	the NIC that you're using.

*	Also, you might want to bind as early in the process as 
	possible so that all your memory is local (vs. on a remote 
	NUMA node, which can tremendously slow down your overall 
	performance).

*	hwloc's lstopo(1) will give you a good picture of the hardware 
	topology in your machine; that will help you understand what's 
	happening.

*	If you're really trying to get as much performance as 
	possible, you might want to stop all other services on your 
	machine (X, NFS, bluetooth, mail, printing, ...etc.) such that 
	essentially only the OS and your server are running.

These are a few rules of thumb that should point you in the right direction...

Kernel Panic
------------

==============
Panic a Kernel
==============
How to panic a kernel

::

        echo "1" > /proc/sys/kernel/kdb
        echo "1" > /proc/sys/kernel/sysrq
        echo "c" > /proc/sys/kernel/sysrq-trigger

===========================
Path where dumps are stored
===========================
Typically machine will dump core upon panic and save it in a particular 
directory while rebooting.

On Solaris:
	Dump directory => **/var/crash/<machine-name>/{unix.nn, vmcore.nn}**

To see the panic string / stacktrace run adb or mdb

::

        #> cd /var/crash/<machine-name>
        #> adb -k *.nn

        $<msgbuf


On HP-UX:
	Dump directory => **/var/adm/crash/<crash.nn>**

To see panic string you can check the INDEX file in the crash.nn 
directory or alternatively run p4 or q4 debugger.

::

        #>cd /var/adm/crash/crash.nn
        #>p4
        p4>Msgbuf


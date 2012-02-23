Kernel Panic
============

.. contents::

Panic a Kernel
--------------
How to panic a kernel

::

        echo "1" > /proc/sys/kernel/kdb
        echo "1" > /proc/sys/kernel/sysrq
        echo "c" > /proc/sys/kernel/sysrq-trigger

Path where dumps are stored
---------------------------
Typically machine will dump core upon panic and save it in a particular directory while rebooting.

On Solaris:
Dump directory => **/var/crash/<machine-name>/{unix.nn, vmcore.nn}**

To see the panic string / stacktrace run adb or mdb

::

        #> cd /var/crash/<machine-name>
        #> adb -k *.nn

        $<msgbuf


On HP-UX:
Dump directory => **/var/adm/crash/<crash.nn>**

To see panic string you can check the INDEX file in the crash.nn directory or alternatively run p4 or q4 debugger.

::

        #>cd /var/adm/crash/crash.nn
        #>p4
        p4>Msgbuf


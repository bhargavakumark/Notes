Linux : Kernel crash debugging
==============================

.. contents::

How long a process has been sleep
---------------------------------

::

        crash> task_struct ffff880154346640 |grep last
        last_wakeup = 0,
        last_arrival = 16702301489932,
        last_queued = 0,
        last_switch_count = 719165,
        last_siginfo = 0x0,

        crash> runq |grep "CPU 0"
        CPU 0 RUNQUEUE: ffff88002c213700
        crash> rq ffff88002c213700 |grep clock
        exec_clock = 3040782483868,
        clock = 16703560001251,
        clock_task = 16703560001251,

        crash> eval 16703560001251 - 16702301489932
        hexadecimal: 4b035bd7
        decimal: 1258511319 



Solaris : Dtrace
================

.. contents::

dtrace
------
Dtrace is SUN solaris tool to help instrument the operating system at runtime without changing the operating system code.

::

        dtrace -l 

lists all the probes that are allowed to be captured. There are more than 50000 probes available in solaris.

Providers
---------
Provider are modules which can proivde probes.
Ex:

::

        ID      PROVIDER        MODULE                  FUNCTION NAME
        .
        .
        .
        5       syscall                                 munmap   return
        6       syscall                              fpathconf   entry


Each provider knows how to instrument a certain part of the system. here syscall is provider which can instrument entry and exit for every system call. The fbt provider knows how to instrument each entry and return of every kernel function.

**MODULE** denotes the kernel module or for user probe user level module.

Listing probes
--------------
Probes can listed as **PROVIDER:MODULE:FUNCTION:NAME**. So to list all probes from provider syscall with name entry would be

::

        dtrace -l -n syscall:::entry


To instrument the system
------------------------

::

        # dtrace -n syscall:::entry
        0    529                pollsys:entry
        0    529                  ioctl:entry
        ...



Program responsible for a certain probe
---------------------------------------

::

         dtrace -n syscall:::entry'{trace(execname)}'


Aggregation of probes
---------------------

::

         dtrace -n syscall:::entry'{#[execname] = count()}'


Predicates
----------

::

        #  dtrace -n syscall:::entry'/execname == "trashapplet"/{#[probefunc] = count()}'


Multiple elements based aggregation
-----------------------------------

::

        #  dtrace -n syscall:::entry'/execname == "trashapplet"/{#[probefunc, pid] = count()}'


stack trace
-----------

::

        #  dtrace -n syscall:::entry'/execname == "trashapplet"/{#[ustack] = count()}'


process instrumentation
-----------------------

::

        # dtrace -n pid100092::XPending:entry 


timestamp
---------

::

        # dtrace -n pid100092::XPending:entry'{printf("Called XPending at %Y\n", walltimestamp)}' -q


example d-script
----------------

::

        #!/usr/sbin/dtrace -s

        pid100092::XPending:entry
        {
                self->follow = 1;
        }

        pid100092:::entry,
        pid100092:::return
        /self->follow/
        {}

        pid100092::XPending:return
        /self->follow/
        {
                self->follow = 0;
                exit(0);
        }



AIX
===

.. contents::

References
----------
* http://storage-emc.blogspot.in/2009/08/add-and-configure-luns-in-solaris.html

Devices
-------

========
HBA WWNs
========

::

    # luxadm -e port
    /devices/pci@1d,700000/SUNW,qlc@2,1/fp@0,0:devctl CONNECTED
    /devices/pci@1d,700000/SUNW,qlc@2/fp@0,0:devctl CONNECTED

    # fcinfo hba-port -l |grep HBA
    HBA Port WWN: 210000e08b1c829a
    HBA Port WWN: 210000e08b1c2395

=========
List LUNs
=========

::

    fcinfo remote-port -sl -p 210000e08b0c5518
    fcinfo remote-port -sl -p 210100e08b2c5518
    cfgadm -al -o show_SCSI_LUN
    cfgadm -al

    luxadm probe

=========
Scan LUNs
=========

::

    luxadm -e dump_map /devices/pci@1c,600000/pci@1/SUNW,qlc@4/fp@0,0:devctl
    luxadm -e dump_map /devices/pci@1c,600000/pci@1/SUNW,qlc@5/fp@0,0:devctl
    devfsadm

    devfsadm -Cv    # remove stale LUNs

==============
Configure LUNs
==============

::

    cfgadm -c c1::2200000c50401277
    cfgadm -c configure c1
    cfgadm -c configure c2

===========
format disk
===========

::
    
    format

Packages
--------

================
From opencsw.org
================

::

   /opt/csw/bin/pkgutil



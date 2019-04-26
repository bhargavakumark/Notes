SUN ALOM shell
==============

.. contents::

credentials
-----------
Logging in : root/changeme

::

        $ ssh root@192.168.25.25
        root@192.168.25.25's password:

        Sun (TM) Embedded Lights Out Manager
        Version 1.0

        Copyright 2006 Sun Microsystems, Inc. All rights reserved.

        Warning: password is set to factory default.
        /SP -> 

Power State change
------------------

::

        # To power on the host, enter the following command:
        set /SP/SystemInfo/CtrlInfo PowerCtrl=on

        # To power off the host gracefully, enter the following command:
        set /SP/SystemInfo/CtrlInfo PowerCtrl=gracefuloff

        # To power off the host forcefully, enter the following command:
        set /SP/SystemInfo/CtrlInfo PowerCtrl=forceoff

        # To reset the host, enter the following command:
        set /SP/SystemInfo/CtrlInfo PowerCtrl=reset

        # To reboot and enter the BIOS automatically, enter the following command:
        set /SP/SystemInfo/CtrlInfo BootCtrl=BIOSSetup 

Host console
------------

::

        # To start start a session on the server console, enter this command:
        start /SP/AgentInfo/console 

        # To terminate a server console session started by another user, enter this command:
        stop /SP/AgentInfo/console 

        # To revert to CLI once the console has been started, press Esc+(  keys. 

Configuring Network of ALOM
---------------------------

::

        set /SP/AgentInfo DhcpConfigured=disabled
        set /SP/AgentInfo IpAddress=xxx.xxx.xxx.xxx
        set /SP/AgentInfo Gateway=xxx.xxx.xxx.xxx
        set /SP/AgentInfo Netmask=xxx.xxx.xxx.xxx


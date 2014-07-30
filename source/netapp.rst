NetApp
++++++

.. contents:: 

SDK
===

* SDK docs - file:///home/bhargava/NetApp/netapp-manageability-sdk-ontap-api-documentation/SDK_help.htm

Simulator 8 - Clustered mode
============================

* Clone VM from bk-vsim8-vanilla
* Change the VM network settings from the first 2 NICs to some private network
* Boot the VM and press 'space' when it prompts for '[Enter] for immediate boot and any other key for command prompt'
* VLOADER> 
* setenv SYS_SERIAL_NUM 4079432-75-3    # Based on the license keys downloaded from netapp site. License keys are tied to serial number.
* setenv bootarg.nvram.sysid 4079432753
* VLOADER> boot
* Press 'Ctrl-C' when it asks for it 'Press Ctrl-C for boot menu'
* Selection (1-8) : 4       # Clean configuration and initialize disks
* Create a new cluster
* When it asks for single node cluster say no, choose cluster even when creating a single node
* Default password that you enter might sometimes be taken with 'caps lock ON' so try to login with both passwords
* autosupport modify -support disable   # To disable autosupport from talking to netapp server

Advanced Commands
=================

::

    priv set advanced; qtree delete <qtree name>



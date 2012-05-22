Linux : Wine
============

.. contents::

Installing Wine
---------------

::

        wget -q http://wine.budgetdedicated.com/apt/387EE263.gpg -O- | sudo apt-key add - sudo wget http://wine.budgetdedicated.com/apt/sources.list.d/gutsy.list -O /etc/apt/sources.list.d/winehq.list
        sudo apt-get update
        sudo apt-get install wine

Installing MFC42
----------------

::

        sudo apt-get install cabextrace 
        wget http://activex.microsoft.com/controls/vc/mfc42.cab
        cabextrace mfc42.cab
        wine ./mfc42.exe

Installing Irfanview
--------------------

*   Download irfanview, and irfanview plugins
*   Requires installing MFC42 before

::

        wine iview410_setup.exe
        wine irfanview_plugins_410_setup.exe 

ERROR "Cannot use first megabyte for DOS address space, please report"
----------------------------------------------------------------------

::

        sudo sysctl -w vm.mmap_min_addr=0
        # To be persistent edit /etc/sysctl.conf


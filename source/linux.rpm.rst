Linux : RPM
===========

.. contents::

.. highlight:: bash   

References
----------

http://www.idevelopment.info/data/Unix/Linux/LINUX_RPMCommands.shtml

Extracing a rpm
---------------

::
 
         rpm2cpio myrpmfile.rpm | cpio -idmv


Listing files in a rpm file
---------------------------

::

        rpm -qpl file.rpm 


Extracting source from a rpm
----------------------------
Install source rpm, which will create files in 
/usr/src/packages/SOURCES (patches) and 
/usr/src/packages/BUILD

::
        
        rpmbuild <specfile> (in SPECS directory) to apply patches/build from source.

Find the rpm which provide a file
---------------------------------

::

        # rpm -q -f `which rpc.mountd`
        nfs-kernel-server-1.2.1-2.6.6


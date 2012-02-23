RPM
===

.. contents::

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
Install source rpm, which will create files in /usr/src/packages/SOURCES (patches) and /usr/src/packages/BUILD
rpmbuild <specfile> (in SPECS directory) to apply patches/build from source.


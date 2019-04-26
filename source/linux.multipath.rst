Linux : Multipath
+++++++++++++++++

.. contents::

References
==========

* https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/5/html-single/DM_Multipath/#tb-multipath_attributes

queue_if_no_path
================

Check if queue_if_no_path is on for a device

::

    # multipath -l

    mpathak (3638a95f2258000602800000000000035) dm-8
        size=1.0T features='1 queue_if_no_path' hwhandler='0' wp=rw

Disable queue_if_no_path runtime

::

    dmsetup message mpathXYZ 0 fail_if_no_path


Disable queue_if_no_path in multipath.conf

::
    
    devices {
        device {
            vendor "IBM"
            product "2145"
            no_path_retry fail
        }
    }


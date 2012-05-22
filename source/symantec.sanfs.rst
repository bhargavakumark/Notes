Symantec : SanFS
================

.. contents::

Building SanFS (Linux)
----------------------

*     Use sanfs-cvs/b_linux1, vxfs-cvs/b_sanfs for the build.
*     top-level build does not work. the dependencies are shown below & you need to build according to that:
        *     sanfs server requires vzlib, vzdlmm
        *     vzdlmm requires vzlib
        *     sanfs client requires vzlib, vzdlmp, reusefs
        *     vzdlmp requires vzlib, reusefs (not sure about reusefs though)
        *     vzlib requires nothing.
        *     reusefs requires nothing.
        *     vzshowexports requires libvzsanfs
        *     mount requires nothing.
        *     libvzsanfs requires nothing

Testing
-------

Typically, here's what I need to do when the machine has just come up through a reboot:

On the server:
 
*     set -x
*     modprobe vxted
*     insmod vxfs.ko (built from vxfs-cvs/b_sanfs)
*     insmod vxportal.ko (ditto)
*     insmod SANFSsrv.ko (built from sanfs-cvs/b_linux1)
*     vxmount64 -F vxfs -o server <device> <mountpoint>

(note that the command exits with an error code but the mount systemcall has succeeded, have't figured out what's the problem yet; vxmount64 is the 64-bit version of the vxfs mount command - yes you need to use that, I STILL haven't gotten around to figure out what's the problem here).


On the Client:

*     set -x
*     modprobe vxted
*     insmod vzsanfs.ko (built from sanfs-cvs/b_linux1 & NOT from the tot).
*     mount -F vzsanfs <server>:<device> <mountpoint>
*     whatever tests you want to run.


Note:

    Use 64 bit versions of the utilities mkfs, mount etc. The 32-bit binaries are not working. Need to investigate.a



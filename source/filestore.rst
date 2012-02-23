FileStore
=========

.. contents::

Configure PXE install on SFS
----------------------------

::

    #!/bin/bash
    set -x
    mkdir /tmp/imagecontents
    mv /instserver /instserver_secondary
    mkdir /instserver
    mount -o loop /tmp/image.iso /tmp/imagecontents
    cp -a /tmp/imagecontents/* /instserver
    tar -C /tmp -cf /instserver/imagecontents.tar imagecontents
    umount /tmp/imagecontents
    set +x


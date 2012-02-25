iSCSI Initiator
===============

.. contents::

open-iscsi
----------

#. Initiator sends ping if there is not activity (READ/WRITE request being sent) on the connection for timeo.noop_out_interval seconds.
#. If we do not get a responce for the ping in noop_out_timeout seconds we fail the connection.
#. iscsi layer will try to relogin to the target.

  * If the command was running (it has not timed out and the scsi eh is not running) then the IO will be failed to the scsi layer and if it has retries left (so if it has been retried less than 5 times for disk IO) it will be queue in the block/scsi layer.
  * If the command had already timedout then it is sort of stuck in the scsi eh until we relogin or replacement_timeout fires. It will sit in there waiting for the outcome of relogin attempt.

#. After relogin attempt  

  * If we relogin within replacement_timeout seconds then IO will be restarted if the command had enough retries left.
  * If cannot relogin withing replacement_timeout seconds then the IO will be failed upwards (if you are using dm-multipath then it will handle the problem).



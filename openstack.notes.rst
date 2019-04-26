OpenStack
+++++++++

Installation
============
yum install deltarpm
http://www.tecmint.com/openstack-installation-guide-rhel-centos/

Links
=====

http://docs.openstack.org/juno/install-guide/install/yum/content/launch-instance-neutron.html
http://docs.openstack.org/image-guide/openstack-images.html
http://docs.amazonwebservices.com/AWSEC2/2009-04-04/UserGuide/AESDG-chapter-instancedata.html
http://cloudgeekz.com/71/how-to-setup-openstack-to-use-local-disks-for-instances.html
Raksha Backup - https://wiki.openstack.org/wiki/Raksha
IBM Cinder Driver - http://docs.openstack.org/juno/config-reference/content/ibm-storwize-svc-driver.html
Multiple Storage backends - https://ask.openstack.org/en/question/52776/iscsi-target-not-provisioned/
Multiple Storage backends - http://docs.openstack.org/admin-guide/blockstorage-multi-backend.html
NFS backend - http://docs.openstack.org/admin-guide/blockstorage-nfs-backend.html


Services
========
Dashboard           : Horizon
Compute             : Nova
Networking          : Neutron
Object Storage      : Swift
Block Storage       : Cinder
Identity Service    : Keystone
Image Service       : Glance
Telemetry           : Ceilometer
Orchestration       : Heat
Database Service    : Trove

Cinder Volume Group
===================

* Attach another disk and create **cinder-volumes** VG if it does not exist

::

    vgcreate cinder-volumes /dev/sdf1

LIO - for iSCSI Target
======================


LVM
===

* Bringing an existing filesystem under LVM2 control - https://www.redhat.com/archives/linux-lvm/2006-June/msg00001.html

Block Device Driver
===================

* https://wiki.openstack.org/wiki/BlockDeviceDriver
** Does not have an option to specify the device while creating the driver, and also does not have the option to dynamically add the devices. You have to edit the list of devices in /etc/cinder/cinder.conf and do systemctl restart openstack-cinder-volume
* https://blueprints.launchpad.net/fuel/+spec/cinder-block-device-driver
* https://fossies.org/dox/cinder-2015.1.4/classcinder_1_1volume_1_1drivers_1_1block__device_1_1BlockDeviceDriver.html
* Cinder Support Matrix - https://wiki.openstack.org/wiki/CinderSupportMatrix

::

    #  Edit cinder.conf

    enabled_backends = lvm,raw

    [raw]
    available_devices='/dev/sdf'
    volume_driver=cinder.volume.drivers.block_device.BlockDeviceDriver
    volume_backend_name=raw


    $ cinder type-create raw
    $ cinder type-key raw set volume_backend_name=raw

Python Source
=============

/usr/lib/python2.7/site-packages/cinder

To change cmd/volume.py

::

    cd /usr/lib/python2.7/site-packages/cinder/cmd

    # Edit volume.py

    python -m compileall .



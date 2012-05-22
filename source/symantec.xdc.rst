Symantec : XDC
==============

.. contents::

Server Pools
------------
Server Pools define the physical systems which form a boundary to which virtual machines could be migrated (similar to cluster). Each pool has one volume server. Each node has a volume client. Full storage connectivity to all the nodes.

VSS
---
Volume shadow copy services. A framework provided by microsoft. Snapshost applications can integrate with VSS to provide consistent snapshots for exchange server and SQL server.

Live Migration
--------------
A volume that is used by a virtual machine is owned by the volume client on that node. During migration the volume client on the old host machine releases thevolume and the volume client on the new desitnation physical server acquires the volume.

XDC Storage model
-----------------
Xen storage manager provides a API which volume managers has to support for functioning with XDC.

Storage Objects in Xen
----------------------

*   Virtual Block device

   *    virtual LUN visible and accessible to guest OS. 

*   Virtual Disk Image

   *    Object representing the phyiscal or virtual storage (volume) providing backing store for Vritual Block Device. 

*   Storage Repository

   *    Group of physical devices, which when used with VxVM would be called as Diskgroup. 

Central Server
--------------
Central server is a virtual machine per pool. It acts as Authentication Broker and Database Server. Its a linux guest.

xptrld
------
It runs of central server and Dom0 and on all instances of guest OS. It is a ligh-weight http server.

Managed Host
Managed host is the managed virtual mahcine. It has Agentlets which is used for storage managers to discover objects or applicationss in the virtual machine. It also hosts DCLI which provides a CLI to do various administrative tasks in the virtual machine. It hosts XDC Reporter, which sends updates to the storage manager about the changes int the virtual machine. Management Scripts that could be executed from the storage manager to do operations on the virtual mahine. It hosts VRTSat for authentication.

DCLI (Windows Guest CLI)
------------------------
CLI is provided in the guest to discover LUNs used and applications running in the virtual machine. It provides CLI to take snapshots from inside the virtual machine. Also Scheduler CLIs.

VSS Plug-in
-----------
It contains 2 components

*    Requestor - which starts the process of creating a snapshot, by using VSS API provided by windows to get a consistent state.
*    Provider - is a hardware snapshot provider. It communicates with Dom0 for creating volume snapshot.


SCSI Provision
--------------
Each of the virtual LUNs observed by guest OS are visible to the guest OSes as SCSI devices. These SCSI devices only support a limited number of commands. THese SCSI devices do not support SCSI Reservations. Certain features such as Vxfen do not work on these devices.


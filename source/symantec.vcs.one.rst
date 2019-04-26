Symantec : VCS One
==================

.. contents::

AWM - Advanced Workload Management
----------------------------------
Groups dependencies are specified as group compatability defintion.

Load defiintions are now defined in terms of CPU load, network load, memory load.

Groups have priorities. Higher priority groups could kick out lower priority groups which if the higher priority group have no where eles to login.

Group transistion queue
-----------------------
Is a queue which maintains all the groups that are waiting to be onlined. When a group is kicked out of higher priority queue the group gets added into this GTQ. GTQ can be viewed and its entries can deleted. Its a priority based queue.

Admin Privilege model
---------------------
Admin privilege model has been changed to use a hierarchial organisational tree.

VAL (Virtualisation Abstaction Layer)
-------------------------------------
Ensures HA for virtual machines and applications running in the VMs. VAL can discover what are VMs configured, and what are the applications running in the VMs. Supports prioritisation of VMs. Usecase is only one application is running in one ~VM. The purpose of the VM is to run the application, if the application goes down the VM is restarted to see if the application comes back online. VAL allows adaptive allocation of resources to VMs.

Supports only vmware virtualisation as of now.

Uses the vmware virtual centre to extract configuration information about the VMs and on which physical machines these VMs can be run.

Data centres can be configured inside virtual centre. VMs can only be failed over onto physical machines in the same data centre.

Frames
------
Objects in a virtual environement are classified into frames. 3 types of frame objects

*    physical frame (ex. ESX Server, PSeries ManagedServer)
*    virtual frame (ex. ESX virtual machine, IBM LPAR)
*    Management Server Frame (ex. Vmware Virtual Centre / IBM HMC)


Physical frames have a capacity attribute that needs to be configured by the user. This capacity is shared amonng the virtual machine frames running on it.

VAD system
----------
A VAD system object is a system which is running VAD client.

A virtual frame may or may not be linked to a VAD system object. If the virtual frame is linked to a VAD system object, the capacity of the VFrame is derived from the load of groups configured to run on the linked VAD system. In case, VFrame is not linked to a VAD system, user can configure the capacity attribute of a VFrame.


A VAD system is a failover destination for applications.

If a VFrame is not linked to a VAD system, it means the VFrame needs to be HA, and the user does not want VAD to maange the applications inside the VFrame, i.e VAD has to manage VFrame for HA and not the applications inside the VM. Similarly we can have a VAD system not linked to a VFrame. In this case the user does not care about HA of VFrame but only needs HA for the applications.

Each PFrame would also have VAD client running on it. It monitors various resources on that PFrame.

There is a hidden group associated with each VFrame, and hidden VAD system associated with PFrame.

A VFrame priority is the highest priority of all the groups configured to run in this VFrame.

Internal Object List
--------------------
InternalObjectList attribute contains hidden objects associated with the frame. For PFrames, the InternalObjectList contains a VAD system_name and a group_name. For VFrames, the InternalObjectList contains group_name of the group whicc is monitoring this VFrame only.

Final Virtual Machine HA
------------------------
Virtual machine HA is supported for both VMware and Xen. The physical servers need to install VAD client on them to be monitored. The virtual machines are monitored using VAD groups configured on these physical servers. The system associated with PFrame and group associated with VFrame are hidden to the user.

Frame State
-----------
For PFrames the state attribute reflects the name and state of the hidden system. For VFrames, the state attribute reflects the names and states of the hidden group on all PFrames. 


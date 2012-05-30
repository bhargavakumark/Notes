Tech : VMware
=============

.. contents::

shift,alt,ctrl,caps lock keys stop working
------------------------------------------
if shift,alt,ctrl,caps lock keys stop working run

::

        # setxkbmap

on any terminal in X sessiona

Configure Shared Disk Resources
-------------------------------
The way to spoof your virtual machines into believing that they have 
access to shared disk resources. In my quest for clustering I found 
two resources on this, one was hideously outdated - but contained 
enough theory to help me out, The other was for version 4.5x and was 
missing one critical piece of data that is apparently now needed in 
VMWare Workstation 5.0. The key concepts here are that you just need 
to create SCSI controllers on both machines, and then provide 
directives that tell VMWare NOT to lock the disks when they are 
connected. This lets machines share disks, as long as all of the 
SCSI connection info is configured correctly. From there you just 
need to, obviously, make sure that the disks aren't busy trying to 
dynamically allocate size; i.e. the disks have to be fixed or each 
VM will see a different size, state, etc.

The first thing you need to do is create some drives that you'll hook 
up to your machines. The best way to do this is to just create them 
with the wizard by 'adding' them to one of your machines, and then 
immediately removing them. Think of it as a 
virtual-hard-drive-egg-laying-chicken (or just think of it as a way 
to make virtual hard drives, if that's easier). To Proceed:

*    Open up one of your VMs and Select VM | Settings from the menu. To add the drives just click Add and use the Wizard.
*    The first drive will be your Quorum drive, and just needs to be a few hundred MB (200 MB will work fine - or .2GB).
*    The wizard steps are as follows: Create a new virtual disk. Next. SCSI. Next. Disk Size = .x GB Then ensure that Allocate all disk space now is checked. Click Next. Browse out and drop the disks in a directory called SharedDisks (or something). And click the Advanced button. Make sure that Independent is checked. Then click Finish.
*    Create as many disks as you want
*    Then select each drive, and Remove it in the Hardware management thingy. We just needed to MAKE Hard Drives, we don't want to add them just now. (You'll add them by hand to the machines in a second.)


Attaching Shared Disks
----------------------
Add your virtual shared drives to the boxes by hand. Now that the 
drives are sized and created, it's time to head to the virtual 
server rack and hook up some virtual SCSI controllers.

*    Navigate to the directories where your Virtual Machines are kept, and for Server 1 open the .vmx file in NotePad.
*    First add some instructions for disk control, and to make sure that the VM won't attempt to lock the drives it connects to:

::

    # Shared Disk Config Info:
      diskLib.dataCacheMaxSize = " 0"
      diskLib.dataCacheMaxReadAheadSize = " 0"
      diskLib.dataCacheMinReadAheadSize = "0" 
      diskLib.dataCachePageSize = "4096"
      diskLib.maxUnsyncedWrites = "0" 
      disk.locking = "FALSE"


*    Then add a new SCSI controller:

::

      scsi1.present = "TRUE"
      scsi1.virtualDev = "lsilogic"
      scsi1.sharedBus = "virtua" 


*    Once that's done, add your Quorum Drive (making sure to specify that the drive itself uses the lsilogic bus (this was the big missing component between Karl's post for 4.5x and 5.0. I found this out by trial and error):

::

      scsi1:1.present = "TRUE"
      scsi1:1.fileName = "\Quorum.vmdk"
      scsi1:1.redo = ""
      scsi1:1.mode = "independent-persistent"
      scsi1:1.deviceType = "disk"
      scsi1:1.virtualDev = "lsilogic"


*     Once the first controller and drive is added, just add the second SCSI controller and disk (making sure to change your paths, etc.:

::

      scsi1:2.present = "TRUE"
      scsi1:2.fileName = "\Resource.vmdk"
      scsi1:2.virtualDev = "lsilogic"
      scsi1:2.redo = ""
      scsi1:2.mode = "independent-persistent"
      scsi1:2.deviceType = "disk"


*     The entire 'snippet' to copy/paste is here:

::

      # Shared Disk Config Info:
      diskLib.dataCacheMaxSize = "0"
      diskLib.dataCacheMaxReadAheadSize = "0"
      diskLib.dataCacheMinReadAheadSize = "0"
      diskLib.dataCachePageSize = "4096"
      diskLib.maxUnsyncedWrites = "0"
      disk.locking = "FALSE"

      scsi1.present = "TRUE"
      scsi1.virtualDev = "lsilogic"
      scsi1.sharedBus = "virtual"
      scsi1:1.present = "TRUE"
      scsi1:1.fileName = "\Quorum.vmdk"
      scsi1:1.redo = ""
      scsi1:1.mode = "independent-persistent"
      scsi1:1.deviceType = "disk"
      scsi1:1.virtualDev = "lsilogic"

      scsi1:2.present = "TRUE"
      scsi1:2.fileName = "\Resource.vmdk"
      scsi1:2.virtualDev = "lsilogic"
      scsi1:2.redo = ""
      scsi1:2.mode = "independent-persistent"
      scsi1:2.deviceType = "disk"

Make sure, of course, that you specify the full path to your shared Drives directory.

Ensure Drive connectivity from both Servers
-------------------------------------------

*    Power down BOTH of your server nodes.
*    Power up BOTH of your server nodes
*    You should see your new drives available


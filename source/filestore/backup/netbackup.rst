NetBackup
=========

.. contents::

NetBackup Accelerator
---------------------

* The increase in speed is made possible by change detection techniques on the client.
* The client sends the changed data to the media server in a more efficient backup stream. The media server combines the changed data with the rest of the client's data that is stored in previous backups to create a new full backup image without needing to transfer all the client data.

**Note that tape, AdvancedDisk and BasicDisk storage are not supported with this feature.**

-----------------------
Use Cases or Advantages
-----------------------
* Large file systems because only changed files are backed up
* Windows file systems because NTFS change journal removes need to enumerate the file system
* Using NFS or CIFS (vs. remote NDMP) to backup NAS filers because only changed files are backed up for Accelerator full backups

---------------------
Underlying Principles
---------------------

#. Change journaling/change logging is used to rapidly identify the files which have changed since the last backup.

        * NetBackup Accelerator uses track logs on the client and reconciles 
          these to the current file system state to determine the changes 
          since the last backup. In NetBackup 7.5 it can also utilize the 
          Windows NTFS Change Journaling to track changes on NTFS file systems.

#. Where available, client side deduplication can be used in combination with NetBackup Accelerator to further reduce the amount of data sent over the network.
#. Once the changed data is received by the backup storage an optimized synthetic full backup is automatically created

**NetBackup Accelerator should be regarded as a complimentary technology of client deduplication, not replacement for it**

--------------------
Policy Configuration
--------------------

* Standard operating mode for both Windows and UNIX clients is achieved by 
  selecting the Use accelerator option on the backup policy Attributes tab. 
  With this option selected the client track log is used to identify changes 
  to the file system between backups.
* Windows clients can also optionally use the Windows NTFS Change Journal. 
  Using the change journal speeds the discovery process because the track 
  log is matched to the change journal rather than the file system directly. 
  This setting requires the Use Change Journal option under 
  **Host Properties > Clients > Windows Client > Client Settings.**
* For both Windows and UNIX clients, an additional type of change detection 
  is available. This setting requires the Accelerator forced rescan option 
  on the policy Schedules tab. This option checksums the content of each 
  file during backup and uses the checksums for change detection. It 
  establishes a new baseline for the next Accelerator backup. This option 
  results in a slower backup than the standard mode and can be used 
  periodically (for example on a monthly full backup schedule) to create a 
  new base line for the track log.

**Note**: Setting the Collect **true image recovery information** option on a 
backup policy prevents backups from that policy using Windows NTFS 
Change Journal feature even if the* **Use Change Journal** option is set on the 
client.

Licensing
---------

* NetBackup Accelerator functionality is included in the new NetBackup Data Protection Optimization Option. This option replaces the NetBackup Deduplication Option and the Deduplication Add-on Option for the platform license and is available free of charge to customers licensed for those options, however customers will need to request a new license key to activate the Accelerator component.

Troubleshooting/Debugging
-------------------------

------------------------
How to set VERBOSE level
------------------------

In Unix environments, edit **/usr/openv/netbackup/bp.conf** and add the following lines. Valid values for VERBOSE are 0-5 and 99.

::
	
	VERBOSE = 5

In Windows environments, In **Host Properties** change the log level to 5, regedit **\\HKEY_LOCAL_MACHINE\SOFTWARE\VERITAS\NetBackup\CurrentVersion\Config**, change **VERSION** to 9 or 10


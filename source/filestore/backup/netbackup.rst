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

Deduplication
-------------

What algorithm/compression scheme is used by PureDisk for fingerprinting?
        PureDisk 6.x uses a MD5 hash algorithm to calculate the file and segment fingerprints.  The MD5 hash calculation creates a 128 bit fingerprint. This fingerprint provides 2^128 unique combinations. That is 340,282,366,920,938,000,000,000,000,000,000,000,000 or over 340 x 10^36 unique combinations. PureDisk 6.2 adds another layer of protection on top of the MD5 data identification. PureDisk 6.2 detects potential MD5 data collisions using a second hash on the segment data. The combination of two hashes results in a new fingerprint that is neither MD5 nor SHA-x.  The combined hash virtually eliminates the chance of a collision and effectively protects the system against artificially generated MD5 collision files.

Some information on Fingerprint used in PD/MSDP:
PD / PDDE hash is MD5 based but not plain MD5.
E.g. compute PD hash of segment S:

*       Extend S by appending CRC of S to the content of S.
*       Compute MD5 of extended S
*       Resulting hash is different from the MD5 of extended S.
*       Main benefit: MD5 collision protection

Suppose that two files have different content but the same MD5. This is an MD5 collision.

*       In NBU Dedupe, these two files will receive a different fingerprint. No collision in NBU Dedupe !

Does this mean that NBU Dedupe is completely collision proof?

*       No! Any hash based approach has a risk of collisions. Possibility is very remote.
*       But the PD hash function moves the possible collisions to an area for which there are no known exploits (contrary to plain MD5).

Secondary benefit:

*       Still MD5 based and therefore computationally efficient + only 16 bytes wide.

NetBackup WAN Optimisation
--------------------------

WAN optimization is a type of Congestion Control technology.  Itâs like a network filter driver that dynamically shapes network throughput to minimize TCP connection failures due to network congestion, and allowing for better WAN utilization and throughput.  This is great for customers with remote sites.

The technology is entirely heuristic-based, so there is no tuning or configuration of the function â itâs either enabled or disabled.

This feature optimizes outbound TCP traffic for each TCP connection.  Where traffic canât be optimized, the heuristic logic disengages so that this function will not degrade network performance. 

WAN optimization will improve throughput when:

*  Latency is greater than 20 msecs
*  Packet loss is greater than 0.01% (1 in 10,000 packets) for metro area networks (networks > 100 Mb/sec)
*  Packet loss is greater than 0.1% (1 in 1,000 packets) for wide area networks (networks < 100 Mb/sec)



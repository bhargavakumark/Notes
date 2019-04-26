EMC
===

.. contents::

Avamar NDMP Accelerator
-----------------------

**NAS backup data deduplication (NDMP Stream Handler)**
        For NAS environments, Avamar deduplicates NDMP backup data streams at the Avamar NDMP
        Accelerator node. By comparing sub-file data segments to those already stored on a central Avamar
        Data Store, only new and unique segments are transferred during daily full backups via IP LAN/WAN
        links. This method reduces the size of backup data before it is transferred to the Avamar Data Store. As a
        result, users continue to leverage existing IP LAN/WAN connectivity for data protection and achieve a
        dramatic reduction in backup completion times.

**Daily full backups (Optimised Synthetics)**
        A full (level-0) NAS backup is performed only once during the initial setup of the Avamar NDMP
        Accelerator node. Subsequent daily backups only request level-1 incremental dumps from the NAS
        systems. Avamar’s technology deduplicates the backup data and also creates daily full backup images
        that can be recovered in one-step. Avamar eliminates the need for recurring, lengthy level-0 full backups
        and the tedious process of restoring from the last good full plus subsequent incremental backups to
        reach the desired recovery point.

**Daily replication for disaster recovery (AIR - Auto Image Replication)** 
        Avamar also enables encrypted, asynchronous replication of data stored in an Avamar server to another
        Avamar server deployed in a remote location, eliminating the need to ship tapes. Replication can be
        scheduled to run at off-peak hours to minimize network impact. In the event of a disaster scenario
        where an Avamar system becomes unavailable, data can be recovered directly from the replication
        target, providing a high level of availability.



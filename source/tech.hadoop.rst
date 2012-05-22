Tech : Hadoop
=============

.. contents::

References
----------

Hadoop file system, paper by Shvachko

Intro
-----

Hadoop provides a distributed file system and a
framework for the analysis and transformation of very large
data sets using the MapReduce paradigm.

An important
characteristic of Hadoop is the partitioning of data and compu-
tation across many (thousands) of hosts, and executing applica-
tion computations in parallel close to their data. A Hadoop
cluster scales computation capacity, storage capacity and IO
bandwidth by simply adding commodity servers.

=========	====================================================
Term		Meaning
=========	====================================================
HDFS		Distributed file system
MapReduce	Distributed computation framework
HBase		Column-oriented table service
Pig		Dataflow language and parallel execution framework
Hive		Distributed coordination service
Chukwa		System for collecting management data
Avro		Data serialization system
=========	====================================================


HDFS stores file system metadata and application data
separately. As in other distributed file systems, like PVFS,
Lustre and GFS, HDFS stores metadata on a
dedicated server, called the NameNode. Application data are
stored on other servers called DataNodes. All servers are fully
connected and communicate with each other using TCP-based
protocols.

Unlike Lustre and PVFS, the DataNodes in HDFS do not
use data protection mechanisms such as RAID to make the data
durable. Instead, like GFS, the file content is replicated on mul-
tiple DataNodes for reliability. While ensuring data durability,
this strategy has the added advantage that data transfer band-
width is multiplied, and there are more opportunities for locat-
ing computation near the needed data.


Ceph has a
cluster of namespace servers (MDS) and uses a dynamic sub-
tree partitioning algorithm in order to map the namespace tree
to MDSs evenly. GFS is also evolving into a distributed name-
space implementation. The new GFS will have hundreds of
namespace servers (masters) with 100 million files per master.
Lustre has an implementation of clustered namespace on its
roadmap for Lustre 2.2 release. The intent is to stripe a direc-
tory over multiple metadata servers (MDS), each of which con-
tains a disjoint portion of the namespace. A file is assigned to a
particular MDS using a hash function on the file name.


NameNode
--------

The file
content is split into large blocks (typically 128 megabytes, but
user selectable file-by-file) and each block of the file is inde-
pendently replicated at multiple DataNodes (typically three, but
user selectable file-by-file). The NameNode maintains the
namespace tree and the mapping of file blocks to DataNodes
(the physical location of file data)

When writing data, the cli-
ent requests the NameNode to nominate a suite of three
DataNodes to host the block replicas. The client then writes
data to the DataNodes in a pipeline fashion.

HDFS keeps the entire namespace in RAM. The inode data
and the list of blocks belonging to each file comprise the meta-
data of the name system called the image. The persistent record
of the image stored in the local host’s native files system is
called a checkpoint. The NameNode also stores the modifica-
tion log of the image called the journal in the local host’s na-
tive file system. For improved durability, redundant copies of
the checkpoint and journal can be made at other servers. Dur-
ing restarts the NameNode restores the namespace by reading
the namespace and replaying the journal. The locations of
block replicas may change over time and are not part of the
persistent checkpoint.


DataNode
--------

Each block replica on a DataNode is represented by two
files in the local host’s native file system. The first file contains
the data itself and the second file is block’s metadata including
checksums for the block data and the block’s generation stamp.

The namespace ID is assigned to the file system instance
when it is formatted. The namespace ID is persistently stored
on all nodes of the cluster. Nodes with a different namespace
ID will not be able to join the cluster, thus preserving the integ-
rity of the file system.

A DataNode that is newly initialized and without any
namespace ID is permitted to join the cluster and receive the
cluster’s namespace ID.

DataNodes persistently store their unique storage
IDs. The storage ID is an internal identifier of the DataNode,
which makes it recognizable even if it is restarted with a differ-
ent IP address or port.

A DataNode identifies block replicas in its possession to the
NameNode by sending a block report. A block report contains
the block id, the generation stamp and the length for each block
replica the server hosts. The first block report is sent immedi-
ately after the DataNode registration. Subsequent block reports
are sent every hour and provide the NameNode with an up-to-
date view of where block replicas are located on the cluster.


Heartbeats from a DataNode also carry information about
total storage capacity, fraction of storage in use, and the num-
ber of data transfers currently in progress. These statistics are
used for the NameNode’s space allocation and load balancing
decisions.


The NameNode does not directly call DataNodes. It uses
replies to heartbeats to send instructions to the DataNodes. The
instructions include commands to:

* replicate blocks to other nodes;
* remove local block replicas;
* re-register or to shut down the node;
* send an immediate block report.

The NameNode can process
thousands of heartbeats per second without affecting other
NameNode operations.

HDFS Client
-----------

When an application reads a file, the HDFS client first asks
the NameNode for the list of DataNodes that host replicas of
the blocks of the file. It then contacts a DataNode directly and
requests the transfer of the desired block.


When a client writes,
it first asks the NameNode to choose DataNodes to host repli-
cas of the first block of the file. The client organizes a pipeline
from node-to-node and sends the data. When the first block is
filled, the client requests new DataNodes to be chosen to host
replicas of the next block. A new pipeline is organized, and the
client sends the further bytes of the file.

Unlike conventional file systems, HDFS provides an API
that exposes the locations of a file blocks. This allows applica-
tions like the MapReduce framework to schedule a task to
where the data are located, thus improving the read perform-
ance.

Image and Journal
-----------------
The namespace image is the file system metadata that de-
scribes the organization of application data as directories and
files. A persistent record of the image written to disk is called a
checkpoint. The journal is a write-ahead commit log for
changes to the file system that must be persistent. For each
client-initiated transaction, the change is recorded in the jour-
nal, and the journal file is flushed and synched before the
change is committed to the HDFS client. The checkpoint file is
never changed by the NameNode; it is replaced in its entirety
when a new checkpoint is created during restart, when re-
quested by the administrator, or by the CheckpointNode

During startup the NameNode ini-
tializes the namespace image from the checkpoint, and then
replays changes from the journal until the image is up-to-date
with the last state of the file system. A new checkpoint and
empty journal are written back to the storage directories before
the NameNode starts serving clients

HDFS can
be configured to store the checkpoint and journal in multiple
storage directories.

Saving a trans-
action to disk becomes a bottleneck since all other threads need
to wait until the synchronous flush-and-sync procedure initi-
ated by one of them is complete. In order to optimize this
process the NameNode batches multiple transactions initiated
by different clients. When one of the NameNode’s threads ini-
tiates a flush-and-sync operation, all transactions batched at
that time are committed together. Remaining threads only need
to check that their transactions have been saved and do not
need to initiate a flush-and-sync operation.


CheckpointNode
--------------

The NameNode in HDFS, in addition to its primary role
serving client requests, can alternatively execute either of two
other roles, either a CheckpointNode or a BackupNode.

The CheckpointNode periodically combines the existing
checkpoint and journal to create a new checkpoint and an
empty journal. The CheckpointNode usually runs on a different
host from the NameNode since it has the same memory re-
quirements as the NameNode. It downloads the current check-
point and journal files from the NameNode, merges them lo-
cally, and returns the new checkpoint back to the NameNode.

Creating a checkpoint lets the NameNode truncate the tail
of the journal when the new checkpoint is uploaded to the
NameNode.

BackupNode
----------
A recently introduced feature of HDFS is the BackupNode.
Like a CheckpointNode, the BackupNode is capable of creating
periodic checkpoints, but in addition it maintains an in-
memory, up-to-date image of the file system namespace that is
always synchronized with the state of the NameNode.

The BackupNode accepts the journal stream of namespace
transactions from the active NameNode, saves them to its own
storage directories, and applies these transactions to its own
namespace image in memory. The NameNode treats the
BackupNode as a journal store the same as it treats journal files
in its storage directories. If the NameNode fails, the
BackupNode’s image in memory and the checkpoint on disk is
a record of the latest namespace state.

Use of a BackupNode pro-
vides the option of running the NameNode without persistent
storage, delegating responsibility for the namespace state per-
sisting to the BackupNode.

File System Snapshots
---------------------

The snapshot mechanism lets administrators persistently
save the current state of the file system

The snapshot (only one can exist) is created at the cluster
administrator’s option whenever the system is started. If a
snapshot is requested, the NameNode first reads the checkpoint
and journal files and merges them in memory. Then it writes
the new checkpoint and the empty journal to a new location, so
that the old checkpoint and journal remain unchanged.

During handshake the NameNode instructs DataNodes
whether to create a local snapshot. The local snapshot on the
DataNode cannot be created by replicating the data files direc-
tories as this will require doubling the storage capacity of every
DataNode on the cluster. Instead each DataNode creates a copy
of the storage directory and hard links existing block files into
it. When the DataNode removes a block it removes only the
hard link, and block modifications during appends use the
copy-on-write technique. Thus old block replicas remain un-
touched in their old directories.

File Read and Write
-------------------

After the file is closed, the bytes writ-
ten cannot be altered or removed except that new data can be
added to the file by reopening the file for append. HDFS im-
plements a single-writer, multiple-reader model.

The HDFS client that opens a file for writing is granted a
lease for the file; no other client can write to the file. The writ-
ing client periodically renews the lease by sending a heartbeat
to the NameNode. When the file is closed, the lease is revoked.

The lease duration is bound by a soft limit and a hard limit.
Until the soft limit expires, the writer is certain of exclusive
access to the file. If the soft limit expires and the client fails to
close the file or renew the lease, another client can preempt the
lease. If after the hard limit expires (one hour) and the client
has failed to renew the lease, HDFS assumes that the client has
quit and will automatically close the file on behalf of the writer,
and recover the lease. The writer's lease does not prevent other
clients from reading the file; a file may have many concurrent
readers.

An HDFS file consists of blocks. When there is a need for a
new block, the NameNode allocates a block with a unique
block ID and determines a list of DataNodes to host replicas of
the block. The DataNodes form a pipeline, the order of which
minimizes the total network distance from the client to the last
DataNode. Bytes are pushed to the pipeline as a sequence of
packets. The bytes that an application writes first buffer at the
client side. After a packet buffer is filled (typically 64 KB), the
data are pushed to the pipeline. The next packet can be pushed
to the pipeline before receiving the acknowledgement for the
previous packets.

After data are written to an HDFS file, HDFS does not pro-
vide any guarantee that data are visible to a new reader until the
file is closed. If a user application needs the visibility guaran-
tee, it can explicitly call the hflush operation. Then the current
packet is immediately pushed to the pipeline, and the hflush
operation will wait until all DataNodes in the pipeline ac-
knowledge the successful transmission of the packet.

When a client creates an HDFS file, it computes the checksum
sequence for each block and sends it to a DataNode along with
the data. A DataNode stores checksums in a metadata file sepa-
rate from the block’s data file. When HDFS reads a file, each
block’s data and checksums are shipped to the client. The client
computes the checksum for the received data and verifies that
the newly computed checksums matches the checksums it re-
ceived. If not, the client notifies the NameNode of the corrupt
replica and then fetches a different replica of the block from
another DataNode.

When a client opens a file to read, it fetches the list of
blocks and the locations of each block replica from the
NameNode. The locations of each block are ordered by their
distance from the reader. When reading the content of a block,
the client tries the closest replica first.

The design of HDFS I/O is particularly optimized for batch
processing systems, like MapReduce, which require high
throughput for sequential reads and writes. However, many
efforts have been put to improve its read/write response time in
order to support applications like Scribe that provide real-time
data streaming to HDFS, or HBase that provides random, real-
time access to large tables.

Block Placement
---------------

HDFS allows an administrator to configure a script that re-
turns a node’s rack identification given a node’s address. The
NameNode is the central place that resolves the rack location of
each DataNode. When a DataNode registers with the
NameNode, the NameNode runs a configured script to decide
which rack the node belongs to. If no such a script is config-
ured, the NameNode assumes that all the nodes belong to a
default single rack

When a new block is created, HDFS places the first replica on
the node where the writer is located, the second and the third
replicas on two different nodes in a different rack, and the rest
are placed on random nodes with restrictions that no more than
one replica is placed at one node and no more than two replicas
are placed in the same rack when the number of replicas is less
than twice the number of racks


After all target nodes are selected, nodes are organized as a
pipeline in the order of their proximity to the first replica. Data
are pushed to nodes in this order


For reading, the NameNode
first checks if the client’s host is located in the cluster. If yes,
block locations are returned to the client in the order of its
closeness to the reader

Replication management
----------------------

The NameNode detects
that a block has become under- or over-replicated when a block
report from a DataNode arrives. When a block becomes over
replicated, the NameNode chooses a replica to remove.


When a block becomes under-replicated, it is put in the rep-
lication priority queue. A block with only one replica has the
highest priority, while a block with a number of replicas that is
greater than two thirds of its replication factor has the lowest
priority. A background thread periodically scans the head of the
replication queue to decide where to place new replicas. Block
replication follows a similar policy as that of the new block
placement.

If the NameNode detects that a
block’s replicas end up at one rack, the NameNode treats the
block as under-replicated and replicates the block to a different
rack using the same block placement policy described above.
After the NameNode receives the notification that the replica is
created, the block becomes over-replicated. The NameNode
then will decides to remove an old replica because the over-
replication policy prefers not to reduce the number of racks

Balancer
--------

HDFS block placement strategy does not take into account
DataNode disk space utilization. This is to avoid placing
new—more likely to be referenced—data at a small subset of
the DataNodes

The balancer is a tool that balances disk space usage on an
HDFS cluster. It takes a threshold value as an input parameter,
which is a fraction in the range of (0, 1). A cluster is balanced
if for each DataNode, the utilization of the node (ratio of used
space at the node to total capacity of the node) differs from the
utilization of the whole cluster (ratio of used space in the clus-
ter to total capacity of the cluster) by no more than the thresh-
old value.

The tool is deployed as an application program that can be
run by the cluster administrator. It iteratively moves replicas
from DataNodes with higher utilization to DataNodes with
lower utilization. One key requirement for the balancer is to
maintain data availability. When choosing a replica to move
and deciding its destination, the balancer guarantees that the
decision does not reduce either the number of replicas or the
number of racks.

Block Scanner
-------------

Each DataNode runs a block scanner that periodically scans
its block replicas and verifies that stored checksums match the
block data. In each scan period, the block scanner adjusts the
read bandwidth in order to complete the verification in a con-
figurable period

Whenever a read client or a block scanner detects a corrupt
block, it notifies the NameNode. The NameNode marks the
replica as corrupt, but does not schedule deletion of the replica
immediately. Instead, it starts to replicate a good copy of the
block. Only when the good replica count reaches the replication
factor of the block the corrupt replica is scheduled to be re-
moved. This policy aims to preserve data as long as possible.
So even if all replicas of a block are corrupt, the policy allows
the user to retrieve its data from the corrupt replicas

Inter-Cluster Data Copy
-----------------------

HDFS provides a tool called
DistCp for large inter/intra-cluster parallel copying. It is a
MapReduce job; each of the map tasks copies a portion of the
source data into the destination file system. The MapReduce
framework automatically handles parallel task scheduling, error
detection and recovery



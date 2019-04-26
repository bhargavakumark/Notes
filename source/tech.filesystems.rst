Tech : FileSystems/Clustering
=============================

List of file systems 
	https://en.wikipedia.org/wiki/List_of_file_systems

**PVFS** : 
	https://en.wikipedia.org/wiki/Parallel_Virtual_File_System

**GPFS** : General Parallel File System (GPFS) is a high-performance shared-disk clustered file system 
	https://en.wikipedia.org/wiki/IBM_General_Parallel_File_System

**Beowulf Cluster** :
	A Beowulf cluster is a computer cluster of what are normally identical, commodity-grade computers networked into a small local area network with libraries and programs installed which allow processing to be shared among them. The result is a high-performance parallel computing cluster from inexpensive personal computer hardware.

	The name Beowulf originally referred to a specific computer built in 1994 by Thomas Sterling and Donald Becker at NASA. The name comes from the main character in the Old English epic poem Beowulf, which was bestowed by Sterling because the eponymous hero is described as having "thirty mens' heft of grasp in the grip of his hand".

	There is no particular piece of software that defines a cluster as a Beowulf.

	Beowulf is not a special software package, new network topology, or the latest kernel hack. Beowulf is a technology of clustering computers to form a parallel, virtual supercomputer. Although there are many software packages such as kernel modifications, PVM and MPI libraries, and configuration tools which make the Beowulf architecture faster, easier to configure, and much more usable, one can build a Beowulf class machine using standard Linux distribution without any additional software. If you have two networked computers which share at least the /home file system via NFS, and trust each other to execute remote shells (rsh), then it could be argued that you have a simple, two node Beowulf machine.

**Hadoop** :
	https://en.wikipedia.org/wiki/Apache_Hadoop

	Hadoop provides a distributed file system and a
	framework for the analysis and transformation of very large
	data sets using the MapReduce paradigm.

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


**Google File System (GFS or GoogleFS)**
	https://en.wikipedia.org/wiki/Google_File_System	

	is a proprietary distributed file system developed by Google Inc.

	Google File System grew out of an earlier Google effort, "BigFiles", developed by Larry Page and Sergey Brin in the early days of Google, while it was still located in Stanford.[3] Files are divided into fixed-size chunks of 64 megabytes,[4] similar to clusters or sectors in regular file systems, which are only extremely rarely overwritten, or shrunk; files are usually appended to or read. It is also designed and optimized to run on Google's computing clusters, dense nodes which consist of cheap, "commodity" computers

	GFS cluster consists of multiple nodes.These nodes are divided into two types: one Master node and a large number of Chunkservers. Each file is divided into fixed-size chunks. Chunkservers store these chunks. Each chunk is assigned a unique 64-bit label by the master node at the time of creation, and logical mappings of files to constituent chunks are maintained. Each chunk is replicated several times throughout the network, with the minimum being three, but even more for files that have high end-in demand or need more redundancy.

	Permissions for modifications are handled by a system of time-limited, expiring **leases**

	As opposed to other file systems, GFS is **not implemented in the kernel** of an operating system, but is instead provided as a **userspace library**.


**BigTable**
	https://en.wikipedia.org/wiki/BigTable

	BigTable is a compressed, high performance, and proprietary data storage system built on Google File System, Chubby Lock Service, SSTable and a few other Google technologies. It is not distributed outside Google, although Google offers access to it as part of its Google App Engine.	


**CloudStore**
	https://en.wikipedia.org/wiki/CloudStore

	CloudStore (KFS, previously Kosmosfs) is Kosmix's C++ implementation of Google File System. It parallels the Hadoop project, which is implemented in Java. CloudStore supports incremental scalability, replication, checksumming for data integrity, client side fail-over and access from C++, Java and Python. There is a FUSE module so that the file system can be mounted on Linux.


**Lustre**
	https://en.wikipedia.org/wiki/Lustre_%28file_system%29

	Lustre is a parallel distributed file system, generally used for large scale cluster computing. The name Lustre is a portmanteau word derived from Linux and cluster.

	Because Lustre has high performance capabilities and open licensing, it is often used in super computers

	Lustre file systems are scalable and can support tens of thousands of client systems, tens of petabytes (PB) of storage, and hundreds of gigabytes per second (GB/s) of aggregate I/O throughput.

**Ceph**
	https://en.wikipedia.org/wiki/Ceph

	Ceph is a free software distributed file system initially created by Sage Weil. Ceph's main goals are to be POSIX-compatible, and completely distributed without a single point of failure. The data is seamlessly replicated, making it fault tolerant.[1]

	Clients mount the file system using a Linux kernel client. On March 19, 2010, Linus Torvalds merged the Ceph client for Linux kernel 2.6.34[2] which was released on May 16, 2010. An older FUSE-based client is also available. The servers run as regular Unix daemons

	Ceph employs three distinct kinds of daemons:
		Cluster monitors (**ceph-mon**), which keep track of active and failed cluster nodes.

		Metadata servers (**ceph-mds**) which store the metadata of inodes and directories.

		Object storage devices (**ceph-osds**) which actually store the content of files. Ideally, OSDs store their data on a local btrfs filesystem, though other local filesystems can be used instead.[4]

	All of these are fully distributed, and may run on the same set of servers. Clients directly interact with all of them.[5]

	Ceph does striping of individual files across multiple nodes to achieve higher throughput, similarly to how RAID0 stripes partitions across multiple hard drives. Adaptive load balancing is supported whereby frequently accessed objects are replicated over more nodes



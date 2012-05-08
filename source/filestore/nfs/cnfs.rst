NFS with CNFS/FRL
=================

Basic problem with NLM locking over clustered NFS is that the failover of clients cannot be made lock consistent easily. When a client is connected to a node and acquires a lock that lock is acquired using the underlying CFS, when that node dies CFS assumes that the application died with that node and hance considers all locks have to be released when a node dies. When locks are taken over NFS, the NFS application is just translating the client's requests for locks over network into a form a filesystem can understand. As such the locks are really held by client, and NFS just acquires the locks on behalf of the client. When a node dies, the NFS dies on that node and CFS releases the locks, but the client could still be assuming that the locks that it acquired from the original NFS node to which it is connected are still valid. In the meantime as the node died all locks that were held on that node are now open and could be given to other clients. 

CNFS tries to solve the above problem with blocking the locks when a node dies. **frlpause_enable** sets a counter as to how many IPs on that node is serving the files over NFS and could potentially take locks. When a registration is done with frlock manager with **frlpause_enable** then CFS assumes that node could have given away locks over network which should not be released during failover. FRL blocks all locking calls when a node that was registered to be serving locks with **frlpause_enable** till a explicit call to **frlock_resume** is done to notify that locking can resume. 

This provides CNFS and filestore NFS opportunity to ask clients to recover locks before resuming locking. When a node dies and it had registered with **frlpause_enable** all locking is blocked by CFS. FileStore would then restart lockd in reclaim mode which only reclaim locks. It then resumes locking with **frlock_resume** and asks clients to request reclaim of the locks they were holding. 

This task is accomplised using triggers by CNFS and some custom VCS resources. 

/var/lib/nfs/sm
---------------
In NAT forwarding approach all locking requests are forwarded to one node which tracks the clients in a filesystem mounted on /var/lib/nfs/sm. All nodes uses the same shared directory for client tracking information, this is no longer feasible as each node has to maintain its own client tracking information this has to be a per-node directory.

Several options are considered on how to make this a per-node directory. rpc.statd and sm-notify provide -P option to specify a directory that needs to be used for lock recovery. 

One option was to configure NLM to start with -P directory that points to a directory on a shared filesystem so that the client tracking information is available to other nodes when a node dies.

Configuring statd and sm-notify 'rpc.statd -P /var/lib/nfs/sm/nlm/node_01' would impose a limitation that it would only work if the filesystem is infact available and mounted on /var/lib/nfs/sm (The directory given with -P option should be available). If the shared filesystem goes down then rpc.statd would fail to start and the whole NFS service could fail. Or if the shared filesystem is not created then the service will fail to start. This would be equivalent to putting a strict depedency that the NFS service requires the shared filesystem to be mounted. There are hardly 10% of customers who use locking on NFSv3, failing to start NFS service because locking will not work would be a terrible excuse. Even though CIFS keeps a dependecy on /var/lib/nfs/sm in group dependency hierarchy, but NFS doesn't, even though we are first users of this shared filesystem. NFS should be available even if locking is broken. 

The workaround for this -P problem, was to use soft-links for only directories inside the base dir and don't put the base directory directly in the local filesystem. Something like this

::

	rpc.statd -P /var/lib/nfs_new/  (local filesystem, not shared filesystem)
	/var/lib/nfs_new/sm --> /var/lib/nfs/sm/nlm/node_*/sm

This did seem to work. 

But then this would require changes in VCS NFS agent scripts and it creates a nightmare while discussing issues with VCS. We have always tried to talk to VCS team about the stuff we wanted from them, and avoid any direct changes to their scripts. Sometimes VCS refused to make a change during which they agreed that it is fine for us to modify and they will support such modifications as long as they are made aware of it, which was perfectly fine.

If we go to VCS for this changes, the first question that would be asked why doesn't CNFS need this and why does only filestore needs this. The answer would be, we already have a filesystem mounted on /var/lib/nfs/sm. If i am sitting in VCS place, i would say 'why don't you change your filesystem path'. The answer cannot be, we are too lazy to change our paths, and we want VCS to provide a patch.

So a similar approach as that of CNFS has been taken, which will have a shared filesystem mounted on a separate path (/shared in case of FileStore). And each node's /var/lib/nfs/sm will be a symlink to a directory on that shared filesystem. 


Triggers
--------
Most of the logic for handling failover is done through VCS triggers

=========
preonline
=========
In the preonline trigger we verify if the IP that is being onlined was online before on any other node. If it was online on any other node before, then we verify if that node was tracking any clients. We cannot really be sure that the clients that node was tracking were connected via this IP only or by any other IP. So we always assume that all the clients the previous online node was tracking were connected via this IP and will try to recover locks for that those clients.

Once the verification is done that the previous online node was tracking some NLM clients, then we restart lockd all nodes in the cluster, if not already in reclaim node. Unlike CNFS we don't do restart kill dameons in preonline and start them in postonline. As we don't kill any daemons at all, we just send a kill signal to lockd which just releases all the locks and puts the lockd in reclaim mode. So we ask lockd to enter relcaim mode from preonline trigger and don't try to start anything in postonline. 

Before restarting we also verify if the cluster is not already in reclaim mode. If the cluster is already in reclaim mode then there isn't much to gain by again dropping all locks and entering reclaim mode. As there is no reliable way of verifying from NFS whether lockd is currently in reclaim mode or not, we track the last restart time in **nlm_last_restart** file which is maintained per node, to handle any system time inconsistencies between the nodes in the cluster. 

Once we confirm that the previous node was tracking some clients and the cluster is not already in reclaim mode we go ahead with restarting lockd on all the nodes in cluster.

1.	Stop all locking at CFS layer with **frlock_pause** 
2.	Ask each node to release locks and enter reclaim mode, by using hares -action
3.	Make a copy of each node's sm/* into sm.copy/* which will be used for recovery
4.	Resume locking

We do step #1 of disabling locks before restarting locks, to ensure that while restart locks on one node, other nodes don't give out locks that were released during restart by other node. In step #2 we rely on VCS actions to restart lockd instead of ssh to avoid any delays or limitations or variances in restart times, with restarting locks on multiple nodes. hares -action is triggered parallelly on all the nodes. The lockd restarting uses locks on shared filesystem to ensure that there are no parallel restarts of lockd happening anywhere across the cluster.

Once the restart is done, from the previous online node's sm.copy we copy the list of clients that node was tracking to this node's sm.copy. When the group comes online we just use this node's sm.copy direcotry to request reclaim from this IP. 

As part of preonline we also send sm-notify request for clustername. Clients could be using either the cluster-name, cluster-name.FQDN or a virtual-ip directly while mounting. Depending upon the client OS version, some clients might just do simple string matching and validating that they are using some locks from this NFS server. If there are any such clients or clients which would resolve the name to IP and validate, some of the clients might try to reclaim their requests. We ensure that this clustername based reclaim request is being done from the node which started reclaim and not from all the nodes in the cluster. As part of the reclaim clients would try to reclaim, some of those reclaim could be for the node which is in still preonline and running this code, those clients will just keep trying. Since we have already entered reclaim mode with lockd restart, whether we wait for this IP to come online does not matter. We could do this for the current IP which is running preonline, but this will fail as a socket needs to be bound by sm-notify on this IP and this would fail as the IP is not up. So reclaim for this IP is done in postonline, when the IP is available and sm-notify could bind to this IP while sending reclaim requests even though we have already entered reclaim state in preonline itself.

For any VIPs that are already online on any of the nodes we send reclaim at this stage as we already in reclaim node and don't have to wait until postonline for IP to come online. 

==========
postonline
==========
In postonline we check if we are currently in relcaim node, if yes we would send reclaim via this IP.

It could be quite possible that a reclaim was triggered because this IP switched from a node or the node where this IP was previously online died, and the cluster went into reclaim mode as part of preonline and by the time we reached postonline we came out of reclaim mode. This is a very unlikely event to happen, we use the default value of grace_period of 90 seconds, and it is quite unlikely that the IP online would take that long. Even if it done, there isn't much we can do, we cannot delay the restart of lockd till postonline and lockd has to be restarted in preonline. Unlike CNFS we don't completely kill lockd/nfsd, we only ask lockd to enter reclaim mode and it does it immediately in preonline itself. Extreme care has been taken to ensure that we don't spend much time in preonline after we restart lockd. Most of tasks done in preonline post lockd restart are done in background so the preonline trigger is not delayed and will quickly start the online of the IP. In postonline too, care has been taken to ensure that the lock reclaim requests are ASAP.

==========
sysoffline
==========
When a node dies all locking is blocked if that node is registered as network locking node with **frlpause_enable**. In sysoflfine we verify if there any locking recovery that needs to be done, if none needs ot be done, then we resume locking with **frlock_resume**. 

We also proactively restart lockd if required, with the same logic as would have been done through preonline. 

state/nsm_local_state file
--------------------------
rpc.statd maintains a state counter in /var/lib/nfs/state, which is like a generation number of the NFS locking daemon. The corresponding kernel file is /proc/sys/fs/nfs/nsm_local_state. This state counter is sent to the client during sm-notify reclaim request. The client then verifies that the generation counter is ahead of the counter it thinks the NFS server was perviously in, otherwise the clients assumes that there was something wrong or some state has been lost on the server side and would not attempt to reclaim. 

When providing locking across multiple nodes in a cluster, the state counter maintained by each node can drift away from each other, depending upon the when a server was restarted and what other nodes were available as part of the restart. Consider a simple case 

1. Customer starts with one node
2. The first node starts with state counter as 1 or 3
3. After a few node/lock restarts the counter changes to 11
4. A new node is added to the cluster which starts it counter with 1 or 3
5. When a VIP failover happens from node_01 to node_02 then the reclaim request sent from node_02 would use a counter value of 3 or 5 which is lower than the state counter value being used by node_01. So clients would discard such sm-notify requests as the state counter of the NFS server went behind

A clustered NFS should maintain the same state counter across all nodes to ensure each node gives out locks with the same state counter so clients would honour sm-notify requests from any server. 

FileStore NFS keeps a global state counter in /shared/nlm/state file. This state file is used during recovery with sm-notify always. When sm-notify runs it reads the current value of state counter and updates to the next odd number and uses that number to send reclaim requests to clients. It also updates the kernel about the new state counter that should be used. 

During each sm-notify tirggered from FileStore code

1. Update the local state counter /var/lib/nfs/state from /shared/nlm/state
2. Run sm-notify which updates the state file with new counter at /var/lib/nfs/state
3. Update the global state file /shared/nlm/state with local state file created by sm-notify /var/lib/nfs/state

All of this is done with locks taken over a shared filesystem, this ensures that state counter will always move forward but never back and also state file is not update simultaneously by multiple sm-notify's. 

A node which was done for sometime might have drifted away from the global state counter, so when a node comes back up and mounts the shared filesystem, we sync the local state counter on that node (/var/lib/nfs/state and /proc/sys/fs/nfs/nsm_local_state) with the global state counter stored in /shared/nlm/state.

For any sm-notify running outside for filestore control (through VCS NFS agent) they should not affect the state counter, as /var/lib/nfs/sm and /var/lib/nfs/sm.bak would be on different filesystems. So sm-ntoify run by VCS would just assume that there are no clients in sm.bak that should be notified and it would not update the counter. Though ideally we should avoid such restarts happening outside of filestore control

Running sm-notify
-----------------
sm-notify is used to notify clients that the server has been restarted and clients should reclaim requests for all the locks they were holding. 

The typical steps involved in sm-notify run are

1. Rename each flie in /var/lib/nfs/sm to /var/lib/nfs/sm.bak
2. After the rename is complete check if any files are there in /var/lib/nfs/sm.bak
3. If there are no files in sm.bak directory quit
4. If there are files in sm.bak, update the /var/lib/nfs/state file with the new counter to be used and also notify the kernel of the new state counter value
5. For each file in /var/lib/nfs/sm.bak, send a notify request to client from the local host name or with the name provided by -v option. 
6. Once each file is processed in pervious step, the file is deleted as the client has been notified. It is not a bunch-delete at the end of notifying all the clients

The above steps are described to highlight the problems that could be faced when running multiple sm-notify requests from a node. If multiple sm-notify are running over the same directory (say /var/lib/nfs) then they would be using same sm.bak and as each sm-notify would be deleting files after they have processed each one of them, it could result in potentinally one sm-notify deleting files in sm.bak before other sm-notify reads and processes it. 

To avoid the situation where multiple sm-notify's are running over the same sm.bak directory, each sm-notify fired by FileStore uses its own temporary directory created. This directory is also updated with the correct value state counter from the global state counter before running sm-notify. Typically each sm-notify would run on a directory /tmp/nlm/<ip>. These directories are created and destroyed as needed. They are created on local /tmp filesystem instead of shared filesystem as these are just copies of sm/sm.copy directories in shared filesystem, and it also reduces the amount of space required on shared filesystem for NLM locking.

For any sm-notify running outside for filestore control (through VCS NFS agent) they should not affect the state counter, as /var/lib/nfs/sm and /var/lib/nfs/sm.bak would be on different filesystems. So sm-ntoify run by VCS would just assume that there are no clients in sm.bak that should be notified and it would not update the counter. Though ideally we should avoid such restarts happening outside of filestore control

frlpause_enable/disable
-----------------------
Unlike CNFS we don't do enable/disable as part of IP online, we do enable/disable as part of shared FS online/offline. 

Logically CFS would only need to know that are network locks that could have been given from a node or not. It should not care how many IPs are online on any node. Unlike CNFS we allow NFS to be running even when the shared filesystem is not available (as long as it is not available on all the nodes, global failure), in which case NFS locking would not work so it would not make sense to tell CFS to block locks.

Known Issues/Limitations/hacks
------------------------------
Even with new FRL based locking we still rely on TCPConnTrack for tracking locking connections and statd has some bugs while converting IPs to names. If a IP cannot be resolved to a name then statd incorrectly uses the local node name as the client name and starts tracking that client. So TCPConnTrack will be used to monitor all clients connecting to NLM.



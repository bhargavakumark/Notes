NFS Linux Implementation
========================

.. contents::

Module Load
-----------

::

	init_nfsd
		nfs4_state_init
			nfsd4_init_slabs
				# Initialise slabs
				stateowner_slab = "nfsd4_stateowners"
				file_slab = "nfsd4_files"
				stateid_slab = "nfsd4_stateids"
				deleg_slab = "nfsd4_delegations"

			# Initiailse lists
			# CLIENT_HASH_SIZE
			&conf_id_hashtbl
			&conf_str_hashtbl
			&unconf_str_hashtbl
			&unconf_id_hashtbl
			&reclaim_str_hashtbl

			# SESSION_HASH_SIZE
			&sessionid_hashtbl

			# OWNER_HASH_SIZE
			&ownerstr_hashtbl
			&ownerid_hashtbl

			# STATEID_HASH_SIZE
			&stateid_hashtbl
			&lockstateid_hashtbl

			# LOCK_HASH_SIZE
			&lock_ownerid_hashtbl
			&lock_ownerstr_hashtbl

			&close_lru
			&client_lru
			&del_recall_lru
			
		nfsd_stat_init	# Initialise nfsd statistics
			svc_register	# register nfs services for rpc stats, 
					# using progname "nfsd" which creates 
					# proc file /proc/net/rpc/nfsd and also
					# set fileops for that file to 
					# nfsd_proc_fops

		nfsd_reply_cache_init	# Initialise duplicate reply cache
					# stored in lru_head to CACHESIZE
					# All cache entries are allocated 
					# now and formed as a list with head
					# lru_head and traversal pointers
					# as c_lru in svc_cacherep
					
					# A hash node is initialised for 
					# this reply cache to cache_hash
		
		nfsd_export_init
			cache_register(svc_export_cache)
					# Register the export cache to 
					# sunrpc cache manager (nfsd.export)
			cache_register(svc_expkey_cache)
					# register the export key cache
					# (nfsd.fh)

		nfsd_lockd_init	# setup lockd->nfsd callbacks
				# by setting nlmsvc_ops = nfsd_nlm_ops
				# Used by nlm to callback into nfs
				# to open and close files for 
				# locking

		nsfd_idmap_init
			cache_register(idtoname_cache)
				# Register nfs4.idtoname cache
			cache_register(nametoid_cache)
				# Register nfs4.nametoid cache

		create_proc_exports_entry
			# if CONFIG_PROC_FS is defined, then tries
			# to create /proc/fs/nfs/exports. 
			# XXX : Why is nfsd trying to create a file in nfs ?
		
		register_filesystem
			# Registers the given filesystem (nfsd_fs_type, 
			# name = nfsd) for a entry in /proc/fs/ as 
			# /proc/fs/nfsd, which also registers nfsd
			# as a filesystem with OS. 
			# When nfsd superblock is read for the first time
			# through nfsd_get_sb, which indirectly calls 
			# nfsd_fill_super to create all the required files
			# in nfsd_files at /proc/fs/nfsd/

			# The fileops for all files in /proc/fs/nfsd/* is set
			# to transaction_ops. write to these files get 
			# redirected to nfsctl_transaction_write which calls
			# the corresponding op define in write_op of nfsctl.c


Module Unload
-------------

::

	exit_nfsd
		nfsd_export_shutdown
			cache_unregister(svc_export_cache)
			cache_unregister(svc_expkey_cache)
			cache_purge(auth.unix.ip)

		nfsd_reply_cache_shutdown
			frees and replies in reply cache
			deletes all allocated reply cache entries
			free cache_hash

		remove_proc_entry (fs/nfs/exports and fs/nfs)

		nfsd_stat_shutdown
			svc_unregister # unregister "nfsd" in stats

		nsfd_lockd_shutdown
			# nlmsvc_ops = NULL, nlm cannot call into nfsd

		nfsd_idmap_shutdown
			cache_unregister(idtoname/nametoid)

		nfs4_free_slabs
			# kmem_cache_destroy slabs
			&stateowner_slab
			&file_slab
			&stateid_slab
			&deleg_slab

		unregister_filesytem
			# unregister "nfsd" as a filesystem
	
/proc/fs/nfsd/* files
---------------------

The fileops for all these files is set to transaction_ops in nfsctl.c 

These files have custom write ops defined in **write_op** but no custom
read ops. 

**filehandle** and **pool_stats** do not support write

=================
.svc - DEPRECATED
=================

=================
.add - DEPRECATED
=================

=================
.del - DEPRECATED
=================

====================
.export - DEPRECATED
====================

======================
.unexport - DEPRECATED
======================

===================
.getfs - DEPRECATED
===================

===================
.getfd - DEPRECATED
===================

==========
filehandle
==========

Get a variable-length NFS file handle by path

handled in **write_filehandle** of nfsctl.c

Input :

::

	3 alphanumeric words (can contain escape sequences)

	domain:         client domain name

	path:           export pathname

	maxsize:        numeric maximum size of @buf

Output :

::

	Passed in buf, will have filehandle in hex

Used by **mountd** in NFSv3 to get a initial filehandle for a 
filesystem being mounted by client

Code :

::

	Parse input args

	unix_domain_find(domain)
		# the client information from the export
		# which matched the mount request, handle
		# will be generated based on this client 
		# export : XXX is this true

	exp_rootfh(path)
		kern_path
			# gets the dentry for the path
		exp_parent
			# finds a export going backwards
			# from the path to find a valid
			# export

			# Recursive search is required because,
			# client could be mounting /vx/a//b/c
			# when only /vx/a is being exported

			exp_get_by_name 
				# which looks up the path in 
				# svc_export_cache, if entry does
				# not exist it will be added immediately
				
				sunrpc_cache_lookup 
					# adds if it does exist
				cache_check
		
		if export found, create a fh and return

=========
unlock_ip
=========

processed in **write_unlock_ip**

Release all locks associated with this IP, does not put lockd
in grace mode

Input :

::

	buf:	'\n'-terminated C string containing a
		presentation format IP address
	size:	length of C string in @buf


Code : 

::

	nlmsvc_unlock_all_by_ip
		nlm_traverse_files
			# with given IP address, and lock match 
			# function as nlmsvc_match_ip, which given
			# a lock compares the server IP in the lock
			# with given IP address, no superblock cmp

			# For each nlm_file, traverse all locks/blocks/
			# shares that match the IP and release them
			# through 
			
			nlm_inspect_file
				nlm_traverse_blocks
				nlm_traverse_shares
				nlm_traverse_locks

			# If no more references for this
			# close the file pointer

=========
unlock_fs
=========

processed in **write_unlock_fs**

Release all locks associated with this fs, does not put lockd
in grace mode

Input :

::

	buf:	'\n'-terminated C string containing
		absolute pathname of a local file system	
	size:	length of C string in @buf


Code : 

::

	kern_path
		# get dentry for the path

	nlmsvc_unlock_all_by_sb
		nlm_traverse_files
			# with given sb, and lock match 
			# function as nlmsvc_match_sb, which given
			# a lock compares the sb in the lock
			# with given sb, match all server IPs

			# For each nlm_file, traverse all locks/blocks/
			# shares that match the IP and release them
			# through 
			
			nlm_inspect_file
				nlm_traverse_blocks
				nlm_traverse_shares
				nlm_traverse_locks

			# If no more references for this
			# close the file pointer

=======
threads
=======

processed in **write_threads**

echoing a integer starts that many nfsd threads, cat of this file
will show the current number of nfsd threads

Input:

::

	buf:            C string containing an unsigned
			integer value representing the
			number of NFSD threads to start
			non-zero length of C string in @buf

Output:

::

	NFS service is started;
	passed-in buffer filled with '\n'-terminated C
	string numeric value representing the number of
	running NFSD threads;

Code :

::

	If no input	
		# print current threads and return
		nfsd_nrthreads
		return

	nfsd_svc(newthreads)
		# Maximum 8192 threads can be started
		# as defined in NFSD_MAXSERVS
		
		# Initialise read ahead buffers
		# If already initialised, the buffers
		# don't increase. So if a new thread
		# count is being echoed, when already
		# started, this won't increase the
		# read-ahead buffers
		#
		nfsd_racache_init (2 * noofthreads)
			# Initialise the cache with
			# buckets if not already
			# initiailsed

		nfs4_state_start
			nfsd4_load_reboot_recovery_data
				nfs4_lock_state
				nfsd4_init_recdir
					nfs4_save_creds
					kern_path
					nfs4_reset_creds
				nfsd4_recdir_load
					nfsd4_list_rec_dir use 
							load_recdir
						nfs4_save_creds
						dentry_open
						vfs_readdir 
							nfsd4_build_namelist
							# creates a 
							# name list
						for each entry in 
								namelist
							lookup_one_len
							load_recdir
								nfs4_client_to_reclaim
									add client to
									&reclaim_str_hashtbl

									set cr_recdir
									as name
				nfs4_unlock_state

				# Currently there is no additional
				# data about a client that is 
				# stored in a directory for that 
				# client. Only the directory name
				# is used to identify the client
				# name 

			__nfs4_state_start
				set boot_time/grace_time/lease_time
				locks_start_grace nfsd_manager
					add itself to grace list of
					lockd
				create_singlethread_workqueue "nfsd4"
					# laundry_wq, for laundromat 
					# work
				queue_delayed_work &laundromat_work
						(laundromat_main)
					# delay laundromat_work till
					# grace_time, no clenaup to
					# be called till grace_time 
					# is completed so that clients
					# have a chance to reclaim
					# locks/delegations/opens
				set_max_delegations
					# calculate max delegations
					# based on memory
				set_callback_cred

		nfsd_reset_versions
			# If no versions configured currently
			# configure versions in nfsd_versions
			# based on nfsd_version. nfsd_version
			# lists all the versions possible,
			# nfsd_versions is configured dynamically
			# to the list of versions we want to use

		nfsd_create_serv
			# If server already created return

			# calculate max_blk_size based on RAM
			# 1/4096 of RAM, for 4G ram 1MB size
			# upto a maximum of NFSSVC_MAXBLKSIZE 
			# which is a RPC max payload. RPC allows
			# another PAGE_SIZE for the whole message

			svc_create_pooled
				# a nfsd_last_thread pointer is
				# passed to let svc manager know
				# what to do when the last thread
				# is exiting

				# a funtion pointer to the function
				# that should initialise the thread

				# sunrpc maps pools to CPUs, default
				# is all CPUs in one pool 
				# SVC_POOL_DEFAULT

				svc_pool_map_get # return 1 pool

				__svc_create
					# Initialise the svc
					# Initialise pools and
					# and their list of threads

					svc_unregister(svc) 
					# remove stale registrations

				set sv_fucntion to nfsd()
				and module as THIS_MODULE

			set_max_drc
				# max memory to be used for
				# duplicate reply cache


			record current time in nfssvc_boot

		nfsd_init_socks
			# sv_permsocks already created return

			create udp/tcp transport on port 2049
			
			lockd_up
				# if already running return

				svc_create
					# create NLM service, with 
					# bufsize of 1024 and no
					# shutdown function to be
					# called when last thread dies
						
					make_socks
						create_lockd_family
						# IPv4 and IPv6 
						# TCP and UDP 
						# socket creation

					svc_prepare_thread
						# Prepares the svc
						# for a new thread in
						# a given pool and 
						# return set as
						# nlmsvc_rqst
						init wait queue rq_wait
						sv_nrthreads++
						adds thread to pool
						allocates rq_argp &
							rq_resp
						svc_init_buffer which
						initialises rq_pages
						to the required no of
						pages as per sv_max_mesg

					svc_sock_update_bufs
					sv_maxconn = 1024

					start kernel thread with
					lockd()

					svc_destory 
						# to reduce the thread
						# count of current 
						# foreground thread
						# svc_prepare_thread 
						# would have inc the 
						# thread count to 2
					
					nlmsvc_users++

		svc_set_num_threads
			# set nfsd threads to given count

			# if no of threads greater than current
			# no of threads in the given pool or 
			# or pick a pool by balancing 
			choose_pool
			svc_prepare_thread
			start kernel thread at nfsd()


			# If not of threads is less than current
			# threads, pick a victim and kill
			choose_victim
			send_sig(SIGINT)

		svc_destroy	# Release current thread

============
pool_threads
============

Set or report the current number of threads per pool

handled in **write_pool_threads**

Input:

::

	buf:            C string containing whitespace-
			separated unsigned integer values
			representing the number of NFSD
			threads to start in each pool

NFS threads cannot be started by writing to pool_threads. It has to 
be started by writing to threads, and then can be balanced by writing
to pool_threads

Code :

::

	npools == 0 && return 
		# NFS server not started, cannot be started
		# by writing to pool_threads

	nfsd_set_nrthreads
		# Ensure total threads is not greater
		# than 8192

		# If no of threads greater than 8192
		# scale down proportinally as user
		# requested

		# for each pool
		svc_set_num_threads 

		# reduce the counter for our instance
		svc_destroy

	nfsd_get_nrthreads	# get current threads

	print current threads per pool
		as a space separated list and return

========
versions
========

Set or report the available NFS protocol versions

cat /proc/fs/nfsd/versions 
+2 +3 -4 -4.1

echo -2 +3 +4 > /proc/fs/nfsd/versions
# will enable NFSv3 and NFSv4

handled in **write_versions**

Input:

::

	buf:            C string containing whitespace-
			separated positive or negative
			integer values representing NFS
			protocol versions to enable ("+n")
			or disable ("-n")

Code : **__write_versions**

::

	If server already running return busy

	# Call nfsd_vers with NFSD_CLEAR or NFSD_SET as
	# per user request
	nfsd_vers
		if (set)
			nfsd_versions[vers] = nfsd_version[vers];
		if (clear)
			 nfsd_versions[vers] = NULL
	
	nfsd_reset_versions
		# If user removed all versions
		# restore defaults

	# for 2..4
	nfsd_vers # and print +/-
	If +4
		nfsd_minorversion(minor, NFSD_TEST) # 4.1

========
portlist
========

Pass a socket file descriptor or transport name to listen on

Input:

::

	buf:            C string containing an unsigned
			integer value representing a bound
			but unconnected socket that is to be
			used as an NFSD listener; listen(3)
			must be called for a SOCK_STREAM
			socket, otherwise it is ignored

	buf:            C string containing a "-" followed
			by an integer value representing a
			previously passed in socket file
			descriptor

	buf:            C string containing a transport
			name and an unsigned integer value
			representing the port to listen on,
			separated by whitespace

	buf:            C string containing a "-" followed
			by a transport name and an unsigned
			integer value representing the port
			to listen on, separated by whitespace

Output:

::

	passed-in buffer filled with a '\n'-terminated C
	string containing a whitespace-separated list of
	named NFSD listeners;


Code : calls **__write_ports**

::

	__write_ports_names
		svc_xprt_names
			for each socket sv_permsocks
			add string from svc_one_xprt_name
			to buf

	
	__write_ports_addfd   # if format "123"
		# single 'fd' number was written, in which case 
		# it must be for a socket of a supported 
		# family/protocol, and we use it as an
		# nfsd listener

		nfsd_create_serv
			
		lockd_up

		svc_addsock (nfsd_serv, fd, buf
			sockfd_lookup
				fget(fd)
				sock_from_file(file)
			check sock is IPv4/IPv6/UDP/TCP
			check socket not connected already

			svc_setup_socket
				svc_register(nfsd_serv, socket)a
					for each program and prog_version
					# nfs and nfs_acl(hidden)
						__svc_register

				svc_udp/tcp_init

			add socket to sv_permsocks
			svc_xprt_received

			svc_one_sock_name
				# prints socket type udp/tcp
				# ipv4/ipv6 in a text format to
				# buf. This is the same
				# string that should be used
				# for deletion with write_ports
				# as -"string"
		sv_nrthreads--



	__write_ports_delfd	# if format "-123"
		 svc_sock_names
			# for each socket in sv_permsocks
			svc_one_sock_name

			If string == user_string
				closesk=sk
			else
				# exclude the socket
				# to be closed from returning
				add string to buf

		svc_close_xprt(closesk) # Cannot unregister 
					# just one protocol
					# to portmap
		if (len >= 0)
			lockd_down	# always


	__write_ports_addxprt	# if format "tcp 2049"
		nfsd_create_serv

		svc_create_xprt	# only PF_INET called in 2.6.32
				# 3.0 call for PF_INET and PF_INET6
			__svc_xpo_create
			add transport to sv_permsocks


	__write_ports_delxprt	# if format "-tcp 2049)
		svc_find_xprt(AF_UNSPEC matches INET4 and INET6)
			search in sv_permsocks for given transport
			svc_xprt_get	# only one socket is returned
					# If IPv4 and IPv6, need to
					# call twice
		svc_close_xprt
		svc_xprt_put
		
==============
max_block_size
==============

Set or report the current NFS blksize

handled in **write_maxblksize**

Input:

::

	buf:            C string containing an unsigned
			integer value representing the new
			NFS blksizea

Code :

::

	no input print nfsd_max_blksize

	new size between 1024 .. NFSSVC_MAXBLKSIZE
	round off to nearest 1K 
	if (no nfsd threads started)
		nfsd_max_blksize = user provided size

==============
nfsv4leasetime
==============

Set or report the current NFSv4 lease time

handled in **write_leasetime**

Input:

::

	buf:            C string containing an unsigned
			integer value representing the new
			NFSv4 lease expiry time

Code : calls __write_leasetime

::

	if (nfsd_serv) return EBUSY
	lease should be between 10..3600
	nfs4_reset_lease
		user_lease_time = leasetime
		# Lease time cannot be changed on 
		# the fly. Lease time is updated 
		# when the next time ew start to 
		# register any changes in least time
	
	if no input
		nfs4_lease_time
			prints lease time lease_time  
			# prints the current running
			# lease time and not modified 

================
nfsv4recoverydir
================

Set or report the pathname of the recovery directory

handled in **write_recoverydir**

Input:

::

	buf:            C string containing the pathname
			of the directory on a local file
			system containing permanent NFSv4
			recovery data


Code : calls **__write_recoverydir**

::
	
	if (nfsd_serv) return EBUSY
	nfs4_reset_recoverydir
		kern_path (LOOKUP_FOLLOW, path)
		if (dir)
			nfs4_set_recdir
				user_recovery_dirname = dir
		path_put
	
	if no input
		nfs4_recoverydir
			print user_recovery_dirname


nfsd() kernel thread start
--------------------------

This is called from **svc_set_num_threads** when the no
of threads is set to **/proc/fs/nfsd/threads**

::

	lock &nfsd_mutex
	set umask = 0 after unshare_fs_struct from init process
	allow signals to kill this thread
	increase thread count in nfsdstats

	less throttling in balance_dirty_pages by PF_LESS_THROTTLE
	set_freezable

	infinite loop
		svc_recv
			need to allocate sv_max_mesg + PAGE_SIZE for
			request processing

			# Since this allocation is done all threads
			# if a maximum of 8192 threads are used, then
			# with max_blksize of 1M, 8G will be used by
			# nfsd threads (even if idle)

			alloc required sv_max_mesg + PAGE_SIZE in 
			PAGE_SIZE chunks (rq_pages would have been
			initialised when the thread was created from
			svc_prepare_thread)
				alloc_page(GFP_KERNEL)
				if cannot alloc retry every 500ms

			assign first page for request args
			next pages-2 as data
			last page for response

			svc_xprt_dequeue (get first xprt from sp_sockets)
			if (xprt available)
				svc_xprt_get(xprt)
			else
				add_wait_queue (rq_wait)
				wait for timeout time
				remove_wait_queue (rq_wait)

				if (rq_xprt still NULL)
					svc_thread_dequeue from pool
					return EAGAIN

			if xprt closed, 
				svc_delete_xprt
			if listener xprt
				accept connection
				svc_xprt_get(newxpt)
				add new xpt to sv_tempsocks
				svc_xprt_received(new)
				svc_xprt_put
				svc_xprt_received
			if existing connection xprt
				if any deferred request, process it
				else xpo_recvfrom

		exp_readlock	# Lock the export hash tables
		svc_process
			# setup response xdr_buf
			# verify its a RPC call not RPC reply
			svc_process_common
				Find the program that matches the request
				svc_authenticate
				verify valid version for the program
				verify procedure number

				if (prog/version provides vs_dispatch)
					call vs_dispatch
					# nfsd (nfsd_program) uses this

				otherwise
					call procedure pc_func directly
					# nlm (nlmsvc_program) uses this
					if reply required
				call pc_release is defined
					NFS uses this to release 
					file handle used in this RPC
					(releases dentry and other stuff)
		exp_readunlock

	thread has received kill signal or EINTR
	flush_signals
	decrement thread count in nfsdstats

	svc_exit_thread		
		# Free up resources allocated for this 
		# thread to process requests
		# decrement pool thread count
		svc_destroy	# decrement service thread count

	unlock &nfsd_mutex

nfsd_last_thread - nfsd last thread end
---------------------------------------

This is called by svc thread manager when the last nfsd thread
is about to shutdown due to signal or no of threads being set to
0 

::

	for each sock listed in serv->sv_permsocks
		lockd_down
			reduce nlmsvc_users counters
			if no users left
				kthread_stop nlmsvc_task
				svc_exit_thread nlmsvc_rqst

		nfsd_serv = NULL
		nfsd_racache_shutdown
			free all the readahead buffers allocated
		
		nfs4_state_shutdown
			cancel_rearming_delayed_workqueue
				# laundromat_work
			destroy_workqueue laundry_wq
				# destory laundromat work queue
			locks_end_grace	nfs4_manager
				# remove nfs4 lock managers users

			nfs4_lock_state
			nfs4_release_reclaim
				# cleanup &reclaim_str_hashtbl

			__nfs4_state_shutdown
				for each client &conf_id_hashtbl and
						&unconf_str_hashtbl
					expire_client
						move all delegations for
						this client in 
						cl_delegations to a separate
						list

						for each of the delegations
						moved, unhash_delegation

						remove client from all other
						lists, (idhash, strhash, lru)

						release all openowners for 
						this client in cl_openowners
						release_openowner

						for all NFSv4.1 sessions open
						for this client in cl_sessions
						release_session

						put_nfs4_client
							free_client (if last ref)
								shutdown_callback_client
								cl_cb_conn->cb_client = NULL
								rpc_shutdown_client
							put cb_xprt


				move any delegations in recall lru
				&del_recall_lru to separate list

				for all delegations in separate list
					unhash_delegation

				nfsd4_shutdown_recdir
					rec_dir_init = 0
				nfs4_init = 0


nfsd_dispatch
-------------

::

	Check whether we have this call in the cache
	nfsd_cache_lookup
		if no cache return

		cache_lock

		get hash for this xid
		search in hash for matching
			xid, proc, prot, vers, addr
		if found in cache 
			update nfsdstats.rchits
			update the time for entry as replied now
			move the entry to end of LRU
			if RPC in progress or age is less than RC_DELAY
				drop rpc	(in progress or aggressive 
						retries)
			if RC_NOCACHE cannot reply drop
				# For a successful rpc, this is usually
				# set based on pc_cachetype of the 
				# procedure. Operations that can be
				# safely replayed (idempotent) do
				# not cache results (usually read ops)
				For NFSv3 refer to nfsd_procedures3
				For NFSv4 refer to nfsd_procedures4, but
					as of 3.0 kernel, linux NFS does
					not implement DRC for NFSv4
			if RC_REPLSTAT just copy status and reply
			if RC_REPLBUFF copy the reply buffer, which might
					have quite a bit of data
				# For a successful rpc, this is usually
				# set based on pc_cachetype of the 
				# procedure. Operations that CANNOT be
				# safely replayed (non-idempotent)
				# like any write ops, try to cache the
				# results and replies
				For NFSv3 refer to nfsd_procedures3
				For NFSv4 refer to nfsd_procedures4, but
					as of 3.0 kernel, linux NFS does
					not implement DRC for NFSv4
		if (not found in cache)
			update nfsdstats.rcmisses

			find a free entry in lru DRC
				rp->c_state != RC_INPRO

			rp->c_state = RC_INPROG
			rehash this based on new xid
		
	if found in cache and drop/reply, then return 0/1

	pc_decode	# decode args

	grab the location to store the status, as
	nfsv4 does some encoding while processing

	call the procedure handler
		pc_func

	if (not null procedure)
		update error in respone

	nfsd_cache_update
		if reply size quite large ignore
		if RC_REPLSTAT
			save status in entry
		RC_REPLBUFF
			allocate new memory for this
			copy status to new memory
			move the entry to end of LRU
			update timestamp as jiffies


laundromat_main - laundromat service
------------------------------------

::

	nfs4_laundromat
		nfs4_lock_state
		locks_in_grace
			# laundromant would have been already delayed
			# ddring nfs start to ensure that this cannot
			# get run before lease time has expired.
			# If we are here, then the lease time must
			# have expired already
			nfsd4_end_grace
				nfsd4_recdir_purge_old
					mnt_want_write
					nfsd4_list_rec_dir purge_old
						purge_old called for
						every dentry in the 
						directory
						
						nfs4_has_reclaimed_state
							# This client has
							# reclaimed state
							# and is now in 
							# confirmed state
							# then skip
						if (client not confirmed)
							vfs_rmdir

					nfsd4_sync_rec_dir
					mnt_drop_write

				locks_end_grace
					# grace period ends when all users
					# of lockd (NFSv3/NFSv4) have said
					# end_grace. Similarly all locking
					# should be disabled when any of
					# the users of lockd are in grace
					# by verifying locks_in_grace

			for each client in client_lru
				# since this an LRU, the least recently used
				# would be at the head of the list

				if (client is not used in the previous
						LEASE_TIME)
					nfsd4_remove_clid_dir
					expire_client
				else
					check how many seconds is left for 
					client to renew its leases, we will
					wake once that time has past

					break out of the loop
			done

			for each delegation reacll in &del_recall_lru list
				if delegation is older than LEASE_TIME
					move delegation into a separate list
				else 
					break	# this is an LRU, we don't
						# have to go further in the
						# list
			done

			for each delegation is separate list
				remove delegation from list
				unhash_delegation
			done

			for each entry in close_lru
				if not used in LEASE_TIME
					release_openowner
				else
					break
			done

			nfs4_unlock_state

	queue_delayed_work self for 




NFSv3 Procedures
----------------

==========================
nfs3svc_decode_fhandleargs
==========================

General procedure for decoding args and verify filehandle, set 
as .pc_decode for all NFSv3 procedures

Code : calls **decode_fh**

::

	fh_init
	copy on-the-wire fh contents to a svc_fh structure

=========
fh_verify
=========

::

	fh_verify
		if (dentry not set)
			nfsd_set_fh_dentry
				decode filehandle
				rqst_exp_find
					exp_find (client ..)
						exp_find_key
							svc_expkey_lookup
								build hash for expkey
								sunrpc_cache_lookup
							cache_check
						exp_get_by_name

				if (exp not found)
					# client had a handle
					# but it is no longer valid
					# return stale

	# FIXME : need to fully understand how this works in code
		
		nfsd_mode_check	# check inode type, requested type

		check_nfsd_access
			# check security
		nfsd_permission
			# checks access permissions

=============
NFS3PROC_NULL
=============

::

	return ok

================
NFS3PROC_GETATTR
================

handled in **nfsd3_proc_getattr,**

::

	fh_copy		# copy filehandle from request to svc_fh
	fh_verify
	vfs_getattr
		security_inode_getattr
			# check for security errors
		inode->i_op->getattr	# calls FS getattr
		generic_fillattr	# copies stat to NFSv3 format

================
NFS3PROC_SETATTR
================

handled in **nfsd3_proc_setattr,**

::

	fh_copy
	nfsd_setattr
		if ia_valid & ATTR_SIZE		# size reset requested
			ftype = S_IFREG		# file type should be REG
		fh_verify

		if (symlink)
			cannot update i_mode on symlink
		
		if (size change)
			if (truncate to smaller size)
				nfsd_permission		# check inode is not
							# append only inode

				break_lease (write lease, non-blocking)
				if (EWOULDBLOCK)
					# if the lease taken by us NFS
					# itself, then the kernel would
					# consider this as a deadlock
					return ETIMEDOUT
			
				get_write_access
				locks_verify_truncate
				vfs_dq_init

			if (!check_guard || guardtime == inode->i_ctime.tv_sec) {
				# client has not asked to verify
				# ctime, or ctime verification 
				# requested and passed
				fh_lock
				notify_change
				fh_unlock
		
			if (size change)
				put_write_access

			if (export is sync)
				write_inode_now (sync)
					&inode_lock
					writeback_single_inode
					spin_unlock
					if (sync)
						inode_sync_wait


===============
NFS3PROC_LOOKUP
===============

handled in **nfsd3_proc_lookup**

::

	fh_copy incoming filehandle to resp->dirfh
	fh_init resp->fh
	nfsd_lookup
		nfsd_lookup_dentry
			fh_verify dir file handle
			exp_get 
			if ( . or ..)
				if (.)
					dentry = dget()
				if (..)
					dentry = dget_parent()
				handle crossing mount points
			if (normal lookup)
				fh_lock directory
				lookup_one_len

				# check mount point crossed
				nfsd_cross_mnt
					follow_down(dentry)
					if (mount point crossed and
						nfsv4 or exp|crossmnt)
						update dentry
		check_nfsd_access

		fh_compose
			# create a fileandle from dentry
			# in resp->fh
		dput dentry
		exp_put

===============
NFS3PROC_ACCESS
===============

handled in **nfsd3_proc_access**

::

	fh_copy incoming fh to resp->fh
	nfsd_access
		fh_verify
		check access permissions
			nfsd_permission

=================
NFS3PROC_READLINK
=================

handled in **nfsd3_proc_readlink**

::

	fh_copy incoming fh to resp->fh
	nfsd_readlink
		fh_verify
		i_op->readlink is not available return error
		touch_atime

		get_fs and set_fs
		i_op->readlink
		set_fs

=============
NFS3PROC_READ
=============

handled in **nfsd3_proc_read**

::

	if requested size > max_payload_size
		resp->count = max_payload_size

	svc_reserve_auth
	fh_copy incoming fh to resp->fh
	nfsd_read
		if (file already open)		# In 3.0 kernel
			nfsd_permission		# we don't have file
			nfsd_vfs_read		# argument passed here
		else
			nfsd_open
				fh_verify
				if (append only inode and write requested)
					return error
				if (regular file and mandatory lock enabled)
					# we cannot know that mandatory
					# lock has been taken via NLM
					# as there is no integration between
					# NFS and NLM
					reject the request
				break_lease O_NONBLOCK and read/write mode
				if (EWOULDBLOCK)
					# lease taken by us
					# probably via NFSv4
					return ETIMEDOUT
					dentry_open

			nfsd_vfs_read
				nfsd_get_raparams	# 3.0 does ra 
							# mgmt in nfsd_read
							# itself

					# checks if there is any ra params 
					# in use for this inode on dev
					# and returns that
					
					# otherwise finds a free slot
					# if available
				if (ra available)
					file->f_ra = ra->p_ra
				set O_NONBLOCK on file

				if (f_op->splice_read and not gss)
					initialise splice_desc
					splice_direct_to_actor 
						# nfsd_direct_splice_actor
						__splice_from_pipe

					# XXX: do_splice_to can use 
					# default_file_splice_read if there 
					# is no default splice read provided
					# by FS, why isn't NFS using it

				else
					set_fs
					vfs_readv
					set_fs

			nfsd_close

	if (eof reached with data read)
		set resp->eof

==============
NFS3PROC_WRITE
==============

handled in **nfsd3_proc_write**

::

	fh_copy incoming fh to resp->fh
	set resp->committed and incoming
	nfsd_write
		if (file already open)		
			nfsd_permission		
			nfsd_vfs_write
		else
			nfsd_open
			nfsd_vfs_write
				if (nfsv2 and wgather on export)
					wgather = 1

				if (no f_op->fsync)
					# we cannot honour fsync
					# or COMMIT, so write the
					# data now itself
					stable = 2

				if (export async)
					stable = 0
				if (stable and no wgather)
					set O_SYNC
				set O_NONBLOCK on file

				set_fs
				vfs_writev
				set_fs

				update nfsdstats.io_write
				fsnotify_modify

				if (stable and wgather)
					wait_for_concurrent_writes
						# used only for NFSv2
						if (another write on inode ||
						    last write was done on this
							sleep 10ms
						if (inode dirty)
							nfsd_sync
					
			nfsd_close

===============
NFS3PROC_CREATE
===============

handled in **nfsd3_proc_create**

::

	fh_copy incoming fh to resp->dirfh
	fh_init resp->fh

	fh_verify 
	nfsd_create_v3
		check not . or ..
		fh_verify fh is a DIR
		lookup given name
		if (not exist)
			fh_verify MAY_CREATE
		fh_compose

		mnt_want_write
		if (already exist)
			if UNCHECKED and not REG
				return exists
			if UNCHECKED and REG
				update size
			if EXCLUSIVE and mtime/ctime/size do not match
				return exists
			mnt_drop_write
		else
			vfs_create
			if (export is sync)
				nfsd_sync_dir	# which calls fsync
			if (EXCLUSIVE create)
				put verifier in atime/mtime
			nfsd_create_setattr
				nfsd_setattr
			mnt_drop_write
			fh_update

		fh_unlock
		dput

==============
NFS3PROC_MKDIR
==============

handled in **nfsd3_proc_mkdir**

::

	fh_copy incoming fh to resp->dirfh
	fh_init resp->fh
	nfsd_create type DIR
		check not . or ..
		fh_verify fh is DIR

		if (resp dentry not set)
			lookup_one_len new name
			fh_compose new dentry
		else
			dget resp dentry
		
		verify dentry d_inode is still negative
		mnt_want_write
		vfs_create/mkdir/mknod

		if (export is sync)
			nfsd_sync_dir
			write_inode_now
		nfsd_create_setattr
		mnt_drop_write
		fh_update
		
		dput child

================
NFS3PROC_SYMLINK
================

handled in **nfsd3_proc_symlink**

::

	fh_copy incoming fh to resp->dirfh
	fh_init resp->fh
	nfsd_symlink
		check not . or ..
		fh_verify fh is DIR and MAY_CREATE
		lookup_one_len

		mnt_want_write
		vfs_symlink
		if export is sync
			nfsd_sync_dir
		fh_unlnk
		mnt_drop_write

		fh_compose
		dput new

==============
NFS3PROC_MKNOD
==============

handled in **nfsd3_proc_mknod**

::

	fh_copy incoming fh to resp->dirfh
	fh_init resp->fh
	nfsd_create

===============
NFS3PROC_REMOVE
===============

handled in **nfsd3_proc_remove**

::

	fh_copy incoming fh to resp->fh
	nfsd_unlink not DIR
		check not . or ..
		fh_verify

		fh_lock_netsted

		lookup_one_len
		if (no d_inode)
			return noent
		
		mnt_want_write
		if (not DIR)
			vfs_unlink
		else
			vfs_rmdir
		dput deleted dentry
		if (export is sync)
			nfsd_sync_dir

==============
NFS3PROC_RMDIR
==============

handled in **nfsd3_proc_rmdir**

fh_copy incoming fh to resp->fh
nfsd_unlink is DIR

===============
NFS3PROC_RENAME
===============

handled in **nfsd3_proc_rename**

::

	fh_copy from to fh to resp
	nfsd_rename
		fh_verify from fh DIR
		fh_verify to fh DIR

		check neither are . or ..

		lock_rename	# cannot use fh_lock, can deadlock

		lookup_one_len from name
		if no inode
			return error
		
		lookup_one_len new name

		verify both fh are coming from same mntpoint
		mnt_want_write
		vfs_rename
		if (export is sync)
			nfsd_sync_dir (todir)
			nfsd_sync_dir (fromdir)
		mnt_drop_write

		dput ndentry
		dput odentry

=============
NFS3PROC_LINK
=============

handled in **nfsd3_proc_link**

::

	fh_copy incoming from handle to resp->fh
	fh_copy incoming to handle to resp->tfh
	nfsd_link
		fh_verify from fh is DIR and MAY_CREATE
		fh_verify to fh is not DIR

		check not . or ..

		fh_lock_nested

		lookup_one_len new name
		mnt_want_write

		vfs_link
		if (export is sync)
			nfsd_sync_dir dest dir
			write_inode_now new inode
		mnt_drop_write
		dput dnew
		fh_unlock

================
NFS3PROC_READDIR
================

handled in **nfsd3_proc_readdir**

::

	fh_copy incoming fh to resp->fh
	nfsd_readdir
		# we don't use verifier

		vfs_llseek offset
			
		nfsd_buffered_readdir
			while (1)
				vfs_readdir
				encode
					for readdir it is
					nfs3svc_encode_entry

					for readdirplus it is
					nfs3svc_encode_entry_plus
				vfs_llseek SEEK_CUR
		nfsd_close

====================
NFS3PROC_READDIRPLUS
====================

handled in **nfsd3_proc_readdirplus**

::

	fh_copy incoming fh to resp->fh
	nfsd_readdir 

===============
NFS3PROC_FSSTAT
===============

handled in **nfsd3_proc_fsstat**

::

	nfsd_statfs
		fh_verify
		vfs_statfs
	fhput fh

===============
NFS3PROC_FSINFO
===============

handled in **nfsd3_proc_fsinfo**

::

	fh_verify
	copy all relevant stats from sb and nfsd variables
	fh_put

=================
NFS3PROC_PATHCONF
=================

handled in **nfsd3_proc_pathconf**

::

	fh_verify 
	set attribues 
	fh_put

===============
NFS3PROC_COMMIT
===============

handled in **nfsd3_proc_commit**

::

	fh_copy incoming fh to resp->fh
	nsfd_commit
		nfsd_open REG and MAY_WRITE
		if (export is sync)
			if f_op->f_sync
				nfsd_sync
					lock i_mutex
					nsfd_dosync
						filemap_write_and_wait
						fsync
					unlock
			else
				not supp

		nsfd_close



NFSv4 Procedures
----------------

NFSv4 procedures and their handling is defined in **nfsd_procedures4**

NULL procedure just return nfs_ok

COMPOUND procedure is handled in nfsd4_proc_compound which loops 
for all the procedures inside the compound operation

all nfsv4 ops are defined in **nfsd4_ops**

**nfsd4_enc_ops** defines all functions to be used for encoding 
replies

===================
nfsd4_proc_compound
===================

::

	fh_init resp-> current_fh with NFS4_FHSIZE
	fh_init resp-> save_fh

	if not NFSv4
		rq_usedeferral = 0	# 3.0 kernel seems to completely
					# disable referrals with comment
					# that compounds make it hard to
					# avoid non-idempotency problems 

					# Is this RPC deferral or NFSv4
					# deferral ?

					# XXX: need to figure out how 
					# this affects

	nfs41_check_op_ordering		# XXX: what does this do

	while (current op not failed, and all ops not processsed)
		check if XDR encode failed for curren op

		if (current_fh has no dentry)
			check if op is allowed WITHOUT_FH
		if (current fh is from export that is migrated)
			check if op is allowed with ABSENT_FS

		execute op with current state

		if (op->status is replay_me)
			nfsd4_encode_replay
			status = replay->rp_status
		else
			nfsd4_encode_operation
				call nfsd4_enc_ops[opnum] to call 
				corresponding encode_ops for a op type

				if op error check nfsd4_check_drc_limit
				to verify we have enough space to hold
				the error status

			status = op->status

		increment counter for stats of this op	

	resp->cstate.status = status	# set status of the compound
					# as status of the last op
					# or the first op that failed
		
	fh_put current_fh
	fh_put save_fh

=========
OP_ACCESS
=========

handled in **nfsd4_access**

::

	nfsd_access for current_fh

========
OP_CLOSE
========

handled in **nfsd4_close**

::

	nfs4_lock_state

	nfs4_preprocess_seqid_op for OPEN_STATE or CLOSE_STATE
		check if stateid is all 0 or all 1
			# stateid of all 0 is no lock/lease state
			# process as normal read
			# stateid of all 1 is bypass locking for
			# READ, no bypass allowed for WRITE

		STALE_STATEID	# check if stateid is stale or not
			check boot_time in stateid is ahead 
			current boot_time

		check if there is a NFSv4.1 session
		and set flags as having HAS_SESSION

		find_stateid
			if LOCK|RD|WR STATE 
				search in &lockstateid_hashtbl
			if OPEN|RD|WR STATE
				search in &stateid_hashtbl

		if (stateid not found)
			check if it is replay in DRC
			search_close_lru
				search for si_stateownerid in close_lru cache
		
		if (lock)
			if (lk_is_new)
				validate owner
				nfs4_check_openmode
					# checks if lock/access type is 
					# allowed for the open mode 
					# stored in stateid
			else
				nfs4_check_openmode

			nfs4_check_fh
				# check dentry in stateid is
				# same as dentry in current_fh

			verify if seqid passed = seqid expected for 
							state owner
			if (passed in seqid = last seqid )
				return replay_me

			check if state owner CONFIRM matches incoming 
			flags
			
			check_stateid_generation
			check incoming stateid generation is less
			than current generation for stored stateid

			renew_client	# automatically renew leases
					# for this client, as client
					# is alive
				move client to tail in client_lru cache
				cl_time = get_seconds

	update_stateid
		# update generation counter for stateid

	update stateid in close reply
		# so clients gets new expected stateid (generation 
							has changed)

	release_open_stateid
		unhash_generic_stateid
			remove from hash list of state,file,stateowner
		release_stateid_lockowners
			for each lockowner for this stateid
				release_lockowner
					unhash_lockowner
						# XXX: why is it unhashing
						# stateowner from all lists
					nfs4_put_stateowner
				nfsd_close
				free_generic_stateid
					put_nfs4_file
						# if no futher references 
						# to this nfs4_file, then 
						delete file from hash
						iput inode
						free from slab file_slab

	if current stateowner has no more stateids
		move statewoner to so_close_lru to be picked up
		laundromat service after lease expire time to 
		handle CLOSE replay

	set replay_owner for cached state as close owner
	nfs4_unlock_state

=========
OP_COMMIT
=========

handled in **nfsd4_commit**

::

	set commit verifier as nfssvc_boot time

	nfsd_commit

=========
OP_CREATE
=========

handled in **nfsd4_create,**

::

	fh_init for new fh to be created
	fh_verify incoming fh is a DIR

	check_attr_support writeable	# check if incoming attributes are
					# supported
		check attributes requested are in acl_supported
		if FATTR4_WORD0_ACL 
			check inode has support POSIXACL
		if (writeable)
			check if all attr requested are writeable

	based on filetype
		call nfsd_create or nfsd_symlink
		# REG files cannot be created by this call
		# REG files should be created with OPEN

	if incoming acl
		do_set_nfs4_acl
			nfsd4_set_nfs4_acl
				fh_verify
				nfs4_acl_nfsv4_to_posix
					# convert NFSv4 acl to posix
				set_nfsv4_acl_one XATTR_ACCESS
					posix_acl_xattr_size
					posix_acl_to_xattr
					vfs_setxattr

				if dir
					set_nfsv4_acl_one XATTR_DEFAULT

	set_change_info
	fh_put new fh

==============
OP_DELEGRETURN
==============

handled in **nfsd4_delegreturn,**

::

	fh_verify
	nfs4_lock_state
	check stateid all 0 or 1
	STALE_STATEID
	is_delegation_stateid
		si_fileid == 0
	find_delegation_stateid
		find_file for inode based on fh
			search in file_hashtbl for this inode
			get_nfs4_file
		find_delegation_file
			search in nfs4_file delegations for this
			stateowner id
		put_nfs4_file

		check_stateid_generation
		renew_client
		unhash_delegation
			delete delegation from perfile/perclnt lists
			delete delegation from recall_lru
			nfs4_close_delegation
				if dl_flock
					vfs_setlease F_UNLCK
				nfsd_close
					fput
			nfs4_put_delegation
				if no more users of delegation
				put_nfs4_file
				num_delegations--	# no lock required
							# here because 
							# nfs4_lock_state
							# done by caller

	nfs4_unlock_state

==========
OP_GETATTR
==========

handled in **nfsd4_getattr**

allowed on ABSENT_FS, so client can find out that the FS has
infact be moved, and moved where by querying hte fs_locations
attribute

::

	fh_verify current_fh
	check incoming attr list do not try to get WRITEONLY_ATTRS
	mask requested attribute list to supported attr list
	set resp->fhp as current_fh, encode will copy attributes from fh

========
OP_GETFH
========

handled in **nfsd4_getfh**

::

	set response fh as current_fh

=======
OP_LINK
=======

handled in **nfsd4_link**

::

	nfsd_link from current_fh to given filename in save_fh

	set_change_info

=======
OP_LOCK
=======

handled in **nfsd4_lock**

::

	fh_verify current_fh
	nfs4_lock_state

	if lk_is_new
		# Client indicates that this is a new lockowner

		STALE_CLIENTID and not NFSv4.1 session
			# check clientid is not stale

		nfs4_preprocess_seqid_op for OPEN_STATE

		lock_ownerstr_hashval
			# create hashval for new owner string
		
		alloc_init_lock_stateowner
			lockownerid_hashval based on current_ownerid
			init other list for stateowner
			add owner to &lock_ownerid_hashtbl
					&lock_ownerstr_hashtbl
					&open_stp->st_lockowners
			so_id = current_ownerid++	# caller has to 
							# take 
							# nfs4_lock_state

		alloc_init_lock_stateid
			init other lists in stateid struct
			add stateid to &lockstateid_hashtbl
					&fp->fi_stateids
					&sop->so_stateids
			st_stateowner = sop
			get_nfs4_file
			st_file = file
			si_boot = get_seconds
			generation = 0
			openstp = stp returned for OPEN using which
					lock is requested

	else
		nfs4_preprocess_seqid_op LOCK_STATE	# lock owner and stateid
							# already exist

	if locks_in_grace and not reclaim lock
		return err_grace

	if not locks_in_grace and reclaim lock
		return no_grace

	set lock owner as lockowner in-memory in NFS

	vfs_lock_file
		
	if (error and lk_is_new and new lock onwer allocated)
		release_lockowner new lock owner
	nfs4_unlock_state

========
OP_LOCKT
========

handled in **nfsd4_lockt**

::

	locks_in_grace return err_grace
	nfs4_lock_state
	no nfsd4_has_session and STALE_CLIENTID
		return error

	fh_verify
	nfsd_test_lock
		nfsd_open REG
		vfs_test_lock
		nfsd_close
	set result of test 
	nfs4_unlock_state

========
OP_LOCKU
========

handled in **nfsd4_locku**

::

	nfs4_lock_state
	nfs4_preprocess_seqid_op LOCK_STATE
	vfs_lock_file
	update_stateid
	copy updated stateid to response
	nfs4_get_stateowner
	set replay_owner = lockowner
	nfs4_unlock_state

=========
OP_LOOKUP
=========

handled in **nfsd4_lookup**

::

	nfsd_lookup

==========
OP_LOOKUPP
==========

handled in **nfsd4_lookupp**

::

	fh_init	new fh
	exp_pseudoroot
		# the root of the pseudofs, for a given NFSv4 
		# client.   The root is defined to be the 
		# export point with fsid==0

		mk_fsid of fsid 0
		rqst_exp_find 

		fh_compose
		check_nfsd_access

		exp_put
	if incoming fh == psuedoroot
		# no parent for pusedoroot
		return error

	nfsd_lookup ..

==========
OP_NVERIFY
==========

handled in **nfsd4_nverify**

::

	opposite of OP_VERIFY

	_nfsd4_verify
		fh_verify current_fh
		check_attr_support non-writeable

		nfsd4_encode_fattr
			if exp fslocs migrated
				fattr_handle_absent_fs and return
			vfs_getattr
			if (fs related values like SPACE_AVAIL)
				vfs_statfs

			if FATTR4_WORD0_FILEHANDLE | FATTR4_WORD0_FSID and input fh
				allocate a temp fh
				fh_compose from dentry

			if (acl requested)
				nfsd4_get_nfs4_acl
					_get_posix_acl	XATTR_ACCESS
					posix_acl_from_mode

					if dir
						_get_posix_acl XATTR_DEFAULT
				nfs4_acl_posix_to_nfsv4

			if FATTR4_WORD1_MOUNTED_ON_FILEID
				handle getting mnt_root ino
		
		memcmp input expected attr with read attr
		if same
			return err_same
		
	if not_same
		return ok
	else
		return same

=======
OP_OPEN
=======

handled in **nfsd4_open,**

::

	if op_create and not CLAIM_NULL
		return error

	if (has session)
		copy_clientid to open->op_clientid from session

	nfs4_lock_state
	nfsd4_process_open1	
		STALE_CLIENTID

		ownerstr_hashval for cl_id/op_owner pair
		find_openstateowner_str	
			search in &ownerstr_hashtbl for matching 
			clid/owner pair
		
		if no cl_id/owner pair
			find_confirmed_client
				# verify atleast client is CONFIRMed
				search in &conf_id_hashtbl for client
		
		if (sessions in use)
			no seqid processing required
		
		if (owner found but not confirmed !sop->so_confirmed)
			release_openowner
			alloc_init_open_stateowner
		
		if (incoming seqid is prev seqid)
			if replay info available
				return replay_me
		
		if (incoming seqid != expected seqid)
			return bad_seqid

		remove stateowner from close_lru list
		renew_client

	if replay_me
		fh_put current_fh
		fh_copy_shallow open_fh from replay data to current_fh
		fh_verify current_fh

	nfsd4_check_open_attributes
		if op_create == OPEN_CREATE
			if (UNCHECKED || GUARDED)
				check_attr_support nfsd_attrmask
			if (EXCLUSIVE4_1)
				check_attr_support nfsd41_ex_attrmask

	if locks_in_grace and not NFS4_OPEN_CLAIM_PREVIOUS
		return err_grace

	if not locks_in_grace and NFS4_OPEN_CLAIM_PREVIOUS
		return no_grace

	if (NFS4_OPEN_CLAIM_DELEGATE_CUR || NFS4_OPEN_CLAIM_NULL)
		do_open_lookup
			fh_init
			if op_create
				nfsd_create_v3

				if NFS4_CREATE_EXCLUSIVE
					return FATTR4_WORD1_TIME_ACCESS and
						FATTR4_WORD1_TIME_MODIFY as 
						attributes used for verifier

			else
				nfsd_lookup
				fh_unlock current_fh

			
			if is_create_with_attrs
				do_set_nfs4_acl

			set_change_info
			fh_dup2 newfh to current_fh
			fh_copy_shallow		# set reply cache

			if (not created now)
				do_open_permission
					fh_verify for accessmode as requested
					for open request
		

	elif NFS4_OPEN_CLAIM_PREVIOUS
		do_open_fhandle
			nfs4_check_open_reclaim
				nfs4_find_reclaim_client
					find_confirmed_client or return NULL
					search in &reclaim_str_hashtbl

				fh_copy_shallow current_fh to replay
				chekc truncate reqd
				do_open_permission

	elif NFS4_OPEN_CLAIM_DELEGATE_PREV:
		err_notsupp
			# delegation reclaim not supported ?


	nfsd4_process_open2
		access_valid and deny_valid
		find_file
		if (nfs4_file in cache)
			nfs4_check_open
				search all stateids for this file
					if not openstateids (maybe lockstateids)
						ignore
					if stateowner is requested owner
						remember stateid
					test_share
						# check if this openstateids 
						# has conflicting share resrvs
						# with requested share resrvs

			nfs4_check_deleg
				find_delegation_file
					# check if there is a delegation
					# on this file for this owner
				nfs4_check_delegmode
					if open is WRITE but delegation
					for this owner is READ
						return err_openmode

				# if open is not based on an existing
				# delegation then return
				op_claim_type != NFS4_OPEN_CLAIM_DELEGATE_CUR
					return ok

		else (nfs4_file not in cache)
			NFS4_OPEN_CLAIM_DELEGATE_CUR 
				return err	# we don't even have the 
						# file open

			alloc_init_file


		if (stateid found for this owner)
			nfs4_upgrade_open
				if new access is write
					get_write_access
					mnt_want_write
					file_take_write

				nfsd4_truncate
					nfsd_setattr

				update the file->f_mode with new open modes
				update the reply share_access with granted
					access modes

			update_stateid
		
		else (stateid not found)
			# new open for this owner

			nfs4_new_open
			init_stateid
				initialise all the lists
				add stateid to &stateid_hashtbl
						&sop->so_stateids
						&fp->fi_stateids
				st_stateowner = sop
				get_nfs4_file
				si_boot = get_seconds
				set st_access_bmap and st_deny_bmap
					based on open request
				st_openstp NULL	# This is a open stateid
						# by itself, it is not based
						# on any other opens, yet
			nfsd4_truncate
			if session
				update_stateid

		
		copy reply stateid from stateid created/found

		if (has_session)
			state_owner confirmed = 1
				# no OPEN_CONFIRM required
		
		nfs4_open_delegation	# attempt to hand out a delegation
			NFS4_OPEN_CLAIM_PREVIOUS
				if (! callback set for client)
					op_recall = 1
						# delegation is granted but
						# since callback not setup
						# immediately recalling 
						# the delegation
				if (delegate_type != DELEGATE_NONE)
					# delegation cannot be reclaimed
					# incorrect protocol, while reclaiming
					# delegate_type should be NONE

			NFS4_OPEN_CLAIM_NULL
				locks_in_grace 
					delegation not granted
				callback not set or owner not confirmed
					delegation not granted


			alloc_init_deleg
				check not exceeding max_delegations
				num_delegations++
				init lists
				get_nfs4_file
				get_file (vfs_file)
				si_boot = get_seconds
				fh_copy_shallow current_fh to delegation
				add to &fp->fi_delegations
					&clp->cl_delegations

			vfs_setlease
			memcpy delegation state id to resp

		put_nfs4_file
		NFS4_OPEN_CLAIM_PREVIOUS and open succeed
			nfs4_set_claim_prev
				set owner confirmed so_confirmed = 1
				cl_firststate = 1

		op_rflags = NFS4_OPEN_RESULT_LOCKTYPE_POSIX
		if (no session and owner not confirmed)
			# set as OPEN_CONFIRM not reqd
			op_rflags | = NFS4_OPEN_RESULT_CONFIRM
		

	if (open succeed and open stateowner set)
		nfs4_get_stateowner
		set replay_owner as stateowner

	nfs4_unlock_state

===============
OP_OPEN_CONFIRM
===============

handled in **nfsd4_open_confirm**

::

	fh_verify current_fh
	nfs4_lock_state
	nfs4_preprocess_seqid_op	CONFIRM | OPEN_STATE
	set owner as confirmed
	update_stateid
	copy stateid to resp
	nfsd4_create_clid_dir
		if no rec_dir_init, then return
		if cl_firststate, then return
		nfs4_save_creds
			prepare_creds new
			put_cred new

		lock parent directory
		lookup_one_len
		if dentry found
			unlock inode
			nfs4_reset_creds
		
		mnt_want_write
		vfs_mkdir
		mnt_drop_write
		unlock inode
		cl_firststate = 1
		nfsd4_sync_rec_dir
			nfsd_sync_dir

	set replay_owner as current owner
	nfs4_unlock_state

=================
OP_OPEN_DOWNGRADE
=================

handled in **nfsd4_open_downgrade**

::

	nfs4_lock_state
	nfs4_preprocess_seqid_op OPEN_STATE
	check if new access/deny is a downgrade of existing
	set_access
	nfs4_file_downgrade
		drop_file_write_access
		set file mode as READ and remove write
	update new access/deny into resp
	update_stateid
	copy new stateid to resp
	set replay_owner to current owner
	nfs4_unlock_state

========
OP_PUTFH
========

handled in **nfsd4_putfh**

since this is the first operation to set current_fh, this is allowed
without any current_fh. Obviously allowed with ABSENT_FS

::

	fh_put current_fh
	copy and set current_fh from incoming fh
	fh_verify

===========
OP_PUTPUBFH
===========

handled in **nfsd4_putrootfh**

::

	fh_put current_fh	# we don't need current_fh anymore
				# user is attempting to change the fh
	exp_pseudoroot as current_fh

============
OP_PUTROOTFH
============

handled in **nfsd4_putrootfh**

::

	same as OP_PUTPUBFH

=======
OP_READ
=======

handled in **nfsd4_read**

::

	nfs4_lock_state
	nfs4_preprocess_stateid_op
		grace_disallows_io
			if locks_in_grace and mandatory_lock on inode
				return err_grace
		
		if stateid all 0 or all 1
			check_special_stateids
				if stateid all 1 and read
					bypass locking and return ok
				else locks_in_grace
					return err_grace
					#
					# we don't allow read/write when 
					# in grace, as we don't know any 
					# delegations or locks we might
					# have given, might have cached 
					# data
				else if write_requested
					nfs4_share_conflict for DENY_WRITE
						find nfs4_file for inode

						search in stateids for file
						if there are any DENY's set

						# FIXME: since this 
						# verification is done at NFS
						# level and not at FS/OS level
						# this won't work for CFS

				else read_requested and stateid 0
					nfs4_share_conflict for DENY_READ

		STALE_STATEID
		
		if is_delegation_stateid
			find_delegation_stateid
			check_stateid_generation
			nfs4_check_delegmode
			renew_client
		else # open or lock state id
			find_stateid
			nfs4_check_fh
			check stateowner confirmed
			check_stateid_generation
			nfs4_check_openmode
			renew_client

actual **nfsd_read** is called from **nfsd4_encode_read** while encoding
reply which does the actual read of data from file

==========
OP_READDIR
==========

handled in **nfsd4_readdir**


::

	check if requested permissions are supported and no write 
	attributes are requested

	check if cookie is valid, cookie == 1/2 is for ./.. and is
	invalid cookie, we never return cookie with 1/2

	set fhp in resp as current_fh


actual **nfsd_readdir** is done from **nfsd4_encode_readdir**

===========
OP_READLINK
===========

handled in **nfsd4_readlink**

::

	just set the fhp as current_fh

actual **nfsd_readlink** is done from **nfsd4_encode_readlink**

=========
OP_REMOVE
=========

handled in **nfsd4_remove**

::

	locks_in_grace
		return err_grace
	nfsd_unlink
	fh_unlock current_fh
	set_change_info from current_fh

=========
OP_RENAME
=========

handled in **nfsd4_rename**

::

	if save_fh not set return err
	if locks_in_grace and save_fh export has no no_subtree_check
		return err_grace
	nfsd_rename
	set_change_info frominfo from current_fh
	set_change_info toinfo from save_fh

========
OP_RENEW
========

handled in **nfsd4_renew**

allows op to be called WITHOUT_FH and for ABSENT_FS, it just renews
leases client has and only needs to identify client. Automatic
lease renewal is also done for a client when client does a op
which passes all valid tests

::

	nfs4_lock_state
	STALE_CLIENTID
		check boot_time in the client_id we generated is the
		current boot_time
	find_confirmed_client
	renew_client
	if client has delegations and callback not set !cb_set
		return err_cb_path_down # make client aware that callback 
					# path is broken we wouldn't have 
					# given delegations if callback
					# is not up. It is either callback
					# was up when delegation was given
					# but down now, or delegation 
					# recovery happened after server 
					# failure and we found callback not
					# set so we recalled delegtaions
					# but recall is not complete yet

============
OP_RESTOREFH
============

handled in **nfsd4_restorefh**

::

	if save_fh has no dentry return err
	fhdup2 current_fh from save_fh

=========
OP_SAVEFH
=========

handled in **nfsd4_savefh**

::

	if no dentry for current_fh return err
	fh_dup2 save_fh from current_fh

==========
OP_SECINFO
==========

handled in **nfsd4_secinfo**

::

	fh_init		# response fh
	nfsd_lookup_dentry	# secinfo->si_name
				# xxx: what does lookup 
	if dentry not found
		return err_noent
	else
		set export in secinfo as export for current_fh
	dput dentry

handling of setting real secinfo from exp is in 
**nfsd4_encode_secinfo**

==========
OP_SETATTR
==========

handled in **nfsd4_setattr**

::

	if (size change requested)
		nfs4_lock_state
		nfs4_preprocess_stateid_op
		nfs4_unlock_state

	mnt_want_write
	check_attr_support nfsd_attrmask
	if acl set requested
		nfsd4_set_nfs4_acl
	nfsd_setattr
	mnt_drop_write

==============
OP_SETCLIENTID
==============

handled in **nfsd4_setclientid**

::

	This is the first request from a client, to identify itself to the
	server, so can be done WITHOUT_FH and with ABSENT_FS

	nfs4_make_rec_clidname
		compute a md5 hash and return that clientid that can
		be used to uniquely identify a client
	nfs4_lock_state

	find_confirmed_client_by_str
	if (client found usign the generated client str)
		if incoming client cred does not match existing cred
			return clid_inuse

	find_unconfirmed_client_by_str
	if (no confirmed client, but unconfirmed client found)
		expire_client	# existing unconf client
		create_client
			alloc and initialise gss
			set recdir as clientname 
				# recdir name is set, but recdir not
				# created in local FS yet
			cl_count =1
			
			cb_set = 0	# callback not setup yet

			initialise lists
			cb_slot_busy = 0

			init wait queue for callback
			in cl_cb_waitq

			store client verifier 
			store client addr
			store client cred (principal)
			gen_confirm
				# set confirm data for client
				# based on get_seconds
		
		gen_clid
			cl_boot = get_seconds	# 3.0 kernel uses 
						# boot_time at all 
						# places instead of
						# get_seconds

			cl_id = current_clientid++
		

	if (existing client found and cred match)
		# possible callback update

		if (unconfirmed also found)
			expire_client unconfirmed client

		create_client
		copy_clid from existing client to new client

		
	if (existing client found and no cred match, and no unconfirmed 
								client)
		# possible client reboot, so client has 
		# initiated a new SETCLIENTID with a new verifier

		create_client
		gen_clid for new client

	if (existing client found and no cred match, and no unconfirmed 
								client)
		# possible client reboot, before it could 
		# confirm its previous SETCLIENTID

		expire_client unconfirmed client
		create_client new client
		gen_clid new client

	gen_callback
		check tcp/tcp6 is provided for callback, no udp support

		set cb_addr and cb_addrlen based on provided callback 
		data

		cb_prog = incoming callback_prog
		cb_ident = incoming callback_ident	
			# ident is used by client to identify which server
			# is issuing the callback, this allowes the client
			# to use the same callback program for multiple
			# servers, and identify the server based on ident
		
	add_to_unconfirmed
		add to &unconf_str_hashtbl
		add to &unconf_id_hashtbl
		add to tail of &client_lru
		set cl_time as get_seconds

	copy resp clid from allocated client object
	copy resp confirm date from allocated client object

	nfs4_unlock_state

======================
OP_SETCLIENTID_CONFIRM
======================

handled in **nfsd4_setclientid_confirm**

This is the first request from a client, to identify itself to the
server, so can be done WITHOUT_FH and with ABSENT_FS

::

	STALE_CLIENTID
	nfs4_lock_state
	find_confirmed_client
	find_unconfirmed_client
	if confirmed client found but client cl_addr does not match
		return err
	if unconfirmed client found but client cl_addr does not match
		return err

	if conf && unconf && verifier match with unconf
		callback update
		verify cred same as unconf
		cb_set = 0
		expire_client unconf

	if (conf && !unconf)
		# probable retransmit of confirm message
		verify creds

	if (!conf && unconf && verifier match)
		# Normal case, client is confirming its previous
		# SETCLIENTID, new or rebooted

		verify creds match with unconf

		find_confirmed_client_by_str unconf->cl_recdir
		if already existing conf 
			nfsd4_remove_clid_dir	
				mnt_want_write
				cl_firststate = 0
				nfs4_save_creds into a local variable
				nfsd4_unlink_clid_dir
					lock on parent
					lookup_one_len
					if (dentry found)
						vfs_rmdir
					dput

				nfs4_reset_creds using stored local
				nfsd4_sync_rec_dir
				mnt_drop_write
			expire_client

		move_to_confirmed
			move client to &conf_id_hashtbl
			add client to &conf_str_hashtbl
			renew_client
		
		nfsd4_probe_callback
			setup_callback_client
				rpc_create
				if callback setup success
					cl_cb_conn->cb_client = callback 
								client
				do_probe_callback
					rpc_call_async with 
							nfsd4_cb_probe_ops
					# if callback succeeds then from 
					# .done (nfsd4_cb_probe_done) cb_set
					# will be set to 1, otherwise it
					# remains at its previous value

	if (no conf or unconf)
		# probably we rebooted, and client was in
		# confirming state before

		return stale_clientid

	nfs4_unlock_state

=========
OP_VERIFY
=========

handled in **nfsd4_verify**

::

	opposite of OP_NVERIFY

	_nfsd4_verify

	if same
		return ok
	else
		return not_same

========
OP_WRITE
========

handled in **nfsd4_write**

::

	nfs4_lock_state
	nfs4_preprocess_stateid_op
	get_file
	nfs4_unlock_state

	set reps wverifier as nfssvc_boot
	nfsd_write

====================
OP_RELEASE_LOCKOWNER
====================

handled in **nfsd4_release_lockowner**

lockowner operation does not require to have a filehandle
nor a FS so works WITHOUT_FH and ABSENT_FS

::

	STALE_CLIENTID
	nfs4_lock_state

	#
	# There could be multiple lockowners which match
	# from different clients
	#
	for each in &lock_ownerid_hashtbl
		if lockowner found
			for each stateid of lockowner
				check_for_locks
					# check if the lockowner has
					# any locks, if any locks
					# then lockowner cannot be 
					# released, return locks_held
				use so_perclient to create a list
				of matched lockowners, so_perclient
				is not used for lockowners


	for each lockowner found
		release_lockowner

	nfs4_unlock_state

==============
OP_EXCHANGE_ID
==============

FIXME : need to read NFSv4.1

=================
OP_CREATE_SESSION
=================

FIXME : need to read NFSv4.1

==================
OP_DESTROY_SESSION
==================

FIXME : need to read NFSv4.1

===========
OP_SEQUENCE
===========

FIXME : need to read NFSv4.1



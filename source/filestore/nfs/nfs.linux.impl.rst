NFS Linux Implementation
========================

Module Load
-----------

init_nfsd
	nsf4_state_init
		# FIXME: need to read what it does
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
		# FIXME: need to understand what this does

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
	3 alphanumeric words (can contain escape sequences)

	domain:         client domain name

	path:           export pathname

	maxsize:        numeric maximum size of @buf

Output :
	Passed in buf, will have filehandle in hex

Used by **mountd** in NFSv3 to get a initial filehandle for a 
filesystem being mounted by client

Code :
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
	 buf:    '\n'-terminated C string containing a
		presentation format IP address
	 size:   length of C string in @buf


Code : 
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
	 buf:    '\n'-terminated C string containing
		 absolute pathname of a local file system	
	 size:   length of C string in @buf


Code : 
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
	buf:            C string containing an unsigned
			integer value representing the
			number of NFSD threads to start
			non-zero length of C string in @buf

Output:
	NFS service is started;
        passed-in buffer filled with '\n'-terminated C
	string numeric value representing the number of
	running NFSD threads;

Code :
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
			# FIXME: need to figure out what
			# it does

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
	buf:            C string containing whitespace-
			separated unsigned integer values
			representing the number of NFSD
			threads to start in each pool

NFS threads cannot be started by writing to pool_threads. It has to 
be started by writing to threads, and then can be balanced by writing
to pool_threads

Code :
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
	buf:            C string containing whitespace-
			separated positive or negative
			integer values representing NFS
			protocol versions to enable ("+n")
			or disable ("-n")

Code : __write_versions

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
	passed-in buffer filled with a '\n'-terminated C
	string containing a whitespace-separated list of
	named NFSD listeners;


Code : calls __write_ports

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
	buf:            C string containing an unsigned
			integer value representing the new
			NFS blksizea

Code :
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
	buf:            C string containing an unsigned
			integer value representing the new
			NFSv4 lease expiry time

Code : calls __write_leasetime

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
	buf:            C string containing the pathname
			of the directory on a local file
			system containing permanent NFSv4
			recovery data


Code : calls __write_recoverydir
	
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

nfsd_dispatch
-------------

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

NFSv3 Procedures
----------------

==========================
nfs3svc_decode_fhandleargs
==========================

General procedure for decoding args and verify filehandle, set 
as .pc_decode for all NFSv3 procedures

Code : calls decode_fh

fh_init
copy on-the-wire fh contents to a svc_fh structure

=========
fh_verify
=========

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

return ok

================
NFS3PROC_GETATTR
================

handled in **nfsd3_proc_getattr,**

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

fh_copy incoming fh to resp->fh
nfsd_access
	fh_verify
	check access permissions
		nfsd_permission

=================
NFS3PROC_READLINK
=================

handled in **nfsd3_proc_readlink**

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

fh_copy incoming fh to resp->dirfh
fh_init resp->fh
nfsd_create

===============
NFS3PROC_REMOVE
===============

handled in **nfsd3_proc_remove**

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

fh_copy incoming fh to resp->fh
nfsd_readdir 

===============
NFS3PROC_FSSTAT
===============

handled in **nfsd3_proc_fsstat**

nfsd_statfs
	fh_verify
	vfs_statfs
fhput fh

===============
NFS3PROC_FSINFO
===============

handled in **nfsd3_proc_fsinfo**

fh_verify
copy all relevant stats from sb and nfsd variables
fh_put

=================
NFS3PROC_PATHCONF
=================

handled in **nfsd3_proc_pathconf**

fh_verify 
set attribues 
fh_put

===============
NFS3PROC_COMMIT
===============

handled in **nfsd3_proc_commit**

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



NFSv4
=====

.. contents::

References
----------

NFSv4 RFC
	https://www.ietf.org/rfc/rfc3530.txt

NFSv4 vs NFSv3 comparison slides
	http://www.citi.umich.edu/projects/nfsv4/OLS2001/sld011.htm

NFSv4 ACL mapping
	https://tools.ietf.org/html/draft-ietf-nfsv4-acl-mapping-05


Security RPCSEC_GSS
-------------------

With the
use of RPCSEC_GSS, various mechanisms can be provided to offer
authentication, integrity, and privacy to the NFS version 4 protocol.
Kerberos V5 will be used as described in [RFC1964] to provide one
security framework.  The LIPKEY GSS-API mechanism described in
[RFC2847] will be used to provide for the use of user password and
server public key by the NFS version 4 protocol.  With the use of
RPCSEC_GSS, other mechanisms may also be specified and used for NFS
version 4 security.

To enable in-band security negotiation, the NFS version 4 protocol
has added a new operation which provides the client a method of
querying the server about its policies regarding which security
mechanisms must be used for access to the server's filesystem
resources.  With this, the client can securely match the security
mechanism that meets the policies specified at both the client and
server.

=======
SECINFO
=======

The new SECINFO operation will allow the client to determine, on a
per filehandle basis, what security triple is to be used for server
access.  In general, the client will not have to use the SECINFO
operation except during initial communication with the server or when
the client crosses policy boundaries at the server.  It is possible
that the server's policies change during the client's interaction
therefore forcing the client to negotiate a new security triple.

==============
Security Error
==============

Based on the assumption that each NFS version 4 client and server
must support a minimum set of security (i.e., LIPKEY, SPKM-3, and
Kerberos-V5 all under RPCSEC_GSS), the NFS client will start its
communication with the server with one of the minimal security
triples.  During communication with the server, the client may
receive an NFS error of NFS4ERR_WRONGSEC.  This error allows the
server to notify the client that the security triple currently being
used is not appropriate for access to the server's filesystem
resources.

RPC Procedures NULL and COMPOUND
--------------------------------

The model used for **COMPOUND** is very simple.  There is no logical OR
or ANDing of operations.  The operations combined within a COMPOUND
request are evaluated in order by the server.  Once an operation
returns a failing result, the evaluation ends and the results of all
evaluated operations are returned to the client.

The COMPOUND
procedure has a method of passing a filehandle from one operation to
another within the sequence of operations.  There is a concept of a
"current filehandle" and "saved filehandle".  Most operations use the
"current filehandle" as the filesystem object to operate upon.  The
"saved filehandle" is used as temporary filehandle storage within a
COMPOUND procedure as well as an additional operand for certain
operations.

The **NFS4_CALLBACK** program is used to provide server to client
signaling and is constructed in a similar fashion as the NFS version
4 program.  The procedures **CB_NULL and CB_COMPOUND** are defined in the
same way as NULL and COMPOUND are within the NFS program.  The
CB_COMPOUND request also encapsulates the remaining operations of the
NFS4_CALLBACK program.  There is **no predefined RPC program number for
the NFS4_CALLBACK** program.  It is up to the client to specify a
program number in the "transient" program range.  The program and
port number of the NFS4_CALLBACK program are provided by the client
as part of the SETCLIENTID/SETCLIENTID_CONFIRM sequence

 The basic structure of the COMPOUND procedure is:

::

   +-----+--------------+--------+-----------+-----------+-----------+--
   | tag | minorversion | numops | op + args | op + args | op + args |
   +-----+--------------+--------+-----------+-----------+-----------+--

and the reply's structure is:

::

      +------------+-----+--------+-----------------------+--
      |last status | tag | numres | status + op + results |
      +------------+-----+--------+-----------------------+--

Contained within the COMPOUND results is a **"status"** field.  If the
results array length is non-zero, this status must be equivalent to
the **status of the last operation** that was executed within the
cOMPOUND procedure.  Therefore, if an operation incurred an error
then the "status" value will be the same error value as is being
returned for the operation that failed.

The definition of the **"tag"** in the request is **left to the
implementor.**  It may be used to summarize the content of the compound
request for the benefit of packet sniffers and engineers debugging
implementations.  However, the value of "tag" in the response SHOULD
be the same value as provided in the request.  This applies to the
tag field of the CB_COMPOUND procedure as well.

==============
OPEN and CLOSE
==============

The NFS version 4 protocol introduces OPEN and CLOSE operations.  The
OPEN operation provides a single point where file lookup, creation,
and share semantics can be combined.  The CLOSE operation also
provides for the release of state accumulated by OPEN.



No MOUNTD
---------

The NFS version 4 protocol does not require a separate protocol to
provide for the initial mapping between path name and filehandle.
Instead of using the older MOUNT protocol for this mapping, the
server provides a **ROOT filehandle** that represents the logical root or
top of the filesystem tree provided by the server.  The server
provides **multiple filesystems by gluing them together with pseudo
filesystems**.  These pseudo filesystems provide for potential gaps in
the path names between real filesystems.

The owner string **"nobody"** may be used to designate an anonymous user,
which will be associated with a file created by a security principal
that cannot be mapped through normal means to the owner attribute.



Filehandle
----------

================
Filehandle Types
================

* **Persistent filehandle**
* **Volatile filehandle**

volatile filehandle can no longer be used, error of **NFS4ERR_FHEXPIRED**.

The mandatory attribute **"fh_expire_type"** is used by the client to
determine what type of filehandle provided by server

===============
Root Filehandle
===============

The **ROOT filehandle** is the **"conceptual" root** of the 
filesystem name space.  The client uses or starts with the ROOT
filehandle by employing the **PUTROOTFH** operation, instructs 
the server to set the "current" filehandle to the
ROOT of the server's file tree.  Client can then traverse the 
entirety of the server's file tree with the LOOKUP operation.

=================
Public Filehandle
=================

**PUBLIC filehandle**.  Unlike the ROOT filehandle, the PUBLIC 
filehandle may be **bound or represent an arbitrary filesystem 
object**.  The server is responsible for this binding.  
It may be that the PUBLIC filehandle and the ROOT
filehandle refer to the same filesystem object.

The client uses the PUBLIC filehandle via the **PUTPUBFH** operation.

====================
Distinct Filehandles
====================

In the NFS version 4 protocol, there is now the possibility to have
significant **deviations from a "one filehandle per object" model**
because a filehandle may be constructed on the basis of the object's
pathname.  Therefore, clients need a reliable method to determine if
two filehandles designate the same filesystem object.  If clients
were simply to assume that all distinct filehandles denote distinct
objects and proceed to do data caching on this basis, caching
inconsistencies would arise between the distinct client side objects
which mapped to the same server side object.

For the purposes of data caching, the following steps allow an NFS
version 4 client to determine whether two distinct filehandles denote
the same server side object:

*  If GETATTR directed to two filehandles returns different values of
   the fsid attribute, then the filehandles represent distinct
   objects.

*  If GETATTR for any file with an fsid that matches the fsid of the
   two filehandles in question returns a unique_handles attribute
   with a value of TRUE, then the two objects are distinct.

*  If GETATTR directed to the two filehandles does not return the
   fileid attribute for both of the handles, then it cannot be
   determined whether the two objects are the same.  Therefore,
   operations which depend on that knowledge (e.g., client side data
   caching) cannot be done reliably.

*  If GETATTR directed to the two filehandles returns different
   values for the fileid attribute, then they are distinct objects.

*  Otherwise they are the same object.


File Attributes
---------------

* **mandatory**
* **recommended** 
* **named attributes**

**Access Control List (ACL)** is a **recommended** attribute.

They are requested by
setting a bit in the bit vector sent in the GETATTR request; the
server response includes a bit vector to list what attributes were
returned in the response.

**Named attributes** are accessed by the new **OPENATTR** operation, which
accesses a hidden directory of attributes associated with a file
system object.  OPENATTR takes a filehandle for the object and
returns the filehandle for the attribute hierarchy.  The filehandle
for the named attributes is a directory object accessible by LOOKUP
or READDIR and contains files whose names represent the named
attributes and whose data bytes are the value of the attribute.  For

example:

::

      LOOKUP     "foo"       ; look up file
      GETATTR    attrbits
      OPENATTR               ; access foo's named attributes
      LOOKUP     "x11icon"   ; look up specific attribute
      READ       0,4096      ; read stream of bytes


The **per server attribute** is:

         lease_time

The **per filesystem attributes** are:

      supp_attr, fh_expire_type, link_support, symlink_support,
      unique_handles, aclsupport, cansettime, case_insensitive,
      case_preserving, chown_restricted, files_avail, files_free,
      files_total, fs_locations, homogeneous, maxfilesize, maxname,
      maxread, maxwrite, no_trunc, space_avail, space_free, space_total,
      time_delta

The **per filesystem object attributes** are:

      type, change, size, named_attr, f**sid, rdattr_error, filehandle,
      ACL, archive, fileid, hidden, maxlink, mimetype, mode, numlinks,
      owner, owner_group, rawdev, space_used, system, time_access,
      time_backup, time_create, time_metadata, time_modify,
      mounted_on_fileid

=================
owner/owner_group
=================

The recommended attributes "owner" and "owner_group" (and also users
and groups within the "acl" attribute) are represented in terms of a
**UTF-8 string**.  It is expected that the client and
server will have their own local representation of owner and
owner_group that is used for local storage or presentation to the end
user.  Therefore, it is expected that when these attributes are
transferred between the client and server that the local
representation is translated to a syntax of the form
"user@dns_domain".

When a server does accept an owner or owner_group value as valid 
on a SETATTR (and similarly for the owner and group strings in an acl), 
it is promising to return that same string for corresponding GETATTR.  
Configuration changes and ill-constructed name translations (those 
that contain aliasing) may make that promise impossible to honor.  
Servers should make appropriate efforts to avoid a situation in which these
attributes have their values changed when no real change to ownership
has occurred.

In the case where there is no translation available to the client or
server, the attribute value must be constructed without the "@".
Therefore, the absence of the @ from the owner or owner_group
attribute signifies that no translation was available at the sender
and that the receiver of the attribute should not use that string as
a basis for translation into its own internal format.  Even though
the attribute value can not be translated, it may still be useful.
In the case of a client, the attribute string may be used for local
display of ownership.

To provide a greater degree of compatibility with previous versions
of NFS (i.e., v2 and v3), which identified users and groups by 32-bit
unsigned uid's and gid's, owner and group strings that consist of
decimal numeric values with no leading zeros can be given a special
interpretation by clients and servers which choose to provide such
support.  The receiver may treat such a user or group string as
representing the same user as would be represented by a v2/v3 uid or
gid having the corresponding numeric value.

The owner string "nobody" may be used to designate an anonymous user,
which will be associated with a file created by a security principal
that cannot be mapped through normal means to the owner attribute.

=========================
ACL (Access Control List)
=========================

The NFS version 4 ACL attribute is an **array of access control entries
(ACE**).  Although, the client can read and write the ACL attribute,
the **NFSv4 model is the server does all access control** based on the
server's interpretation of the ACL.  If at any point the client wants
to check access without issuing an operation that modifies or reads
data or metadata, the client can use the OPEN and ACCESS operations
to do so.

There are various ACE types.  The server is able to communicate which
**ACE types** are supported by returning the appropriate value within the
**aclsupport** attribute.  

::

         typedef uint32_t        acetype4;
         typedef uint32_t        aceflag4;
         typedef uint32_t        acemask4;

         struct nfsace4 {
                 acetype4        type;
                 aceflag4        flag;
                 acemask4        access_mask;
                 utf8str_mixed   who;
         }

**ACETYPE**:

*	ALLOW
*	DENY
*	AUDIT
*	ALARM

The **access_mask** field contains values based on the following:

*   READ_DATA              
*   LIST_DIRECTORY         
*   WRITE_DATA             
*   ADD_FILE               
*   APPEND_DATA            
*   ADD_SUBDIRECTORY       
*   READ_NAMED_ATTRS       
*   WRITE_NAMED_ATTRS      
*   EXECUTE                
*   DELETE_CHILD           
*   READ_ATTRIBUTES        
*   WRITE_ATTRIBUTES       
*   DELETE                 
*   READ_ACL               
*   WRITE_ACL              
*   WRITE_OWNER            
*   SYNCHRONIZE    

If a server receives a SETATTR request that it cannot accurately
implement, it should **error in the direction of more restricted
access**.  For example, 

	suppose a server cannot distinguish overwriting data from 
	appending new data, as described in the previous paragraph.
	If a client submits an ACE where APPEND_DATA is set but 
	WRITE_DATA is not, the server should reject the request with
	NFS4ERR_ATTRNOTSUPP.  Nonetheless, if the ACE has type DENY, the
	server may silently turn on the other bit, so that both 
	APPEND_DATA and WRITE_DATA are denied.

**ACE flag**

*   ACE4_FILE_INHERIT_ACE
	Inherit ACE to files created in this directory
*   ACE4_DIRECTORY_INHERIT_ACE
	Inherit ACE to directories created in this directory
*   ACE4_INHERIT_ONLY_ACE
	ACE should be ignored for this directory, only to be used for inheritance
*   ACE4_NO_PROPAGATE_INHERIT_ACE
*   ACE4_SUCCESSFUL_ACCESS_ACE_FLAG
*   ACL4_FAILED_ACCESS_ACE_FLAG
*   ACE4_IDENTIFIER_GROUP
	"who" is a group (not user)

**ACE who**
   There are several special identifiers ("who") which need to be
   understood universally, rather than in the context of a particular
   DNS domain.  Some of these identifiers cannot be understood when an
   NFS client accesses the server, but have meaning when a local process
   accesses the file.  The ability to display and modify these
   permissions is permitted over NFS, even if none of the access methods
   on the server understands the identifiers.

*   "OWNER"                
*   "GROUP"                
*   "EVERYONE"             
*   "INTERACTIVE"          
*   "NETWORK"              
*   "DIALUP"               
*   "BATCH"                
*   "ANONYMOUS"            
*   "AUTHENTICATED"        
*   "SERVICE"          

The server that supports both mode and ACL must take care to
synchronize the MODE4_*USR, MODE4_*GRP, and MODE4_*OTH bits with the
ACEs which have respective who fields of "OWNER@", "GROUP@", and
"EVERYONE@" so that the client can see semantically equivalent access
permissions exist whether the client asks for owner, owner_group and
mode attributes, or for just the ACL. 

==================
change/time_modify
==================

*	**change** attribute is **updated for data and metadata**
	modifications, 

some client implementors may be tempted to use the
time_modify attribute and not change to validate cached data, so
that metadata changes do not spuriously invalidate clean data.
The implementor is cautioned in this approach.  The change
attribute is guaranteed to change for each update to the file,
whereas **time_modify is guaranteed to change only at the
granularity of the time_delta** attribute.  Use by the client's data
cache validation logic of time_modify and not change runs the risk
of the client incorrectly marking stale data as valid.


File Locking
------------

* **byte range file locking** supported
* RPC **callback** mechanism is **not required**
* The state associated with file locks is maintained at the server under a **lease-based model**.
* **single lease period** for all state held by a NFS client.  

If the client does not renew its lease within the defined
period, all state associated with the client's lease may be released
by the server.  The client may renew its lease with use of the **RENEW**
operation or implicitly by use of other operations (primarily READ)

To support Win32 share reservations it is necessary to atomically
OPEN or CREATE files.  Having a separate share/unshare operation
would not allow correct implementation of the Win32 OpenFile API.

The policy
of granting access or modifying files is managed by the server based
on the client's state.  These mechanisms can implement policy ranging
from advisory only locking to full mandatory locking.

=========
Client id
=========

For each LOCK request, the client must identify itself to the server.
   This is done in such a way as to allow for correct lock
   identification and crash recovery.  A sequence of a **SETCLIENTID**
   operation followed by a **SETCLIENTID_CONFIRM** operation is required to
   establish the identification onto the server.  Establishment of
   identification by a new incarnation of the client also has the effect
   of immediately breaking any leased state that a previous incarnation
   of the client might have had on the server, as opposed to forcing the
   new client incarnation to wait for the leases to expire.

Client identification is encapsulated in the following structure:

::

         struct nfs_client_id4 {
                 verifier4     verifier;
                 opaque        id<NFS4_OPAQUE_LIMIT>;
         };

The first field, **verifier** is a client **incarnation verifier** that is
used to **detect client reboots**.  Only if the verifier is different
from that which the server has previously recorded the client (as
identified by the second field of the structure, id) does the server
start the process of canceling the client's leased state.

The second field, **id** is a variable length string that **uniquely
defines the client**.

The **string should be different for each server network address
that the client accesses**, rather than common to all server network
addresses.  The reason is that it may not be possible for the
client to tell if the same server is listening on multiple network
addresses.  If the client issues SETCLIENTID with the same id
string to each network address of such a server, the server will
think it is the same client, and each successive SETCLIENTID will
cause the server to begin the process of removing the client's
previous leased state.

Note that SETCLIENTID and SETCLIENTID_CONFIRM has a secondary purpose
of establishing the information the server needs to make **callbacks to
the client for purpose of supporting delegations**.  It is permitted to
**change this information via SETCLIENTID and SETCLIENTID_CONFIRM**
within the same incarnation of the client without removing the
client's leased state.


Once a SETCLIENTID and SETCLIENTID_CONFIRM sequence has successfully
completed, the **client uses the shorthand client identifier**, of type
clientid4, instead of the longer and less compact nfs_client_id4
structure.  This shorthand client identifier (a clientid) is **assigned
by the server** and should be chosen so that it will **not conflict** with
a clientid previously assigned by the server.  This applies across
server restarts or reboots.  When a clientid is presented to a server
and that clientid is not recognized, as would happen after a server
reboot, the server will reject the request with the error
NFS4ERR_STALE_CLIENTID.  When this happens, the client must obtain a
new clientid by use of the SETCLIENTID operation and then proceed to
any other necessary recovery for the server reboot case

The client must also employ the SETCLIENTID operation when it
receives a NFS4ERR_STALE_STATEID error using a stateid derived from
its current clientid, since this also indicates a server reboot which
has invalidated the existing clientid 

lock requests are associated
with an instance of the client by a client supplied verifier.  This
verifier is part of the initial SETCLIENTID call made by the client.
The server returns a clientid as a result of the SETCLIENTID
operation.  The client then confirms the use of the clientid with
SETCLIENTID_CONFIRM.  The clientid in combination with an opaque
owner field is then used by the client to identify the lock owner for
OPEN.  This chain of associations is then used to identify all locks
for a particular client.


==========================
Server Release of Clientid
==========================

*	If client holds no associated state for its clientid, server 
	may choose to release the clientid.  

Note that if the id string in a SETCLIENTID request is properly
constructed, and if the client takes care to use the same principal
for each successive use of SETCLIENTID, then, barring an active
denial of service attack, NFS4ERR_CLID_INUSE should never be
returned.

======================
lock_owner and stateid
======================

When requesting a lock, the client must present to the server the
**clientid and an identifier for the owner** of the requested lock.
These two fields are **referred to as the lock_owner** and the definition
of those fields are:

*	A clientid returned by the server as part of the client's use of
	the SETCLIENTID operation.

*	A variable length opaque array used to uniquely define the owner
	of a lock managed by the client. This may be a thread id, 
	process id, or other unique value.

Server responds with a **unique stateid** used as a **shorthand 
reference to the lock_owner**. Server will be maintaining the 
correspondence between them

==============================
Use of the stateid and Locking
==============================

*	READ, WRITE and SETATTR (which change size) use a stateid
*	stateid must be **used to indicate what locks**, including both
	record locks and share reservations, held by the lockowner.  
*	If no record lock or share reservation, a **stateid of all bits 0** 
	is used.  
*	If client gets NFS4ERR_LOCKED on a file it knows it has the 
	proper share reservation for, it will need to issue a LOCK 
	request on the region of the file that includes the region 
	the I/O was to be performed
*	**stateid of all bits 1** (one) MAY **allow READ operations to 
	bypass locking** checks.  However, **WRITE operations MUST NOT 
	bypass locking** checks.

Note that for UNIX environments that support mandatory file locking,
the distinction between advisory and mandatory locking is subtle.  In
fact, advisory and mandatory record locks are exactly the same in so
far as the APIs and requirements on implementation.  If the mandatory
lock attribute is set on the file, the server checks to see if the
lockowner has an appropriate shared (read) or exclusive (write)
record lock on the region it wishes to read or write to.

For Windows environments, there are no advisory record locks, so the
server always checks for record locks during I/O requests.

Thus, the NFS version 4 LOCK operation does not need to distinguish
between advisory and mandatory record locks.  It is the NFS version 4
server's processing of the READ and WRITE operations that introduces
the distinction.


===========================
Sequencing of Lock Requests
===========================

*	Locking requires "at-most-one" semantics not provided by ONCRPC.  
	ONCRPC over a reliable transport is not sufficient because a 
	sequence of locking requests may span multiple TCP connections.

*	In the face of retransmission or reordering, lock requests must 
	have a well defined and consistent behavior.  To accomplish this, 
	each lock request contains a **sequence number** that is a 
	montonically increasing integer for CLOSE, LOCK, LOCKU, OPEN, 
	PEN_CONFIRM, and OPEN_DOWNGRADE. 

*	**Different lock_owners have different sequences**.  

*	Server maintains the last sequence number (L) received and 
	response returned.  The first request issued for any given 
	lock_owner is issued with a sequence number of zero.

*	for each lock_owner, there should be no more than 
	**one outstanding request**.

If a request (r) with a previous sequence number L is received

*	(r < L) is rejected with error NFS4ERR_BAD_SEQID. Given a
	properly-functioning client, the response to (r) must have been
	received before the last request (L) was sent.  i
*	(r == L) duplicate of last request ) is received, the stored 
	response is returned.
*	(r > L) request beyond the next sequence (r == L + 2) is 
	received, it is rejected with NFS4ERR_BAD_SEQID.  

Sequence history is **reinitialized whenever the 
SETCLIENTID/SETCLIENTID_CONFIRM sequence changes the client verifier**.

==========================
Releasing lock_owner State
==========================

*	When a particular lock_owner no longer holds open or file 
	locking state, the server may release the sequence number state  

========================
Use of Open Confirmation
========================

In the case that an OPEN is retransmitted and the lock_owner is being
used for the first time or the lock_owner state has been previously
released by the server, the use of the OPEN_CONFIRM operation will
prevent incorrect behavior.  

When the server observes the use of the lock_owner for the first 
time, it will direct the client to perform the OPEN_CONFIRM. This sequence
establishes the use of an lock_owner and associated sequence number.
Since the OPEN_CONFIRM sequence connects a new open_owner on the
server with an existing open_owner on a client, the sequence number
may have any value.

==============
Blocking Locks
==============

*	Two new lock types are added, **READW and WRITEW**, the client 
	is requesting a **blocking lock**.  

*	NFS version 4 protocol must not rely on a callback mechanism 
	and therefore is unable to notify a client when a previously 
	denied lock has been granted.  

*	Clients have no choice but to continually poll for the
	lock.  

This presents a **fairness problem**.  The server should maintain an 
**ordered list of pending blocking locks**.  When the conflicting 
lock is released, the server may wait the lease 
period for the first waiting client to re-request the lock.  After 
the lease period expires the next waiting client request is allowed 
the lock.  

=============
Lease Renewal
=============

*	The purpose of a **lease is to allow a server to remove stale 
	locks that are held by a client that has crashed or is otherwise
	unreachable**.  
*	Lease renewals may not be denied if lease interval not expired.

Implicit renewal of all of the leases for a given client is done  
for a positive indication that the client is still active and
that the associated state held at the server, for the client, is
still valid.

*	An OPEN with a valid clientid.

*	Any operation made with a valid stateid (CLOSE, DELEGPURGE,
	DELEGRETURN, LOCK, LOCKU, OPEN, OPEN_CONFIRM, OPEN_DOWNGRADE,
	READ, RENEW, SETATTR, WRITE).  This does not include the special
	stateids of all bits 0 or all bits 1.

The number of locks held by the client is
not a factor since all state for the client is involved with the
lease renewal action.

Since all operations that create a new lease also renew existing
leases, the server must maintain a **common lease expiration time for
all valid leases for a given client**.  This lease time can then be
easily updated upon implicit lease renewal actions.

==================
Share Reservations
==================

share reservation is a mechanism to control access to a file.  It
is a separate and independent mechanism from record locking.  When a
client opens a file, it issues an OPEN operation to the server
specifying the type of access required (READ, WRITE, or BOTH) and the
type of access to deny others (deny NONE, READ, WRITE, or BOTH).  If
the OPEN fails the client will fail the application's open request.

==========================
Open Upgrade and Downgrade
==========================

Open Upgrade :
	
	When an OPEN is done for a file and the lockowner already has 
	the file open, the result is to upgrade the open file status 
	maintained on the server to include the access and
	deny bits specified by the new OPEN with those for the existing
	OPEN.  The result is that there is one open file, as far as the
	protocol is concerned, and it includes the union of the access and
	deny bits for all of the OPEN requests completed.  Only a single
	CLOSE will be done to reset the effects of both OPENs.  Note: the
	client, when issuing the OPEN, may not know that same file is in
	fact being opened.  The above only applies if both OPENs result in
	the OPENed object being designated by the same filehandle.

Open Downgrade : 

	When multiple open files on client are merged into a single open
	file object on the server, the close of one open file (on the
	client) may necessitate change of the access and deny status of 
	open file on the server.  This is because union of the access and
	deny bits for the remaining opens may be smaller (i.e., a proper
	subset) than previously.  The OPEN_DOWNGRADE operation is used to
	make the necessary change and the client should use it

==============================
Notification of Migrated Lease
==============================

Problem :
	In the case of lease renewal, client may not be submitting
	requests for a filesystem migrated to another server. This can 
	occur because of the implicit lease renewal.  The client renews 
	leases for all filesystems when submitting a request to
	any one filesystem at the server.

Solution :
	In order for the client to schedule renewal of leases that may 
	have been relocated to the new server, the client must find 
	out about lease relocation before those leases expire.  

	To accomplish this,
 
	1. all operations which implicitly renew leases for a client 
	   (i.e., OPEN, CLOSE, READ, WRITE, RENEW, LOCK, LOCKT, LOCKU), 
	   will return the error NFS4ERR_LEASE_MOVED 
	2. When a client receives an NFS4ERR_LEASE_MOVED error, it 
	   should perform an operation on each filesystem associated 
	   with the server in question. 
	3. When the client receives an NFS4ERR_MOVED error, the
	   client can follow the normal process to obtain the new server
	   and perform lease renewal on that server


Lock Recovery
-------------

==============
Client Failure
==============

Client does NOT recover before lease interval :
	Server recovers client's locks when leases have expired

Client recovers before lease interval :
	Client does SETCLIENTID with new verifier (id+verifier). 
	The id passed by client would not change, but the verifier
	would be different for the new instance. Server recognises
	the new verifier and uses the id->clientid->lock_owner chain
	to release any leases held by the client

==============
Server Failure
==============

*	On restart the server goes into grace period, wich is atleast 
	equal to duration of the lease period.

*	During grace period, the server would reject any READ/WRITE or
	non-reclaim locking requests, as the server is not aware of 
	which locks were given to clients and waits for client to recover
	their locks

*	A client can determine that server failure has occurred, when it 
	receives one of two errors.  The NFS4ERR_STALE_STATEID error 
	indicates a stateid invalidated by a reboot or restart.  
	The NFS4ERR_STALE_CLIENTID error indicates a clientid 
	invalidated by reboot or restart.  When either of these are
	received, the client must establish a new clientid 
	and re-establish the locking state by sending reclaim requests

Optionally

*	If the server can reliably determine that granting a non-reclaim
	request will not conflict with reclamation of locks by other 
	clients, then the NFS4ERR_GRACE error does not have to be 
	returned and the non-reclaim client request can be serviced.

*	A reclaim-type locking request outside the server's grace 
	period can only succeed if the server can guarantee that no 
	conflicting lock or I/O request has been granted since reboot 
	or restart.

===============================
Network Partitions and Recovery
===============================

If the duration of a network partition is greater than the lease
period provided by the server, the server will have not received a
lease renewal from the client.  If this occurs, the server may free
all locks held for the client.

As a courtesy to the client or as an optimization, the server may
continue to hold locks on behalf of a client for which recent
communication has extended beyond the lease period.  If the server
receives a lock or I/O request that conflicts with one of these
courtesy locks, the server must free the courtesy lock and grant the
new request.

When a network partition is combined with a server reboot, there are
edge conditions that place requirements on the server in order to
avoid silent data corruption following the server reboot.  Two of
these edge conditions are known, and are discussed below.

The first edge condition has the following scenario:

1. Client A acquires a lock.

2. Client A and server experience mutual network partition, such
   that client A is unable to renew its lease.

3. Client A's lease expires, so server releases lock.

4. Client B acquires a lock that would have conflicted with that
   of Client A.

5. Client B releases the lock

6. Server reboots

7. Network partition between client A and server heals.

8. Client A issues a RENEW operation, and gets back a
   NFS4ERR_STALE_CLIENTID.

9. Client A reclaims its lock within the server's grace period.

Thus, at the final step, the server has erroneously granted client
A's lock reclaim. 

The second known edge condition follows:

1. Client A acquires a lock.

2. Server reboots.

3. Client A and server experience mutual network partition, such
   that client A is unable to reclaim its lock within the grace
   period.

4. Server's reclaim grace period ends.  Client A has no locks
   recorded on server.

5. Client B acquires a lock that would have conflicted with that
   of Client A.

6. Client B releases the lock.

7. Server reboots a second time.

8. Network partition between client A and server heals.

9. Client A issues a RENEW operation, and gets back a
   NFS4ERR_STALE_CLIENTID.

10. Client A reclaims its lock within the server's grace period.


Delegations
-----------

At OPEN, the server may provide the client either a read or write 
delegation for the file.

*	If the client is granted a read delegation, it is assured 
	that no other client has the ability to write to the file 
	for the duration of the delegation.  

*	If the client is granted a write delegation, the client 
	is assured that no other client has read or write access to
	the file.

The essence of a delegation is that it allows the client to 
locally service operations such as OPEN, CLOSE, LOCK, LOCKU, READ, 
WRITE without immediate interaction with the server.

*	Delegation is made to the client as a whole and not to any specific
	process or thread of control within it.

*	Preliminary testing of callback functionality by means of a
	CB_NULL procedure determines whether callbacks can be supported.
	If callback path does not exist, delegation cannot be granted.

*	Once granted, a delegation behaves in most ways like a lock.  There
	is an associated lease that is subject to renewal together with all
	of the other leases held by that client.

Unlike locks, an operation by a second client to a delegated file
will cause the server to recall a delegation through a callback.


=========================
Recall of Open Delegation
=========================

When the server receives a conficting request

1. Server will not send response to the conflicting request until
   the recall is complete

2. Recall begins. Server will send a delegation revoke request to 
   the client

3. Client flushes all the state related to the file to the server. 
   Client might have substantial state that needs to be flushed to 
   the server.  Therefore, the server should allow sufficient time 
   for the delegation to be returned since it may involve numerous 
   RPCs to the server.

4. Client sends delegation release to the server, or server timeouts 
   and release the lease. Recall is complete. 

5. Server sends a response for the conflicting request


A client failure or a network partition can result in failure to
respond to a recall callback.  In this case, the server will revoke
the delegation which in turn will render useless any modified state
still on the client.

The following items of state need to be dealt with:

*  If file associated with the delegation is no longer open and
   no previous CLOSE operation has been sent to the server, a CLOSE
   operation must be sent to the server.

*  If a file has other open references at the client, then OPEN
   operations must be sent to the server.  The appropriate stateids
   will be provided by the server for subsequent use by the client
   since the delegation stateid will not longer be valid.  These OPEN
   requests are done with the claim type of CLAIM_DELEGATE_CUR.

*  If there are granted file locks, the corresponding LOCK operations
   need to be performed.  This applies to the write open delegation
   case only.

*  For a write open delegation, if at the time of recall the file is
   not open for write, all modified data for the file must be flushed
   to the server.  If the delegation had not existed, the client
   would have done this data flush before the CLOSE operation.

*  For a write open delegation when a file is still open at the time
   of recall, any modified data for the file needs to be flushed to
   the server.

*  With the write open delegation in place, it is possible that the
   file was truncated during the duration of the delegation.


==================
Handling of Quotas
==================

Problem : 
	The file close system call is the usual point at which the 
	client is notified of a lack of stable storage for the 
	modified file data generated by the application.  At the 
	close, file data is written to the server and through normal 
	accounting the server is able to determine if the available 
	filesystem space for the data has been exceeded (i.e., server 
	returns NFS4ERR_NOSPC or NFS4ERR_DQUOT).  This accounting
	includes quotas.  The introduction of delegations requires 
	that a alternative method be in place for the same type of 
	communication to occur between client and server.

Solution :
	In the delegation response, the server provides either the limit of
	the size of the file or the number of modified blocks and associated
	block size.  The server must ensure that the client will be able to
	flush data to the server of a size equal to that provided in the
	original delegation.  The server must make this assurance for all
	outstanding delegations.  Therefore, the server must be careful in
	its management of available space for new or modified data taking
	into account available filesystem space and any applicable quotas.

======================
Handling of CB_GETATTR
======================

Problem : 
	The server needs to employ special handling for a GETATTR where the
	target is a file that has a write open delegation in effect.  The
	reason for this is that the client holding the write delegation may
	have modified the data and the server needs to reflect this change to
	the second client that submitted the GETATTR. Therefore, the client
	holding the write delegation needs to be interrogated.  The server
	will use the CB_GETATTR operation.  The only attributes that the
	server can reliably query via CB_GETATTR are size and change.

Solution :
	Server uses the CB_GETATTR operation. The only attributes that
	server can reliably query via CB_GETATTR are size and change.
	
	Since the form of the change attribute is determined by server
	and is opaque to client, the client and server need to agree on a
	method of communicating modified state of file.  For the size
	attribute, the client will report its current view of file size

Upon providing a write delegation, the server will cache a copy of
the change attribute in the data structure it uses to record the
delegation.  Let this value be represented by sc.

*  When a second client sends a GETATTR operation on the same file to
   the server, the server obtains the change attribute from the first
   client.  Let this value be cc.

*  If the value cc is equal to sc, the file is not modified and the
   server returns the current values for change, time_metadata, and
   time_modify (for example) to the second client.

*  If the value cc is NOT equal to sc, the file is currently modified
   at the first client and most likely will be modified at the server
   at a future time.  The server then uses its current time to
   construct attribute values for time_metadata and time_modify.  A
   new value of sc, which we will call nsc, is computed by the
   server, such that nsc >= sc + 1.  The server then returns the
   constructed time_metadata, time_modify, and nsc values to the
   requester.  The server replaces sc in the delegation record with
   nsc. 

Delegation Recovery
-------------------

==============
Client Failure
==============

To allow for this type of client recovery, the server MAY extend the
period for delegation recovery beyond the typical lease expiration
period.  This implies that requests from other clients that conflict
with these delegations will need to wait.  Because the normal recall
process may require significant time for the client to flush changed
state to the server, other clients need be prepared for delays that
occur because of a conflicting delegation.  This longer interval
would increase the window for clients to reboot and consult stable
storage so that the delegations can be reclaimed.  For open
delegations, such delegations are reclaimed using OPEN with a claim
type of CLAIM_DELEGATE_PREV.  

A server MAY support a claim type of CLAIM_DELEGATE_PREV, but if it
does, it MUST NOT remove delegations upon SETCLIENTID_CONFIRM, and
instead MUST, for a period of time no less than that of the value of
the lease_time attribute, maintain the client's delegations to allow
time for the client to issue CLAIM_DELEGATE_PREV requests.  The
server that supports CLAIM_DELEGATE_PREV MUST support the DELEGPURGE
operation.

==============
Server Failure
==============

When the server reboots or restarts, delegations are reclaimed (using
the OPEN operation with CLAIM_PREVIOUS) in a similar fashion to
record locks and share reservations.  However, there is a slight
semantic difference.  In the normal case if the server decides that a
delegation should not be granted, it performs the requested action
(e.g., OPEN) without granting any delegation.  For reclaim, the
server grants the delegation but a special designation is applied so
that the client treats the delegation as having been granted but
recalled by the server.  Because of this, the client has the duty to
write all modified state to the server and then return the
delegation.  This process of handling delegation reclaim reconciles
three principles of the NFS version 4 protocol:

*	Upon reclaim, a client reporting resources assigned to it by an
	earlier server instance must be granted those resources.

*	The server has unquestionable authority to determine whether
	delegations are to be granted and, once granted, whether they are
	to be continued.

*	The use of callbacks is not to be depended upon until the client
	has proven its ability to receive them.

=================
Netowrk Partition
=================

When a network partition occurs, delegations are subject to freeing
by the server when the lease renewal period expires.  This is similar
to the behavior for locks and share reservations.  For delegations,
however, the server may extend the period in which conflicting
requests are held off.  Eventually the occurrence of a conflicting
request from another client will cause revocation of the delegation.
A loss of the callback path (e.g., by later network configuration
change) will have the same effect.  A recall request will fail and
revocation of the delegation will result.

A client normally finds out about revocation of a delegation when it
uses a stateid associated with a delegation and receives the error
NFS4ERR_EXPIRED.


FS_LOCATION 
------------

With the use of the recommended attribute **"fs_locations"**, the NFS
version 4 server has a method of providing filesystem migration or
replication services.

The fs_location attribute is structured in the following way:

::

   struct fs_location {
           utf8str_cis     server<>;
           pathname4       rootpath;
   };

   struct fs_locations {
           pathname4       fs_root;
           fs_location     locations<>;
   };

===========
Replication
===========

The fs_locations attribute will provide the list of these locations 
to the client.  On first access of the filesystem, the client should 
obtain the value of the fs_locations attribute.  If, in the future, 
the client finds the server unresponsive, the client may attempt to 
use another server specified by fs_locations.

If applicable, the client must take the appropriate steps to recover
valid filehandles from the new server.

=========
Migration
=========

Once the servers participating in the migration have completed the
move of the filesystem, the error NFS4ERR_MOVED will be returned for
subsequent requests received by the original server.  The
NFS4ERR_MOVED error is returned for all operations except PUTFH and
GETATTR.  Upon receiving the NFS4ERR_MOVED error, the client will
obtain the value of the fs_locations attribute.  The client will then
use the contents of the attribute to redirect its requests to the
specified server.  To facilitate the use of GETATTR, operations such
as PUTFH must also be accepted by the server for the migrated file
system's filehandles.

The fs_locations struct and attribute then contains an array of
locations.  Since the name space of each server may be constructed
differently, the "fs_root" field is provided.  The path represented
by fs_root represents the location of the filesystem in the server's
name space.  Therefore, the fs_root path is only associated with the
server from which the fs_locations attribute was obtained.  The
fs_root path is meant to aid the client in locating the filesystem at
the various servers listed.

At servA the filesystem is located at
path "/a/b/c".  At servB the filesystem is located at path "/x/y/z".
In this example the client accesses the filesystem first at servA
with a multi-component lookup path of "/a/b/c/d"

To facilitate this, the
fs_locations attribute provided by servA would have a fs_root value
of "/a/b/c" and two entries in fs_location.  One entry in fs_location
will be for itself (servA) and the other will be for servB with a
path of "/x/y/z".  With this information, the client is able to
substitute "/x/y/z" for the "/a/b/c" at the beginning of its access
path and construct "/x/y/z/d" to use for the new server


Clientid
--------

A 64-bit quantity used as a unique, short-hand reference to a client 
supplied Verifier and ID.  The server is responsible for 
supplying the Clientid.

========
Verifier 
========

A 64-bit quantity generated by the client that the server can use 
to determine if the client has restarted and lost all previous 
lock state.

If TCP is used as the transport, the client and server SHOULD use
persistent connections. 


Client Retransmission Behavior
------------------------------

When processing a request received over a reliable transport such as
TCP, the NFS version 4 server MUST NOT silently drop the request,
except if the transport connection has been broken.  Given such a
contract between NFS version 4 clients and servers, clients MUST NOT
retry a request unless one or both of the following are true:

*  The transport connection has been broken

*  The procedure being retried is the NULL procedure

So, when a client experiences a RPC call timeout rather than retrying the
RPC, it could instead issue a NULL procedure call to the server.  
If the server has died, the transport connection
break will eventually be indicated to the NFS version 4 client.  The
client can then reconnect, and then retry the original request.  If
the NULL procedure call gets a response, the connection has not
broken.  The client can decide to wait longer for the original
request's response, or it can break the transport connection and
reconnect before re-sending the original request

Exports
-------

=================
Psuedo Filesystem
=================

*	NFSv4 client uses LOOKUP and READDIR to browse one export to 
	another.  

*	Portions of the server name space that are not exported are 
	bridged via a **"pseudo filesystem"** that provides a view of 
	exported directories only. A pseudo filesystem has a unique 
	fsid and behaves like a normal, read only filesystem.

	For example,

	::

	   /a         pseudo filesystem
	   /a/b       real filesystem
	   /a/b/c     pseudo filesystem
	   /a/b/c/d   real filesystem

*	The server's pseudo filesystem is a logical representation 
	of filesystem(s) available from the server.

*	The pseudo filesystem is most likely constructed dynamically 
	when the server is first instantiated.  It is expected
	that the pseudo filesystem may not have an on disk counterpart 
	from which persistent filehandles could be constructed.  

=============
Exported Root
=============

If the server's root filesystem is exported, one might conclude that
a pseudo-filesystem is not needed.  This would be wrong.  Assume the
following filesystems on a server:

::

         /       disk1  (exported)
         /a      disk2  (not exported)
         /a/b    disk3  (exported)

Because disk2 is not exported, disk3 cannot be reached with simple
LOOKUPs.  The server must bridge the gap with a pseudo-filesystem.

====================
Mount Point Crossing
====================


For example:

::

         /a/b            (filesystem 1)
         /a/b/c/d        (filesystem 2)

The pseudo filesystem for this server may be constructed to look like:

::

         /               (place holder/not exported)
         /a/b            (filesystem 1)
         /a/b/c/d        (filesystem 2

It is the server's responsibility to present the pseudo filesystem
that is complete to the client.  If the client sends a lookup request
for the path "/a/b/c/d", the server's response is the filehandle of
the filesystem "/a/b/c/d".  In previous versions of the NFS protocol,
the server would respond with the filehandle of directory "/a/b/c/d"
within the filesystem "/a/b"


RPC Procedures
--------------

============================
ACCESS - Check Access Rights
============================

*	ACCESS determines the access rights that a user identified 
	by the credentials in the RPC request for the filehandle
   
*	The client encodes the set of access rights that are to be 
	checked in the bit mask "access".

*	"supported", represents the access rights for which the server 
	can verify reliably.  The second, "access", represents access 
	rights available to the user for the filehandle provided.

::

     struct ACCESS4args {
             /* CURRENT_FH: object */
             uint32_t        access;
     };

     struct ACCESS4resok {
             uint32_t        supported;
             uint32_t        access;
     };

In general, it is not sufficient for the client to attempt to deduce
access permissions by inspecting the uid, gid, and mode fields in the
file attributes or by attempting to interpret the contents of the ACL
attribute.  This is because the server may perform uid or gid mapping
or enforce additional access control restrictions.  It is also
possible that the server may not be in the same ID space as the
client.  In these cases (and perhaps others), the client can not
reliably perform an access check with only current file attributes.

==================
CLOSE - Close File
==================

::

     struct CLOSE4args {
             /* CURRENT_FH: object */
             seqid4          seqid
             stateid4        open_stateid;
     };

     union CLOSE4res switch (nfsstat4 status) {
      case NFS4_OK:
              stateid4       open_stateid;
      default:
              void;
     };

*	CLOSE operation releases share reservations for as filehandle.

*	If record locks are held, the client SHOULD release all locks 
	before issuing a CLOSE.  

*	The server MAY free all outstanding locks on CLOSE but some 
	servers may not support the CLOSE of a file that still has
	record locks held.

===========================
COMMIT - Commit Cached Data
===========================

::

     struct COMMIT4args {
             /* CURRENT_FH: file */
             offset4         offset;
             count4          count;
     };

     struct COMMIT4resok {
             verifier4       writeverf;
     };

     union COMMIT4res switch (nfsstat4 status) {
      case NFS4_OK:
              COMMIT4resok   resok4;
      default:
              void;
     };

*	Server returns a write verifier upon successful completion 
	of COMMIT.  

*	The write verifier is used by client to determine if the
	server has restarted or rebooted between the initial WRITE(s) 
	and the COMMIT.  If the write verifier returne by COMMIT does
	not match the write verifier returned for WRITE, then client
	should arrange to flush all uncommitted data to the server.
   
*	The server must vary the value of the write verifier at each 
	server event or instantiation that may lead to a loss of 
	uncommitted data.

*	Metadata must be flushed before returning

*	If server receives a full file COMMIT request, that is 
	starting at offset 0 and count 0, it should do the equivalent 
	of fsync()'ing the file.  Otherwise, it should arrange to 
	flush data in the given range 

COMMIT differs from fsync(2) in that it is possible for the client to
flush a range of the file (most likely triggered by a buffer-
reclamation scheme on the client before file has been completely
written)


=========================================
CREATE - Create a Non-Regular File Object
=========================================

::

     struct CREATE4args {
             /* CURRENT_FH: directory for creation */
             createtype4     objtype;
             component4      objname;
             fattr4          createattrs;
     };

     struct CREATE4resok {
             change_info4    cinfo;
             bitmap4         attrset;        /* attributes set */
     };

     union CREATE4res switch (nfsstat4 status) {
      case NFS4_OK:
              CREATE4resok resok4;
      default:
              void;
     };

*	CREATE operation creates a non-regular file object 

*	OPEN operation MUST be used to create a regular file.

*	For the directory where the new file object was created, the 
	server returns change_info4 information in cinfo.  With the 
	atomic field of the change_info4 struct, the server will 
	indicate if the before and after change attributes were 
	obtained atomically with respect to the file object creation.

The **current filehandle is replaced** by that of the new object.

================================================
DELEGPURGE - Purge Delegations Awaiting Recovery
================================================

::

     struct DELEGPURGE4args {
             clientid4       clientid;
     };

     struct DELEGPURGE4res {
             nfsstat4        status;
     };

*	Purges all delegations awaiting recovery for a given client.

*	Clients which do not commit delegation information to stable 
	storage, indicate that conflicting requests need not be delayed 
	by the server awaiting recovery of delegation information. 

*	Clients that record delegation information on stable storage,
	DELEGPURGE should be issued immediately after doing delegation
	recovery on all delegations known to the client.  Doing so will
	notify the server that no additional delegations for the client 
	will be recovered 

The server MAY support DELEGPURGE, but if it does not, it MUST NOT
support CLAIM_DELEGATE_PREV.

===============================
DELEGRETURN - Return Delegation
===============================

::

     struct DELEGRETURN4args {
             /* CURRENT_FH: delegated file */
             stateid4        stateid;
     };

     struct DELEGRETURN4res {
             nfsstat4        status;
     };

Returns the delegation represented by the current filehandle and stateid.

========================
GETATTR - Get Attributes
========================

::

     struct GETATTR4args {
             /* CURRENT_FH: directory or file */
             bitmap4         attr_request;
     };

     struct GETATTR4resok {
             fattr4          obj_attributes;
     };

     union GETATTR4res switch (nfsstat4 status) {
      case NFS4_OK:
              GETATTR4resok  resok4;
      default:
              void;
     };

The server returns an attribute bitmap that indicates the attribute 
values for which it was able to return, followed by the attribute 
values ordered lowest attribute number first.

==============================
GETFH - Get Current Filehandle
==============================

::

     /* CURRENT_FH: */
     void;


     struct GETFH4resok {
             nfs_fh4         object;
     };

     union GETFH4res switch (nfsstat4 status) {
      case NFS4_OK:
             GETFH4resok     resok4;
      default:
             void;
     };

Operations that change the current filehandle like LOOKUP or CREATE
do not automatically return the new filehandle as a result.  For
instance, if a client needs to lookup a directory entry and obtain
its filehandle then the following request is needed.

::

      PUTFH  (directory filehandle)
      LOOKUP (entry name)
      GETFH

============================
LINK - Create Link to a File
============================

::

     struct LINK4args {
             /* SAVED_FH: source object */
             /* CURRENT_FH: target directory */
             component4      newname;
     };

     struct LINK4resok {
             change_info4    cinfo;
     };

     union LINK4res switch (nfsstat4 status) {
      case NFS4_OK:
              LINK4resok resok4;
      default:
              void;
     };

*	the current filehandle will continue to be the target directory.

*	For the target directory, the server returns change_info4 
	information in cinfo.  With the atomic field of the 
	change_info4 struct, the server will indicate if the before 
	and after change attributes were
	obtained atomically with respect to the link creation.

==================
LOCK - Create Lock
==================

::

     struct open_to_lock_owner4 {
             seqid4          open_seqid;
             stateid4        open_stateid;
             seqid4          lock_seqid;
             lock_owner4     lock_owner;
     };

     struct exist_lock_owner4 {
             stateid4        lock_stateid;
             seqid4          lock_seqid;
     };

     union locker4 switch (bool new_lock_owner) {
      case TRUE:
             open_to_lock_owner4     open_owner;
      case FALSE:
             exist_lock_owner4       lock_owner;
     };

     enum nfs_lock_type4 {
             READ_LT         = 1,
             WRITE_LT        = 2,
             READW_LT        = 3,    /* blocking read */
             WRITEW_LT       = 4     /* blocking write */
     };

     struct LOCK4args {
             /* CURRENT_FH: file */
             nfs_lock_type4  locktype;
             bool            reclaim;
             offset4         offset;
             length4         length;
             locker4         locker;
     };



     struct LOCK4denied {
             offset4         offset;
             length4         length;
             nfs_lock_type4  locktype;
             lock_owner4     owner;
     };

     struct LOCK4resok {
             stateid4        lock_stateid;
     };

     union LOCK4res switch (nfsstat4 status) {
      case NFS4_OK:
              LOCK4resok     resok4;
      case NFS4ERR_DENIED:
              LOCK4denied    denied;
      default:
              void;
     };

*	Bytes in a file may be locked even if those bytes are not 
	currently allocated to the file.  

*	To lock the file from a specific offset through the 
	end-of-file use a length field with all bits set to 1 (one). 

*	In the case that the lock is denied, the owner, offset, and 
	length of a conflicting lock are returned.

*	If the server is unable to determine the exact offset and 
	length of the conflicting lock, the same offset and length 
	that were provided in the arguments should be returned in 
	the denied results.

*	In the case that the lock_owner is known to the server and 
	as an established lock_seqid, the argument is just the 
	lock_owner and lock_seqid.  In the case that the lock_owner 
	is not known to the server, the argument contains not only 
	the lock_owner and lock_seqid but also the open_stateid 
	and open_seqid. 

When the client makes a lock request that corresponds to a range that
the lockowner has locked already (with the same or different lock
type), or to a sub-region of such a range, or to a region which
includes multiple locks already granted to that lockowner, in whole
or in part, and the server does not support such locking operations
(i.e., does not support POSIX locking semantics), the server will
return the error NFS4ERR_LOCK_RANGE.  In that case, the client may
return an error, or it may emulate the required operations, using
only LOCK for ranges that do not include any bytes already locked by
that lock_owner and LOCKU of locks held by that lock_owner
(specifying an exactly-matching range and type).  Similarly, when the
client makes a lock request that amounts to upgrading (changing from
a read lock to a write lock) or downgrading (changing from write lock
to a read lock) an existing record lock, and the server does not
support such a lock, the server will return NFS4ERR_LOCK_NOTSUPP.


=====================
LOCKT - Test For Lock
=====================

::

     struct LOCKT4args {
             /* CURRENT_FH: file */
             nfs_lock_type4  locktype;
             offset4         offset;
             length4         length;
             lock_owner4     owner;
     };

     struct LOCK4denied {
             offset4         offset;
             length4         length;
             nfs_lock_type4  locktype;
             lock_owner4     owner;
     };

     union LOCKT4res switch (nfsstat4 status) {
      case NFS4ERR_DENIED:
              LOCK4denied    denied;
      case NFS4_OK:
              void;
      default:
              void;
     };

*	LOCKT operation tests the lock as specified in the arguments.  

*	If a conflicting lock exists, the owner, offset, length, 
	and type of the conflicting lock are returned;

*	The test for conflicting locks should exclude locks for the 
	current lockowner.

LOCKT uses a lock_owner4 rather a stateid4, as is used in LOCK to
identify the owner.  This is because the client does not have to open
the file to test for the existence of a lock, so a stateid may not be
available.


===================
LOCKU - Unlock File
===================

::

     struct LOCKU4args {
             /* CURRENT_FH: file */
             nfs_lock_type4  locktype;
             seqid4          seqid;
             stateid4        stateid;
             offset4         offset;
             length4         length;
     };


     union LOCKU4res switch (nfsstat4 status) {
      case   NFS4_OK:
              stateid4       stateid;
      default:
              void;
     };

========================
LOOKUP - Lookup Filename
========================

::

     struct LOOKUP4args {
             /* CURRENT_FH: directory */
             component4      objname;
     };


     struct LOOKUP4res {
             /* CURRENT_FH: object */
             nfsstat4        status;
     };


*	if the object exists the current filehandle is replaced 
	with the component's filehandle.

*	LOOKUP requests to cross mountpoints on the server.  The 
	client can detect a mountpoint crossing by comparing the
	fsid attribute of the directory with the fsid attribute of 
	the directory looked up.

*	Note that this operation does not follow symbolic links.  
	The client is responsible for all parsing of filenames 
	including filenames that are modified by symbolic links 
	encountered during the lookup process.

*	If the current filehandle supplied is not a directory but a 
	symbolic link, the error NFS4ERR_SYMLINK is returned as the 
	error.  For all other non-directory file types, the error 
	NFS4ERR_NOTDIR is returned.

If the client wants to achieve the effect of a multi-component
lookup, it may construct a COMPOUND request such as (and obtain each
filehandle):

::

      PUTFH  (directory filehandle)
      LOOKUP "pub"
      GETFH
      LOOKUP "foo"
      GETFH
      LOOKUP "bar"
      GETFH

Note: previous versions of the protocol assigned special semantics to
the names "." and "..".  NFS version 4 assigns no special semantics
to these names.  The LOOKUPP operator must be used to lookup a parent
directory.


=================================
LOOKUPP - Lookup Parent Directory
=================================

::

     /* CURRENT_FH: object */
     void;


     struct LOOKUPP4res {
             /* CURRENT_FH: directory */
             nfsstat4        status;
     };

*	The current filehandle is assumed to refer to a regular 
	directory or a named attribute directory.  LOOKUPP assigns 
	the filehandle for its parent directory to be the current 
	filehandle.

*	LOOKUPP will also cross mountpoints.

=========================================
NVERIFY - Verify Difference in Attributes
=========================================

::

     struct NVERIFY4args {
             /* CURRENT_FH: object */
             fattr4          obj_attributes;
     };


     struct NVERIFY4res {
             nfsstat4        status;
     };

This operation is used to prefix a sequence of operations to be
performed if one or more attributes have changed on some filesystem
object.  If all the attributes match then the error NFS4ERR_SAME must
be returned.

If the object to which the attributes belong has changed then the following
operations may obtain new data associated with that object.  For
instance, to check if a file has been changed and obtain new data if
it has:

::

      PUTFH  (public)
      LOOKUP "foobar"
      NVERIFY attrbits attrs
      READ 0 32767

==========================
OPEN - Open a Regular File
==========================

::

     struct OPEN4args {
             seqid4          seqid;
             uint32_t        share_access;
             uint32_t        share_deny;
             open_owner4     owner;
             openflag4       openhow;
             open_claim4     claim;
     };

     enum createmode4 {
             UNCHECKED4      = 0,
             GUARDED4        = 1,
             EXCLUSIVE4      = 2
     };

     union createhow4 switch (createmode4 mode) {
      case UNCHECKED4:
      case GUARDED4:
              fattr4         createattrs;
      case EXCLUSIVE4:
              verifier4      createverf;
     };

     enum opentype4 {
             OPEN4_NOCREATE  = 0,
             OPEN4_CREATE    = 1
     };

     union openflag4 switch (opentype4 opentype) {
      case OPEN4_CREATE:
              createhow4     how;
      default:
              void;
     };

     /* Next definitions used for OPEN delegation */
     enum limit_by4 {
             NFS_LIMIT_SIZE          = 1,
             NFS_LIMIT_BLOCKS        = 2
             /* others as needed */
     };

     struct nfs_modified_limit4 {
             uint32_t        num_blocks;
             uint32_t        bytes_per_block;
     };

     union nfs_space_limit4 switch (limit_by4 limitby) {
      /* limit specified as file size */
      case NFS_LIMIT_SIZE:
              uint64_t               filesize;
      /* limit specified by number of blocks */
      case NFS_LIMIT_BLOCKS:
              nfs_modified_limit4    mod_blocks;
     } ;

     enum open_delegation_type4 {
             OPEN_DELEGATE_NONE      = 0,
             OPEN_DELEGATE_READ      = 1,
             OPEN_DELEGATE_WRITE     = 2
     };

     enum open_claim_type4 {
             CLAIM_NULL              = 0,
             CLAIM_PREVIOUS          = 1,
             CLAIM_DELEGATE_CUR      = 2,
             CLAIM_DELEGATE_PREV     = 3
     };

     struct open_claim_delegate_cur4 {
             stateid4        delegate_stateid;
             component4      file;
     };

     union open_claim4 switch (open_claim_type4 claim) {
      /*
       * No special rights to file. Ordinary OPEN of the specified file.
       */
      case CLAIM_NULL:
              /* CURRENT_FH: directory */
              component4     file;

      /*
       * Right to the file established by an open previous to server
       * reboot.  File identified by filehandle obtained at that time
       * rather than by name.
       */
      case CLAIM_PREVIOUS:
              /* CURRENT_FH: file being reclaimed */
              open_delegation_type4   delegate_type;

      /*
       * Right to file based on a delegation granted by the server.
       * File is specified by name.
       */
      case CLAIM_DELEGATE_CUR:
              /* CURRENT_FH: directory */
              open_claim_delegate_cur4       delegate_cur_info;

      /* Right to file based on a delegation granted to a previous boot
       * instance of the client.  File is specified by name.
       */
      case CLAIM_DELEGATE_PREV:
              /* CURRENT_FH: directory */
              component4     file_delegate_prev;
     };

     RESULT

     struct open_read_delegation4 {
           stateid4        stateid;        /* Stateid for delegation*/
           bool            recall;         /* Pre-recalled flag for
                                              delegations obtained
                                              by reclaim
                                              (CLAIM_PREVIOUS) */
           nfsace4         permissions;    /* Defines users who don't
                                              need an ACCESS call to
                                              open for read */
     };

     struct open_write_delegation4 {
           stateid4        stateid;        /* Stateid for delegation*/
           bool            recall;         /* Pre-recalled flag for
                                              delegations obtained
                                              by reclaim
                                              (CLAIM_PREVIOUS) */
           nfs_space_limit4 space_limit;   /* Defines condition that
                                              the client must check to
                                              determine whether the
                                              file needs to be flushed
                                              to the server on close.
                                              */
           nfsace4         permissions;    /* Defines users who don't
                                              need an ACCESS call as
                                              part of a delegated
                                              open. */
     };

     union open_delegation4
     switch (open_delegation_type4 delegation_type) {
           case OPEN_DELEGATE_NONE:
                   void;
           case OPEN_DELEGATE_READ:
                   open_read_delegation4 read;
           case OPEN_DELEGATE_WRITE:
                   open_write_delegation4 write;
     };

     const OPEN4_RESULT_CONFIRM      = 0x00000002;
     const OPEN4_RESULT_LOCKTYPE_POSIX = 0x00000004;

     struct OPEN4resok {
           stateid4        stateid;        /* Stateid for open */
           change_info4    cinfo;          /* Directory Change Info */
           uint32_t        rflags;         /* Result flags */
           bitmap4         attrset;        /* attributes on create */
           open_delegation4 delegation;    /* Info on any open
                                              delegation */
     };

     union OPEN4res switch (nfsstat4 status) {
      case NFS4_OK:
           /* CURRENT_FH: opened file */
           OPEN4resok      resok4;
      default:
           void;
     };

*	OPEN resembles LOOKUP in that it generates a filehandle for the
	client to use.  Unlike LOOKUP, OPEN creates server state on
	the filehandle. 

*	The OPEN operation creates and/or opens a regular file 

*	If the file does not exist at the server and creation is desired, 
	specification of the method of creation is provided by the 
	openhow parameter.  The client has the choice of
	three creation methods: UNCHECKED, GUARDED, or EXCLUSIVE.

*	If current filehandle is a named attribute directory, OPEN will
	then create or open a named attribute file.  Note that exclusive
	create of a named attribute is not supported.

UNCHECKED 
	means that the file should be created if a file of that
	name does not exist and encountering an existing regular 
	file of that name is not an error.  When an
	UNCHECKED create encounters an existing file, the attributes
	specified by createattrs are not used, except that when an size of
	zero is specified, the existing file is truncated. 

GUARDED
	the server checks for the presence of a duplicate object
	by name before performing the create.  If a duplicate exists, an
	error of NFS4ERR_EXIST is returned as the status.

EXCLUSIVE
	The server should check for the presence of a duplicate
	object by name.  If the object does not exist, the server 
	creates the object and stores the verifier with object.  

	If the object does exist and the stored verifier matches 
	the client provided verifier, the server uses the existing 
	object as the newly created object.

	If stored verifier does not match, then an error of 
	NFS4ERR_EXIST is returned. 
	
	No attributes may be provided in this case, since the
	server may use an attribute of the target object to store the
	verifier.  If the server uses an attribute to store the exclusive
	create verifier, it will signify which attribute by setting the
	appropriate bit in the attribute mask that is returned in the
	results.

	For filesystems that do not provide a mechanism for the storage 
	of arbitrary file attributes, the server may use one or more 
	elements of the object meta-data to store
	the verifier. The verifier must be stored in stable storage to
	prevent erroneous failure on retransmission of the request.
	In the UNIX local filesystem environment, the expected storage
	location for verifier on creation is the meta-data (time stamps)
	of object. For this reason, an exclusive object create may not
	include initial attributes because the server would have nowhere to
	store the verifier.

	Once the client has performed a successful exclusive create, it must
	issue a SETATTR to set the correct object attributes.


For the target directory, the server returns change_info4 information
in cinfo.  With the atomic field of the change_info4 struct, the
server will indicate if the before and after change attributes were
obtained atomically with respect to the link creation.

Upon successful creation, the current filehandle is replaced by that
of the new object.

The OPEN operation provides for Windows share reservation capability
with the use of the **share_access and share_deny** fields of the OPEN
arguments.  The client specifies at OPEN the required share_access
and share_deny modes.

The "claim" field of the OPEN argument is used to specify the file to
be opened and the state information which the client claims to
possess.


CLAIM_NULL
	 For the client, this is a new OPEN
	 request and there is no previous state
	 associate with the file for the client.

CLAIM_PREVIOUS
	 The client is claiming basic OPEN state
	 for a file that was held previous to a
	 server reboot.  Generally used when a
	 server is returning persistent
	 filehandles; the client may not have the
	 file name to reclaim the OPEN.

CLAIM_DELEGATE_CUR
	 The client is claiming a delegation for
	 OPEN as granted by the server.
	 Generally this is done as part of
	 recalling a delegation.

CLAIM_DELEGATE_PREV
	 The client is claiming a delegation
	 granted to a previous client instance;
 	 used after the client reboots.

For any OPEN request, the server may return an open delegation, which
allows further opens and closes to be handled locally on the client
as described in the section Open Delegation.  Note that delegation is
up to the server to decide.  The client should never assume that
delegation will or will not be granted in a particular instance.  It
should always be prepared for either case.


OPEN4_RESULT_CONFIRM indicates that the client MUST execute an
OPEN_CONFIRM operation before using the open file.
OPEN4_RESULT_LOCKTYPE_POSIX indicates the server's file locking
behavior supports the complete set of Posix locking techniques.

=========================================
OPENATTR - Open Named Attribute Directory
=========================================

::

     struct OPENATTR4args {
             /* CURRENT_FH: object */
             bool    createdir;
     };


     struct OPENATTR4res {
             /* CURRENT_FH: named attr directory*/
             nfsstat4        status;
     };

The OPENATTR operation is used to obtain the filehandle of the named
attribute directory associated with the current filehandle.  The
result of the OPENATTR will be a filehandle to an object of type
NF4ATTRDIR.  From this filehandle, READDIR and LOOKUP operations can
be used to obtain filehandles for the various named attributes
associated with the original filesystem object.  Filehandles returned
within the named attribute directory will have a type of
NF4NAMEDATTR.

The createdir argument allows the client to signify if a named
attribute directory should be created as a result of the OPENATTR
operation.  Some clients may use the OPENATTR operation with a value
of FALSE for createdir to determine if any named attributes exist for
the object.  If none exist, then NFS4ERR_NOENT will be returned.

===========================
OPEN_CONFIRM - Confirm Open
===========================

::

     struct OPEN_CONFIRM4args {
             /* CURRENT_FH: opened file */
             stateid4        open_stateid;
             seqid4          seqid;
     };

     RESULT

     struct OPEN_CONFIRM4resok {
             stateid4        open_stateid;
     };

     union OPEN_CONFIRM4res switch (nfsstat4 status) {
      case NFS4_OK:
              OPEN_CONFIRM4resok     resok4;
      default:
              void;
     };

This operation is used to confirm the sequence id usage for the first
time that a open_owner is used by a client.  The stateid returned
from the OPEN operation is used as the argument for this operation
along with the next sequence id for the open_owner.  The sequence id
passed to the OPEN_CONFIRM must be 1 (one) greater than the seqid
passed to the OPEN operation from which the open_confirm value was
obtained.  If the server receives an unexpected sequence id with
respect to the original open, then the server assumes that the client
will not confirm the original OPEN and all state associated with the
original OPEN is released by the server.

A given client might generate many open_owner4 data structures for a
given clientid.

Servers must not require confirmation on OPENs that grant delegations
or are doing reclaim operations.  The server can easily avoid this by
noting whether it has disposed of one open_owner4 for the given
clientid.

========================================
OPEN_DOWNGRADE - Reduce Open File Access
========================================

::

     struct OPEN_DOWNGRADE4args {
             /* CURRENT_FH: opened file */
             stateid4        open_stateid;
             seqid4          seqid;
             uint32_t        share_access;
             uint32_t        share_deny;
     };

     RESULT

     struct OPEN_DOWNGRADE4resok {
             stateid4        open_stateid;
     };

     union OPEN_DOWNGRADE4res switch(nfsstat4 status) {
      case NFS4_OK:
             OPEN_DOWNGRADE4resok    resok4;
      default:
             void;
     };


This operation is used to adjust the share_access and share_deny bits
for a given open.  This is necessary when a given openowner opens the
same file multiple times with different share_access and share_deny
flags.  In this situation, a close of one of the opens may change the
appropriate share_access and share_deny flags to remove bits
associated with opens no longer in effect.

The share_access and share_deny bits specified in this operation
replace the current ones for the specified open file.  The
share_access and share_deny bits specified must be exactly equal to
the union of the share_access and share_deny bits specified for some
subset of the OPENs in effect for current openowner on the current
file.

==============================
PUTFH - Set Current Filehandle
==============================

::

     struct PUTFH4args {
             nfs_fh4         object;
     };

     RESULT

     struct PUTFH4res {
             /* CURRENT_FH: */
             nfsstat4        status;
     };

Replaces the current filehandle with the filehandle provided as an
argument.

================================
PUTPUBFH - Set Public Filehandle
================================

::

     void;

     RESULT

     struct PUTPUBFH4res {
             /* CURRENT_FH: public fh */
             nfsstat4        status;
     };


Replaces the current filehandle with the filehandle that represents
the public filehandle of the server's name space.  This filehandle
may be different from the "root" filehandle which may be associated
with some other directory on the server.

If the public and root
filehandles are not equivalent, then the public filehandle MUST be a
descendant of the root filehandle.

===============================
PUTROOTFH - Set Root Filehandle
===============================

::

     void;

     struct PUTROOTFH4res {
             /* CURRENT_FH: root fh */
             nfsstat4        status;
     };

Replaces the current filehandle with the filehandle that represents
the root of the server's name space. 

=====================
READ - Read from File
=====================

::

     struct READ4args {
             /* CURRENT_FH: file */
             stateid4        stateid;
             offset4         offset;
             count4          count;
     };

     RESULT

     struct READ4resok {
             bool            eof;
             opaque          data<>;
     };

     union READ4res switch (nfsstat4 status) {
      case NFS4_OK:
              READ4resok     resok4;
      default:
              void;
     };

The server may choose to return fewer bytes
than specified by the client.  The client needs to check for this
condition and handle the condition appropriately.

The stateid value for a READ request represents a value returned from
a previous record lock or share reservation request.  The stateid is
used by the server to verify that the associated share reservation
and any record locks are still valid and to update lease timeouts for
the client.

If the read ended at the end-of-file eof is returned as TRUE

For a READ with a stateid value of all bits 0, the server MAY allow
the READ to be serviced subject to mandatory file locks or the
current share deny modes for the file.  For a READ with a stateid
value of all bits 1, the server MAY allow READ operations to bypass
locking checks at the server.

========================
READDIR - Read Directory
========================

::

     struct READDIR4args {
             /* CURRENT_FH: directory */
             nfs_cookie4     cookie;
             verifier4       cookieverf;
             count4          dircount;
             count4          maxcount;
             bitmap4         attr_request;
     };

     RESULT

     struct entry4 {
             nfs_cookie4     cookie;
             component4      name;
             fattr4          attrs;
             entry4          *nextentry;
     };

     struct dirlist4 {
             entry4          *entries;
             bool            eof;
     };

     struct READDIR4resok {
             verifier4       cookieverf;
             dirlist4        reply;
     };


     union READDIR4res switch (nfsstat4 status) {
      case NFS4_OK:
              READDIR4resok  resok4;
      default:
              void;
     };


The READDIR operation retrieves a variable number of entries from a
filesystem directory and returns client requested attributes for each
entry along with information to allow the client to request
additional directory entries in a subsequent READDIR.

The arguments contain a cookie value that represents where the
READDIR should start within the directory.  A value of 0 (zero) for
the cookie is used to start reading at the beginning of the
directory.  For subsequent READDIR requests, the client specifies a
cookie value that is provided by the server on a previous READDIR
request.

The cookieverf value should be set to 0 (zero) when the cookie value
is 0 (zero) (first directory read).  On subsequent requests, it
should be a cookieverf as returned by the server.

The dircount portion of the argument is a hint of the maximum number
of bytes of directory information that should be returned.  This
value represents the length of the names of the directory entries and
the cookie value for these entries.  This length represents the XDR
encoding of the data (names and cookies) and not the length in the
native format of the server.

The maxcount value of the argument is the maximum number of bytes for
the result.  This maximum size represents all of the data being
returned within the READDIR4resok structure and includes the XDR
overhead.  The server may return less data.  If the server is unable
to return a single directory entry within the maxcount limit, the
error NFS4ERR_TOOSMALL will be returned to the client

Each of these entries contains the name of the
directory entry, a cookie value for that entry, and the associated
attributes as requested.  The "eof" flag has a value of TRUE if there
are no more entries in the directory.

In some cases, the server may encounter an error while obtaining the
attributes for a directory entry.  Instead of returning an error for
the entire READDIR operation, the server can instead return the
attribute 'fattr4_rdattr_error'.  With this, the server is able to
communicate the failure to the client and not fail the entire
operation in the instance of what might be a transient failure.
Obviously, the client must request the fattr4_rdattr_error attribute
for this method to work properly.

For some filesystem environments, the directory entries "." and ".."
have special meaning and in other environments, they may not.  If the
server supports these special entries within a directory, they should
not be returned to the client as part of the READDIR response.  To
enable some client environments, the cookie values of 0, 1, and 2 are
to be considered reserved.  Note that the UNIX client will use these
values when combining the server's response and local representations
to enable a fully formed UNIX directory presentation to the
application.

For READDIR arguments, cookie values of 1 and 2 should not be used
and for READDIR results cookie values of 0, 1, and 2 should not be
returned.


Since some servers will not be returning "." and ".." entries as has
been done with previous versions of the NFS protocol, the client that
requires these entries be present in READDIR responses must fabricate
them.

=============================
READLINK - Read Symbolic Link
=============================

::

     /* CURRENT_FH: symlink */
     void;

     RESULT

     struct READLINK4resok {
             linktext4       link;
     };

     union READLINK4res switch (nfsstat4 status) {
      case NFS4_OK:
              READLINK4resok resok4;
      default:
              void;
     };

READLINK reads the data associated with a symbolic link.  The data is
a UTF-8 string that is opaque to the server.  That is, whether
created by an NFS client or created locally on the server, the data
in a symbolic link is not interpreted when created, but is simply
stored.

If different implementations want to share access to
symbolic links, then they must agree on the interpretation of the
data in the symbolic link.

=================================
REMOVE - Remove Filesystem Object
=================================

::

     struct REMOVE4args {
             /* CURRENT_FH: directory */
             component4       target;
     };

     RESULT

     struct REMOVE4resok {
             change_info4    cinfo;
     }

     union REMOVE4res switch (nfsstat4 status) {
      case NFS4_OK:
              REMOVE4resok   resok4;
      default:
              void;
     }

If the entry in the directory was the last reference to the
corresponding filesystem object, the object may be destroyed.

For the directory where the filename was removed, the server returns
change_info4 information in cinfo.  With the atomic field of the
change_info4 struct, the server will indicate if the before and after
change attributes were obtained atomically with respect to the
removal.

NFS versions 2 and 3 required a different operator RMDIR for
directory removal and REMOVE for non-directory removal. This allowed
clients to skip checking the file type when being passed a non-
directory delete system call (e.g., unlink() in POSIX) to remove a
directory, as well as the converse (e.g., a rmdir() on a non-
directory) because they knew the server would check the file type.
NFS version 4 REMOVE can be used to delete any directory entry
independent of its file type.

the client should not rely on the resources
(disk space, directory entry, and so on) formerly associated with the
object becoming immediately available.  Thus, if a client needs to be
able to continue to access a file after using REMOVE to remove it,
the client should take steps to make sure that the file will still be
accessible.  The usual mechanism used is to RENAME the file from its
old name to a new hidden name.

===============================
RENAME - Rename Directory Entry
===============================

::

     struct RENAME4args {
             /* SAVED_FH: source directory */
             component4      oldname;
             /* CURRENT_FH: target directory */
             component4      newname;
     };


     RESULT

     struct RENAME4resok {
             change_info4    source_cinfo;
             change_info4    target_cinfo;
     };

     union RENAME4res switch (nfsstat4 status) {
      case NFS4_OK:
              RENAME4resok   resok4;
      default:
              void;
     };

The operation is required to be atomic to
the client.  Source and target directories must reside on the same
filesystem on the server.

If the target directory already contains an entry with the name,
newname, the source object must be compatible with the target:
either both are non-directories or both are directories and the
target must be empty.

If oldname and newname both refer to the same file (they might be
hard links of each other), then RENAME should perform no action and
return success.

For both directories involved in the RENAME, the server returns
change_info4 information.  With the atomic field of the change_info4
struct, the server will indicate if the before and after change
attributes were obtained atomically with respect to the rename.

If the oldname refers to a named attribute and the saved and current
filehandles refer to different filesystem objects, the server will
return NFS4ERR_XDEV just as if the saved and current filehandles
represented directories on different filesystems.

=====================
RENEW - Renew a Lease
=====================

::

     struct RENEW4args {
             clientid4       clientid;
     };

     RESULT

     struct RENEW4res {
             nfsstat4        status;
     };

In processing the RENEW request, the
server renews all leases associated with the client.  The associated
leases are determined by the clientid provided via the SETCLIENTID
operation.

When the client holds delegations, it needs to use RENEW to detect
when the server has determined that the callback path is down.  When
the server has made such a determination, only the RENEW operation
will renew the lease on delegations.  If the server determines the
callback path is down, it returns NFS4ERR_CB_PATH_DOWN.  Even though
it returns NFS4ERR_CB_PATH_DOWN, the server MUST renew the lease on
the record locks and share reservations that the client has
established on the server.  If for some reason the lock and share
reservation lease cannot be renewed, then the server MUST return an
error other than NFS4ERR_CB_PATH_DOWN, even if the callback path is
also down.

====================================
RESTOREFH - Restore Saved Filehandle
====================================

::

     /* SAVED_FH: */
     void;

     RESULT

     struct RESTOREFH4res {
             /* CURRENT_FH: value of saved fh */
             nfsstat4        status;
     };

Set the current filehandle to the value in the saved filehandle.

Operations like OPEN and LOOKUP use the current filehandle to
represent a directory and replace it with a new filehandle.  Assuming
the previous filehandle was saved with a SAVEFH operator, the
previous filehandle can be restored as the current filehandle.  This
is commonly used to obtain post-operation attributes for the
directory, e.g.,

::

         PUTFH (directory filehandle)
         SAVEFH
         GETATTR attrbits     (pre-op dir attrs)
         CREATE optbits "foo" attrs
         GETATTR attrbits     (file attributes)
         RESTOREFH
         GETATTR attrbits     (post-op dir attrs)

================================
SAVEFH - Save Current Filehandle
================================

::

     /* CURRENT_FH: */
     void;

     RESULT

     struct SAVEFH4res {
             /* SAVED_FH: value of current fh */
             nfsstat4        status;
     };

   
Save the current filehandle.  The saved filehandle can be restored as
the current filehandle with the RESTOREFH operator.

===================================
SECINFO - Obtain Available Security
===================================

::

     struct SECINFO4args {
             /* CURRENT_FH: directory */
             component4     name;
     };

     RESULT

     enum rpc_gss_svc_t {/* From RFC 2203 */
             RPC_GSS_SVC_NONE        = 1,
             RPC_GSS_SVC_INTEGRITY   = 2,
             RPC_GSS_SVC_PRIVACY     = 3
     };


     struct rpcsec_gss_info {
             sec_oid4        oid;
             qop4            qop;
             rpc_gss_svc_t   service;
     };

     union secinfo4 switch (uint32_t flavor) {
      case RPCSEC_GSS:
              rpcsec_gss_info        flavor_info;
      default:
              void;
     };

     typedef secinfo4 SECINFO4resok<>;

     union SECINFO4res switch (nfsstat4 status) {
      case NFS4_OK:
              SECINFO4resok resok4;
      default:
              void;
     };

The SECINFO operation is used by the client to obtain a list of valid
RPC authentication flavors for a specific directory filehandle, file
name pair.  SECINFO should apply the same access methodology used for
LOOKUP when evaluating the name.

The result will contain an array which represents the security
mechanisms available, with an order corresponding to server's
preferences,

The field 'flavor' will contain a value of AUTH_NONE,
AUTH_SYS (as defined in [RFC1831]), or RPCSEC_GSS (as defined in
[RFC2203]).

For the flavors AUTH_NONE and AUTH_SYS, no additional security
information is returned.  For a return value of RPCSEC_GSS, a
security triple is returned that contains the mechanism object id (as
defined in [RFC2743]), the quality of protection (as defined in
[RFC2743]) and the service type (as defined in [RFC2203]).  It is
possible for SECINFO to return multiple entries with flavor equal to
RPCSEC_GSS with different security triple values.

The SECINFO operation is expected to be used by the NFS client when
the error value of NFS4ERR_WRONGSEC is returned from another NFS
operation.  This signifies to the client that the server's security
policy is different from what the client is currently using.

========================
SETATTR - Set Attributes
========================

::

     struct SETATTR4args {
             /* CURRENT_FH: target object */
             stateid4        stateid;
             fattr4          obj_attributes;
     };


     RESULT

     struct SETATTR4res {
             nfsstat4        status;
             bitmap4         attrsset;
     };

The new attributes are specified with a bitmap
and the attributes that follow the bitmap in bit order.

The stateid argument for SETATTR is used to provide file locking
context that is necessary for SETATTR requests that set the size
attribute.

A valid stateid should always be
specified.  When the file size attribute is not set, the special
stateid consisting of all bits zero should be passed.

On either success or failure of the operation, the server will return
the attrsset bitmask to represent what (if any) attributes were
successfully set. 

SETATTR is not guaranteed atomic.  A failed SETATTR may partially
change a file's attributes.

================================
SETCLIENTID - Negotiate Clientid
================================

::

     struct SETCLIENTID4args {
             nfs_client_id4  client;
             cb_client4      callback;
             uint32_t        callback_ident;
     };


     RESULT

     struct SETCLIENTID4resok {
             clientid4       clientid;
             verifier4       setclientid_confirm;
     };

     union SETCLIENTID4res switch (nfsstat4 status) {
      case NFS4_OK:
              SETCLIENTID4resok      resok4;
      case NFS4ERR_CLID_INUSE:
              clientaddr4    client_using;
      default:
              void;
     };

The client uses the SETCLIENTID operation to notify the server of its
intention to use a particular client identifier, callback, and
callback_ident for subsequent requests that entail creating lock,
share reservation, and delegation state on the server.  Upon
successful completion the server will return a shorthand clientid
which, if confirmed via a separate step, will be used in subsequent
file locking and file open requests.

Confirmation of the clientid
must be done via the SETCLIENTID_CONFIRM operation to return the
clientid and setclientid_confirm values, as verifiers, to the server.
The reason why two verifiers are necessary is that it is possible to
use SETCLIENTID and SETCLIENTID_CONFIRM to modify the callback and
callback_ident information but not the shorthand clientid.  In that
event, the setclientid_confirm value is effectively the only
verifier.

The callback information provided in this operation will be used if
the client is provided an open delegation at a future point.
Therefore, the client must correctly reflect the program and port
numbers for the callback program at the time SETCLIENTID is used.

The callback_ident value is used by the server on the callback.  The
client can leverage the callback_ident to eliminate the need for more
than one callback RPC program number, while still being able to
determine which server is initiating the callback.

Since SETCLIENTID is a non-idempotent operation, let us assume that
the server is implementing the duplicate request cache (DRC).


When the server gets a SETCLIENTID { v, x, k } request, it processes
it in the following manner.

*     It first looks up the request in the DRC. If there is a hit, it
      returns the result cached in the DRC.  The server does NOT remove
      client state (locks, shares, delegations) nor does it modify any
      recorded callback and callback_ident information for client { x }.

      For any DRC miss, the server takes the client id string x, and
      searches for client records for x that the server may have
      recorded from previous SETCLIENTID calls. For any confirmed record
      with the same id string x, if the recorded principal does not
      match that of SETCLIENTID call, then the server returns a
      NFS4ERR_CLID_INUSE error.

*     The server checks if it has recorded a confirmed record for { v,
      x, c, l, s }, where l may or may not equal k. If so, and since the
      id verifier v of the request matches that which is confirmed and
      recorded, the server treats this as a probable callback
      information update and records an unconfirmed { v, x, c, k, t }
      and leaves the confirmed { v, x, c, l, s } in place, such that t
      != s. It does not matter if k equals l or not.  Any pre-existing
      unconfirmed { v, x, c, *, * } is removed.

*     The server returns { c, t }. It is indeed returning the old
      clientid4 value c, because the client apparently only wants to
      update callback value k to value l.

*     The server awaits confirmation of k via
      SETCLIENTID_CONFIRM { c, t }.

      The server does NOT remove client (lock/share/delegation) state
      for x.

*     ...

======================================
SETCLIENTID_CONFIRM - Confirm Clientid
======================================

::

     struct SETCLIENTID_CONFIRM4args {
             clientid4       clientid;
             verifier4       setclientid_confirm;
     };

     RESULT

     struct SETCLIENTID_CONFIRM4res {
             nfsstat4        status;
     };

This operation is used by the client to confirm the results from a
previous call to SETCLIENTID.  The client provides the server
supplied (from a SETCLIENTID response) clientid.  The server responds
with a simple status of success or failure.

As with SETCLIENTID, SETCLIENTID_CONFIRM is a non-idempotent
operation

===============================
VERIFY - Verify Same Attributes
===============================

::

     struct VERIFY4args {
             /* CURRENT_FH: object */
             fattr4          obj_attributes;
     };

     RESULT

     struct VERIFY4res {
             nfsstat4        status;
     };


The VERIFY operation is used to verify that attributes have a value
assumed by the client before proceeding with following operations in
the compound request.  If any of the attributes do not match then the
error NFS4ERR_NOT_SAME must be returned.

One possible use of the VERIFY operation is the following compound
sequence.  With this the client is attempting to verify that the file
being removed will match what the client expects to be removed.  This
sequence can help prevent the unintended deletion of a file.

::

         PUTFH (directory filehandle)
         LOOKUP (file name)
         VERIFY (filehandle == fh)
         PUTFH (directory filehandle)
         REMOVE (file name)

=====================
WRITE - Write to File
=====================

::

     enum stable_how4 {
             UNSTABLE4       = 0,
             DATA_SYNC4      = 1,
             FILE_SYNC4      = 2
     };

     struct WRITE4args {
             /* CURRENT_FH: file */
             stateid4        stateid;
             offset4         offset;
             stable_how4     stable;
             opaque          data<>;
     };

     RESULT

     struct WRITE4resok {
             count4          count;
             stable_how4     committed;
             verifier4       writeverf;
     };

     union WRITE4res switch (nfsstat4 status) {
      case NFS4_OK:
              WRITE4resok    resok4;
      default:
              void;
     };

The server may
choose to write fewer bytes than requested by the client.

The stateid value for a WRITE request represents a value returned
from a previous record lock or share reservation request.  The
stateid is used by the server to verify that the associated share
reservation and any record locks are still valid and to update lease
timeouts for the client.


The final portion of the result is the write verifier.  The write
verifier is a cookie that the client can use to determine whether the
server has changed instance (boot) state between a call to WRITE and
a subsequent call to either WRITE or COMMIT.  This cookie must be
consistent during a single instance of the NFS version 4 protocol
service and must be unique between instances of the NFS version 4
protocol server, where uncommitted data may be lost.

For a WRITE with a stateid value of all bits 0, the server MAY allow
the WRITE to be serviced subject to mandatory file locks or the
current share deny modes for the file.  For a WRITE with a stateid
value of all bits 1, the server MUST NOT allow the WRITE operation to
bypass locking checks at the server and are treated exactly the same
as if a stateid of all bits 0 were used.

===========================================
RELEASE_LOCKOWNER - Release Lockowner State
===========================================

::

     struct RELEASE_LOCKOWNER4args {
             lock_owner4     lock_owner;
     };

     RESULT

     struct RELEASE_LOCKOWNER4res {
             nfsstat4        status;
     };

This operation is used to notify the server that the lock_owner is no
longer in use by the client.  This allows the server to release
cached state related to the specified lock_owner.

===========================
ILLEGAL - Illegal operation
===========================

::

     void;

     RESULT

             struct ILLEGAL4res {
                     nfsstat4        status;
             };


This operation is a placeholder for encoding a result to handle the
case of the client sending an operation code within COMPOUND that is
not supported. 

A client will probably not send an operation with code OP_ILLEGAL but
if it does, the response will be ILLEGAL4res just as it would be with
any other invalid operation code. Note that if the server gets an
illegal operation code that is not OP_ILLEGAL, and if the server
checks for legal operation codes during the XDR decode phase, then
the ILLEGAL4res would not be returned.

======================
CB_NULL - No Operation
======================

::

     void;

     RESULT

     void;


Standard NULL procedure.  Void argument, void response.  Even though
there is no direct functionality associated with this procedure, the
server will use CB_NULL to confirm the existence of a path for RPCs
from server to client.

=================================
CB_COMPOUND - Compound Operations
=================================

::

     enum nfs_cb_opnum4 {
             OP_CB_GETATTR           = 3,
             OP_CB_RECALL            = 4,
             OP_CB_ILLEGAL           = 10044
     };

     union nfs_cb_argop4 switch (unsigned argop) {
      case OP_CB_GETATTR:    CB_GETATTR4args opcbgetattr;
      case OP_CB_RECALL:     CB_RECALL4args  opcbrecall;
      case OP_CB_ILLEGAL:    void            opcbillegal;
     };

     struct CB_COMPOUND4args {
             utf8str_cs      tag;
             uint32_t        minorversion;
             uint32_t        callback_ident;
             nfs_cb_argop4   argarray<>;
     };

     RESULT

     union nfs_cb_resop4 switch (unsigned resop){
      case OP_CB_GETATTR:    CB_GETATTR4res  opcbgetattr;
      case OP_CB_RECALL:     CB_RECALL4res   opcbrecall;
     };

     struct CB_COMPOUND4res {
             nfsstat4 status;
             utf8str_cs      tag;
             nfs_cb_resop4   resarray<>;
     };

Contained within the CB_COMPOUND results is a 'status' field.  This
status must be equivalent to the status of the last operation that
was executed within the CB_COMPOUND procedure.  Therefore, if an
operation incurred an error then the 'status' value will be the same
error value as is being returned for the operation that failed.


The value of callback_ident is supplied by the client during
SETCLIENTID.  The server must use the client supplied callback_ident
during the CB_COMPOUND to allow the client to properly identify the
server.

===========================
CB_GETATTR - Get Attributes
===========================

::

     struct CB_GETATTR4args {
             nfs_fh4 fh;
             bitmap4 attr_request;
     };

     RESULT

     struct CB_GETATTR4resok {
             fattr4  obj_attributes;
     };

     union CB_GETATTR4res switch (nfsstat4 status) {
      case NFS4_OK:
              CB_GETATTR4resok       resok4;
      default:
              void;
     };

The CB_GETATTR operation is used by the server to obtain the
current modified state of a file that has been write delegated.
The attributes size and change are the only ones guaranteed to be
serviced by the client.

The client returns attrmask bits and the associated attribute
values only for the change attribute, and attributes that it may
change (time_modify, and size).

=====================================
CB_RECALL - Recall an Open Delegation
=====================================

::

     struct CB_RECALL4args {
             stateid4        stateid;
             bool            truncate;
             nfs_fh4         fh;
     };

     RESULT

     struct CB_RECALL4res {
             nfsstat4        status;
     };


The CB_RECALL operation is used to begin the process of recalling an
open delegation and returning it to the server.

The truncate flag is used to optimize recall for a file which is
about to be truncated to zero.  When it is set, the client is freed
of obligation to propagate modified data for the file to the server,
since this data is irrelevant.

The client should reply to the callback immediately.  Replying does
not complete the recall except when an error was returned.  The
recall is not complete until the delegation is returned using a
DELEGRETURN.

=======================================
CB_ILLEGAL - Illegal Callback Operation
=======================================

::

       void;

       RESULT

             struct CB_ILLEGAL4res {
                     nfsstat4        status;
             };

This operation is a placeholder for encoding a result to handle the
   case of the client sending an operation code within COMPOUND that is
   not supported.

Security Considerations
-----------------------

NFS has historically used a model where, from an authentication
perspective, the client was the entire machine, or at least the
source IP address of the machine.  The NFS server relied on the NFS
client to make the proper authentication of the end-user.  The NFS
server in turn shared its files only to specific clients, as
identified by the client's source IP address.  Given this model, the
AUTH_SYS RPC security flavor simply identified the end-user using the
client to the NFS server.  When processing NFS responses, the client
ensured that the responses came from the same IP address and port
number that the request was sent to.  While such a model is easy to
implement and simple to deploy and use, it is certainly not a safe
model.  Thus, NFSv4 mandates that implementations support a security
model that uses end to end authentication, where an end-user on a
client mutually authenticates (via cryptographic schemes that do not
expose passwords or keys in the clear on the network) to a principal
on an NFS server.  Consideration should also be given to the
integrity and privacy of NFS requests and responses.  The issues of
end to end mutual authentication, integrity, and privacy are
discussed as part of the section on "RPC and Security Flavor".

Note that while NFSv4 mandates an end to end mutual authentication
model, the "classic" model of machine authentication via IP address
checking and AUTH_SYS identification can still be supported with the
caveat that the AUTH_SYS flavor is neither MANDATORY nor RECOMMENDED
by this specification, and so interoperability via AUTH_SYS is not
assured.


ACL Mapping
-----------

==========
Posix ACLs
==========

POSIX ACLs use access masks with only the traditional "read",
"write", and "execute" bits.  Each ACE in a POSIX ACL is one of five
types: ACL_USER_OBJ, ACL_USER, ACL_GROUP_OBJ, ACL_GROUP, ACL_MASK,
and ACL_OTHER.  Each ACL_USER ACE has a uid associated with it, and
each ACL_GROUP ACE has a gid associated with it.  Every POSIX ACL
must have exactly one ACL_USER_OBJ, ACL_GROUP_OBJ, and ACL_OTHER ACE,
and at most one ACL_MASK ACE.  The ACL_MASK ACE is required if the
ACL has any ACL_USER or ACL_GROUP ACEs.  There may not be two
ACL_USER ACEs with the same uid, and there may not be two ACL_GROUP
ACEs with the same gid.

we never allow the ACL_USER, ACL_OWNER_OBJ, or
ACL_GROUP objects to grant more than the ACL_MASK object does, and in
the case of ACL_GROUP_OBJ and ACL_GROUP ACEs

In more detail:

1.  If the requester is the file owner, then allow or deny access
    depending on whether the ACL_USER_OBJ ACE allows or denies it.
    Otherwise,

2.  if the requester matches the file's group, and the ACL mask ACE
    would deny the requested access, then skip to step 5.  Otherwise,

3.  if the requester's uid matches the uid of one of the ACL_USER
    ACEs, then allow or deny access depending on whether the
    ACL_USER_OBJ ACE allows or denies it.  Otherwise,

4.  Consider the set of all ACL_GROUP ACEs whose gid the requester is
    a member of.  Add to that set the ACL_GROUP_OBJ ACE, if the
    requester is also a member of the file's group.  Allow access if
    any ACE in the resulting set allows access.  If the set of
    matching ACEs is nonempty, and none allow access, then deny
    access.  Otherwise, if the set of matching ACEs is empty,

5.  if the requester's access mask is allowed by the ACL_OTHER ACE,
    then grant access.  Otherwise, deny access.

Directories, however, may have two
ACLs: one, the "access ACL", used to determine access to the
directory, and one, the "default ACL", used only as the ACL to be
inherited by newly created objects in the directory.

POSIX ACLs are unordered


Full details refer 
	https://tools.ietf.org/html/draft-ietf-nfsv4-acl-mapping-05


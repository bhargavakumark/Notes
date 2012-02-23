DNS and BIND
============

.. contents::

Types of Nameservers
--------------------
A primary master nameserver for a zone reads the data for the zone from a file on its host. A secondary master nameserver for a zone gets the zone data from another nameserver authoritative for the zone, called its master server. Quite often, the master server is the zone's primary master, but that's not required: a secondary master can load zone data from another secondary. Nowadays, the preferred term for a secondary master nameserver is a slave.

Queries
-------
Queries come in two flavors, recursive and iterative, also called nonrecursive. Recursive queries place most of the burden of resolution on a single nameserver. Recursion, or recursive resolution, is just a name for the resolution process used by a nameserver when it receives recursive queries.
In recursion, a resolver sends a recursive query to a nameserver for information about a particular domain name. The queried nameserver is then obliged to respond with the requested data or with an error stating either that data of the requested type doesn't exist or that the domain name specified doesn't exist.[*] The nameserver can't just refer the querier to a different nameserver, because the query was recursive. If the queried nameserver isn't authoritative for the data requested, it will have to query other nameservers to find the answer.

Setting Up Zone Data
--------------------
The DNS version of the data has multiple files. One file maps all the hostnames to addresses. Other files map the addresses back to hostnames. A file that maps hostnames to addresses is called db.DOMAIN. For movie.edu, this file is called db.movie.edu. The files mapping addresses to hostnames are called db.ADDR, where ADDR is the network number without trailing zeros or the specification of a netmask. In our example, the files are called db.192.249.249 and db.192.253.253; there's one for each network. There are a few other zone datafiles: db.cache and db.127.0.0.

Zone Data Files
---------------
DNS lookups are case-insensitive, so you can enter names in your zone datafiles in uppercase, lowercase, or mixed case. However, even though lookups are case-insensitive, case is preserved. That way, if you add records for Titanic.movie.edu to your zone data, people looking up titanic.movie.edu will find the records, but with a capital "T" in the domain name.

Resource records must start in the first column of a line. The order of resource records in the zone datafiles is as follows:

    SOA record
        Indicates authority for this zone 
    NS record
        Lists a nameserver for this zone 
    A
        Name-to-address mapping 
    PTR
        Address-to-name mapping 
    CNAME
        Canonical name (for aliases) 

----------
SOA record
----------

::
        @ movie.edu. IN SOA toystory.movie.edu. al.movie.edu. (
                                  1        ; Serial
                                  3h       ; Refresh after 3 hours
                                  1h       ; Retry after 1 hour
                                  1w       ; Expire after 1 week
                                  1h )     ; Negative caching TTL of 1 hour

The first name after SOA (toystory.movie.edu.) is the name of the primary nameserver for the movie.edu zone. The second name (al.movie.edu.) is the mail address of the person in charge of the zone if you replace the first "." with an "@". Often you'll see root, postmaster, or hostmaster as the email address. Nameservers won't use this address; it's meant for human consumption.

Serial number can any number like date, but it should always increase with changes to zone data. Slaves when contacting master check the serial number for verification of any changes.

**retry** value is used if slave cannot reach the master currently and when to retry connecting to the master.

**expire** declares when the slave will expire the cached data. If master could not reached even after retries then the config expires after expire time.

add similar SOA records to the beginning of the db.192.249.249 and db.192.253.253 files. In these files, we change the first name in the SOA record from movie.edu. to the name of the appropriate in-addr.arpa zone: 249.249.192.in-addr.arpa. and 253.253.192.in-addr.arpa., respectively.

---------
NS record
---------
We add one NS record for each nameserver authoritative for our zone. Here are the NS records from the db.movie.edu file:

::

        movie.edu.  IN NS  toystory.movie.edu.
        movie.edu.  IN NS  wormhole.movie.edu.

As with the SOA record, we add NS records to the db.192.249.249 and db.192.253.253 files, too.

Address and Alias records
-------------------------

::

        ;
        ; Host addresses
        ;
        localhost.movie.edu.      IN A     127.0.0.1
        shrek.movie.edu.          IN A     192.249.249.2
        toystory.movie.edu.       IN A     192.249.249.3
        monsters-inc.movie.edu.   IN A     192.249.249.4
        misery.                   IN A     192.253.253.2
        shining.movie.edu.        IN A     192.253.253.3
        carrie.movie.edu.         IN A     192.253.253.4
        ;
        ; Multi-homed hosts
        ;
        wormhole.movie.edu.       IN A     192.249.249.1
        wormhole.movie.edu.       IN A     192.253.253.1
        ;
        ; Aliases
        ;
        toys.movie.edu.           IN CNAME toystory.movie.edu.
        mi.movie.edu.             IN CNAME monsters-inc.movie.edu.
        wh.movie.edu.             IN CNAME wormhole.movie.edu.
        wh249.movie.edu.          IN A     192.249.249.1
        wh253.movie.edu.          IN A     192.253.253.1

A **CNAME** record maps an alias to its canonical name. When a nameserver looks up a name and finds a CNAME record, it replaces the name with the canonical name and looks up the new name. For example, when the nameserver looks up wh.movie.edu, it finds a CNAME record pointing to wormhole.movie.edu. It then looks up wormhole.movie.edu and returns both addresses.

There is one thing to remember about aliases like toys.movie.edu: they should never appear on the right side of a resource record. Notice that the NS records we just created use the canonical name.

if a host is multihomed (has more than one network interface), create an address (A) record for each alias unique to one address and then create a CNAME record for each alias common to all the addresses.

----------
PTR record
----------

::

        .249.249.192.in-addr.arpa.  IN PTR wormhole.movie.edu.
        .249.249.192.in-addr.arpa.  IN PTR shrek.movie.edu.
        .249.249.192.in-addr.arpa.  IN PTR toystory.movie.edu.
        .249.249.192.in-addr.arpa.  IN PTR monsters-inc.movie.edu.

Addresses should point to only a single name: the canonical name.

---------
MX record
---------
MX records specify a mail exchanger for a domain name: a host that will either process or forward mail for the domain name. Processing the mail means either delivering it to the individual to whom it's addressed or gatewaying it to another mail transport, such as X.400. Forwarding means sending it to its final destination or to another mail exchanger closer to the destination via SMTP

::

        plange.puntacana.dr.  IN  MX  1 listo.puntacana.dr.
        plange.puntacana.dr.  IN  MX  2 hep.puntacana.dr.

specifies that listo.puntacana.dr is a mail exchanger for plange.puntacana.dr at preference value 10. Taken together, the preference values of a destination's mail exchangers determine the order in which a mailer should use them. Mailers should attempt delivery to the mail exchangers with the lowest preference values first. The most preferred mail exchanger has the lowest preference value.

To prevent mail from looping between mail servers, mailers discard certain MX records before they decide where to send a message. A mailer sorts the list of MX records by preference value and looks in the list for the canonical domain name of the host on which it's running. If the local host appears as a mail exchanger, the mailer discards that MX record and all MX records in which the preference value is equal or higher (that is, equally or less-preferred mail exchangers). That prevents the mailer from sending messages to itself or to mailers "farther" from the eventual destination.

---------------------------------
Responsible Person and TXT record
---------------------------------

The record takes two arguments as its record-specific data: an electronic mail address in domain name format and a domain name pointing to additional data about the contact. The electronic mail address is in the same format the SOA record uses: it substitutes a "." for the "@". The next argument is a domain name, which must have a TXT record associated with it. The TXT record then contains free-format information about the contact, such as full name and phone number. If you omit either field, you must specify the root domain (".") as a placeholder instead.
Here are some example RP (and associated) records:

::

        shrek        IN  RP   root.movie.edu.  hotline.movie.edu.
                     IN  RP   snewman.movie.edu.  sn.movie.edu.
        hotline      IN  TXT  "Movie U. Network Hotline, (415) 555-4111"
        sn           IN  TXT  "Sommer Newman, (415) 555-9612"

BIND configuration
------------------
On a primary server, the configuration file contains one zone statement for each zone datafile to be read. Each line starts with the keyword zone followed by the zone's domain name and the class (in stands for Internet). The type master indicates this server is a primary nameserver. The last line contains the filename:

::

        zone "movie.edu" in {
              type master;
              file "db.movie.edu";
        };
        zone "249.249.192.in-addr.arpa" in {
                type master;
                file "db.192.249.249";
        };
        zone "253.253.192.in-addr.arpa" in {
                type master;
                file "db.192.253.253";
        };
        zone "0.0.127.in-addr.arpa" in {
                type master;
                file "db.127.0.0";
        };
        zone "." in {
                type hint;
                file "db.cache";
        };

By default, BIND expects the configuration file to be named /etc/named.conf. The zone datafiles for our example are in the directory /var/named.

Configuring Slave
-----------------

::

        zone "movie.edu" in {
              type slave;
              file "bak.movie.edu";
              masters { 192.249.249.3; };
        };

The slave nameserver keeps a backup copy of this zone in the local file bak.movie.edu.

sortlist directive
------------------

::

        sortlist 128.32.42.0/255.255.255.0 15.0.0.0

The resolver sorts any addresses in a reply that match these arguments into the order in which they appear in the directive, and appends addresses that don't match to the end.

options directive
-----------------
BIND 8.2 introduced four new resolver options: attempts, timeout, rotate, and no-check-names. attempts allows you to specify how many queries the resolver should send to each nameserver in resolv.conf before giving up (default:2). timeout allows you to specify the initial timeout for a query to a nameserver in resolv.conf. The default value is five seconds. For the second and successive rounds of queries, the resolver still doubles the initial timeout and divides by the number of nameservers in resolv.conf. rotate lets your resolver use all the nameservers in resolv.conf, not just the first one.

Note that many programs can't take advantage of this because they initialize the resolver, look up a name, then exit. Rotation has no effect on repeated ping commands, for example, because each ping process initializes the resolver, queries the first nameserver in resolv.conf, and then exits before using the resolver again. Each successive invocation of ping has no idea which nameserver the previous one usedor even that ping was run earlier. But long-lived processes that send lots of queries, such as a sendmail daemon, can take advantage of rotation.

ndc and controls
----------------
You send messages to a nameserver via the control channel using a program called ndc (in BIND 8) or rndc (in BIND 9). Prior to BIND 8.2, ndc was simply a shell script that allowed you to substitute convenient arguments (such as reload) for signals (such as HUP). We'll talk about that version of ndc later in this chapter.

Executed without arguments, ndc will try to communicate with a nameserver running on the local host by sending messages through a Unix domain socket. The socket is usually called /var/run/ndc. You can also use ndc to send messages across a TCP socket to a nameserver, possibly remote from the host that you're running ndc on. To use this mode of operation, run ndc with the -c command-line option, specifying the name or address of the nameserver, a slash, and the port on which it's listening for control messages. For example:

::

         ndc -c 127.0.0.1/953

To configure your nameserver to listen on a particular TCP port for control messages, use the controls statement:

::

        controls {
            inet 127.0.0.1 port 953 allow { localhost; };
        };
        controls {
            inet * port 953 allow { localnets; };
        };

rndc and controls
-----------------

::

        controls {
               inet * allow { any; } keys { "rndc-key"; };
        };


This determines which cryptographic key rndc users must authenticate themselves with to send control messages to the nameserver. If you leave the keys specification out, you'll see this message after the nameserver starts:

::

        Jan 13 18:22:03 terminator named[13964]: type 'inet' control channel
        has no 'keys' clause; control channel will be disabled

The key or keys specified in the keys substatement must be defined in a key statement:

::

        key "rndc-key" {
                algorithm hmac-md5;
                secret "Zm9vCg==";
        };

The key statement can go directly in named.conf, but if your named.conf file is world-readable, it's safer to put it in a different file that's not world-readable and include that file in named.conf:

::

        include "/etc/rndc.key";

The only algorithm currently supported is HMAC-MD5, a technique for using the fast MD5 secure hash algorithm to do authentication.[*] The secret is simply the base-64 encoding of a password that named and authorized rndc users will share. You can generate the secret using programs such as mmencode or dnssec-keygen from the BIND distribution. For example, you can use mmencode to generate the base-64 encoding of foobarbaz:

::

        % mmencode foobarbaz
        CmZvb2JhcmJh

If your version of BIND comes with rndc-confgen, you can let the tool do most of the work for you. Simply run:

::

        # rndc-confgen > /etc/rndc.conf

        Here is what you'll see in /etc/rndc.conf: 
        # Start of rndc.conf
        key "rndc-key" {
            algorithm hmac-md5;
            secret "4XErjUEy/qgnDuBvHohPtQ==";
        };
        options {
            default-key "rndc-key";
            default-server 127.0.0.1;
            default-port 953;
        };
        # End of rndc.conf
        # Use with the following in named.conf,
        # adjusting the allow list as needed:
        #
        # key "rndc-key" {
        #     algorithm hmac-md5;
        #     secret "4XErjUEy/qgnDuBvHohPtQ==";
        # };
        #
        # controls {
        #     inet 127.0.0.1 port 953
        #         allow { 127.0.0.1; } keys { "rndc-key"; };
        # };
        # End of named.conf

-------------
rndc commands
-------------

    reload
        Same as the ndc command. 
    refresh zone
        Schedules an immediate refresh for the specified zone (i.e., an SOA query to the zone's master). 
    retransfer zone
        Immediately retransfers the specified zone without checking the serial number. 
    freeze zone
        Suspends dynamic updates to the specified zone. Covered in Chapter 10. 
    thaw zone
        Resumes dynamic updates to the specified zone. Covered in Chapter 10. 
    reconfig
        Same as the ndc command. 
    stats
        Same as the ndc command. 
    querylog
        Same as the ndc command. 
    dumpdb
        Same as the ndc command. Also allows you to specify whether to dump just cache with the -cache option, authoritative zones with the -zones option, or both with the -all option. 
    stop
        Same as the ndc command. 
    halt
        Same as stop, but doesn't save pending dynamic updates. 
    trace
        Same as the ndc command. 
    notrace
        Same as the ndc command. 
    flush
        Flushes (empties) the nameserver's cache. 
    flushname name
        Flushes all records attached to the specified domain name from the nameserver's cache. 
    status
        Same as the ndc command. 
    recursing
        Dump information about the recursive queries currently being processed to the file named.recursing in the current working directory. 

------------------------
Adding or Deleting hosts
------------------------

*   Update the serial number in db.DOMAIN.
*   Add any A (address), CNAME (alias), and MX (mail exchanger) records for the host to the db.DOMAIN file.
*   Update the serial number and add PTR records to each db.ADDR file for which the host has an address.
*   Reload the primary nameserver; this forces it to load the new information:

   *    # rndc reload
   *    # rndc reload movie.edu

Caching-only name servers
-------------------------
Creating caching-only nameservers is another alternative when you need more servers. Caching-only nameservers are nameservers not authoritative for any zones (except 0.0.127.in-addr.arpa). The named.conf file for a caching-only server contains these lines:

::

        options {
            directory "/var/named";  // or your data directory
        };
        zone "0.0.127.in-addr.arpa" {
            type master;
            file "db.127.0.0";
        };
        zone "." {
            type hint;
            file "db.cache";
        };

Subdomain in Parent's zone
--------------------------

By creating resource records that refer to the subdomain within the parent's zone.

::

        brazil.personnel      IN  A      192.253.253.10
                              IN  MX     10 brazil.personnel.movie.edu.
                              IN  MX     100 postmanrings2x.movie.edu.
        employeedb.personnel  IN  CNAME  brazil.personnel.movie.edu.
        db.personnel          IN  CNAME  brazil.personnel.movie.edu.

Delegating a subdomain
----------------------
To delete fx.movie.edu to bladerunner and outland servers

::

        fx    86400    IN    NS    bladerunner.fx.movie.edu.
              86400    IN    NS    outland.fx.movie.edu.
        bladerunner.fx.movie.edu.  86400  IN  A  192.253.254.2
        outland.fx.movie.edu.      86400  IN  A  192.253.254.3


Subdomains in in-addr.arpa domain
---------------------------------
Within its db.172.20 zone datafile, it needs to add NS records like these:

::

        2     86400    IN    NS    gump.fx.altered.edu.
        15    86400    IN    NS    prettywoman.makeup.altered.edu.
        15    86400    IN    NS    priscilla.makeup.altered.edu.
        25    86400    IN    NS    blowup.foley.altered.edu.

        200.1.15.in-addr.arpa.    86400    IN    NS    ns-1.cns.hp.com.
        201.1.15.in-addr.arpa.    86400    IN    NS    ns-1.cns.hp.com.

Dynamic DNS updates
-------------------
For the most part, dynamic update functionality is used by programs such as DHCP servers that assign IP addresses automatically to computers and then need to register the resulting name-to-address and address-to-name mappings. Some of these programs use the new ns_update() resolver routine to create update messages and send them to an authoritative server for the zone that contains the domain name.

It's also possible to create updates manually with the command-line program nsupdate, which is part of the standard BIND distribution. nsupdate reads one-line commands and translates them into an update message. Commands can be specified on standard input (the default) or in a file, whose name must be given as an argument to nsupdate. Commands not separated by a blank line are incorporated into the same update message, as long as there's room.
nsupdate understands the following commands:

    prereq yxrrset domain name type [rdata]
        Makes the existence of an RRset of type type owned by domain name a prerequisite for performing the update specified in successive update commands. If rdata is specified, it must also match. 
    prereq nxrrset domain name type
        Makes the nonexistence of an RRset of type type owned by domain name a prerequisite for performing the update specified. 
    prereq yxdomain domain name
        Makes the existence of the specified domain name a prerequisite for performing the update. 
    prereq nxdomain domain name
        Makes the nonexistence of the specified domain name a prerequisite for performing the update. 
    update delete domain name [type] [rdata]
        Deletes the domain name specified or, if type is also specified, deletes the RRset specified or, if rdata is also specified, deletes the record matching domainname, type, and rdata. 
    update add domain name ttl [class] type rdata
        Adds the record specified to the zone. Note that the TTL, in addition to the type and resource record-specific data, must be included, but the class is optional and defaults to IN. 

So, for example, the command:

::

        % nsupdate
        > prereq nxdomain mib.fx.movie.edu.
        > update add mib.fx.movie.edu. 300 A 192.253.253.16
        > send
        % nsupdate
        > prereq yxrrset mib.fx.movie.edu. MX
        > update delete mib.fx.movie.edu. MX
        > update add mib.fx.movie.edu. 600 MX 10 mib.fx.movie.edu.
        > update add mib.fx.movie.edu. 600 MX 50 postmanrings2x.movie.edu.
        > send


As with queries, the nameservers that process dynamic updates answer them with DNS messages that indicate whether the update was successful and, if not, what went wrong. Updates may fail for many reasons: for example, because the nameserver wasn't actually authoritative for the zone being updated, because a prerequisite wasn't satisfied, or because the updater wasn't allowed.
There are some limitations to what you can do with dynamic update: you can't delete a zone entirely (though you can delete everything in it except the SOA record and one NS record), and you can't add new zones.

When a nameserver processes a dynamic update, it's changing a zone and must increment that zone's serial number to signal the change to the zone's slaves. This is done automatically. However, the nameserver doesn't necessarily increment the serial number for each dynamic update.

BIND 8 nameservers defer updating a zone's serial number for as long as 5 minutes or 100 updates, whichever comes first. The deferral is intended to deal with a mismatch between a nameserver's ability to process dynamic updates and its ability to transfer zones: the latter may take significantly longer for large zones. When the nameserver does finally increment the zone's serial number, it sends a NOTIFY announcement (described later in this chapter) to tell the zone's slaves that the serial number has changed. BIND 9 nameservers update the serial number once for each dynamic update that is processed.

when they receive dynamic updates, both BIND 8 and 9 nameservers simply append a short record of the update to a logfile.[*] The change takes effect immediately in the copy of the zone the nameservers maintain in memory, of course. But the nameservers can wait and write the entire zone to disk only at a designated interval (hourly, usually). BIND 8 nameservers then delete the logfile because it's no longer needed. (At that point, the copy of the zone in memory is the same as that on disk.) BIND 9 nameservers, however, leave the logfile because they also use it for incremental zone transfers, which we'll cover later in this chapter. (BIND 8 nameservers keep incremental zone transfer information in another file.)

allow-update takes an address match list as an argument. The address or addresses matched by the list are the only addresses allowed to update the zone. It's prudent to make this access control list as restrictive as possible:

::

        zone "fx.movie.edu" {
            type master;
            file "db.fx.movie.edu";
            allow-update { 192.253.253.100; }; // just our DHCP server
        };


The allow-update-forwarding substatement takes an address match list as an argument. Only updates from IP addresses that match the address match list will be forwarded. So the following zone statement forwards only those updates from the Special Effects Department's subnet:

::

        zone "fx.movie.edu" {
            type slave;
            file "bak.fx.movie.edu";
            allow-update-forwarding { 192.253.254/24; };
        };
        zone "fx.movie.edu" {
            type master;
            file "db.fx.movie.edu";
            allow-update { key dhcp-server.fx.movie.edu.; }; // allow only updates
                                                             // signed by the dhcp
                                                             // server's tsig key
        };

        So, if the host mummy.fx.movie.edu uses a key called mummy.fx.movie.edu to sign its dynamic updates, we can restrict mummy.fx.movie.edu to updating its own records with the following: 
        zone "fx.movie.edu" {
            type master;
            file "db.fx.movie.edu";
            update-policy { grant mummy.fx.movie.edu. self mummy.fx.movie.edu.; };
        };

        or just its own address records with this: 
        zone "fx.movie.edu" {
            type master;
            file "db.fx.movie.edu";
            update-policy { grant mummy.fx.movie.edu. self mummy.fx.movie.edu. A; };
        };

        More generally, we can restrict all our clients to updating only their own address records using: 
        zone "fx.movie.edu" {
            type master;
            file "db.fx.movie.edu";
            update-policy { grant *.fx.movie.edu. self fx.movie.edu. A; };
        };
        zone "fx.movie.edu" {
            type master;
            file "db.fx.movie.edu";
            update-policy {
                grant dhcp-server.fx.movie.edu. wildcard *.fx.movie.edu. A TXT PTR;
            };
        };

DNS NOTIFY (Zone Change Notification)
-------------------------------------
When does the nameserver notice a change? Restarting a primary nameserver causes it to notify all its slaves as to the current serial number of all of its zones because the primary has no way of knowing whether its zone datafiles were edited before it started. Reloading one or more zones with new serial numbers causes a nameserver to notify the slaves of those zones. And a dynamic update that causes a zone's serial number to increment also causes notification.

::

        zone "fx.movie.edu" {
            type slave;
            file "bak.fx.movie.edu";
            notify yes;
            also-notify { 15.255.152.4; }; // This is a BIND 8 slave, which
                                           // must be explicitly configured
                                           // to notify its slave
        };


Incremental Zone Transfer (IXFR)
--------------------------------

::

        options {
            directory "/var/named";
            ixfr-from-differences yes;
        };

Forwarding
----------
A primary or slave nameserver's mode of operation changes slightly when it is configured to use a forwarder. If a resolver requests records that are already in the nameserver's authoritative data or cached data, the nameserver answers with that information; this part of its operation hasn't changed. However, if the records aren't in its database, the nameserver sends the query to a forwarder and waits a short period for an answer before resuming normal operation and starting the iterative name resolution process. This mode of operation is called forward first. What the nameserver is doing differently here is sending a recursive query to the forwarder, expecting it to find the answer. At all other times, the nameserver sends out only nonrecursive queries to other nameservers.

You may want to restrict your nameservers even furtherstopping them from even trying to contact an off-site server if their forwarder is down or doesn't respond. You can do this by configuring your nameservers to use forward-only mode.

::

        options {
            forwarders { 192.249.249.1; 192.249.249.3; };
            forward only;
        };

Round-robin load balancing
--------------------------

::

        foo.bar.baz.    60    IN    A    192.168.1.1
        foo.bar.baz.    60    IN    A    192.168.1.2
        foo.bar.baz.    60    IN    A    192.168.1.3

It's a good idea to reduce the records' time to live, too, as we did in this example. This ensures that if the addresses are cached on an intermediate nameserver that doesn't support round-robin, they'll time out of the cache quickly. If the intermediate nameserver looks up the name again, your authoritative nameserver can round-robin the addresses again.

rrset-order
-----------
if we want to ensure that the address records for www.movie.edu are always returned in the same order, we'd use this rrset-order substatement:

::

        options {
            rrset-order {
                class IN type A name "www.movie.edu" order fixed;
            };
        };
        options {
            rrset-order {
                order random;
            };
        };
        options {
            rrset-order {
                type A name "*.movie.edu" order cyclic;
            };
        };

The default behavior is:

::

        options {
            rrset-order {
                class IN type ANY name "*" order cyclic;
            };
        };


TSIG
----
transaction signatures, or TSIG for short. TSIG uses shared secrets and a one-way hash function to authenticate DNS messages, particularly responses and updates. With TSIG configured, a nameserver or updater adds a TSIG record to the additional data section of a DNS message. The TSIG record "signs" the DNS message, proving that the message's sender had a cryptographic key shared with the receiver and that the message wasn't modified after it left the sender.

TSIG provides authentication and data integrity through the use of a special type of mathematical formula called a one-way hash function. A one-way hash function, also known as a cryptographic checksum or message digest, computes a fixed-size hash value based on arbitrarily large input. The magic of a one-way hash function is that each bit of the hash value depends on each and every bit of the input. Change a single bit of the input, and the hash value changes dramatically and unpredictablyso unpredictably that it's "computationally infeasible" to reverse the function and find an input that produces a given hash value.

TSIG uses a one-way hash function called MD5. In particular, it uses a variant of MD5 called HMAC-MD5. HMAC-MD5 works in a keyed mode in which the 128-bit hash value depends not only on the input, but also on a key.

we need to configure both nameservers with a common key:

::

        key toystory-wormhole.movie.edu. {
            algorithm hmac-md5;
            secret "skrKc4Twy/cIgIykQu7JZA==";
        };

::

        # dnssec-keygen -a HMAC-MD5 -b 128 -n HOST toystory-wormhole.movie.edu.
        Ktoystory-wormhole.movie.edu.+157+28446


There's one last problem that we see cropping up frequently with TSIG: time synchronization. The timestamp in the TSIG record is useful for preventing replay attacks, but it tripped us up initially because the clocks on our nameservers weren't synchronized. (They need to be synchronized to within five minutes, the default value for "fudge.")

If you're only concerned about zone transfers (and not about general query traffic, for example), you can specify the key in the masters substatement for any slave zones: Now, on toystory.movie.edu, we can restrict zone transfers to those signed with the toystory-wormhole.movie.edu key:

::
        
        zone "movie.edu" {
            type slave;
            masters { 192.249.249.1 key toystory-wormhole.movie.edu.; };
            file "bak.movie.edu";
        };

        zone "movie.edu" {
            type master;
            file "db.movie.edu";
            allow-transfer { key toystory-wormhole.movie.edu.; };
        };


Firewall
--------
Internal nameservers that can directly query nameservers on the Internet don't require any special configuration. Their root hints files contain the Internet's root nameservers, which enables them to resolve Internet domain names. Internal nameservers that can't query nameservers on the Internet, however, need to know to forward queries they can't resolve to one of the nameservers that can. This is done with the forwarders substatement,

Ours is a packet-filtering firewall, and we negotiated with our firewall administrator to allow DNS traffic between Internet nameservers and two of our nameservers, toystory.movie.edu and wormhole.movie.edu. Here's how we configured the other internal nameservers at the university. For our BIND 8 and 9 nameservers, we used the following:

::

        options {
            forwarders { 192.249.249.1; 192.249.249.3; };
            forward only;
        };


        options {
            directory "/var/named";
            forwarders { 192.249.249.1; 192.253.253.3; };
        };
        zone "movie.edu" {
            type slave;
            masters { 192.249.249.3; };
            file "bak.movie.edu";
            forwarders {};
        };


Samba
+++++

.. contents::

Samba AD Config
===============

krb5.conf
---------

::

    [libdefaults]
        default_realm = BK-AD-01.DEV.ACTIIFO.COM
        dns_lookup_realm = false
        dns_lookup_kdc = false
        ticket_lifetime = 24h
        renew_lifetime = 7d
        forwardable = true

    [realms]
    BK-AD-01.DEV.ACTIFIO.COM = {
        kdc = 192.168.29.7
        admin_server = 192.168.29.7
        kpasswd_server = 192.168.29.7
        default_domain = BK-AD-01.DEV.ACTIFIO.COM
    }

smb.conf
--------

::

    workgroup = BK-AD-01

    log level = 3 passdb:3 auth:3 ads:3 winbind:7
    template shell = /bin/bash
    domain master = no
    local master = no
    winbind use default domain = Yes
    winbind enum users = Yes
    winbind enum groups = Yes
    winbind nested groups = Yes
    idmap uid = 5000-33554431
    idmap gid = 5000-33554431

    encrypt passwords = yes
    wins server = 192.168.29.7
    password server = 192.168.29.7

    security = ads
    passdb backend = tdbsam
    realm = BK-AD-01.DEV.ACTIFIO.COM

resolv.conf
-----------

::

    nameserver  <AD_SERVER>     # first line

pam.d
-----

/etc/pam.d/password-auth

::

    #%PAM-1.0
    # This file is auto-generated.
    # User changes will be destroyed the next time authconfig is run.
    auth        required      pam_env.so
    auth        sufficient    pam_unix.so nullok try_first_pass
    #auth       sufficient    pam_winbind.so use_first_pass             # NEW
    auth        sufficient    pam_winbind.so                            # NEW
    auth        requisite     pam_succeed_if.so uid >= 500 quiet
    auth        required      pam_deny.so

    account     required      pam_unix.so
    account     sufficient    pam_localuser.so
    account     sufficient    pam_succeed_if.so uid < 500 quiet
    #account     sufficient    pam_winbind.so use_first_pass            # NEW
    account     sufficient    pam_winbind.so                            # NEW
    account     required      pam_permit.so

    password    requisite     pam_cracklib.so try_first_pass retry=3 type=
    password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok
    #password    sufficient    pam_winbind.so use_first_pass            # NEW
    password    sufficient    pam_winbind.so                            # NEW
    password    required      pam_deny.so

    session     optional      pam_keyinit.so revoke
    session     required      pam_limits.so
    session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
    session     required      pam_unix.so
    session     required      pam_winbind.so                            # NEW
    #session     required      pam_winbind.so use_first_pass            # NEW

/etc/pam.d/system-auth

::

    #%PAM-1.0
    # This file is auto-generated.
    # User changes will be destroyed the next time authconfig is run.
    auth        required      pam_env.so
    auth        sufficient    pam_fprintd.so
    auth        sufficient    pam_unix.so nullok try_first_pass
    #auth       sufficient    pam_winbind.so use_first_pass         # NEW
    auth        sufficient    pam_winbind.so                        # NEW
    auth        requisite     pam_succeed_if.so uid >= 500 quiet
    auth        required      pam_deny.so

    account     required      pam_unix.so
    account     sufficient    pam_localuser.so
    account     sufficient    pam_succeed_if.so uid < 500 quiet
    #account     sufficient    pam_winbind.so use_first_pass        # NEW
    account     sufficient    pam_winbind.so                        # NEW
    account     required      pam_permit.so

    password    requisite     pam_cracklib.so try_first_pass retry=3 type=
    password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok
    #password    sufficient    pam_winbind.so use_first_pass        # NEW
    password    sufficient    pam_winbind.so                        # NEW
    password    required      pam_deny.so

    session     optional      pam_keyinit.so revoke
    session     required      pam_limits.so
    session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
    session     required      pam_unix.so
    #session     required      pam_winbind.so use_first_pass        # NEW
    session     required      pam_winbind.so                        # NEW

nsswitch.conf
-------------

::

    passwd:     files winbind
    shadow:     files winbind
    group:      files winbind
    
    hosts:      files dns wins

wbinfo
------

::
    
    # Verify username/password
    wbinfo -a 'administrator%12!pass345'

    wbinfo -h 

Mounting CIFS share
===================

::

    mount -t cifs -o username=<>,password=<> //<server>/IP <mntpt>



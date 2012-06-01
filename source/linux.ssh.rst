Linux : SSH
===========

.. contents::

SSH Ask Password (SSH_ASKPASS)
------------------------------

If ssh needs a passphrase, it will read the passphrase from the 
current terminal if it was run from a terminal. If ssh does not 
have a terminal associated with it but **DISPLAY** and 
**SSH_ASKPASS** are set, it will execute the program specified by 
SSH_ASKPASS and open an X11 window to read the passphrase. This 
is particularly useful when calling ssh from a .Xsession or related 
script. (Note that on some machines it may be necessary to redirect 
the input from /dev/null to make this work.)

::

        export DISPLAY=none:0.0
        export SSH_ASKPASS=/tmp/ssh_askpass.sh
        pipename="/tmp/ssh_pipe.$$.$$"

        username=$1
        hostname=$2
        password=$3

        # SSH askpass script.
        cat > ${SSH_ASKPASS} << EOF
        #!/bin/bash
        head -1 ${pipename}
        EOF
        chmod 700 ${SSH_ASKPASS}

        # Write password to pipe. We need to go in background as writing to pipe will
        # not return until someone reads it.
        echo $password  > ${pipename} &

        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o NumberOfPasswordPrompts=1 -o UserKnownHostsFile=/dev/null $username@$hostname "ls /" 2> /dev/null
        # Remove the pipe
        rm -f ${pipename}

        exit 0

SSH Tunneling
-------------
  
To open a port on the remote server and let content on that port to 
be forwarded to local ssh port, so that users on the remote server 
can login to this machine

::

        ssh -R 1234:127.0.0.1:22 bhargava@10.216.50.132

To open a port locally and forward any incoming connections on that 
port to a remoteserver on port 80

::

        ssh -L 8080:www.google.com:80 bhargava@10.216.50.132

===========
Socks Proxy
===========

::

	ssh -D 9999 username@ip-address-of-ssh-server

Debug : sshd -d
---------------

PAM
---

Sample pam.d/sshd

::

	session include common-session
	#account [default=ignore success=1] pam_succeed_if.so quiet user ingroup sysstoadmin
	#account [default=bad success=ignore] pam_succeed_if.so quiet user in support:root:sfs-replication
	account [default=ignore success=done] pam_succeed_if.so quiet user ingroup sysstoadmin
	account [default=ignore success=done] pam_succeed_if.so quiet user in support:root:sfs-replication



PAM
===

Conf files
----------
- /etc/pam.conf
- /etc/pam.d/

This dynamic configuration is set by the contents of the single Linux-PAM configuration file /etc/pam.conf. Alternatively, the configuration can be set by individual configuration files located in the /etc/pam.d/ directory. The presence of this directory will cause Linux-PAM to ignore /etc/pam.conf.

 account
   this module type performs non-authentication based account management. It is typically used to restrict/permit access to a service based on the time of day, currently available system resources (maximum number of users) or perhaps the location of the applicant user -- ´root´ login only on the console.

 auth
   this module type provides two aspects of authenticating the user. Firstly, it establishes that the user is who they claim to be, by instructing the application to prompt the user for a password or other means of identification. Secondly, the module can grant group membership or other privileges through its credential granting properties.

 password
   this module type is required for updating the authentication token associated with the user. Typically, there is one module for each ´challenge/response´ based authentication (auth) type.

 session
   this module type is associated with doing things that need to be done for the user before/after they can be given service. Such things include the logging of information concerning the opening/closing of some data exchange with a user, mounting directories, etc.

man Pages
---------

- man pam
- man pam.conf

FileStore Notes
---------------
SFTP:
increase MaxStartups value in /etc/ssh/sshd_config as done in install.sh to something larger so as to allow more number of SSH connections if sftp is required
http://www.techrepublic.com/blog/opensource/chroot-users-with-openssh-an-easier-way-to-confine-users-to-their-home-directories/229
http://www.debian.org/doc/manuals/securing-debian-howto/ap-chroot-ssh-env.en.html
https://calomel.org/sftp_chroot.html
http://www.debian-administration.org/articles/590
https://bbs.archlinux.org/viewtopic.php?pid=957639

ChrootDirectory
        Specifies a path to chroot(2) to after authentication.  This path, and all its components, must be root-owned directories that are not writable by any other user or group.
        The path may contain the following tokens that are expanded at runtime once the connecting user has been authenticated: %% is replaced by a literal '%', %h is replaced by the home directory of the user being authenticated, and %u is replaced by the username of that user.
        The ChrootDirectory must contain the necessary files and directories to support the users' session.  For an interactive session this requires at least a shell, typically sh(1), and basic /dev nodes such as null(4), zero(4), stdin(4), stdout(4), stderr(4), arandom(4) and tty(4) devices.  For file transfer sessions using “sftp”, no additional configuration of the environment is necessary if the in-process sftp server is used (see Subsystem for details).
        The default is not to chroot(2).

ForceCommand
        Forces the execution of the command specified by ForceCommand, ignoring any command supplied by the client and ~/.ssh/rc if present.  The command is invoked by using the user's login shell with the -c option.  This applies to shell, command, or subsystem execution.  It is most useful inside a Match block.  The command originally supplied by the client is available in the SSH_ORIGINAL_COMMAND environment variable.  Specifying a command of “internal-sftp” will force the use of an in-process sftp server that requires no support files when used with ChrootDirectory.

Subsystem
        Configures an external subsystem (e.g. file transfer daemon).  Arguments should be a subsystem name and a command (with optional arguments) to execute upon subsystem request.
        The command sftp-server(8) implements the “sftp” file transfer subsystem.
        Alternately the name “internal-sftp” implements an in-process “sftp” server.  This may simplify configurations using ChrootDirectory to force a different filesystem root on clients.
        By default no subsystems are defined.  Note that this option applies to protocol version 2 only.

Sample Config:
Subsystem       sftp    internal-sftp
Match Group !stoadmin,!sysadmin,!sysstoadmin,*, User *,!root,!sfs-replication,!support
        forceCommand internal-sftp
        ChrootDirectory /vx/fs1/home/nisuser1

- ChrootDirectory requires "all its components, must be root-owned directories" which imposes the limitation that if we want to chroot user to his home directory, then his home directory must be root-owned which sounds pathetic solution, otherwise, error will be 'bad ownership or modes for chroot directory "/vx/fs1/home/nisuser1"'


- Match is based on user or group, Group "!stoadmin,!sysadmin,!sysstoadmin,*" User "!root,!sfs-replication,!support,*", The '*' at the end allows for matching anything else. Even though multiple critiera can be specified on the same as per the man page, and they 'all' have to match, from the debug output it looks like even if only checks for the first one. So we are forced to use the 'User' based pattern, and add all admin users that are create from 'admin> ' to this list. During 'admin> user add' and 'admin> user del' this has to be updated, and also during config import of /etc/passwd file.
[Edit] Once we remove the double quotes it seems to work, instead of '"!stoadmin,!sysadmin,!sysstoadmin,*"' use just '!stoadmin,!sysadmin,!sysstoadmin,*'

Sample pam.d/sshd
session include common-session
#account [default=ignore success=1] pam_succeed_if.so quiet user ingroup sysstoadmin
#account [default=bad success=ignore] pam_succeed_if.so quiet user in support:root:sfs-replication
account [default=ignore success=done] pam_succeed_if.so quiet user ingroup sysstoadmin
account [default=ignore success=done] pam_succeed_if.so quiet user in support:root:sfs-replication

Debug : sshd -d


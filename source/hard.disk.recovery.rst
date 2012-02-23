Hard Disk Recovery
==================

If you do not have an extra hard disk or laptop where you could plugin the faulty disk for recovery and just want to retrieve your data ASAP you could try using Trinity. Trinity Rescue Kit or TRK is a free live Linux distribution that aims specifically at recovery and repair operations on Windows and Linux machines.

The iso image can be downloaded from http://trinityhome.org/

You might have to refer a couple of man pages before this works but the short procedure would be. Boot using the rescue CD, it obtains network ip using dhcp so you should have nfs/ssh access to the server on which you want to backup your disk. Use ddrescue to recover as much of the corrupted disk as possible. Alternately you could mount the ntfs partition and retrieve the files you want.

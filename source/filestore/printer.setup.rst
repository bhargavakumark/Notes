Printer Setup
=============

::

	system-config-printer

	>> Hi,
	>>
	>> How do I configure a Baner B office printer on my SYMC Apple Macbook
	>> Pro? I want the IP address of the printer but did not find it handy
	>> near the machine.
	>>
	>
	> Assuming MacOSX uses CUPS (fair assumption, I think, since it is an
	> Apple project now), add this URI as a network printer:
	>
	> smb://<username>:<password>@SYMC/punaopslptpin02.enterprise.veritas.com/<printer>
	>
	> username -> your SYMC username
	> password -> your SYMC password
	> printer -> find the printer name for your nearest printer
	>
	> To get a list of printers, run:
	>
	> smbclient -W SYMC -U <username> -L punaopslptpin02.enterprise.veritas.com
	>
	> If MacOSX does not have the samba utilities, use whatever tools are
	> provided by the OS.  If not, ask a neighbour with a Windows machine what
	> the printer name is.  For example, Baner B 3rd floor north side printer
	> is PUNAB3FIDF02RICOH2000D02.
	>

	Thanks for the pointer. MacOSX indeed has CUPS and the add printer wizard is also nice. 
	The only thing I was doing wrong was choosing Generic postscript printer driver. 
	I tried it using Generic PCL printer drivers and that worked. 

nsswitch
========

/etc/nsswitch.conf is used to configure the order in which a number of different sources are checked. You select the database you want to configure by specifying a keyword. For naming services, the database name is hosts. The possible sources for the hosts database are dns, nis, nisplus, and files (which refers to /etc/hosts in this case).

::

        hosts:  dns files


By default, resolution moves from one source to the next (e.g., falls back to /etc/hosts from DNS) if the first source isn't available or the name being looked up isn't found. You can modify this behavior by specifying a condition and an action in square brackets between the sources. The possible conditions are:

    UNAVAIL
        The source hasn't been configured (in DNS's case, there is no resolv.conf file, and there is no nameserver running on the local host). 
    NOTFOUND
        The source can't find the name in question (for DNS, the name looked up or the type of data looked up doesn't exist). 
    TRYAGAIN
        The source is busy, but might respond next time (for example, the resolver has timed out while trying to look up a name). 
    SUCCESS
        The requested name was found in the specified source. 


For each criterion, you can specify that the resolver should either continue and fall back to the next source or simply return. The default action is return for SUCCESS and continue for all the other conditions

::

        hosts:  dns [NOTFOUND=return] files


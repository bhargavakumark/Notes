cvs
===

.. contents::

Checkout the source code
------------------------

::

        $ cvs checkout tc
        # Checkout a branch or a tagged source code
        cvs -r <branch> checkout tc

Commit changes
--------------

::

        cvs commit backend.c
        # commit by specifying comments in the command line
        cvs commit -m "Added an optimization pass" backend.c

Defining the CVS repository to use
----------------------------------

        # To checkout from a local repository
        cvs -d /usr/local/cvsroot checkout yoyodyne/tc
        setenv CVSROOT /usr/local/cvsroot

Creating a CVS repository
-------------------------

::

        cvs -d /usr/local/cvsroot init

RSH/SSH protocol for cvs
------------------------
CVS uses the remote shell protocol to perform operations on the server, via the ‘rsh’ or ‘ssh’ commands. To specify the method to use

::

        $ CVS_RSH=ssh
        $ export CVS_RSH
        $ cvs -d :ext:bach@faun:/usr/local/cvsroot checkout foo
        # The ‘bach@’ can be omitted if the username is the same on 
        # both the local and remote hosts.

Importing files into cvs (Creating a directory tree from an existing source directory)
--------------------------------------------------------------------------------------

::

        # If the files you want to install in CVS reside in ‘wdir’, and you want them 
        # to appear in the repository as ‘$CVSROOT/yoyodyne/rdir’, you can do 
        $ cd wdir
        $ cvs import -m "Imported sources" yoyodyne/rdir
            yoyo start

Tag a tree (not same as creating a branch). This will the version that is existing in the current working directory
-------------------------------------------------------------------------------------------------------------------

::

        $ cvs tag rel-1-0 .
        cvs tag: Tagging .
        T Makefile
        T backend.c
        T driver.c
        T frontend.c
        T parser.c

Tag a tree based upon some date of time
---------------------------------------

::

        # NOT TESTED
        cvs rtag -D "24 Sep 1972 20:05" rel-2-0 .

Remove a tag (not branch)
-------------------------

::

        cvs rtag -d rel-0-4 tc

Creating a branch
-----------------

::

        # Using the working copy of the current working directory
        $ cvs tag -b rel-1-0-patches
        # Without using the working copy
        $ cvs rtag -b -r rel-1-0 rel-1-0-patches tc

Update the working copy to a branch or tag
------------------------------------------

::

        $ cvs update -r rel-1-0-patches

Merging branches
----------------

::

        # Merge all changes from the branch, to the current working dir
        $ cvs update -j R1fix m.c  

Adding files to cvs
-------------------

::

        cvs add a.c
        cvs commit a.c
        cvs add b
        cvs add b/b.c

Removing file sfrom cvs
-----------------------

::

        cvs remove a.c
        cvs commit a.c

Keyword list
------------

::

        $Author$
            The login name of the user who checked in the revision. 
        $Date$
            The date and time (UTC) the revision was checked in. 
        $Header$
            A standard header containing the full pathname of the RCS file, the revision number, the date (UTC), the author, the state, and the locker (if locked). Files will normally never be locked when you use CVS. 
        $Id$
            Same as $Header$, except that the RCS filename is without a path. 
        $Name$
            Tag name used to check out this file. The keyword is expanded only if one checks out with an explicit tag name. For example, when running the command cvs co -r first, the keyword expands to ‘Name: first’. 
        $Locker$
            The login name of the user who locked the revision (empty if not locked, which is the normal case unless cvs admin -l is in use). 
        $Log$
            The log message supplied during commit, preceded by a header containing the RCS filename, the revision number, the author, and the date (UTC). Existing log messages are not replaced. Instead, the new log message is inserted after $Log:...$. Each new line is prefixed with the same string which precedes the $Log keyword. For example, if the file contains:

              /* Here is what people have been up to:
               *
               * $Log: frob.c,v $
               * Revision 1.1  1997/01/03 14:23:51  joe
               * Add the superfrobnicate option
               *
               */

            then additional lines which are added when expanding the $Log keyword will be preceded by ‘ * ’. Unlike previous versions of CVS and RCS, the comment leader from the RCS file is not used. The $Log keyword is useful for accumulating a complete change log in a source file, but for several reasons it can be problematic. See section 12.5 Problems with the $Log$ keyword.. 
        $RCSfile$
            The name of the RCS file without a path. 
        $Revision$
            The revision number assigned to the revision. 
        $Source$
            The full pathname of the RCS file. 
        $State$
            The state assigned to the revision. States can be assigned with cvs admin -s---see section A.6.1 admin options. 


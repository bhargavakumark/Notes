Debian Package
==============

.. contents::

Intro
-----
Every .deb is an archive that contains just an ar archive

::

        [root@asldfjk]:# ar t tcpdump_i386.deb
        debian.binary
        control.tar.gz
        data.tar.gz
        [root@asldfjk]:#


dpkg
----

*   **dpkg --info foo.deb** will list metadata about the package, mostly listed information from control file
*   **dpkg --contents foo.deb** will list the files in the package
*   **dpkg --unpack foo.deb** will extract the package locally
*   **dpkg --install foo.deb** will install the package on the local system

control.tar.gz
--------------

*   **Package** contain package name not the file name
*   **Source** shows the source pacakge from which the binary packages was built
*   **Version** will show full package version, including the upstream version (before the hyphen) and Debian version (after the hyphen)
*   **Architecture** will show the CPU for which the package was built
*   **Depends, Recommends, Suggests, Replaces, Conflicts, Enhances** outline the relationships with other packages

Maintainer Scripts
------------------

Typically bash or perl scripts.

*   **preinst** Run prior to extraction onto filesystem
*   **postinst** Run after the extraction onto filesystem
*   **prerm** Run prior to removal from filesystem
*   **postrm** Run after removal from filesystem
*   **config** ask questions to seed to other maintainer scripts

debian/rules
------------

rules file controls how the package is built.

*   **configure** does pre-build configuration such as running ./configure with appropriate options.
*   **build** complies the package from the source
*   **install** copies/moves files from their build destination into the installation tree.
*   **binary, binary-arch and binar-indep** create the binary packages. Typically calls -arch, -indep
*   **clean** returns the packate to the prebuilt stage

Building Debian Package
-----------------------

dh_make requires deb_helper package.

::

        dh_make  -e blabla@blabla -f ./foo.tar.gz

and answer the questions. This will create a directory which contain control file control and the rules file rules.

::

        dpkg-buildpackage -fakeroot

cvs-buildpackage customised for using cvs co and build and remove unncessary files.


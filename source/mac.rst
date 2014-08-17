Mac - Apple
+++++++++++

swapfile
========

swapfile and hibernate files are located at **/private/var/vm**

We can safely remove **sleepimage** in that location, other swapfile* might be in use

::

    $ ls -l /private/var/vm
    total 7340032
    -rw-------  1 root  wheel   67108864 Jun 13 21:27 swapfile0
    -rw-------  1 root  wheel   67108864 Jul 27 20:54 swapfile1
    -rw-------  1 root  wheel  134217728 Jul 27 20:54 swapfile2
    -rw-------  1 root  wheel  268435456 Jul 27 20:54 swapfile3
    -rw-------  1 root  wheel  536870912 Jul 27 20:54 swapfile4
    -rw-------  1 root  wheel  536870912 Jul 27 20:54 swapfile5
    -rw-------  1 root  wheel  536870912 Jul 27 20:54 swapfile6
    -rw-------  1 root  wheel  536870912 Jul 27 20:54 swapfile7
    -rw-------  1 root  wheel  536870912 Jul 27 20:54 swapfile8
    -rw-------  1 root  wheel  536870912 Jul 27 20:54 swapfile9


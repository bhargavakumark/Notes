Linux : nc
==========

.. contents::

nc (pronounced net-cat). nc is one of a large number of tools for 
making a simple TCP connection.

Simple use of nc
----------------
::

        [root@tristan]# nc 192.168.100.17 25
        220 isolde ESMTP
        quit
        221 isolde


Specifying timeout with nc
--------------------------
::

        [root@tristan]# nc -w 5 192.168.98.82 22
         


Specifying source address with nc
---------------------------------
::

        [root@masq-gw]# nc -s 192.168.99.254 192.168.47.3 25
        

Using nc as a server
--------------------
::

        [root@tristan]# nc -l -p 2048
        

Delaying a stream with nc
-------------------------
::

        [root@tristan]# nc -l -p 2048
        

Using nc with UDP
-----------------
::

        [root@tristan]# nc -u 192.168.100.17 3000



Networking : Connectivity Testing
+++++++++++++++++++++++++++++++++

.. contents::

telnet
======

::

    # telnet 192.168.178.1 443
    Trying 192.168.178.1...
    Connected to 192.168.178.1.
    Escape character is '^]'.
    ^]

/dev
====

::

    cat < /dev/tcp/172.24.1.180/26
    SSH-2.0-OpenSSH_5.9
    ^C

Powershell
==========

::

    New-Object System.Net.Sockets.TcpClient("192.168.178.1", 443)

     Client              : System.Net.Sockets.Socket
     Available           : 0
     Connected           : True
     ExclusiveAddressUse : False
     ReceiveBufferSize   : 8192
     SendBufferSize      : 8192
     ReceiveTimeout      : 0
     SendTimeout         : 0
     LingerState         : System.Net.Sockets.LingerOption
     NoDelay             : False

SSL
===

::

    openssl s_client -connect 192.168.178.1:443
    CONNECTED(00000003)

curl
====

::

    curl 127.0.0.1:22
    SSH-2.0-OpenSSH_6.2
    Protocol mismatch

wget
====

::

    wget -v -O- 127.0.0.1:22
    --2014-10-30 13:08:32--  http://127.0.0.1:22/
    Connecting to 127.0.0.1:22... connected.
    HTTP request sent, awaiting response... 200 No headers, assuming HTTP/0.9
    Length: unspecified
    Saving to: `STDOUT'

     [<=>                                                                                                                                                                      ] 0           --.-K/s              SSH-2.0-OpenSSH_6.2

     Protocol mismatch.

     [ <=>                                                                                                                                                                     ] 40          --.-K/s   in 0s     

      2014-10-30 13:08:32 (3.81 MB/s) - written to stdout [40]

netcat
======

::

    $ nc -zv 192.168.178.1 80
    found 0 associations
    found 1 connections:
         1: flags=82<CONNECTED,PREFERRED>
      outif en0
      src 192.168.178.155 port 63237
      dst 192.168.178.1 port 80
      rank info not available
      TCP aux info available
    Connection to 192.168.178.1 port 80 [tcp/http] succeeded!

    $ nc -zv 192.168.178.1 80-81
    found 0 associations
    found 1 connections:
         1: flags=82<CONNECTED,PREFERRED>
      outif en0
      src 192.168.178.155 port 63615
      dst 192.168.178.1 port 80
      rank info not available
      TCP aux info available

    Connection to 192.168.178.1 port 80 [tcp/http] succeeded!
    nc: connectx to 192.168.178.1 port 81 (tcp) failed: Connection refused



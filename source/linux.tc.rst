Linux : tc
==========

.. contents::

Example: Reduce speed of a device
---------------------------------

Reduce speed of a device to 100mbit

::

	tc qdisc add dev pubeth0 root handle 1: htb default 10
	tc class add dev pubeth0 parent 1: classid 1:1 htb rate 100mbit ceil 100mbit
	tc class add dev pubeth0 parent 1:1 classid 1:10 htb rate 100mbit ceil 100mbit

Remove the tc qdisc and restore speed

::

	tc qdisc del dev pubeth0 root



Tech : iSNS
===========

.. contents::

iSNS
----
Internet Storage Name Service (iSNS) protocol allows automated discovery, management and configuration of iSCSI and Fibre Channel devices (using iFCP gateways) on a TCP/IP network.

Components

*    The iSNS Protocol (iSNSP)
*    iSNS clients
*    iSNS servers
*    iSNS databases

Service provided
----------------

*    Name Registration and Storage Resource Discovery
*    Discovery Domains and Login Control
*    State Change Notification
*    Bidirectional Mappings Between Fibre Channel and iSCSI Devices - Because the iSNS database stores naming and discovery information about both Fibre Channel and iSCSI devices, iSNS servers are able to store mappings of Fibre Channel devices to proxy iSCSI device images on the IP network. These mappings may also be made in the opposite direction, allowing iSNS servers to store mappings from iSCSI devices to proxy WWNs.

RFC
---
RFC 4171: Internet Storage Name Service (iSNS)

Entity Status monitoring
------------------------

*    iSCSI target device may register for Entity Status Inquiry (ESI) messages
*    Entity Status Inquiry (ESI) message is sent by the iSNS server, and is used to verify that an iSNS client Portal is reachable and available.
*    If the Portal fails to respond to an administratively-determined number of consecutive ESI messages, then the iSNS server SHALL remove that Portal from the iSNS database.
*    Appropriate State Change Notifications, if any, SHALL be triggered. 


iSNS Server Discovery by clients
--------------------------------

*    Static
*    SLP (Service Location Protocol)
*    DHCP (rfc 4174)
*    Broadcast from Server (periodically)


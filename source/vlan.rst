VLAN
====

.. contents::

VLAN protocol
-------------
The protocol most commonly used today in configuring virtual LANs is IEEE 802.1Q. rior to the introduction of the 802.1Q standard, several proprietary protocols existed, such as Cisco's ISL (Inter-Switch Link) and 3Com's VLT (Virtual LAN Trunk). Cisco also implemented VLANs over FDDI by carrying VLAN information in an IEEE 802.10 frame header, contrary to the purpose of the IEEE 802.10 standard.

Both ISL and IEEE 802.1Q tagging perform "explicit tagging" - the frame itself is tagged with VLAN information. ISL uses an external tagging process that does not modify the existing Ethernet frame, while 802.1Q uses a frame-internal field for tagging, and so does modify the Ethernet frame. This internal tagging is what allows IEEE 802.1Q to work on both access and trunk links: frames are standard Ethernet, and so can be handled by commodity hardware.

The IEEE 802.1Q header contains a 4-byte tag header containing a 2-byte tag protocol identifier (TPID) and a 2-byte tag control information (TCI). The TPID has a fixed value of 0x8100 that indicates that the frame carries the 802.1Q/802.1p tag information. The TCI contains the following elements:

*    Three-bit user priority
*    One-bit canonical format indicator (CFI)
*    Twelve-bit VLAN identifier (VID)-Uniquely identifies the VLAN to which the frame belongs

With ISL, an Ethernet frame is encapsulated with a header that transports VLAN IDs between switches and routers. ISL does add overhead to the packet as a 26-byte header containing a 10-bit VLAN ID. In addition, a 4-byte CRC is appended to the end of each frame. This CRC is in addition to any frame checking that the Ethernet frame requires. The fields in an ISL header identify the frame as belonging to a particular VLAN.

A VLAN ID is added only if the frame is forwarded out a port configured as a trunk link. If the frame is to be forwarded out a port configured as an access link, the ISL encapsulation is removed.

Vlan switchport modes
---------------------

*    **access mode** - vlan is configured on switch. Each port on the switch is set to be in 'access' mode and a corresponding vlan set. In this mode the ethernet packet coming out of the server is 1518 bytes and switch adds the vlan header to make the packet of size 1522. Also called port-based VLANs.
*    **trunk mode** - In trunk mode the ethernet packet coming out of server will itself consist of vlan header and packet size would be 1522. On the switch the port should be configured to be a 'trunk' port so that the switch does not add any more headers or change the headers. 

Cisco VLAN ranges
-----------------

*    Normal range VLANs - VLAN range 1-1005. VLAN numbers 1002 through 1005 are reserved for Token Ring and FDDI VLANs.
*    Extended range VLANs - VLAN range 1006-4094

Cisco VLAN Trunking Protocol (VTP)
----------------------------------
On Cisco Devices, VTP (VLAN Trunking Protocol) maintains VLAN configuration consistency across the entire network. VTP uses Layer 2 trunk frames to manage the addition, deletion, and renaming of VLANs on a network-wide basis from a centralized switch in the VTP server mode. VTP is responsible for synchronizing VLAN information within a VT|P domain and reduces the need to configure the same VLAN information on each switch.

VTP provides the following benefits:

* VLAN configuration consistency across the network
* Mapping scheme that allows a VLAN to be trunked over mixed media
* Accurate tracking and monitoring of VLANs
* Dynamic reporting of added VLANs across the network
* Plug-and-play configuration when adding new VLANs

Before creating VLANs on the switch that will be propagated via VTP, a VTP domain must first be set up. A VTP domain for a network is a set of all contiguously trunked switches with the same VTP domain name. All switches in the same management domain share their VLAN information with each other, and a switch can participate in only one VTP management domain. Switches in different domains do not share VTP information.

Dynamic VLANs are created through the use of software. With a VLAN Management Policy Server (VMPS), an administrator can assign switch ports to VLANs dynamically based on information such as the source MAC address of the device connected to the port or the username used to log onto that device. As a device enters the network, the device queries a database for VLAN membership. See also FreeNAC which implements a VMPS server.

VTP only learns about normal-range VLANs (VLAN IDs 1 to 1005). Extended-range VLANs (VLAN IDs greater than 1005) are not supported by VTP or stored in the VTP VLAN database.

---------
VTP Modes
---------

===========================     =============
VTP Mode                        Description
===========================     =============
VTP server                      In VTP server mode, you can create, modify, and delete VLANs, and specify other configuration parameters (such as the VTP version) for the entire VTP domain. VTP servers advertise their VLAN configurations to other switches in the same VTP domain and synchronize their VLAN configurations with other switches based on advertisements received over trunk links. In VTP server mode, VLAN configurations are saved in NVRAM. VTP server is the default mode.
VTP client                      A VTP client behaves like a VTP server and transmits and receives VTP updates on its trunks, but you cannot create, change, or delete VLANs on a VTP client. VLANs are configured on another switch in the domain that is in server mode. In VTP client mode, VLAN configurations are not saved in NVRAM.
VTP transparent(disabled)       VTP transparent switches do not participate in VTP. A VTP transparent switch does not advertise its VLAN configuration and does not synchronize its VLAN configuration based on received advertisements. However, in VTP Version 2, transparent switches do forward VTP advertisements that they receive from other switches through their trunk interfaces. You can create, modify, and delete VLANs on a switch in VTP transparent mode.
===========================     =============

The switch must be in VTP transparent mode when you create extended-range VLANs.

The switch must be in VTP transparent mode when you create private VLANs.

When the switch is in VTP transparent mode, the VTP and VLAN configurations are saved in NVRAM, but they are not advertised to other switches. In this mode, VTP mode and domain name are saved in the switch running configuration, and you can save this information in the switch startup configuration file by using the copy running-config startup-config privileged EXEC command. The running configuration and the saved configuration are the same for all switches in a stack.

---------------
Configuring VTP
---------------

::

        cisco> enable
        cisco # configure terminal
        cisco (config) # vtp mode server
        cisco (config) # vtp domain <domain-name>
        cisco (config) # vtp password <password>
        cisco (config) # end
        cisco # show vtp status

        cisco> enable
        cisco # configure terminal
        cisco (config) # vtp mode client
        cisco (config) # vtp domain <domain-name>
        cisco (config) # vtp password <password> (optional)
        cisco (config) # end
        cisco # show vtp status

        cisco> enable
        cisco # configure terminal
        cisco (config) # vtp mode transparent
        cisco (config) # end
        cisco # show vtp status

Always **copy running-config startup-config.**

Protocol Based VLANs
--------------------
In a protocol based VLAN enabled switch, traffic is forwarded through ports based on protocol. Essentially, the user tries to segregate or forward a particular protocol traffic from a port using the protocol based VLANs; traffic from any other protocol is not forwarded on the port. For example, if you have connected a host, pumping ARP traffic on the switch at port 10, connected a Lan pumping IPX traffic to the port 20 of the switch and connected a router pumping IP traffic on port 30, then if you define a protocol based VLAN supporting IP and including all the three ports 10, 20 and 30 then IP packets can be forwarded to the ports 10 and 20 also, but ARP traffic will not get forwarded to the ports 20 and 30, similarly IPX traffic will not get forwarded to ports 10 and 30.

Port Membership Modes and Characteristics
-----------------------------------------

+------------------------------+----------------------------------------------+-------------------------------------------------+
| Membership Mode              | VLAN Membership Characteristics              |   VTP Characteristics                           |
+==============================+==============================================+=================================================+
| Static-access                | A static-access port can belong to one VLAN  | VTP is not required. If you do not want VTP     |
|                              | and is manually assigned to that VLAN.       | to globally propagate information, set the VTP  |
|                              |                                              | mode to transparent. To participate in VTP,     |
|                              |                                              | there must be at least one trunk port on the    |
|                              |                                              | switch stack connected to a trunk port of a     |
|                              |                                              | second switch or switch stack.                  |
+------------------------------+----------------------------------------------+-------------------------------------------------+
| Trunk (ISL or IEEE 802.1Q)   | A trunk port is a member of all VLANs by     | VTP is recommended but not required. VTP        |
|                              | default, including extended-range VLANs,     | maintains VLAN configuration consistency by     |
|                              | but membership can be limited by configuring | managing the addition, deletion, and renaming   |
|                              | the allowed-VLAN list. You can also modify   | of VLANs on a network-wide basis. VTP exchanges |
|                              | the pruning-eligible list to block flooded   | VLAN configuration messages with other switches |
|                              | traffic to VLANs on trunk ports that are     | over trunk links.                               |
|                              | included in the list.                        |                                                 |
+------------------------------+----------------------------------------------+-------------------------------------------------+
| Dynamic access               | A dynamic-access port can belong to one VLAN | VTP is required. Configure the VMPS and the     |
|                              | (VLAN ID 1 to 4094) and is dynamically       | client with the same VTP domain name. To        | 
|                              | assigned by a VMPS. The VMPS can be a        | participate in VTP, there must be at least one  |
|                              | Catalyst 5000 or Catalyst 6500 series switch,| trunk port on the switch stack connected to a   |
|                              | for example, but never a Catalyst 3750 switch| trunk port of a second switch or switch stack.  |
|                              | The Catalyst 3750 switch is a VMPS client.   |                                                 |
|                              | You can have dynamic-access ports and trunk  |                                                 |
|                              | ports on the same switch, but you must       |                                                 |
|                              | connect the dynamic-access port to an end    |                                                 |
|                              | station or hub and not to another switch.    |                                                 |
+------------------------------+----------------------------------------------+-------------------------------------------------+
| Voice VLAN                   | A voice VLAN port is an access port attached | VTP is not required; it has no affect on a      |
|                              | to a Cisco IP Phone, configured to use one   | voice VLAN.                                     |
|                              | VLAN for voice traffic and another VLAN for  |                                                 |
|                              | data traffic from a device attached to the   |                                                 |
|                              | phone.                                       |                                                 |
+------------------------------+----------------------------------------------+-------------------------------------------------+
| Private VLAN                 | A private VLAN port is a host or promiscuous | The switch must be in VTP transparent mode when | 
|                              | port that belongs to a private VLAN primary  | you configure private VLANs. When private VLANs |
|                              | or secondary VLAN.                           | are configured on the switch, do not change VTP |
|                              |                                              | mode from transparent to client or server mode. |
+------------------------------+----------------------------------------------+-------------------------------------------------+
| Tunnel (dot1q-tunnel)        | Tunnel ports are used for IEEE 802.1Q        | VTP is not required. You manually assign the    |
|                              | tunneling to maintain customer VLAN          | tunnel port to a VLAN by using the switchport   |
|                              | integrity across a service-provider network. | access vlan interface configuration command.    |
|                              | You configure a tunnel port on an edge       |                                                 |
|                              | switch in the service-provider network and   |                                                 |
|                              | connect it to an IEEE 802.1Q trunk port on   |                                                 |
|                              | a customer interface, creating an asymetric  |                                                 |
|                              | link. A tunnel port belongs to a single VLAN |                                                 |
|                              | that is dedicated to tunneling.              |                                                 |
+------------------------------+----------------------------------------------+-------------------------------------------------+
                                                                                

Trunk Encapsulation Types

==============================================  ==================================================
Encapsulation                                   Function
==============================================  ==================================================
**switchport trunk encapsulation isl**          Specifies ISL encapsulation on the trunk link.
**switchport trunk encapsulation dot1q**        Specifies IEEE 802.1Q encapsulation on the trunk link.
**switchport trunk encapsulation negotiate**    Specifies that the interface negotiate with the neighboring interface to become an ISL (preferred) or IEEE 802.1Q trunk, depending on the configuration and capabilities of the neighboring interface. This is the default for the switch.
==============================================  ==================================================


Configuring VLAN on cisco catalyst 3750
---------------------------------------

-------------
Create a VLAN
-------------

::

        cisco> enable
        cisco # configure terminal
        cisco (config) # vlan <vlan-id>  (This will create the vlan, if vlan does not exist)
        cisco (config-vlan) # name <vlan-name>  (Optional)
        cisco (config-vlan) # exit

Always **copy running-config startup-config.**

---------------
Deleting a VLAN
---------------

::

        cisco> enable
        cisco # configure terminal
        cisco (config) # no vlan <vlan-id>

This operation only deletes vlan and does not move any ports on this vlan to default vlan. To move any ports on this vlan, you have to explicitly put those ports on a specific vlan
Always **copy running-config startup-config.**

----------------------------
Adding/Moving a port to VLAN
----------------------------

::

        cisco> enable
        cisco # configure terminal
        cisco (config) # interface GigabitEthernet 1/0/1
        cisco (config-fi) # switchport mode access
        cisco (config-if) # switchport access vlan <vlan-id>
        cisco (config-if) # exit
        cisco (config) # exit

Always **copy running-config startup-config.**

-------------------------
Removing a port from VLAN
-------------------------

::

        cisco> enable
        cisco # configure terminal
        cisco (config) # interface GigabitEthernet 1/0/1
        cisco (config-if) # no switchport
        cisco (config-if) # switchport
        cisco (config-if) # exit
        cisco (config) # exit

Always **copy running-config startup-config.**

------------------------------------
Configuring a port to trunk (802.1q)
------------------------------------

::

        cisco> enable
        cisco # configure terminal
        cisco (config) # interface GigabitEthernet 1/0/1
        cisco (config-if) # switchport trunk encapsulation do1q
        cisco (config-if) # switchport mode trunk
        cisco (config-if) # switchport trunk allowed vlan {add | all | except | remove} <vlan-list>
        cisco (config-if) # switchport access vlan <vlan-id> (Optional, Specify the default VLAN, which is used if the interface stops trunking.
        cisco (config-if) # switchport native vlan <vlan-id> (Optional, Specify the native VLAN for IEEE 802.1Q trunks, for non-tagged traffic )
        cisco (config-if) # exit

Always **copy running-config startup-config.**

Cisco VMPS
----------
The VLAN Query Protocol (VQP) is used to support dynamic-access ports, which are not permanently assigned to a VLAN, but give VLAN assignments based on the MAC source addresses seen on the port. Each time an unknown MAC address is seen, the switch sends a VQP query to a remote VMPS; the query includes the newly seen MAC address and the port on which it was seen. When the VMPS receives this query, it searches its database for a MAC-address-to-VLAN mapping. The VMPS responds with a VLAN assignment for the port. The switch cannot be a VMPS server but can act as a client to the VMPS and communicate with it through VQP. In secure mode, the server shuts down the port when an illegal host is detected. In open mode, the server simply denies the host access to the port. The switch continues to monitor the packets directed to the port and sends a query to the VMPS when it identifies a new host address. If the switch receives a port-shutdown response from the VMPS, it disables the port. The port must be manually re-enabled by using Network Assistant, the CLI, or SNMP.

http://www.cisco.com/en/US/docs/switches/lan/catalyst3750/software/release/12.2_25_sec/configuration/guide/swvlan.html#wp1103064


VPLS
====

.. contents::

Bridge
------
A network bridge connects multiple network segments at the data link layer (layer 2) of the OSI model, and the term layer 2 switch is very often used interchangeably with bridge.

In Ethernet networks, the term "bridge" formally means a device that behaves according to the IEEE 802.1D standard, this is most often referred to as a network switch in marketing literature. Bridges tend to be more complex than hubs or repeaters due to the fact that bridges are capable of analyzing incoming data packets on a network to determine if the bridge is able to send the given packet to another segment of that same network.

**Switches** that additionally process data at the Network layer (layer 3) (and above) are often referred to as Layer 3 switches or Multilayer switches.

At any layer, a modern switch may implement power over Ethernet (PoE), which avoids the need for attached devices, such as an IP telephone or wireless access point, to have a separate power supply.

Transparent bridging
--------------------
This method uses a forwarding database to send frames across network segments. The forwarding database is initially empty and entries in the database are built as the bridge receives frames. If an address entry is not found in the forwarding database, the frame is rebroadcast to all ports of the bridge, forwarding the frame to all segments except the source address.

By means of these broadcast frames, the destination network will respond and a route will be created. Along with recording the network segment to which a particular frame is to be sent, bridges may also record a bandwidth metric to avoid looping when multiple paths are available. Devices that have this transparent bridging functionality are also known as adaptive bridges. They are primarily found in Ethernet networks.

Source route bridging
---------------------
With source route bridging two frame types are used in order to find the route to the destination network segment. Single-Route (SR) frames comprise most of the network traffic and have set destinations, while All-Route(AR) frames are used to find routes.

Bridges send AR frames by broadcasting on all network branches; each step of the followed route is registered by the bridge performing it. Each frame has a maximum hop count, which is determined to be greater than the diameter of the network graph, and is decremented by each bridge. The first AR frame which reaches its destination is considered to have followed the best route, and the route can be used for subsequent SR frames; the other AR frames are discarded.

This method of locating a destination network can allow for indirect load balancing among multiple bridges connecting two networks. The more a bridge is loaded, the less likely it is to take part in the route finding process for a new destination as it will be slow to forward packets. This method is very different from transparent bridge usage, where redundant bridges will be inactivated; however, more overhead is introduced to find routes, and space is wasted to store them in frames.

Traffic monitoring on a switched network
----------------------------------------
Unless port mirroring or other methods such as RMON[10] or SMON are implemented in a switch, it is difficult to monitor traffic that is bridged using a switch because all ports are isolated until one transmits data, and even then only the sending and receiving ports can see the traffic. These monitoring features rarely are present on consumer-grade switches.

Two popular methods that are specifically designed to allow a network analyst to monitor traffic are:

*    Port mirroring - the switch sends a copy of network packets to a monitoring network connection.
*    SMON - "Switch Monitoring" is described by RFC 2613 and is a protocol for controlling facilities such as port mirroring.

Another method to monitor may be to connect a Layer-1 hub between the monitored device and its switch port. This will induce minor delay, but will provide multiple interfaces that can be used to monitor the individual switch port.

VPLS
----
Virtual private LAN service (VPLS) is a way to provide Ethernet based multipoint to multipoint communication over IP/MPLS networks. It allows geographically dispersed sites to share an Ethernet broadcast domain by connecting sites through pseudo-wires. The technologies that can be used as pseudo-wire can be Ethernet over MPLS, L2TPv3 or even GRE. There are two IETF standards track RFCs (RFC 4761 and RFC 4762) describing VPLS establishment.

VPLS is a virtual private network (VPN) technology. In contrast to layer 2 MPLS VPNs or L2TPv3, which allow only point-to-point layer 2 tunnels, VPLS allows any-to-any (multipoint) connectivity.

In a VPLS, the local area network (LAN) at each site is extended to the edge of the provider network. The provider network then emulates a switch or bridge to connect all of the customer LANs to create a single bridged LAN.

Since VPLS emulates a LAN, full mesh connectivity is required. There are two methods for full mesh establishment for VPLS: using BGP and using Label Distribution Protocol (LDP). The "control plane" is the means by which provider edge (PE) routers communicate for auto-discovery and signaling. Auto-discovery [1] refers to the process of finding other PE routers participating in the same VPN or VPLS. Signaling is the process of establishing pseudo-wires (PW). The PWs constitute the "data plane", whereby PEs send customer VPN/VPLS traffic to other PEs.

With BGP, one has auto-discovery as well as signaling. The mechanisms used are very similar to those used in establishing Layer-3 MPLS VPNs. Each PE is configured to participate in a given VPLS. The PE, through the use of BGP, simultaneously discovers all other PEs in the same VPLS, and establishes a full mesh of pseudo-wires to those PEs.

With LDP, each PE router must be configured to participate in a given VPLS, and, in addition, be given the addresses of other PEs participating in the same VPLS. A full mesh of LDP sessions is then established between these PEs. LDP is then used to create an equivalent mesh of PWs between those PEs.

PEs participating in a VPLS-based VPN must appear as an Ethernet bridge to connected customer edge (CE) devices. Received Ethernet frames must be treated in such a way as to ensure CEs can be simple Ethernet devices.

When a PE receives a frame from a CE, it inspects the frame and learns the CE's MAC address, storing it locally along with LSP routing information. It then checks the frame's destination MAC address. If it is a broadcast frame, or the MAC address is not known to the PE, it floods the frame to all PEs in the mesh.

Ethernet does not have a time to live (TTL) field in its frame header, so loop avoidance must be arranged by other means. In regular Ethernet deployments, Spanning Tree Protocol is used for this. In VPLS, loop avoidance is arranged by the following rule: A PE never forwards a frame received from a PE, to another PE. The use of a full mesh combined with split horizon forwarding guarantees a loop-free broadcast domain.

VPLS is typically used to link a large number of sites together. Scalability is therefore an important issue that needs addressing.


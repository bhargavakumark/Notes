Teredo or IPv6 to IPv4
======================

Teredo is a tunneling protocol designed to grant IPv6 connectivity to nodes that are located behind IPv6-unaware NAT devices. It defines a way of encapsulating IPv6 packets within IPv4 UDP datagrams that can be routed through NAT devices and on the IPv4 internet.

6to4, the most common IPv6 over IPv4 tunneling protocol, requires the tunnel endpoint to have a public IPv4 address. However, many hosts are currently attached to the IPv4 Internet through one or several NAT devices. In such a situation, the only available public IPv4 address is assigned to the NAT device.

Teredo alleviates this problem by encapsulating IPv6 packets within UDP/IPv4 datagrams, which most NATs can forward properly. Thus, IPv6-aware hosts behind NATs can be used as Teredo tunnel endpoints even when they don't have a dedicated public IPv4 address. In effect, a host implementing Teredo can gain IPv6 connectivity with no cooperation from the local network environment

Teredo node types

Teredo defines several different kind of nodes:

*    A Teredo client is a host which has IPv4 connectivity to the internet from behind a NAT and uses the Teredo tunneling protocol to access the IPv6 Internet. Teredo clients are assigned an IPv6 address that starts with the Teredo prefix (2001:0000::/32).
*    A Teredo server is a well-known host which is used for initial configuration of a Teredo tunnel. A Teredo server never forwards any traffic for the client (apart from IPv6 pings), and has therefore very modest bandwidth requirements (a few thousand bytes per minute per client at most), which allows a single server to support large numbers of clients. Additionally, a Teredo server can be implemented in a fully stateless manner.
*    A Teredo relay serves as the remote end of a Teredo tunnel. A Teredo relay must forward all of the data on behalf of the Teredo clients it serves, with the exception of direct Teredo client to Teredo client exchanges. Therefore, a relay requires a lot of bandwidth and can only support a limited number of simultaneous clients. Each Teredo relay serves a range of IPv6 hosts (e.g. a single campus/company, an ISP or a whole operator network, or even the whole IPv6 Internet); it forwards traffic between any Teredo clients and any host within said range.
*    A Teredo host-specific relay is a Teredo relay whose range of service is limited to the very host it runs on. As such, it has no particular bandwidth or routing requirements. A computer with a host-specific relay will use Teredo to communicate with Teredo clients, but it will stick to its main IPv6 connectivity provider to reach the rest of the IPv6 Internet.


For more details refer http://en.wikipedia.org/wiki/Teredo_tunneling

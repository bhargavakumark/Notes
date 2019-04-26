Linux : libnet
==============

Links
-----

For libnet related information refer

* http://www.securityfocus.com/infocus/1386
* http://repura.livejournal.com/23112.html
* http://www.stanford.edu/~stinson/cs155/libnet/libnet_talk.ppt

Libnet(1.1.2) is a reasonably small programming library, written 
mainly in C, providing a high-level, standard portable interface to 
low-level network packet shaping, handling and injection primitives. 
Libnet allows you create ethernet/ip/tcp packets. It allows to 
create a packet at a time, send the packet, clear the existing 
packet and create a new packet. The upper level of libnet interface 
does not provide a way to operate on multiple packets at the same 
time. Header files are located in /usr/include/libnet.

Steps in using libnet
---------------------

*   libnet_init to create a libnet_handle to a certain device.

::

        libnet_t * libnet_init (int injection_type, char *device, char *err_buf)

*	The device argument can be a device name, or NULL, or ip. 
	The injection_type as in "from the link layer up" or "from 
	the network layer up". We'll use LIBNET_RAW4 (IPv4 and above) 
	and LIBNET_LINK (link layer and above). err_buf is a string 
	which will hold an error message if something goes wrong. The 
	handle returned by this call maintains state for the entire 
	session, tracks all memory usage and packet construction.

*   Next step is to create headers(and payload) for the packet that we want to send.

::

      libnet_ptag_t libnet_build_tcp(u_int16_t sp, u_int16_t dp, u_int32_t seq, u_int32_t ack,
      u_int8_t control, u_int16_t win, u_int16_t sum, u_int16_t urg, u_int16_t len, u_int8_t *payload, u_int32_t payload_s, libnet_t *l, libnet_ptag_t ptag);

*	This will allow you a tcp header and payload. Similarly 
	libnet_build_ip and libnet_build_ethernet (optional) to 
	create other protocol headers. The order of header creation 
	should always be from top to bottom. i.e, always create tcp 
	header before trying to create ip header, from the highest 
	on the OSI model to the lowest. After you setup the headers, 
	libnet_write can be used to write the data to the socket. 
	Once the data has been written libnet_clear_packet can be 
	used to clear the data structures for the existing packet 
	and initialise a new packet. All of these functions operate 
	on a libnet handle, which is acquired during libnet_init. 
	There is no direct access to the actual packet that is sent.

*   libnet_talk.ppt: libnet_talk.ppt 


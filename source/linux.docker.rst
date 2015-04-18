Linux: Docker
+++++++++++++

Docker Network Bridge
=====================

When Docker starts, it creates a virtual interface named docker0 on the host machine. It randomly chooses an address and subnet from the private range defined by RFC 1918 that are not in use on the host machine, and assigns it to docker0. Docker made the choice 172.17.42.1/16 when I started it a few minutes ago, for example — a 16-bit netmask providing 65,534 addresses for the host machine and its containers. The MAC address is generated using the IP address allocated to the container to avoid ARP collisions, using a range from 02:42:ac:11:00:00 to 02:42:ac:11:ff:ff.

To use a custom interface and IP range for your docker bridge

::

    sudo usermod -a -G docker $USER
    sudo service docker.io status
    stop docker
    ip link add br1 type bridge
    ip addr add 10.50.1.1/24 dev br1
    ip link set br1 up
    docker -d -b br1

    # For persistence

    auto br1
    iface br1 inet static
        address 10.50.1.1
        netmask 255.255.255.0
        bridge_ports dummy
        bridge_stp off
        bridge_fd 0
        bridge_maxwait 0

Edit **/etc/default/docker.io**

::

    # Use DOCKER_OPTS to modify the daemon startup options.
    DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4 -b=br1"

Docker IP forwarding
====================

Edit **/etc/default/docker.io** and add **--ip-forward=true**

::

    # Use DOCKER_OPTS to modify the daemon startup options.
    DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4 -b=br1 --ip-forward=true"



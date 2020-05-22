Kubernetes
++++++++++

.. contents:: 

Clusters
========

In Google Kubernetes Engine (GKE), a cluster consists of at least one cluster master and multiple worker machines called nodes. These master and node machines run the Kubernetes cluster orchestration system.

The cluster master runs the Kubernetes control plane processes, including the Kubernetes API server, scheduler, and core resource controllers. You can make Kubernetes API calls directly via HTTP/gRPC, or indirectly, by running commands from the Kubernetes command-line client (kubectl) or interacting with the UI in the Cloud Console.

The cluster master's API server process is the hub for all communication for the cluster. All internal cluster processes (such as the cluster nodes, system and components, application controllers) all act as clients of the API server; the API server is the single "source of truth" for the entire cluster.

When you create or update a cluster, container images for the Kubernetes software running on the masters (and nodes) are pulled from the **gcr.io** container registry.

Single-zone clusters
--------------------

A single-zone cluster has a single control plane (master) running in one zone. This control plane manages workloads on nodes running in the same zone.

Multi-zonal clusters
--------------------

A multi-zonal cluster has a single replica of the control plane running in a single zone, and has nodes running in multiple zones. During an upgrade of the cluster or an outage of the zone where the control plane runs, workloads still run. However, the cluster, its nodes, and its workloads cannot be configured until the control plane is available. Multi-zonal clusters balance availability and cost for consistent workloads. If you want to maintain availability and the number of your nodes and node pools are changing frequently, consider using a regional cluster.

Regional clusters
-----------------

A regional cluster has multiple replicas of the control plane, running in multiple zones within a given region. Nodes also run in each zone where a replica of the control plane runs. Because a regional cluster replicates the control plane and nodes, it consumes more Compute Engine resources than a similar single-zone or multi-zonal cluster.

VPC-native and routes-based clusters
------------------------------------

In Google Kubernetes Engine, clusters can be distinguished according to the way they route traffic from one Pod to another Pod. A cluster that uses Alias IPs is called a VPC-native cluster. A cluster that uses Google Cloud Routes is called a routes-based cluster.

VPC-native is the recommended network mode for new clusters.

Private Clusters
----------------

* https://cloud.google.com/kubernetes-engine/docs/concepts/private-cluster-concept

Nodes
=====

The individual machines are Compute Engine VM instances that GKE creates on your behalf when you create a cluster.

Each node is managed from the master, which receives updates on each node's self-reported status. You can exercise some manual control over node lifecycle, or you can have GKE perform automatic repairs and automatic upgrades on your cluster's nodes.

A node runs the services necessary to support the Docker containers that make up your cluster's workloads. 

* Docker runtime 
* Kubernetes node agent (kubelet) which communicates with the master and is responsible for starting and running Docker containers scheduled on that node.

Sepcial Containers
------------------

In GKE, there are also a number of special containers that run as per-node agents to provide functionality such as log collection and intra-cluster network connectivity.

Node type
---------

Each node is of a standard Compute Engine machine type. The default type is n1-standard-1, with 1 virtual CPU and 3.75 GB of memory. You can select a different machine type when you create a cluster.

Node OS
-------

Each node runs a specialized OS image for running your containers. You can specify which OS image your clusters and node pools use.

* Container-Optimized OS from Google
* Ubuntu
* Container-Optimized OS with containerd (cos_containerd)
* Ubuntu with containerd (ubuntu_containerd)

containerd is an important building block and the core runtime component of Docker.

For debugging or troubleshooting on the node, you can interact with containerd using the portable command-line tool built for Kubernetes container runtimes: crictl. crictl supports common functionalities to view containers and images, read logs, and execute commands in the containers. Refer to the crictl user guide for the complete set of supported features and usage information.

The cos and cos_containerd node images use a minimal root file system with built-in support for the Docker (containerd) container runtime, which also serves as the software package manager for installing software on the host. The Ubuntu image uses the Aptitude package manager.

The Container-Optimized OS image does not provide package management software such as apt-get. You can't install arbitrary software onto the nodes using conventional mechanisms. Instead, create a container image that contains the software you need.

Both the Container-Optimized OS and Ubuntu node image use systemd to manage system resources and services during the system initialization process.

Modifications on the boot disk of a node VM do not persist across node re-creations. Nodes are re-created during manual upgrade, auto-upgrade, auto-repair, and auto-scaling. To preserve modifications across node re-creation, use a DaemonSet.

Some of a node's resources are required to run the GKE and Kubernetes node components necessary to make that node function as part of your cluster. As such, you may notice a disparity between your node's total resources (as specified in the machine type documentation) and the node's allocatable resources in GKE.

To inspect the node allocatable resources available in a cluster, run the following command:

::

    kubectl describe node [NODE_NAME] | grep Allocatable -B 4 -A 3

============================
Container-Optimized OS (cos)
============================

The Container-Optimized OS node image is based on a recent version of the Linux kernel and is optimized to enhance node security. It is backed by a team at Google that can quickly patch it for security and iterate on features. The Container-Optimized OS image provides better support, security, and stability than other images.
Ubuntu

The Ubuntu node image has been validated against GKE's node image requirements. You should use the Ubuntu node image if your nodes require support for XFS, CephFS, or Debian packages.

-------
ToolBox
-------

For debugging purposes only, Container-Optimized OS includes the CoreOS Toolbox for installing and running common debugging tools such as ping, psmisc, or pstree

* https://cloud.google.com/container-optimized-os/docs/how-to/toolbox

Logs

::

    sudo journalctl -u docker
    sudo journalctl -u kubelet

-----------------
FileSystem Layout
-----------------

* **Root partition**, which is mounted as read-only
* **Stateful partitions**, which are writable and stateful
* **Stateless partitions**, which are writable but the contents do not persist across reboots

FileSystem

* **/** - read-only, executable - The root filesystem is mounted as read-only to maintain integrity. The kernel verifies integrity root filesystem during boot up, and refuses to boot in case of errors.
* **/home /var** - writable non-executable stateful - These paths are meant for storing data that persists for the lifetime of the boot disk. They are mounted from /mnt/stateful_partition.
* **/var/lib/google cloud docker kubelet toolbox** - writable executable stateful - These paths are working directories for Compute Engine packages (for example, the accounts manager service), cloud-init, Docker, Kubelet, and Toolbox respectively.
* **/etc** - writable non-executable stateless tmpfs - /etc typically holds your configuration (for example, systemd services defined via cloud-init). It's a good idea to capture the desired state of your instances in cloud-init, as cloud-init is applied when an instance is newly created as well as when an instance is restarted.
* **/tmp** - writable non-executable stateless tmpfs - /tmp is typically used as a scratch space and should not be used to store persistent data.
* **/mnt/disks** - writable executable stateless tmpfs - You can mount Persistent Disks at directories under /mnt/disks.

======
Ubuntu
======

The Ubuntu node image has been validated against GKE's node image requirements. You should use the Ubuntu node image if your nodes require support for XFS, CephFS, or Debian packages

The Ubuntu node image uses the standard Linux file system layout.

=====================================================
containerd on Container-Optimized OS (cos_containerd)
=====================================================

**cos_containerd** is a variant of the Container-Optimized OS image with containerd as the container runtime directly integrated with Kubernetes.

**cos_containerd** requires Kubernetes version 1.14.3 or higher.

========================================
containerd on Ubuntu (ubuntu_containerd)
========================================

**ubuntu_containerd** is a variant of the Ubuntu image that uses containerd as the container runtime.

**ubuntu_containerd** requires Kubernetes version 1.14.3 or higher.

======================
Storage driver support
======================

* https://cloud.google.com/kubernetes-engine/docs/concepts/node-images

* Kubernetes Container Storage Interface - https://kubernetes-csi.github.io/docs/

==========
Node Pools
==========

A node pool is a group of nodes within a cluster that all have the same configuration. Node pools use a NodeConfig specification. Each node in the pool has a Kubernetes node label, cloud.google.com/gke-nodepool, which has the node pool's name as its value. A node pool can contain only a single node or many nodes.

When you create a cluster, the number and type of nodes that you specify becomes the default node pool. Then, you can add additional custom node pools of different sizes and types to your cluster. All nodes in any given node pool are identical to one another.



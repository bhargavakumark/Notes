Kubernetes
++++++++++

.. contents:: 

CheatSheet
==========

* https://kubernetes.io/docs/reference/kubectl/cheatsheet/

CURL Kubernetes API
===================

* https://medium.com/@nieldw/curling-the-kubernetes-api-server-d7675cfc398c

Images
======

Container images are usually given a name such as pause, example/mycontainer, or kube-apiserver. Images can also include a registry hostname; for example: fictional.registry.example/imagename, and possible a port number as well; for example: fictional.registry.example:10443/imagename.

If you don't specify a registry hostname, Kubernetes assumes that you mean the Docker public registry.

After the image name part you can add a tag (as also using with commands such as docker and podman). Tags let you identify different versions of the same series of images.

You should avoid using the latest tag when deploying containers in production, as it is harder to track which version of the image is running and more difficult to roll back to a working version.

Instead, specify a meaningful tag such as v1.42.0

Image Pull
----------

* https://kubernetes.io/docs/concepts/containers/images/
* docker hub: Default location from which images are pulled
    * Dockerfile defines how image is pulled from base image and create. In case of mysql base image is debian based. debian:stretch-slim
    * docker hub mysql : https://hub.docker.com/_/mysql - debian based
    * docker hub postgres : https://hub.docker.com/_/postgres - debian based
    * docker hub ubuntu : https://hub.docker.com/_/ubuntu - from scratch

::

    FROM scratch
    ADD ubuntu-focal-core-cloudimg-amd64-root.tar.gz /   # This is the ubuntu base

Dockerfile from Image
---------------------

You can Image from container using the **docker commit** command. You can then create a Dockerfile from that image using **docker image history** or the tool **dfimage**.

Scratch Image
-------------

* https://hub.docker.com/_/scratch

This image is most useful in the context of building base images (such as debian and busybox) or super minimal images (that contain only a single binary and whatever it requires, such as hello-world).

As of Docker 1.5.0 (specifically, docker/docker#8827), FROM scratch is a no-op in the Dockerfile, and will not create an extra layer in your image (so a previously 2-layer image will be a 1-layer image instead).

From https://docs.docker.com/engine/userguide/eng-image/baseimages/:

* You can use Docker’s reserved, minimal image, scratch, as a starting point for building containers. Using the scratch “image” signals to the build process that you want the next command in the Dockerfile to be the first filesystem layer in your image.

* While scratch appears in Docker’s repository on the hub, you can’t pull it, run it, or tag any image with the name scratch. Instead, you can refer to it in your Dockerfile. For example, to create a minimal container using scratch

Docker Entrypoint
-----------------

* Entry point in docker : /usr/local/bin/docker-entrypoint.sh 

* MySQL
    * Initializes mysql database if nothing exists in /var/lib/mysql

Components
==========

Control Plane Components
------------------------

The control plane's components make global decisions about the cluster (for example, scheduling), as well as detecting and responding to cluster events (for example, starting up a new pod when a deployment's replicas field is unsatisfied).

Control plane components can be run on any machine in the cluster. However, for simplicity, set up scripts typically start all control plane components on the same machine, and do not run user containers on this machine.

.. image:: images/components-of-kubernetes.png

==============
kube-apiserver
==============

The API server is a component of the Kubernetes control plane that exposes the Kubernetes API. The API server is the front end for the Kubernetes control plane.

The main implementation of a Kubernetes API server is kube-apiserver. kube-apiserver is designed to scale horizontally—that is, it scales by deploying more instances. You can run several instances of kube-apiserver and balance traffic between those instances.

====
etcd
====

Consistent and highly-available key value store used as Kubernetes' backing store for all cluster data.

If your Kubernetes cluster uses etcd as its backing store, make sure you have a back up plan for those data.

You can find in-depth information about etcd in the official documentation.

==============
kube-scheduler
==============

Control plane component that watches for newly created Pods with no assigned node , and selects a node for them to run on.

Factors taken into account for scheduling decisions include: individual and collective resource requirements, hardware/software/policy constraints, affinity and anti-affinity specifications, data locality, inter-workload interference, and deadlines.

=======================
kube-controller-manager
=======================

Control Plane component that runs controller processes.

Logically, each controller is a separate process, but to reduce complexity, they are all compiled into a single binary and run in a single process.

These controllers include:

* Node controller: Responsible for noticing and responding when nodes go down.
* Replication controller: Responsible for maintaining the correct number of pods for every replication controller object in the system.
* Endpoints controller: Populates the Endpoints object (that is, joins Services & Pods).
* Service Account & Token controllers: Create default accounts and API access tokens for new namespaces.

========================
cloud-controller-manager
========================

A Kubernetes control plane component that embeds cloud-specific control logic. The cloud controller manager lets you link your cluster into your cloud provider's API, and separates out the components that interact with that cloud platform from components that just interact with your cluster.

The cloud-controller-manager only runs controllers that are specific to your cloud provider. If you are running Kubernetes on your own premises, or in a learning environment inside your own PC, the cluster does not have a cloud controller manager.

As with the kube-controller-manager, the cloud-controller-manager combines several logically independent control loops into a single binary that you run as a single process. You can scale horizontally (run more than one copy) to improve performance or to help tolerate failures.

The following controllers can have cloud provider dependencies:

* Node controller: For checking the cloud provider to determine if a node has been deleted in the cloud after it stops responding
* Route controller: For setting up routes in the underlying cloud infrastructure
* Service controller: For creating, updating and deleting cloud provider load balancers

The cloud controller manager runs in the control plane as a replicated set of processes (usually, these are containers in Pods). Each cloud-controller-manager implements multiple controllers in a single process.

---------------
Node controller
---------------

The node controller is responsible for creating Node objects when new servers are created in your cloud infrastructure. The node controller obtains information about the hosts running inside your tenancy with the cloud provider. The node controller performs the following functions:

* Initialize a Node object for each server that the controller discovers through the cloud provider API.
* Annotating and labelling the Node object with cloud-specific information, such as the region the node is deployed into and the resources (CPU, memory, etc) that it has available.
* Obtain the node's hostname and network addresses.
* Verifying the node's health. In case a node becomes unresponsive, this controller checks with your cloud provider's API to see if the server has been deactivated / deleted / terminated. If the node has been deleted from the cloud, the controller deletes the Node object from your Kubernetes cluster.

Some cloud provider implementations split this into a node controller and a separate node lifecycle controller.

----------------
Route controller
----------------

The route controller is responsible for configuring routes in the cloud appropriately so that containers on different nodes in your Kubernetes cluster can communicate with each other.

Depending on the cloud provider, the route controller might also allocate blocks of IP addresses for the Pod network.

------------------
Service controller 
------------------

Services integrate with cloud infrastructure components such as managed load balancers, IP addresses, network packet filtering, and target health checking. The service controller interacts with your cloud provider's APIs to set up load balancers and other infrastructure components when you declare a Service resource that requires them.

===============
Node controller
===============

The node controller is a Kubernetes control plane component that manages various aspects of nodes.

The node controller has multiple roles in a node's life. The first is assigning a CIDR block to the node when it is registered (if CIDR assignment is turned on).

The second is keeping the node controller's internal list of nodes up to date with the cloud provider's list of available machines. When running in a cloud environment, whenever a node is unhealthy, the node controller asks the cloud provider if the VM for that node is still available. If not, the node controller deletes the node from its list of nodes.

The third is monitoring the nodes' health. The node controller is responsible for updating the NodeReady condition of NodeStatus to ConditionUnknown when a node becomes unreachable (i.e. the node controller stops receiving heartbeats for some reason, for example due to the node being down), and then later evicting all the pods from the node (using graceful termination) if the node continues to be unreachable. (The default timeouts are 40s to start reporting ConditionUnknown and 5m after that to start evicting pods.) The node controller checks the state of each node every --node-monitor-period seconds

Node Components
---------------

Node components run on every node, maintaining running pods and providing the Kubernetes runtime environment.

=======
kubelet
=======

An agent that runs on each node in the cluster. It makes sure that containers are running in a Pod .

The kubelet takes a set of PodSpecs that are provided through various mechanisms and ensures that the containers described in those PodSpecs are running and healthy. The kubelet doesn’t manage containers which were not created by Kubernetes.

The kubelet is responsible for creating and updating the NodeStatus and a Lease object.

* The kubelet updates the NodeStatus either when there is change in status, or if there has been no update for a configured interval. The default interval for NodeStatus updates is 5 minutes (much longer than the 40 second default timeout for unreachable nodes).
* The kubelet creates and then updates its Lease object every 10 seconds (the default update interval). Lease updates occur independently from the NodeStatus updates. If the Lease update fails, the kubelet retries with exponential backoff starting at 200 milliseconds and capped at 7 seconds.

==========
kube-proxy
==========

kube-proxy is a network proxy that runs on each node in your cluster, implementing part of the Kubernetes Service concept.

kube-proxy maintains network rules on nodes. These network rules allow network communication to your Pods from network sessions inside or outside of your cluster.

kube-proxy uses the operating system packet filtering layer if there is one and it's available. Otherwise, kube-proxy forwards the traffic itself.
Container runtime

The container runtime is the software that is responsible for running containers.

Kubernetes supports several container runtimes: Docker , containerd , CRI-O , and any implementation of the Kubernetes CRI (Container Runtime Interface).

Addons
------

Addons use Kubernetes resources (DaemonSet , Deployment , etc) to implement cluster features. Because these are providing cluster-level features, namespaced resources for addons belong within the kube-system namespace.

Selected addons are described below; for an extended list of available addons, please see Addons.

===
DNS
===

While the other addons are not strictly required, all Kubernetes clusters should have cluster DNS, as many examples rely on it.

Cluster DNS is a DNS server, in addition to the other DNS server(s) in your environment, which serves DNS records for Kubernetes services.

Containers started by Kubernetes automatically include this DNS server in their DNS searches.

==================
Web UI (Dashboard)
==================

Dashboard is a general purpose, web-based UI for Kubernetes clusters. It allows users to manage and troubleshoot applications running in the cluster, as well as the cluster itself.
Container Resource Monitoring

Container Resource Monitoring records generic time-series metrics about containers in a central database, and provides a UI for browsing that data.
Cluster-level Logging

A cluster-level logging mechanism is responsible for saving container logs to a central log store with search/browsing interface.

Node to Control Plane
---------------------

Kubernetes has a "hub-and-spoke" API pattern. All API usage from nodes (or the pods they run) terminate at the apiserver (none of the other control plane components are designed to expose remote services). The apiserver is configured to listen for remote connections on a secure HTTPS port (typically 443) with one or more forms of client authentication enabled. One or more forms of authorization should be enabled, especially if anonymous requests or service account tokens are allowed.

Nodes should be provisioned with the public root certificate for the cluster such that they can connect securely to the apiserver along with valid client credentials. For example, on a default GKE deployment, the client credentials provided to the kubelet are in the form of a client certificate. See kubelet TLS bootstrapping for automated provisioning of kubelet client certificates.

Pods that wish to connect to the apiserver can do so securely by leveraging a service account so that Kubernetes will automatically inject the public root certificate and a valid bearer token into the pod when it is instantiated.

The kubernetes service (in all namespaces) is configured with a virtual IP address that is redirected (via kube-proxy) to the HTTPS endpoint on the apiserver.

Control Plane to node
---------------------

There are two primary communication paths from the control plane (apiserver) to the nodes. The first is from the apiserver to the kubelet process which runs on each node in the cluster. The second is from the apiserver to any node, pod, or service through the apiserver's proxy functionality.

====================
apiserver to kubelet
====================

The connections from the apiserver to the kubelet are used for:

* Fetching logs for pods.
* Attaching (through kubectl) to running pods.
* Providing the kubelet's port-forwarding functionality.

These connections terminate at the kubelet's HTTPS endpoint. By default, the apiserver does not verify the kubelet's serving certificate, which makes the connection subject to man-in-the-middle attacks, and unsafe to run over untrusted and/or public networks.

To verify this connection, use the --kubelet-certificate-authority flag to provide the apiserver with a root certificate bundle to use to verify the kubelet's serving certificate.

======================================
apiserver to nodes, pods, and services
======================================

The connections from the apiserver to a node, pod, or service default to plain HTTP connections and are therefore neither authenticated nor encrypted. They can be run over a secure HTTPS connection by prefixing https: to the node, pod, or service name in the API URL, but they will not validate the certificate provided by the HTTPS endpoint nor provide client credentials so while the connection will be encrypted, it will not provide any guarantees of integrity. These connections are not currently safe to run over untrusted and/or public networks.

===========
SSH tunnels
===========

Kubernetes supports SSH tunnels to protect the control plane to nodes communication paths. In this configuration, the apiserver initiates an SSH tunnel to each node in the cluster (connecting to the ssh server listening on port 22) and passes all traffic destined for a kubelet, node, pod, or service through the tunnel. This tunnel ensures that the traffic is not exposed outside of the network in which the nodes are running.

SSH tunnels are currently deprecated so you shouldn't opt to use them unless you know what you are doing. The Konnectivity service is a replacement for this communication channel.

====================
Konnectivity service
====================

FEATURE STATE: Kubernetes v1.18 [beta]

As a replacement to the SSH tunnels, the Konnectivity service provides TCP level proxy for the control plane to cluster communication. The Konnectivity service consists of two parts: the Konnectivity server and the Konnectivity agents, running in the control plane network and the nodes network respectively. The Konnectivity agents initiate connections to the Konnectivity server and maintain the network connections. After enabling the Konnectivity service, all control plane to nodes traffic goes through these connections.


GKE
===

Clusters
--------

In Google Kubernetes Engine (GKE), a cluster consists of at least one cluster master and multiple worker machines called nodes. These master and node machines run the Kubernetes cluster orchestration system.

The cluster master runs the Kubernetes control plane processes, including the Kubernetes API server, scheduler, and core resource controllers. You can make Kubernetes API calls directly via HTTP/gRPC, or indirectly, by running commands from the Kubernetes command-line client (kubectl) or interacting with the UI in the Cloud Console.

The cluster master's API server process is the hub for all communication for the cluster. All internal cluster processes (such as the cluster nodes, system and components, application controllers) all act as clients of the API server; the API server is the single "source of truth" for the entire cluster.

When you create or update a cluster, container images for the Kubernetes software running on the masters (and nodes) are pulled from the **gcr.io** container registry.

====================
Single-zone clusters
====================

A single-zone cluster has a single control plane (master) running in one zone. This control plane manages workloads on nodes running in the same zone.

====================
Multi-zonal clusters
====================

A multi-zonal cluster has a single replica of the control plane running in a single zone, and has nodes running in multiple zones. During an upgrade of the cluster or an outage of the zone where the control plane runs, workloads still run. However, the cluster, its nodes, and its workloads cannot be configured until the control plane is available. Multi-zonal clusters balance availability and cost for consistent workloads. If you want to maintain availability and the number of your nodes and node pools are changing frequently, consider using a regional cluster.

=================
Regional clusters
=================

A regional cluster has multiple replicas of the control plane, running in multiple zones within a given region. Nodes also run in each zone where a replica of the control plane runs. Because a regional cluster replicates the control plane and nodes, it consumes more Compute Engine resources than a similar single-zone or multi-zonal cluster.

====================================
VPC-native and routes-based clusters
====================================

In Google Kubernetes Engine, clusters can be distinguished according to the way they route traffic from one Pod to another Pod. A cluster that uses Alias IPs is called a VPC-native cluster. A cluster that uses Google Cloud Routes is called a routes-based cluster.

VPC-native is the recommended network mode for new clusters.

================
Private Clusters
================

* https://cloud.google.com/kubernetes-engine/docs/concepts/private-cluster-concept

Nodes
-----

The individual machines are Compute Engine VM instances that GKE creates on your behalf when you create a cluster.

Each node is managed from the master, which receives updates on each node's self-reported status. You can exercise some manual control over node lifecycle, or you can have GKE perform automatic repairs and automatic upgrades on your cluster's nodes.

A node runs the services necessary to support the Docker containers that make up your cluster's workloads. 

* Docker runtime 
* Kubernetes node agent (kubelet) which communicates with the master and is responsible for starting and running Docker containers scheduled on that node.

==================
Sepcial Containers
==================

In GKE, there are also a number of special containers that run as per-node agents to provide functionality such as log collection and intra-cluster network connectivity.

=========
Node type
=========

Each node is of a standard Compute Engine machine type. The default type is n1-standard-1, with 1 virtual CPU and 3.75 GB of memory. You can select a different machine type when you create a cluster.

=======
Node OS
=======

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

----------------------------
Container-Optimized OS (cos)
----------------------------

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

------
Ubuntu
------

The Ubuntu node image has been validated against GKE's node image requirements. You should use the Ubuntu node image if your nodes require support for XFS, CephFS, or Debian packages

The Ubuntu node image uses the standard Linux file system layout.

-----------------------------------------------------
containerd on Container-Optimized OS (cos_containerd)
-----------------------------------------------------

**cos_containerd** is a variant of the Container-Optimized OS image with containerd as the container runtime directly integrated with Kubernetes.

**cos_containerd** requires Kubernetes version 1.14.3 or higher.

----------------------------------------
containerd on Ubuntu (ubuntu_containerd)
----------------------------------------

**ubuntu_containerd** is a variant of the Ubuntu image that uses containerd as the container runtime.

**ubuntu_containerd** requires Kubernetes version 1.14.3 or higher.

----------------------
Storage driver support
----------------------

* https://cloud.google.com/kubernetes-engine/docs/concepts/node-images

* Kubernetes Container Storage Interface - https://kubernetes-csi.github.io/docs/

----------
Node Pools
----------

A node pool is a group of nodes within a cluster that all have the same configuration. Node pools use a NodeConfig specification. Each node in the pool has a Kubernetes node label, cloud.google.com/gke-nodepool, which has the node pool's name as its value. A node pool can contain only a single node or many nodes.

When you create a cluster, the number and type of nodes that you specify becomes the default node pool. Then, you can add additional custom node pools of different sizes and types to your cluster. All nodes in any given node pool are identical to one another.

Using a Private Registry
========================

Private registries may require keys to read images from them.
Credentials can be provided in several ways:

* Configuring Nodes to Authenticate to a Private Registry
    * all pods can read any configured private registries
    * requires node configuration by cluster administrator
* Pre-pulled Images
    * all pods can use any images cached on a node
    * requires root access to all nodes to setup
* Specifying ImagePullSecrets on a Pod
    * only pods which provide own keys can access the private registry
* Vendor-specific or local extensions
    * if you're using a custom node configuration, you (or your cloud provider) can implement your mechanism for authenticating the node to the container registry.

Container environment
=====================

The Kubernetes Container environment provides several important resources to Containers:

* A filesystem, which is a combination of an image and one or more volumes.
* Information about the Container itself.
* Information about other objects in the cluster.

Container information
---------------------

The hostname of a Container is the name of the Pod in which the Container is running. It is available through the hostname command or the gethostname function call in libc.

The Pod name and namespace are available as environment variables through the downward API.

* https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/

User defined environment variables from the Pod definition are also available to the Container, as are any environment variables specified statically in the Docker image.

Cluster information 
-------------------

A list of all services that were running when a Container was created is available to that Container as environment variables. Those environment variables match the syntax of Docker links.

For a service named foo that maps to a Container named bar, the following variables are defined:

::

    FOO_SERVICE_HOST=<the host the service is running on>
    FOO_SERVICE_PORT=<the port the service is running on>

Services have dedicated IP addresses and are available to the Container via DNS, if DNS addon is enabled. 

Container Lifecycle Hooks
=========================

There are two hooks that are exposed to Containers:

* PostStart

This hook executes immediately after a container is created. However, there is no guarantee that the hook will execute before the container ENTRYPOINT. No parameters are passed to the handler.

* PreStop

This hook is called immediately before a container is terminated due to an API request or management event such as liveness probe failure, preemption, resource contention and others. A call to the preStop hook fails if the container is already in terminated or completed state. It is blocking, meaning it is synchronous, so it must complete before the call to delete the container can be sent. No parameters are passed to the handler.

Hook handler execution
----------------------

When a Container lifecycle management hook is called, the Kubernetes management system executes the handler in the Container registered for that hook. 

Hook handler calls are synchronous within the context of the Pod containing the Container. This means that for a PostStart hook, the Container ENTRYPOINT and hook fire asynchronously. However, if the hook takes too long to run or hangs, the Container cannot reach a running state.

The behavior is similar for a PreStop hook. If the hook hangs during execution, the Pod phase stays in a Terminating state and is killed after terminationGracePeriodSeconds of pod ends. If a PostStart or PreStop hook fails, it kills the Container.

Users should make their hook handlers as lightweight as possible. There are cases, however, when long running commands make sense, such as when saving state prior to stopping a Container.

Hook delivery is intended to be at least once, which means that a hook may be called multiple times for any given event, such as for PostStart or PreStop. It is up to the hook implementation to handle this correctly.

Working with Pods
=================

You'll rarely create individual Pods directly in Kubernetes--even singleton Pods. This is because Pods are designed as relatively ephemeral, disposable entities. When a Pod gets created (directly by you, or indirectly by a _controller_ ), it is scheduled to run on a Node in your cluster. The Pod remains on that node until the process is terminated, the pod object is deleted, the Pod is evicted for lack of resources, or the node fails.

Note: Restarting a container in a Pod should not be confused with restarting a Pod. A Pod is not a process, but an environment for running a container. A Pod persists until it is deleted.

Pods do not, by themselves, self-heal. If a Pod is scheduled to a Node that fails, or if the scheduling operation itself fails, the Pod is deleted; likewise, a Pod won't survive an eviction due to a lack of resources or Node maintenance. Kubernetes uses a higher-level abstraction, called a controller, that handles the work of managing the relatively disposable Pod instances. Thus, while it is possible to use Pod directly, it's far more common in Kubernetes to manage your pods using a controller.

The shared context of a Pod is a set of Linux namespaces, cgroups, and potentially other facets of isolation - the same things that isolate a Docker container.

Pods and controllers
--------------------

You can use workload resources to create and manage multiple Pods for you. A controller for the resource handles replication and rollout and automatic healing in case of Pod failure. For example, if a Node fails, a controller notices that Pods on that Node have stopped working and creates a replacement Pod. The scheduler places the replacement Pod onto a healthy Node.

Here are some examples of workload resources that manage one or more Pods:

* Deployment
* StatefulSet
* DaemonSet

Ephemeral Containers
====================

FEATURE STATE: Kubernetes v1.16 [alpha]

This page provides an overview of ephemeral containers: a special type of container that runs temporarily in an existing Pod to accomplish user-initiated actions such as troubleshooting. You use ephemeral containers to inspect services rather than to build applications.

::

    Warning: Ephemeral containers are in early alpha state and are not suitable for production clusters. In accordance with the Kubernetes Deprecation Policy, this alpha feature could change significantly in the future or be removed entirely.


Since Pods are intended to be disposable and replaceable, you cannot add a container to a Pod once it has been created. Instead, you usually delete and replace Pods in a controlled fashion using deployments .

Sometimes it's necessary to inspect the state of an existing Pod, however, for example to troubleshoot a hard-to-reproduce bug. In these cases you can run an ephemeral container in an existing Pod to inspect its state and run arbitrary commands.

Ephemeral containers are useful for interactive troubleshooting when kubectl exec is insufficient because a container has crashed or a container image doesn't include debugging utilities.

In particular, distroless images enable you to deploy minimal container images that reduce attack surface and exposure to bugs and vulnerabilities. Since distroless images do not include a shell or any debugging utilities, it's difficult to troubleshoot distroless images using kubectl exec alone.

When using ephemeral containers, it's helpful to enable process namespace sharing so you can view processes in other containers.

See Debugging with Ephemeral Debug Container for examples of troubleshooting using ephemeral containers.

ReplicaSet
==========

A ReplicaSet's purpose is to maintain a stable set of replica Pods running at any given time. As such, it is often used to guarantee the availability of a specified number of identical Pods.

A ReplicaSet is defined with fields, including a selector that specifies how to identify Pods it can acquire, a number of replicas indicating how many Pods it should be maintaining, and a pod template specifying the data of new Pods it should create to meet the number of replicas criteria. A ReplicaSet then fulfills its purpose by creating and deleting Pods as needed to reach the desired number. When a ReplicaSet needs to create new Pods, it uses its Pod template.

A ReplicaSet is linked to its Pods via the Pods' metadata.ownerReferences field, which specifies what resource the current object is owned by. All Pods acquired by a ReplicaSet have their owning ReplicaSet's identifying information within their ownerReferences field. It's through this link that the ReplicaSet knows of the state of the Pods it is maintaining and plans accordingly.

A ReplicaSet identifies new Pods to acquire by using its selector. If there is a Pod that has no OwnerReference or the OwnerReference is not a Controller and it matches a ReplicaSet's selector, it will be immediately acquired by said ReplicaSet.

When to use a ReplicaSet
------------------------

A ReplicaSet ensures that a specified number of pod replicas are running at any given time. However, a Deployment is a higher-level concept that manages ReplicaSets and provides declarative updates to Pods along with a lot of other useful features. Therefore, we recommend using Deployments instead of directly using ReplicaSets, unless you require custom update orchestration or don't require updates at all.

This actually means that you may never need to manipulate ReplicaSet objects: use a Deployment instead, and define your application in the spec section.

::

    apiVersion: apps/v1
    kind: ReplicaSet
    metadata:
      name: frontend
      labels:
        app: guestbook
        tier: frontend
    spec:
      # modify replicas according to your case
      replicas: 3
      selector:
        matchLabels:
          tier: frontend
      template:
        metadata:
          labels:
            tier: frontend
        spec:
          containers:
          - name: php-redis
            image: gcr.io/google_samples/gb-frontend:v3



While you can create bare Pods with no problems, it is strongly recommended to make sure that the bare Pods do not have labels which match the selector of one of your ReplicaSets. The reason for this is because a ReplicaSet is not limited to owning Pods specified by its template-- it can acquire other Pods in the manner specified in the previous sections.

The name of a ReplicaSet object must be a valid DNS subdomain name.

A ReplicaSet also needs a .spec section.

You can delete a ReplicaSet without affecting any of its Pods using kubectl delete with the --cascade=false option.

Once the original is deleted, you can create a new ReplicaSet to replace it. As long as the old and new .spec.selector are the same, then the new one will adopt the old Pods. However, it will not make any effort to make existing Pods match a new, different pod template. To update Pods to a new spec in a controlled way, use a Deployment, as ReplicaSets do not support a rolling update directly.

Isolating Pods from a ReplicaSet
--------------------------------

You can remove Pods from a ReplicaSet by changing their labels. This technique may be used to remove Pods from service for debugging, data recovery, etc. Pods that are removed in this way will be replaced automatically ( assuming that the number of replicas is not also changed).
Scaling a ReplicaSet 

ReplicationController
=====================

::

    Note: A Deployment that configures a ReplicaSet is now the recommended way to set up replication.

A ReplicationController ensures that a specified number of pod replicas are running at any one time. In other words, a ReplicationController makes sure that a pod or a homogeneous set of pods is always up and available.

Deployments
===========

A Deployment provides declarative updates for Pods and ReplicaSets.

You describe a desired state in a Deployment, and the Deployment Controller changes the actual state to the desired state at a controlled rate. You can define Deployments to create new ReplicaSets, or to remove existing Deployments and adopt all their resources with new Deployments.

* Create a Deployment to rollout a ReplicaSet. The ReplicaSet creates Pods in the background. Check the status of the rollout to see if it succeeds or not.
* Declare the new state of the Pods by updating the PodTemplateSpec of the Deployment. A new ReplicaSet is created and the Deployment manages moving the Pods from the old ReplicaSet to the new one at a controlled rate. Each new ReplicaSet updates the revision of the Deployment.
* Rollback to an earlier Deployment revision if the current state of the Deployment is not stable. Each rollback updates the revision of the Deployment.
* Scale up the Deployment to facilitate more load.
* Pause the Deployment to apply multiple fixes to its PodTemplateSpec and then resume it to start a new rollout.
* Use the status of the Deployment as an indicator that a rollout has stuck.
* Clean up older ReplicaSets that you don't need anymore.

::

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deployment
      labels:
        app: nginx
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:1.14.2
            ports:
            - containerPort: 80


Updating a Deployment
---------------------

::

    Note: A Deployment's rollout is triggered if and only if the Deployment's Pod template (that is, .spec.template) is changed, for example if the labels or container images of the template are updated. Other updates, such as scaling the Deployment, do not trigger a rollout.

update the nginx Pods to use the nginx:1.16.1 image instead of the nginx:1.14.2 image.

::

    kubectl --record deployment.apps/nginx-deployment set image deployment.v1.apps/nginx-deployment nginx=nginx:1.16.1
    or
    kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1 --record
    or
    kubectl edit deployment.v1.apps/nginx-deployment

    # To see rollout status
    kubectl rollout status deployment.v1.apps/nginx-deployment

    # to scale a deployment
    kubectl scale deployment.v1.apps/nginx-deployment --replicas=10

    # Auto scaling based on cpu
    kubectl autoscale deployment.v1.apps/nginx-deployment --min=10 --max=15 --cpu-percent=80

Each time a new Deployment is observed by the Deployment controller, a ReplicaSet is created to bring up the desired Pods. If the Deployment is updated, the existing ReplicaSet that controls Pods whose labels match .spec.selector but whose template does not match .spec.template are scaled down. Eventually, the new ReplicaSet is scaled to .spec.replicas and all old ReplicaSets is scaled to 0.

If you update a Deployment while an existing rollout is in progress, the Deployment creates a new ReplicaSet as per the update and start scaling that up, and rolls over the ReplicaSet that it was scaling up previously -- it will add it to its list of old ReplicaSets and start scaling it down.

Deployment status 
-----------------

A Deployment enters various states during its lifecycle. It can be progressing while rolling out a new ReplicaSet, it can be complete, or it can fail to progress.
Progressing Deployment

Kubernetes marks a Deployment as progressing when one of the following tasks is performed:

* The Deployment creates a new ReplicaSet.
* The Deployment is scaling up its newest ReplicaSet.
* The Deployment is scaling down its older ReplicaSet(s).
* New Pods become ready or available (ready for at least MinReadySeconds).

You can monitor the progress for a Deployment by using kubectl rollout status.

StatefulSets
============

StatefulSet is the workload API object used to manage stateful applications.

Manages the deployment and scaling of a set of Pods , and provides guarantees about the ordering and uniqueness of these Pods.

Like a Deployment , a StatefulSet manages Pods that are based on an identical container spec. Unlike a Deployment, a StatefulSet maintains a sticky identity for each of their Pods. These pods are created from the same spec, but are not interchangeable: each has a persistent identifier that it maintains across any rescheduling.

If you want to use storage volumes to provide persistence for your workload, you can use a StatefulSet as part of the solution. Although individual Pods in a StatefulSet are susceptible to failure, the persistent Pod identifiers make it easier to match existing volumes to the new Pods that replace any that have failed.

Using StatefulSets
------------------

StatefulSets are valuable for applications that require one or more of the following.

* Stable, unique network identifiers.
* Stable, persistent storage.
* Ordered, graceful deployment and scaling.
* Ordered, automated rolling updates.

In the above, stable is synonymous with persistence across Pod (re)scheduling. If an application doesn't require any stable identifiers or ordered deployment,

Limitations
-----------

* The storage for a given Pod must either be provisioned by a PersistentVolume Provisioner based on the requested storage class, or pre-provisioned by an admin.
* Deleting and/or scaling a StatefulSet down will not delete the volumes associated with the StatefulSet. This is done to ensure data safety, which is generally more valuable than an automatic purge of all related StatefulSet resources.
* StatefulSets currently require a Headless Service to be responsible for the network identity of the Pods. You are responsible for creating this Service.
* StatefulSets do not provide any guarantees on the termination of pods when a StatefulSet is deleted. To achieve ordered and graceful termination of the pods in the StatefulSet, it is possible to scale the StatefulSet down to 0 prior to deletion.
* When using Rolling Updates with the default Pod Management Policy (OrderedReady), it's possible to get into a broken state that requires manual intervention to repair.

Components 
----------

::

    apiVersion: v1
    kind: Service
    metadata:
      name: nginx
      labels:
        app: nginx
    spec:
      ports:
      - port: 80
        name: web
      clusterIP: None
      selector:
        app: nginx
    ---
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: web
    spec:
      selector:
        matchLabels:
          app: nginx # has to match .spec.template.metadata.labels
      serviceName: "nginx"
      replicas: 3 # by default is 1
      template:
        metadata:
          labels:
            app: nginx # has to match .spec.selector.matchLabels
        spec:
          terminationGracePeriodSeconds: 10
          containers:
          - name: nginx
            image: k8s.gcr.io/nginx-slim:0.8
            ports:
            - containerPort: 80
              name: web
            volumeMounts:
            - name: www
              mountPath: /usr/share/nginx/html
      volumeClaimTemplates:
      - metadata:
          name: www
        spec:
          accessModes: [ "ReadWriteOnce" ]
          storageClassName: "my-storage-class"
          resources:
            requests:
              storage: 1Gi

* A Headless Service, named nginx, is used to control the network domain.
* The StatefulSet, named web, has a Spec that indicates that 3 replicas of the nginx container will be launched in unique Pods.
* The volumeClaimTemplates will provide stable storage using PersistentVolumes provisioned by a PersistentVolume Provisioner.

The name of a StatefulSet object must be a valid DNS subdomain name.

Pod Identity
------------

StatefulSet Pods have a unique identity that is comprised of an ordinal, a stable network identity, and stable storage. The identity sticks to the Pod, regardless of which node it's (re)scheduled on.

=============
Ordinal Index
=============

For a StatefulSet with N replicas, each Pod in the StatefulSet will be assigned an integer ordinal, from 0 up through N-1, that is unique over the Set.

=================
Stable Network ID
=================

Each Pod in a StatefulSet derives its hostname from the name of the StatefulSet and the ordinal of the Pod. The pattern for the constructed hostname is $(statefulset name)-$(ordinal). The example above will create three Pods named web-0,web-1,web-2. A StatefulSet can use a Headless Service to control the domain of its Pods. The domain managed by this Service takes the form: $(service name).$(namespace).svc.cluster.local, where "cluster.local" is the cluster domain. As each Pod is created, it gets a matching DNS subdomain, taking the form: $(podname).$(governing service domain), where the governing service is defined by the serviceName field on the StatefulSet.

==============
Stable Storage
==============

Kubernetes creates one PersistentVolume for each VolumeClaimTemplate. In the nginx example above, each Pod will receive a single PersistentVolume with a StorageClass of my-storage-class and 1 Gib of provisioned storage. If no StorageClass is specified, then the default StorageClass will be used. When a Pod is (re)scheduled onto a node, its volumeMounts mount the PersistentVolumes associated with its PersistentVolume Claims. Note that, the PersistentVolumes associated with the Pods' PersistentVolume Claims are not deleted when the Pods, or StatefulSet are deleted. This must be done manually.

==============
Pod Name Label
==============

When the StatefulSet Controller creates a Pod, it adds a label, statefulset.kubernetes.io/pod-name, that is set to the name of the Pod. This label allows you to attach a Service to a specific Pod in the StatefulSet.

DaemonSet
=========

A DaemonSet ensures that all (or some) Nodes run a copy of a Pod. As nodes are added to the cluster, Pods are added to them. As nodes are removed from the cluster, those Pods are garbage collected. Deleting a DaemonSet will clean up the Pods it created.

Some typical uses of a DaemonSet are:

* running a cluster storage daemon on every node
* running a logs collection daemon on every node
* running a node monitoring daemon on every node

::

    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: fluentd-elasticsearch
      namespace: kube-system
      labels:
        k8s-app: fluentd-logging
    spec:
      selector:
        matchLabels:
          name: fluentd-elasticsearch
      template:
        metadata:
          labels:
            name: fluentd-elasticsearch
        spec:
          tolerations:
          # this toleration is to have the daemonset runnable on master nodes
          # remove it if your masters can't run pods
          - key: node-role.kubernetes.io/master
            effect: NoSchedule
          containers:
          - name: fluentd-elasticsearch
            image: quay.io/fluentd_elasticsearch/fluentd:v2.5.2
            resources:
              limits:
                memory: 200Mi
              requests:
                cpu: 100m
                memory: 200Mi
            volumeMounts:
            - name: varlog
              mountPath: /var/log
            - name: varlibdockercontainers
              mountPath: /var/lib/docker/containers
              readOnly: true
          terminationGracePeriodSeconds: 30
          volumes:
          - name: varlog
            hostPath:
              path: /var/log
          - name: varlibdockercontainers
            hostPath:
              path: /var/lib/docker/containers

If you specify a .spec.template.spec.nodeSelector, then the DaemonSet controller will create Pods on nodes which match that node selector. Likewise if you specify a .spec.template.spec.affinity, then DaemonSet controller will create Pods on nodes which match that node affinity. If you do not specify either, then the DaemonSet controller will create Pods on all nodes.

Jobs
====

A Job creates one or more Pods and ensures that a specified number of them successfully terminate. As pods successfully complete, the Job tracks the successful completions. When a specified number of successful completions is reached, the task (ie, Job) is complete. Deleting a Job will clean up the Pods it created.

A simple case is to create one Job object in order to reliably run one Pod to completion. The Job object will start a new Pod if the first Pod fails or is deleted (for example due to a node hardware failure or a node reboot).

You can also use a Job to run multiple Pods in parallel.

::

    apiVersion: batch/v1
    kind: Job
    metadata:
      name: pi
    spec:
      template:
        spec:
          containers:
          - name: pi
            image: perl
            command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
          restartPolicy: Never
      backoffLimit: 4

There are three main types of task suitable to run as a Job:

* Non-parallel Jobs
    * normally, only one Pod is started, unless the Pod fails.
    * the Job is complete as soon as its Pod terminates successfully.
* Parallel Jobs with a fixed completion count:
    * specify a non-zero positive value for .spec.completions.
    * the Job represents the overall task, and is complete when there is one successful Pod for each value in the range 1 to .spec.completions.
    * not implemented yet: Each Pod is passed a different index in the range 1 to .spec.completions.
* Parallel Jobs with a work queue:
    * do not specify .spec.completions, default to .spec.parallelism.
    * the Pods must coordinate amongst themselves or an external service to determine what each should work on. For example, a Pod might fetch a batch of up to N items from the work queue.
    * each Pod is independently capable of determining whether or not all its peers are done, and thus that the entire Job is done.
    * when any Pod from the Job terminates with success, no new Pods are created.
    * once at least one Pod has terminated with success and all Pods are terminated, then the Job is completed with success.
    * once any Pod has exited with success, no other Pod should still be doing any work for this task or writing any output. They should all be in the process of exiting.

For a non-parallel Job, you can leave both .spec.completions and .spec.parallelism unset. When both are unset, both are defaulted to 1.

For a fixed completion count Job, you should set .spec.completions to the number of completions needed. You can set .spec.parallelism, or leave it unset and it will default to 1.

For a work queue Job, you must leave .spec.completions unset, and set .spec.parallelism to a non-negative integer.

Job termination and cleanup
---------------------------

When a Job completes, no more Pods are created, but the Pods are not deleted either. Keeping them around allows you to still view the logs of completed pods to check for errors, warnings, or other diagnostic output. The job object also remains after it is completed so that you can view its status. It is up to the user to delete old jobs after noting their status. Delete the job with kubectl (e.g. kubectl delete jobs/pi or kubectl delete -f ./job.yaml). When you delete the job using kubectl, all the pods it created are deleted too.

Clean up finished jobs automatically
------------------------------------

Finished Jobs are usually no longer needed in the system. Keeping them around in the system will put pressure on the API server. If the Jobs are managed directly by a higher level controller, such as CronJobs, the Jobs can be cleaned up by CronJobs based on the specified capacity-based cleanup policy.

Garbage Collection
==================

The role of the Kubernetes garbage collector is to delete certain objects that once had an owner, but no longer have an owner.

Some Kubernetes objects are owners of other objects. For example, a ReplicaSet is the owner of a set of Pods. The owned objects are called dependents of the owner object. Every dependent object has a metadata.ownerReferences field that points to the owning object.

Sometimes, Kubernetes sets the value of ownerReference automatically. For example, when you create a ReplicaSet, Kubernetes automatically sets the ownerReference field of each Pod in the ReplicaSet. In 1.8, Kubernetes automatically sets the value of ownerReference for objects created or adopted by ReplicationController, ReplicaSet, StatefulSet, DaemonSet, Deployment, Job and CronJob.

When you delete an object, you can specify whether the object's dependents are also deleted automatically. Deleting dependents automatically is called cascading deletion. There are two modes of cascading deletion: background and foreground.

If you delete an object without deleting its dependents automatically, the dependents are said to be orphaned.

To control the cascading deletion policy, set the propagationPolicy field on the deleteOptions argument when deleting an Object. Possible values include "Orphan", "Foreground", or "Background".

::

    kubectl proxy --port=8080
        curl -X DELETE localhost:8080/apis/apps/v1/namespaces/default/replicasets/my-repset \
          -d '{"kind":"DeleteOptions","apiVersion":"v1","propagationPolicy":"Background"}' \
          -H "Content-Type: application/json"

    kubectl proxy --port=8080
        curl -X DELETE localhost:8080/apis/apps/v1/namespaces/default/replicasets/my-repset \
          -d '{"kind":"DeleteOptions","apiVersion":"v1","propagationPolicy":"Foreground"}' \
          -H "Content-Type: application/json"

    kubectl proxy --port=8080
        curl -X DELETE localhost:8080/apis/apps/v1/namespaces/default/replicasets/my-repset \
          -d '{"kind":"DeleteOptions","apiVersion":"v1","propagationPolicy":"Orphan"}' \
          -H "Content-Type: application/json"

Prior to Kubernetes 1.9, the default garbage collection policy for many controller resources was orphan. This included ReplicationController, ReplicaSet, StatefulSet, DaemonSet, and Deployment. For kinds in the extensions/v1beta1, apps/v1beta1, and apps/v1beta2 group versions, unless you specify otherwise, dependent objects are orphaned by default. In Kubernetes 1.9, for all kinds in the apps/v1 group version, dependent objects are deleted by default.

kubectl also supports cascading deletion. To delete dependents automatically using kubectl, set --cascade to true. To orphan dependents, set --cascade to false. The default value for --cascade is true.

::

    kubectl delete replicaset my-repset --cascade=false

Foreground cascading deletion
-----------------------------

In foreground cascading deletion, the root object first enters a "deletion in progress" state. In the "deletion in progress" state, the following things are true:

* The object is still visible via the REST API
* The object's deletionTimestamp is set
* The object's metadata.finalizers contains the value "foregroundDeletion".

Once the "deletion in progress" state is set, the garbage collector deletes the object's dependents. Once the garbage collector has deleted all "blocking" dependents (objects with ownerReference.blockOwnerDeletion=true), it deletes the owner object.

Note that in the "foregroundDeletion", only dependents with ownerReference.blockOwnerDeletion=true block the deletion of the owner object.

If an object's ownerReferences field is set by a controller (such as Deployment or ReplicaSet), blockOwnerDeletion is set automatically and you do not need to manually modify this field.

Background cascading deletion 
-----------------------------

In background cascading deletion, Kubernetes deletes the owner object immediately and the garbage collector then deletes the dependents in the background.

TTL Controller for Finished Resources
=====================================

FEATURE STATE: Kubernetes v1.12 [alpha]

The TTL controller provides a TTL (time to live) mechanism to limit the lifetime of resource objects that have finished execution. TTL controller only handles Jobs for now, and may be expanded to handle other resources that will finish execution, such as Pods and custom resources. A cluster operator can use this feature to clean up finished Jobs (either Complete or Failed) automatically by specifying the .spec.ttlSecondsAfterFinished field of a Job.

CronJob
=======

FEATURE STATE: Kubernetes v1.8 [beta]

A CronJob creates Jobs on a repeating schedule.

One CronJob object is like one line of a crontab (cron table) file. It runs a job periodically on a given schedule, written in Cron format.

CronJobs are useful for creating periodic and recurring tasks, like running backups or sending emails. CronJobs can also schedule individual tasks for a specific time, such as scheduling a Job for when your cluster is likely to be idle

::

    apiVersion: batch/v1beta1
    kind: CronJob
    metadata:
      name: hello
    spec:
      schedule: "*/1 * * * *"
      jobTemplate:
        spec:
          template:
            spec:
              containers:
              - name: hello
                image: busybox
                args:
                - /bin/sh
                - -c
                - date; echo Hello from the Kubernetes cluster
              restartPolicy: OnFailure


A cron job creates a job object about once per execution time of its schedule. We say "about" because there are certain circumstances where two jobs might be created, or no job might be created. We attempt to make these rare, but do not completely prevent them. Therefore, jobs should be idempotent.

For every CronJob, the CronJob Controller checks how many schedules it missed in the duration from its last scheduled time until now. If there are more than 100 missed schedules, then it does not start the job and logs the error

Service
=======

An abstract way to expose an application running on a set of Pods as a network service.

With Kubernetes you don't need to modify your application to use an unfamiliar service discovery mechanism. Kubernetes gives Pods their own IP addresses and a single DNS name for a set of Pods, and can load-balance across them.

In Kubernetes, a Service is an abstraction which defines a logical set of Pods and a policy by which to access them

The set of Pods targeted by a Service is usually determined by a selector

Cloud-native service discovery
==============================

If you're able to use Kubernetes APIs for service discovery in your application, you can query the API server for Endpoints, that get updated whenever the set of Pods in a Service changes.

For non-native applications, Kubernetes offers ways to place a network port or load balancer in between your application and the backend Pods

For example, suppose you have a set of Pods that each listen on TCP port 9376 and carry a label app=MyApp:

::

    apiVersion: v1
    kind: Service
    metadata:
      name: my-service
    spec:
      selector:
        app: MyApp
      ports:
        - protocol: TCP
          port: 80
          targetPort: 9376

Kubernetes assigns this Service an IP address (sometimes called the "cluster IP"), which is used by the Service proxies

The controller for the Service selector continuously scans for Pods that match its selector, and then POSTs any updates to an Endpoint object also named “my-service”.

Port definitions in Pods have names, and you can reference these names in the targetPort attribute of a Service. This works even if there is a mixture of Pods in the Service using a single configured name, with the same network protocol available via different port numbers. This offers a lot of flexibility for deploying and evolving your Services. For example, you can change the port numbers that Pods expose in the next version of your backend software, without breaking clients.

As many Services need to expose more than one port, Kubernetes supports multiple port definitions on a Service object. Each port definition can have the same protocol, or a different one.

Services without selectors
--------------------------

Services most commonly abstract access to Kubernetes Pods, but they can also abstract other kinds of backends. For example:

    You want to have an external database cluster in production, but in your test environment you use your own databases.
    You want to point your Service to a Service in a different Namespace or on another cluster.
    You are migrating a workload to Kubernetes. Whilst evaluating the approach, you run only a proportion of your backends in Kubernetes.

In any of these scenarios you can define a Service without a Pod selector. For example:

::

    apiVersion: v1
    kind: Service
    metadata:
      name: my-service
    spec:
      ports:
        - protocol: TCP
          port: 80
          targetPort: 9376


Because this Service has no selector, the corresponding Endpoint object is not created automatically. You can manually map the Service to the network address and port where it's running, by adding an Endpoint object manually:

::

    apiVersion: v1
    kind: Endpoints
    metadata:
      name: my-service
    subsets:
      - addresses:
          - ip: 192.0.2.42
        ports:
          - port: 9376

Virtual IPs and service proxies
-------------------------------

Every node in a Kubernetes cluster runs a kube-proxy. kube-proxy is responsible for implementing a form of virtual IP for Services of type other than ExternalName

A question that pops up every now and then is why Kubernetes relies on proxying to forward inbound traffic to backends. What about other approaches? For example, would it be possible to configure DNS records that have multiple A values (or AAAA for IPv6), and rely on round-robin name resolution?

There are a few reasons for using proxying for Services:

    There is a long history of DNS implementations not respecting record TTLs, and caching the results of name lookups after they should have expired.
    Some apps do DNS lookups only once and cache the results indefinitely.
    Even if apps and libraries did proper re-resolution, the low or zero TTLs on the DNS records could impose a high load on DNS that then becomes difficult to manage.

=====================
User space proxy mode 
=====================

In this mode, kube-proxy watches the Kubernetes master for the addition and removal of Service and Endpoint objects. For each Service it opens a port (randomly chosen) on the local node. Any connections to this "proxy port" are proxied to one of the Service's backend Pods (as reported via Endpoints). kube-proxy takes the SessionAffinity setting of the Service into account when deciding which backend Pod to use.

-------------------
iptables proxy mode
-------------------

Lastly, the user-space proxy installs iptables rules which capture traffic to the Service's clusterIP (which is virtual) and port. The rules redirect that traffic to the proxy port which proxies the backend Pod.

For each Endpoint object, it installs iptables rules which select a backend Pod.

By default, kube-proxy in iptables mode chooses a backend at random.

If kube-proxy is running in iptables mode and the first Pod that's selected does not respond, the connection fails. This is different from userspace mode: in that scenario, kube-proxy would detect that the connection to the first Pod had failed and would automatically retry with a different backend Pod.

You can use Pod readiness probes to verify that backend Pods are working OK, so that kube-proxy in iptables mode only sees backends that test out as healthy. Doing this means you avoid having traffic sent via kube-proxy to a Pod that's known to have failed.

.. image:: images/services-iptables-overview.svg

---------------
IPVS proxy mode
---------------

FEATURE STATE: Kubernetes v1.11 [stable]

In ipvs mode, kube-proxy watches Kubernetes Services and Endpoints, calls netlink interface to create IPVS rules accordingly and synchronizes IPVS rules with Kubernetes Services and Endpoints periodically. This control loop ensures that IPVS status matches the desired state. When accessing a Service, IPVS directs traffic to one of the backend Pods.

The IPVS proxy mode is based on netfilter hook function that is similar to iptables mode, but uses a hash table as the underlying data structure and works in the kernel space. That means kube-proxy in IPVS mode redirects traffic with lower latency than kube-proxy in iptables mode, with much better performance when synchronising proxy rules. Compared to the other proxy modes, IPVS mode also supports a higher throughput of network traffic.

IPVS provides more options for balancing traffic to backend Pods; these are:

* rr: round-robin
* lc: least connection (smallest number of open connections)
* dh: destination hashing
* sh: source hashing
* sed: shortest expected delay
* nq: never queue

Multi-Port Services
-------------------

For some Services, you need to expose more than one port. Kubernetes lets you configure multiple port definitions on a Service object. When using multiple ports for a Service, you must give all of your ports names so that these are unambiguous. For example:

::

    apiVersion: v1
    kind: Service
    metadata:
      name: my-service
    spec:
      selector:
        app: MyApp
      ports:
        - name: http
          protocol: TCP
          port: 80
          targetPort: 9376
        - name: https
          protocol: TCP
          port: 443
          targetPort: 9377


DNS
---

You can (and almost always should) set up a DNS service for your Kubernetes cluster using an add-on.

A cluster-aware DNS server, such as CoreDNS, watches the Kubernetes API for new Services and creates a set of DNS records for each one. If DNS has been enabled throughout your cluster then all Pods should automatically be able to resolve Services by their DNS name.

For example, if you have a Service called "my-service" in a Kubernetes Namespace "my-ns", the control plane and the DNS Service acting together create a DNS record for "my-service.my-ns". Pods in the "my-ns" Namespace should be able to find it by simply doing a name lookup for my-service ("my-service.my-ns" would also work).

Pods in other Namespaces must qualify the name as my-service.my-ns. These names will resolve to the cluster IP assigned for the Service.

Kubernetes also supports DNS SRV (Service) records for named ports. If the "my-service.my-ns" Service has a port named "http" with the protocol set to TCP, you can do a DNS SRV query for _http._tcp.my-service.my-ns to discover the port number for "http", as well as the IP address.

Headless Services
-----------------

Sometimes you don't need load-balancing and a single Service IP. In this case, you can create what are termed “headless” Services, by explicitly specifying "None" for the cluster IP (.spec.clusterIP).

You can use a headless Service to interface with other service discovery mechanisms, without being tied to Kubernetes' implementation.

Publishing Services (ServiceTypes)
----------------------------------

For some parts of your application (for example, frontends) you may want to expose a Service onto an external IP address, that's outside of your cluster.

Kubernetes ServiceTypes allow you to specify what kind of Service you want. The default is ClusterIP.

Type values and their behaviors are:

* ClusterIP: Exposes the Service on a cluster-internal IP. Choosing this value makes the Service only reachable from within the cluster. This is the default ServiceType.
* NodePort: Exposes the Service on each Node's IP at a static port (the NodePort). A ClusterIP Service, to which the NodePort Service routes, is automatically created. You'll be able to contact the NodePort Service, from outside the cluster, by requesting <NodeIP>:<NodePort>.
* LoadBalancer: Exposes the Service externally using a cloud provider's load balancer. NodePort and ClusterIP Services, to which the external load balancer routes, are automatically created.
* ExternalName: Maps the Service to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record with its value. No proxying of any kind is set up.

External IPs
------------

If there are external IPs that route to one or more cluster nodes, Kubernetes Services can be exposed on those externalIPs. Traffic that ingresses into the cluster with the external IP (as destination IP), on the Service port, will be routed to one of the Service endpoints. externalIPs are not managed by Kubernetes and are the responsibility of the cluster administrator.



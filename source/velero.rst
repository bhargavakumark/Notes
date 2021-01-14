Backup workflow
+++++++++++++++

When you run velero backup create test-backup:

* The Velero client makes a call to the Kubernetes API server to create a Backup object.
* The BackupController notices the new Backup object and performs validation.
* The BackupController begins the backup process. It collects the data to back up by querying the API server for resources.
* The BackupController makes a call to the object storage service – for example, AWS S3 – to upload the backup file.

By default, velero backup create makes disk snapshots of any persistent volumes. You can adjust the snapshots by specifying additional flags. Run velero backup create --help to see available flags. Snapshots can be disabled with the option --snapshot-volumes=false

Velero backs up resources using the Kubernetes API server’s preferred version for each group/resource. When restoring a resource, this same API group/version must exist in the target cluster in order for the restore to be successful.

Backup/Snapshot Locations
=========================

Velero has two custom resources, BackupStorageLocation and VolumeSnapshotLocation, that are used to configure where Velero backups and their associated persistent volume snapshots are stored.

A BackupStorageLocation is defined as a bucket, a prefix within that bucket under which all Velero data should be stored, and a set of additional provider-specific fields (e.g. AWS region, Azure storage account, etc.) The API documentation captures the configurable parameters for each in-tree provider.

A VolumeSnapshotLocation is defined entirely by provider-specific fields (e.g. AWS region, Azure resource group, Portworx snapshot type, etc.) The API documentation captures the configurable parameters for each in-tree provider.

The user can pre-configure one or more possible BackupStorageLocations and one or more VolumeSnapshotLocations, and can select at backup creation time the location in which the backup and associated snapshots should be stored.

https://velero.io/docs/v1.4/supported-providers/

https://velero.io/docs/v1.4/contributions/minio/

Use a storage provider secured by a self-signed certificate
-----------------------------------------------------------

If you intend to use Velero with a storage provider that is secured by a self-signed certificate, you may need to instruct Velero to trust that certificate. See use Velero with a storage provider secured by a self-signed certificate for details.

Use non-file-based identity mechanisms
======================================

By default, velero install expects a credentials file for your velero IAM account to be provided via the --secret-file flag.

If you are using an alternate identity mechanism, such as kube2iam/kiam on AWS, Workload Identity on GKE, etc., that does not require a credentials file, you can specify the --no-secret flag instead of --secret-file.

Enable server side features
===========================

Features on the Velero server can be enabled using the --features flag to the velero install command. This flag takes as value a comma separated list of feature flags to enable. As an example CSI snapshotting of PVCs can be enabled using EnableCSI feature flag in the velero install command as shown below:

::

    velero install --features=EnableCSI

Enabling and disabling feature flags will require modifying the Velero deployment and also the restic daemonset. This may be done from the CLI by uninstalling and re-installing Velero, or by editing the deploy/velero and daemonset/restic resources in-cluster.

::

    $ kubectl -n velero edit deploy/velero
    $ kubectl -n velero edit daemonset/restic


Enable client side features
===========================

For some features it may be necessary to use the --features flag to the Velero client. This may be done by passing the --features on every command run using the Velero CLI or the by setting the features in the velero client config file using the velero client config set command as shown below:

::

    velero client config set features=EnableCSI

This stores the config in a file at **$HOME/.config/velero/config.json**

All client side feature flags may be disabled using the below command

::

    velero client config set features=

Install with custom resource requests and limits
================================================

::

      velero install \
    --velero-pod-cpu-request <CPU_REQUEST> \
    --velero-pod-mem-request <MEMORY_REQUEST> \
    --velero-pod-cpu-limit <CPU_LIMIT> \
    --velero-pod-mem-limit <MEMORY_LIMIT> \
    [--use-restic] \
    [--default-volumes-to-restic] \
    [--restic-pod-cpu-request <CPU_REQUEST>] \
    [--restic-pod-mem-request <MEMORY_REQUEST>] \
    [--restic-pod-cpu-limit <CPU_LIMIT>] \
    [--restic-pod-mem-limit <MEMORY_LIMIT>]


Enable Velero CLI autocompletion for Bash on MacOS
==================================================

You now have to ensure that the velero completion script gets sourced in all your shell sessions. There are multiple ways to achieve this:

Source the completion script in your ~/.bashrc file:

::

    echo 'source <(velero completion bash)' >>~/.bashrc

Add the completion script to the /usr/local/etc/bash_completion.d directory:

::

    velero completion bash >/usr/local/etc/bash_completion.d/velero

If you have an alias for velero, you can extend shell completion to work with that alias:

::

    echo 'alias v=velero' >>~/.bashrc
    echo 'complete -F __start_velero v' >>~/.bashrc

Uninstalling Velero
===================

If you would like to completely uninstall Velero from your cluster, the following commands will remove all resources created by velero install:

::

    kubectl delete namespace/velero clusterrolebinding/velero
    kubectl delete crds -l component=velero




XSFT
====

CCR - Continous checkpoint and rewind
-------------------------------------

Software based fault-tolerance against h/w failure, against complete virtual machine failure. Not against protection against software faults in the virtual machine.

XSFT works by blocking the externally visible output

*    Network packets are not sent to the client immediately
*    Disk writes are not scheduled immediately
*    Output sent only after a checkpoint


The client does not see intermediate system state, system moves from one checkpoint to the other. Failure becomes part of the intermediate state, client does not know when a failure happens. The interval between 2 checkpoints is called an epoch.

During checkpoint the entire execution context of a virtual machine is replicated. CPU register state, contents of geust physical memory (changes), disk I/O state, network I/O state is transferred to other machine (using usually infiniband)

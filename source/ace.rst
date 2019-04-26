ACE
===

.. contents::

Pattern : Network Server
------------------------

* **Wrapper Facade** : “Encapsulates the functions and data provided by existing non-OO APIs within more concise, robust, portable, maintainable, and cohesive OO class interfaces”
* **Reactor** : “Demultiplexes and dispatches requests that are delivered concurrently to an application by one or more clients”
* **Acceptor** : “Decouple the passive connection and initialization of a peer service in a distributed system from the processing performed once the peer service is connected and initialized”
* **Component Configurator** : “Decouples the implementation of services from the time when they are configured”
* **Active Object** : “Decouples method execution from method invocation to enhance concurrency and simplify synchronized access to an object that resides in its own thread of control”

Sample Program

::

        // Acceptor-mode socket handle.
        static ACE_SOCK_Acceptor acceptor;

        // Set of currently active handles
        static ACE_Handle_Set activity_handles;

        // Scratch copy of activity_handles
        static ACE_Handle_Set ready_handles;

        static void initialize_acceptor (u_short port)
        {
                // Set up address info. to become server.
                ACE_INET_Addr saddr (port);

                // Create a local endpoint of communication.
                acceptor.open (saddr);

                // Set the <SOCK_Acceptor> into non-blocking mode.
                acceptor.enable (ACE_NONBLOCK);
                activity_handles.set_bit (acceptor.get_handle ());
        }


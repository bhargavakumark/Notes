Tech : Map Reduce
=================

.. contents::

Map Reduce
----------
Map Reduces is developed by google as a general-purpse environment for larg-scale data processing. It is designed to use for very large data sets, and to run parallel tasks on thousands of computers in for large clusters. It allows a algorithm to be taken and division to multiple parallel data tasks which can be executed on different machines.

Example: To count the total no of occurences of each word in the input

::

        // input: a document
        // intermediate output: keyword; value=1
        Map(void *input) {
                for each word w in input
                        EmitIntermediate(w,1);
        }

        //intermediate outupt:keyword; value=1
        // output:keyword; value=occurrences
        Reduce(String key, Iterator values) {
                int result = 0;
                for each v in values
                        result += v;
                Emit(key, result);
        }


Phoenix : a shared-memory implementation of MapReduce
-----------------------------------------------------

*   Uses threads instead of cluster nodes for parallelism
*   Communicates through shared memory instead of network messages

   *    Works with CMP and SMP systems

*   Current version works with C/C++ and uses p-threads

   *    Easy to port to other languages or thread evnironments

Pheonix API
-----------

-----------------------
System-define functions
-----------------------

These are functions provided by pheonix for system related tasks.

::

    int pheonix_scheduler(scheduler_args_t *args)
        This initialises the runtime system
    void emit_intermediate (void *key, void *val, int key_size)
    void emit(void *key, void *val)
        These 2 functions are used to modify the pheonix map-reduce queues. 

----------------------
User-defined functions
----------------------

These functions are arguments to the pheonix scheduler.

::

    void (*map_t) (map_args-t *args)
        Map function that needs to be applied to each input element
    void (*reduce_t) (void *key, void **buffer, int count)
        Reduce function applied on intermediate parts with the same key
    int (*key_cmp_t) (const void *key1, const void *key2)
        Function to compare two keys
    int (*splitter_t) (void *input, int size, map_args_t *args)
        Splits input data across map tasks (optional)


Pheonix Runtime
---------------

Pheonix runtime provides starting and stopping of threads, assigning map and reduce tasks to threads, buffer allocation and communication. It allows duynamic scheduling of tasks for load balancing, communication through pointer exchange, locality optimisation through granuality adujstment.


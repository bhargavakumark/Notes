Tech : PRAM
===========

.. contents::

PRAM
----

**Phase-change random access memory (PRAM)** is a
promising storage-class memory technology that has
the potential to replace flash memory and DRAM
in many applications. Because individual cells in a
PRAM can be written independently, only data cells
whose current values differ from the corresponding bits
in a write request need to be updated. Furthermore,
when a block write request is received, the PRAM
may contain many free blocks that are available for
overwriting, and these free blocks will generally have
different contents. For this reason, the number of bit
programming operations required to write new data
to the PRAM (and consequently power consumption
and write bandwidth) depends on the location that
is chosen to be overwritten. 

PRAMs exploit the unique behavior of chalcogenide glass. 
Heat produced by the passage of an electric current 
switches this material between two states, crystalline 
and amorphous. Recent versions can achieve two additional 
distinct states, in effect doubling their storage capacity

The amorphous, high resistance state represents a binary 0, 
while the crystalline, low resistance state represents a 1. 
Chalcogenide is the same material used in re-writable 
optical media (such as CD-RW and DVD-RW). In those 
instances, the material's optical properties are 
manipulated, rather than its electrical resistivity, 
as chalcogenide's refractive index also changes with 
the state of the material.

Wriring to PRAM cells
---------------------

Several researchers have observed that because indi-
vidual PRAM cells can be written independently, only
the memory cells whose current values differ from
the corresponding bits in a write request need to be
programmed. This technique, which we will
call data-comparison write (DCW), reduces
power consumption, improves write bandwidth, and
also contributes to a longer device lifetime by reducing
wear on the cells. 

Since only a fraction of
the bits in a memory block stored in the PRAM
will typically be changed by a write operation, it
is generally advantageous to first read the existing
contents of the entire block, compare it with the new
data to be written, and then update only the bits that
need to change. The cost of the read and comparison
operations is offset by avoiding the unnecessary bit
writes. Any memory technology where this “differ-
ential write” mechanism is effective can benefit from
block placement optimization, since the number of bits
that need to be written (and thus the cost of the write
operation) depends on the location that is chosen to be
overwritten.

PRAM vs. Flash
--------------

It is the switching time and inherent scalability that 
makes PRAM most appealing. PRAM's temperature sensitivity 
is perhaps its most notable drawback, one that may 
require changes in the production process of manufacturers 
incorporating the technology.

PRAM can offer much higher performance in applications 
where writing quickly is important, both because the memory 
element can be switched more quickly, and also because 
single bits may be changed to either 1 or 0 without needing 
to first erase an entire block of cells. PRAM's high 
performance, thousands of times faster than conventional 
hard drives, makes it particularly interesting in 
nonvolatile memory roles that are currently 
performance-limited by memory access timing.

PRAM devices also degrade with use, for different reasons than 
Flash, but degrade much more slowly. A PRAM device may endure 
around 100 million write cycles.[10] PRAM lifetime is limited 
by mechanisms such as degradation due to GST thermal expansion 
during programming, metal (and other material) migration, 
and other mechanisms still unknown.

Flash parts can be programmed before being soldered on to a 
board, or even purchased pre-programmed. The contents of a 
PRAM, however, are lost because of the high temperatures 
needed to solder the device to a board (see reflow soldering 
or wave soldering). This is made worse by the recent drive 
to lead-free manufacturing requiring higher soldering 
temperatures. The manufacturer using PRAM parts must provide 
a mechanism to program the PRAM "in-system" after it has 
been soldered in place.




Tech : Memory Technologies
==========================

.. contents::

Solid-state
-----------
Solid-state electronic components, devices, and systems are based entirely on the semiconductor, such as transistors, microprocessor chips, and the bubble memory. In solid-state components, there is no use of the electrical properties of a vacuum and no mechanical action, no moving parts. In a solid-state component, the current is confined to solid elements and compounds engineered specifically to switch and amplify it. Current flows in two forms: as negatively-charged electrons, and as positively-charged electron deficiencies called electron holes or just "holes". Both the electron and the hole are called charge carriers.

Examples of a non-solid-state electronic components are vacuum tubes and cathode-ray tubes (CRTs). In this device, electrons flow freely through a vacuum from an electron gun, through deflecting and focusing fields, and finally to a phosphorescent screen.

Solid-state devices are much faster and more reliable than mechanical disks and tapes, but are usually more expensive.

SRAM and DRAM
-------------
Dynamic random access memory (DRAM) is a type of random access memory that stores each bit of data in a separate capacitor within an integrated circuit. Since real capacitors leak charge, the information eventually fades unless the capacitor charge is refreshed periodically. Because of this refresh requirement, it is a dynamic memory as opposed to SRAM and other static memory.

The advantage of DRAM is its structural simplicity: only one transistor and a capacitor are required per bit, compared to six transistors in SRAM. This allows DRAM to reach very high density.

For economic reasons, the large (main) memories found in personal computers, workstations, and non-handheld game-consoles (such as Playstation and Xbox) normally consists of dynamic RAM (DRAM). Other parts of the computer, such as cache memories and data buffers in hard disks, normally use static RAM (SRAM).

---------------------
DRAM (memory) modules
---------------------

*    Single In-line Pin Package (SIPP)
*    Single In-line Memory Module (SIMM)
*    Dual In-line Memory Module (DIMM)


Common DRAM packages :
#. DIP 16-pin (DRAM chip, usually pre-FPRAM)
#. SIPP (usually FPRAM)
#. SIMM 30-pin (usually FPRAM)
#. SIMM 72-pin (so-called "PS/2 SIMM", usually EDO RAM)
#. DIMM 168-pin (SDRAM)
#. DIMM 184-pin (DDR SDRAM)
#. RIMM 184-pin
#. DIMM 240-pin (DDR2 SDRAM/DDR3 SDRAM)

-----
SDRAM
-----
SDRAM refers to synchronous dynamic random access memory, a term that is used to describe dynamic random access memory that has a synchronous interface. Traditionally, dynamic random access memory (DRAM) has an asynchronous interface which means that it responds as quickly as possible to changes in control inputs. SDRAM has a synchronous interface, meaning that it waits for a clock signal before responding to control inputs and is therefore synchronized with the computer's system bus. The clock is used to drive an internal finite state machine that pipelines incoming instructions. This allows the chip to have a more complex pattern of operation than asynchronous DRAM which does not have a synchronized interface.

Pipelining means that the chip can accept a new instruction before it has finished processing the previous one. In a pipelined write, the write command can be immediately followed by another instruction without waiting for the data to be written to the memory array. In a pipelined read, the requested data appears after a fixed number of clock pulses after the read instruction, cycles during which additional instructions can be sent. (This delay is called the latency and is an important parameter to consider when purchasing SDRAM for a computer.)

Originally simply known as "SDRAM", Single Data Rate SDRAM can accept one command and transfer one word of data per clock cycle. Typical clock frequencies are 100 and 133 MHz. Chips are made with a variety of data bus sizes.

---------------
SDRAM operation
---------------

A 512 megabyte (i.e., 512 MiB) SDRAM DIMM might be made of 8 or 9 SDRAM chips, each containing 512 Mbit (512 Mibit) of storage, and each one contributing 8 bits to the DIMM's 64- or 72-bit width.

A typical 512 Mbit SDRAM chip internally contains 4 independent 16 Mbyte banks. Each bank is an array of 8192 rows of 16384 bits each. A bank is either idle, active, or changing from one to the other.

An active command activates an idle bank. It takes a 2-bit bank address (BA0âBA1) and a 13-bit row address (A0âA12), and reads that row into the bank's array of 16384 sense amplifiers. This is also known as "opening" the row. This operation has the side effect of refreshing that row.

Once the row has been activated or "opened", read and write commands are possible. Each command requires a column address, but because each chip works on 8 bits at a time, there are 2048 possible column addresses, needing only 11 address lines (A0âA9,A11). Activation requires a minimum time, called the row-to-column delay, or tRCD. This time, rounded up to the next multiple of the clock period, specifies the minimum number of cycles between an active command, and a read or write command. During these delay cycles, arbitrary commands may be sent to other banks; they are completely independent.

When a read command is issued, the SDRAM will produce the corresponding output data on the DQ lines in time for the rising edge of the clock 2 or 3 cycles later (depending on the configured CAS latency). Subsequent words of the burst will be produced in time for subsequent rising clock edges.

A write command is accompanied by the data to be written on the DQ lines during the same rising edge. It is the duty of the memory controller to ensure that the SDRAM is not driving read data on the DQ lines at the same time that it needs to drive write data on those lines. This can be done by waiting until a read burst is not in progress, terminating the read burst, or using the DQM control line.

When the memory controller wants to access a different row, it must first return that bank's sense amplifiers to an idle state, ready to sense the next row. This is known as a "precharge" operation, or "closing" the row. A precharge may be commanded explicitly, or it may be performed automatically at the conclusion of a read or write operation. Again, there is a minimum time, the row precharge delay, tRP, which must elapse before that bank is fully idle and it may receive another active command.

Although refreshing a row is an automatic side effect of activating it, there is a minimum time for this to happen, which requires a minimum row access time tRAS, that must elapse between an active command opening a row, and the corresponding precharge command closing it. This limit is usually dwarfed by desired read and write commands to the row, so its value has little effect on typical performance.

---------
DDR SDRAM
---------
While the access latency of DRAM is fundamentally limited by the DRAM array, DRAM has very high potential bandwidth because each internal read is actually a row of many thousands of bits. To make more of this bandwidth available to users, a Double Data Rate interface was developed. This uses the same commands, accepted once per cycle, but reads or writes two words of data per clock cycle. It achieves nearly twice the bandwidth of the preceding [single data rate] SDRAM by double pumping (transferring data on the rising and falling edges of the clock signal) without increasing the clock frequency.

With data being transferred 64 bits at a time, DDR SDRAM gives a transfer rate of (memory bus clock rate) Ã 2 (for dual rate) Ã 64 (number of bits transferred) / 8 (number of bits/byte). Thus with a bus frequency of 100 MHz, DDR SDRAM gives a maximum transfer rate of 1600 MB/s.

DDR SDRAM for desktop computers DIMMs have 184 pins (as opposed to 168 pins on SDRAM, or 240 pins on DDR2 SDRAM), and can be differentiated from SDRAM DIMMs by the number of notches (DDR SDRAM has one, SDRAM has two). DDR for notebook computers SO-DIMMs have 200 pins which is the same number of pins as DDR2 SO-DIMMs. These two specifications are notched very similarly and care must be taken during insertion when you are unsure of a correct match. DDR SDRAM operates at a voltage of 2.5 V, compared to 3.3 V for SDRAM. This can significantly reduce power consumption. Chips and modules with DDR-400/PC-3200 standard have a nominal voltage of 2.6 Volt.

DDR2 SDRAM is very similar to DDR SDRAM, but doubles the minimum read or write unit again, to 4 consecutive words. The bus protocol was also simplified to allow higher performance operation. (In particular, the "burst terminate" command is deleted.) This allows the bus rate of the SDRAM to be doubled without increasing the clock rate of internal RAM operations; instead, internal operations are performed in units 4 times as wide as SDRAM.

DDR3 continues the trend, doubling the minimum read or write unit to 8 consecutive words. This allows another doubling of bandwidth and external bus rate without having to change the clock rate of internal operations, just the width.

Flash Memory
------------
Flash memory is non-volatile computer memory that can be electrically erased and reprogrammed. It is a technology that is primarily used in memory cards and USB flash drives.

It is a specific type of EEPROM (Electrically Erasable Programmable Read-Only Memory) that is erased and programmed in large blocks.

Flash memory costs far less than byte-programmable EEPROM and therefore has become the dominant technology wherever a significant amount of non-volatile, solid state storage is needed.

Flash memory is non-volatile, which means that no power is needed to maintain the information stored in the chip. In addition, flash memory offers fast read access times (although not as fast as volatile DRAM memory used for main memory in PCs) and better kinetic shock resistance than hard disks. Another feature of flash memory is that when packaged in a "memory card," it is enormously durable, being able to withstand intense pressure, extremes of temperature, and even immersion in water.

Although technically a type of EEPROM, the term "EEPROM" is generally used to refer specifically to non-flash EEPROM which is erasable in small blocks, typically bytes. Because erase cycles are slow, the large block sizes used in flash memory erasing give it a significant speed advantage over old-style EEPROM when writing large amounts of data.

---------------
Flash operation
---------------
Flash memory stores information in an array of memory cells made from floating-gate transistors. In traditional single-level cell (SLC) devices, each cell stores only one bit of information. Some newer flash memory, known as multi-level cell (MLC) devices, can store more than one bit per cell by choosing between multiple levels of electrical charge to apply to the floating gates of its cells.
A flash memory cell.

-------------
Block erasure
-------------
One limitation of flash memory is that although it can be read or programmed a byte or a word at a time in a random access fashion, it must be erased a "block" at a time. This generally sets all bits in the block to 1. Starting with a freshly erased block, any location within that block can be programmed. However, once a bit has been set to 0, only by erasing the entire block can it be changed back to 1. In other words, flash memory (specifically NOR flash) offers random-access read and programming operations, but cannot offer arbitrary random-access rewrite or erase operations. A location can, however, be rewritten as long as the new value's 0 bits are a superset of the over-written value's. For example, a nibble value may be erased to 1111, then written as 1110. Successive writes to that nibble can change it to 1010, then 0010, and finally 0000. In practice few algorithms can take advantage of this successive write capability and in general the entire block is erased and rewritten at once.

-----------
Memory Wear
-----------
Another limitation is that flash memory has a finite number of erase-write cycles. Most commercially available flash products are guaranteed to withstand around 100,000 write-erase-cycles.[citation needed] The guaranteed cycle count may apply only to block zero (as is the case with TSOP NAND parts), or to all blocks (as in NOR). This effect is partially offset in some chip firmware or file system drivers by counting the writes and dynamically remapping blocks in order to spread write operations between sectors; this technique is called wear levelling.
Another approach is to perform write verification and remapping to spare sectors in case of write failure, a technique called bad block management (BBM). For portable consumer devices, these wearout management techniques typically extend the life of the flash memory beyond the life of the device itself, and some data loss may be acceptable in these applications. For high reliability data storage, however, it is not advisable to use flash memory that has been through a large number of programming cycles. This limitation does not apply to 'read-only' applications such as thin clients and routers, which are only programmed once or at most a few times during their lifetime.

----------------
Low-level access
----------------
The low-level interface to flash memory chips differs from those of other memory types such as DRAM, ROM, and EEPROM, which support bit-alterability (both zero to one and one to zero) and random-access via externally accessible address buses.

While NOR memory provides an external address bus for read and program operations (and thus supports random-access); unlocking and erasing NOR memory must proceed on a block-by-block basis. With NAND flash memory, read and programming operations must be performed page-at-a-time while unlocking and erasing must happen in block-wise fashion.

------------
NOR memories
------------

Reading from NOR flash is similar to reading from random-access memory, provided the address and data bus are mapped correctly. Because of this, most microprocessors can use NOR flash memory as execute in place (XIP) memory, meaning that programs stored in NOR flash can be executed directly without the need to first copy the program into RAM. NOR flash may be programmed in a random-access manner similar to reading. Programming changes bits from a logical one to a zero. Bits that are already zero are left unchanged. Erasure must happen a block at a time, and resets all the bits in the erased block back to one. Typical block sizes are 64, 128, or 256 KB.

Bad block management is a relatively new feature in NOR chips. In older NOR devices not supporting bad block management, the software or device driver controlling the memory chip must correct for blocks that wear out, or the device will cease to work reliably.

The specific commands used to lock, unlock, program, or erase NOR memories differ for each manufacturer. To avoid needing unique driver software for every device made, a special set of CFI commands allow the device to identify itself and its critical operating parameters.

Apart from being used as random-access ROM, NOR memories can also be used as storage devices by taking advantage of random-access programming. Some devices offer read-while-write functionality so that code continues to execute even while a program or erase operation is occurring in the background. For sequential data writes, NOR flash chips typically have slow write speeds compared with NAND flash.

-------------
NAND memories
-------------
NAND flash architecture was introduced by Toshiba in 1989. These memories are accessed much like block devices such as hard disks or memory cards. Each block consists of a number of pages. The pages are typically 512[6] or 2,048 or 4,096 bytes in size. Associated with each page are a few bytes (typically 12â16 bytes) that should be used for storage of an error detection and correction checksum.

While reading and programming is performed on a page basis, erasure can only be performed on a block basis. Another limitation of NAND flash is data in a block can only be written sequentially.

NAND devices also require bad block management by the device driver software, or by a separate controller chip. SD cards, for example, include controller circuitry to perform bad block management and wear leveling. When a logical block is accessed by high-level software, it is mapped to a physical block by the device driver or controller. A number of blocks on the flash chip may be set aside for storing mapping tables to deal with bad blocks, or the system may simply check each block at power-up to create a bad block map in RAM. The overall memory capacity gradually shrinks as more blocks are marked as bad.

NAND is best suited to systems requiring high capacity data storage. This type of flash architecture offers higher densities and larger capacities at lower cost with faster erase, sequential write, and sequential read speeds, sacrificing the random-access and execute in place advantage of the NOR architecture.

--------------------------------------
Distinction between NOR and NAND flash
--------------------------------------
NOR and NAND flash differ in two important ways:

*    the connections of the individual memory cells are different
*    the interface provided for reading and writing the memory is different (NOR allows random-access for reading, NAND allows only page access)

It is important to understand that these two are linked by the design choices made in the development of NAND flash. An important goal of NAND flash development was to reduce the chip area required to implement a given capacity of flash memory, and thereby to reduce cost per bit and increase maximum chip capacity so that flash memory could compete with magnetic storage devices like hard disks.

NOR and NAND flash get their names from the structure of the interconnections between memory cells.[11] In NOR flash, cells are connected in parallel to the bit lines, allowing cells to be read and programmed individually. The parallel connection of cells resembles the parallel connection of transistors in a CMOS NOR gate. In NAND flash, cells are connected in series, resembling a NAND gate, and preventing cells from being read and programmed individually: the cells connected in series must be read in series.

When NOR flash was developed, it was envisioned as a more economical and conveniently rewritable ROM than contemporary EPROM, EAROM, and EEPROM memories. Thus random-access reading circuitry was necessary. However, it was expected that NOR flash ROM would be read much more often than written, so the write circuitry included was fairly slow and could only erase in a block-wise fashion; random-access write circuitry would add to the complexity and cost unnecessarily.

Because of the series connection and removal of wordline contacts, a large grid of NAND flash memory cells will occupy perhaps only 60% of the area of equivalent NOR cells. NAND flash's designers realized that the area of a NAND chip, and thus the cost, could be further reduced by removing the external address and data bus circuitry. Instead, external devices could communicate with NAND flash via sequential-accessed command and data registers, which would internally retrieve and output the necessary data. This design choice made random-access of NAND flash memory impossible, but the goal of NAND flash was to replace hard disks, not to replace ROMs.

---------------
Write Endurance
---------------
The write endurance of SLC Floating Gate NOR flash is typically equal or greater than that of NAND flash, while MLC NOR & NAND Flash have similar Endurance capabilities. Example Endurance cycle ratings listed in datasheets for NAND and NOR Flash are provided.

    NAND Flash is typically rated at about 100K cycles (Samsung OneNAND KFW4G16Q2M)
    SLC Floating Gate NOR Flash has typical Endurance rating of 100K to 1,000K cycles (Numonyx M58BW 100K; Spansion S29CD016J 1000K)
    MLC Floating Gate NOR has typical Endurance rating of 100K cycles (Numonyx J3 Flash)

------------------
Flash file systems
------------------
Because of the particular characteristics of flash memory, it is best used with either a controller to perform wear-levelling and error correction or specifically designed file systems which spread writes over the media and deal with the long erase times of NOR flash blocks. The basic concept behind flash file systems is: When the flash store is to be updated, the file system will write a new copy of the changed data over to a fresh block, remap the file pointers, then erase the old block later when it has time.

Around 1994, the PCMCIA, an industry group, approved the Flash Translation Layer (FTL) specification, which allowed a Linear Flash device to look like a FAT disk, but still have effective wear levelling. Other commercial systems such as FlashFX and FlashFX Pro by Datalight were created to avoid patent concerns with FTL.

ZFS by Sun Microsystems has been optimized to manage Flash SSD systems, both as cache as well as main storage facilities, available for OpenSolaris, FreeBSD, and Mac OS X operating systems. Sun has announced a complete line of Flash enabled systems and storage devices.

JFFS was the first flash-specific file system for Linux, but it was quickly superseded by JFFS2, originally developed for NOR flash.

In practice, flash file systems are only used for "Memory Technology Devices" ("MTD"), which are embedded flash memories that do not have a controller. Removable flash memory cards and USB flash drives have built-in controllers to perform wear-levelling and error correction so use of a specific flash file system does not add any benefit.

--------------
Transfer rates
--------------
Commonly advertised is the maximum read speed, NAND flash memory cards are generally faster at reading than writing.

Transferring multiple small files, smaller than the chip specific block size, could lead to much lower rate.

Access latency has an influence on performance but is less of an issue than with their hard drive counterpart.

Sometimes denoted in MB/s (megabyte per second), or in number of "X" like 60x 100x or 150x. "X" speed rating makes reference to the speed at which a legacy audio CD drive would deliver data, 1x is equal to 150 kilobytes per second.

For example, a 100x memory card goes to 150 KB x 100 = 15000 KB per second = 14.65 MB per second.

------------
Serial flash
------------

Serial flash is a small, low-power flash memory that uses a serial interface, typically SPI, for sequential data access. When incorporated into an embedded system, serial flash requires fewer wires on the PCB than parallel flash memories, since it transmits and receives data one bit at a time. This may permit a reduction in board space, power consumption, and total system cost.

USB flash drive
---------------
There are typically four parts to a flash drive:

*    Male type-A USB connector â provides an interface to the host computer.
*    USB mass storage controller â implements the USB host controller. The controller contains a small microcontroller with a small amount of on-chip ROM and RAM.
*    NAND flash memory chip â stores data. NAND flash is typically also used in digital cameras.
*    Crystal oscillator â produces the device's main 12 MHz clock signal and controls the device's data output through a phase-locked loop.


Some file systems are designed to distribute usage over an entire memory device without concentrating usage on any part (e.g., for a directory); this prolongs life of simple flash memory devices. USB flash drives, however, have this functionality built into the controller to prolong device life, and use of such a file system brings less advantage.

Some flash drives retain their memory after being submerged in water [19], even through a machine wash, although this is not a design feature and not to be relied upon. Leaving the flash drive out to dry completely before allowing current to run through it has been known to result in a working drive with no future problems. Channel Five's Gadget Show cooked a flash drive with propane, froze it with dry ice, submerged it in various acidic liquids, ran over it with a jeep and fired it against a wall with a mortar. A company specializing in recovering lost data from computer drives managed to recover all the data on the drive. [20] All data on the other removal storage devices tested, using optical or magnetic technologies, were destroyed.

SSD Solid-state devices
-----------------------
A solid-state drive (SSD) is a data storage device that uses solid-state memory to store persistent data.

-----------
Flash-based
-----------
Most SSD manufacturers use non-volatile flash memory to create more rugged and compact devices for the consumer market. These flash memory-based SSDs, also known as flash drives, do not require batteries. They are often packaged in standard disk drive form factors (1.8-inch, 2.5-inch, and 3.5-inch). In addition, non-volatility allows flash SSDs to retain memory even during sudden power outages, ensuring data persistence. Up to the fall of 2008 flash SSDs were significantly slower than DRAM (and even traditional HDDs on big files), but still perform better than traditional hard drives (at least with regard to reads) because of negligible seek time (flash SSDs have no moving parts, and thus eliminate spin-up time, and greatly reduce seek time, latency, and other delays inherent in conventional electro-mechanical disks).

Micron/Intel SSD made faster flash drives by implementing data striping (similar to RAID0) and interleaving. This allowed creation of ultra-fast SSDs with 250 MB/s effective read/write - the maximum SATA interface can really manage.[4]

----------
DRAM based
----------
SSDs based on volatile memory such as DRAM are characterized by ultra fast data access, generally less than 0.01 milliseconds, and are used primarily to accelerate applications that would otherwise be held back by the latency of Flash SDDs or traditional HDDs. DRAM-based SSDs usually incorporate internal battery and backup storage systems to ensure data persistence while no power is being supplied to the drive from external sources. If power is lost, the battery provides power while all data is copied from random access memory (RAM) to back-up storage, or to allow the data's transfer to another computer.

These types of SSD are usually fitted with the same type of DRAM modules used in regular PC's and servers, allowing them to be swapped out and replaced with larger modules.

A secondary computer with a fast network connection can be used as a RAM-based SSD.[7]


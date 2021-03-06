Security : Armoring Techniques
==============================

.. contents::

Packing and Encryption
----------------------

Pakcing is the method that an executable uses to obfuscate an executable or to reduce its size. Packets are typically implemented with a asmall decoder stub which is used to unpack, or deobfuscate the binary in question. Once the decoding of 'unpacking' process is complete, the decoder sutb then transfers control back to the original code of the program. Execution proceeds similarly to that of a normal executable.

Virtual Machine Detection
-------------------------

The typical targets for malware authors are stand-alone systems that are being used for everyday tasks such as email, and online banking. If a virtual machine is detected, it is most likely being used to analyze the program. Due to inherent flaws in the X86 architecture, virtualization cannot be supported at the hardware level. Certain instructions cannot be supported at the hardware level. Fox x86 architecture these are composed of SLDT, SIDT and SGDT instructions. The malware author can simply perform these instructions, and compare the results afterwards. Results will be different for virtual machines executing these instructions when compared to real hardware executing them.

Debugger Detection
------------------

**Windows Debugging API**
        The windows operating system implements a robust API for developing custom debuggers for applications. It is implemented using a call-back method which allows the operating system to single-step a running program at the machine instruction level. Detection of this type of debugger is as simple as looking at the process execution block PEB for a running program. One field that is available inside the data-structure is BeingDebugged field. If thit bit is set, it indicates that a debugger is attached to the process. Fortunately for the anlayst, this bit can be toggled without losing the debugging capability.

**INT3 Instruction Scanning**
        This instruction causes a CPU trap to occur in the operating system. The trap is then propogated to the running program via the operating system. This provides a method by which a developer can set a breakpoint. However, programmers almost never put int3 instructions directly into their programs so it is likely if this is observed, a process is being monitored. Malware authors have implemented various methods to scan for the prescence of this INT3 instruction, and alter execution if it is found. A simple CRC check or MD5SUM can detect and validate that the code has not been altered by an INT3

**Unhandled Structured Exception Handlers**
        Structed Exception Handlers (SEH) are a method of catching exceptions from running applications. Normally when a SEH is reached execution is passed to the handler the program developer has defined, or treated as an unhandled exception and execution halts. Malware authors have seized this as a method for implementing an unpacker. The malware author inserts a SEH and their own handler. This hanlder is typically a set of unpacking instructions. The SEH frame contains a pointer to the previous frame. By triggering SEH executions the stack of a malware program is unwound until an appropriate handler is found. Due to the nature of the debugging interface, the debugger will insert its own SEH handling onto this stack. When the debugged program is run, it will raise an exception. This causes the debugger's stack to catch and handle the SEH instead, possibly crashing the debugger and preventing the malware from unpacking itself. Since there is no way for the debugger to discern between an exception generated by an error in its program, and the debugged program, this typically thwarts unpacking.

**Mid-Instruction Jumping**
        Tpyically a debugger will try to interpret the machine code of a running executable and print out more human readable output. A typical trick that can be performed is to take a long instruction and the value of 0x90 as a parameter. This last parameter, interpreted on its own is the nop, or no-operation instruction. This will cause the CPU to run to the next instruction and continue execution.

**Shifting Decode Frame**
        Shifting decode frame is a method by which a protion of the executable is unpacked, executed then re-encoded. This method has the effect of preventing static post-execution analysis. This precludes the ability to step the executable to the position of the original entry point, and dump the entire executable.

Dynamic Instrumentation
-----------------------

**Dynamic Instrumentation** (DI) can be used to trace the exact execution of a debugged binary. Debug tools such as Vargrind and PIN can provide insight into the exeuction characterstics of a program.

Pin interfaces with the machine code via a series of callbacks that are registered on analysis startup. One can divert execution of a program at each instruction to addresses.

By tracking memory read and writes, we can watch where the program modifies memory locations during the course of execution. Furthermore we can use this information to watch for executions inside of this written memory area. 

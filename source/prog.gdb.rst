Prog : GDB
==========

.. contents::

Registers
---------

=======================
Print register contents
=======================

Prints register contents for the current stack frame. To change
stack frame use **up/down** and then view the register contents
for that frame

::

	(gdb) info registers
	rax            0x0	0
	rbx            0x7f657a6024c0	140073821545664
	rcx            0x1000000	16777216
	rdx            0x0	0
	rsi            0x0	0
	rdi            0x7fff853416d0	140735428171472
	rbp            0x0	0x0
	rsp            0x7fff853416d0	0x7fff853416d0
	r8             0x0	0
	r9             0x7f657a6024c0	140073821545664
	r10            0x0	0
	r11            0x246	582
	r12            0x7f657a5ff7a0	140073821534112
	r13            0x0	0
	r14            0x1f	31
	r15            0x7f6579f2e3a0	140073814385568
	rip            0x7f6579d27d27	0x7f6579d27d27
	eflags         0x10206	[ PF IF RF ]
	cs             0x33	51
	ss             0x2b	43
	ds             0x0	0
	es             0x0	0
	fs             0x0	0
	gs             0x0	0
	fctrl          0x37f	895
	fstat          0x0	0
	ftag           0xffff	65535
	fiseg          0x0	0
	fioff          0x0	0
	foseg          0x0	0
	fooff          0x0	0
	fop            0x0	0
	mxcsr          0x1f80	[ IM DM ZM OM UM PM ]
	(gdb) 

Memory
------

===============================
Examine(Resolve) memory address
===============================

**x** comamnd examines the given address as any given format

::

	(gdb) help x
	Examine memory: x/FMT ADDRESS.
	ADDRESS is an expression for the memory address to examine.
	FMT is a repeat count followed by a format letter and a size letter.
	Format letters are o(octal), x(hex), d(decimal), u(unsigned decimal),
	  t(binary), f(float), a(address), i(instruction), c(char) and s(string).
	Size letters are b(byte), h(halfword), w(word), g(giant, 8 bytes).
	The specified number of objects of the specified size are printed
	according to the format.

Examine an address as code or instructions **x/i <address>**

::

	(gdb) bt
	#0  0x00007f6579d27d27 in ?? () from /lib64/libblkid.so.1
	#1  0x00007f6579d21613 in blkid_do_probe () from /lib64/libblkid.so.1
	#2  0x00007f6579d2193a in blkid_do_safeprobe () from /lib64/libblkid.so.1
	....
	(gdb) disassemble blkid_do_probe
	Dump of assembler code for function blkid_do_probe:
	...
	0x00007f6579d21611 <blkid_do_probe+433>:	callq  *%rdx
	0x00007f6579d21613 <blkid_do_probe+435>:	test   %eax,%eax
	0x00007f6579d21615 <blkid_do_probe+437>:	jne    0x7f6579d21586 <blkid_do_probe+294>
	0x00007f6579d2161b <blkid_do_probe+443>:	mov    0x2cc(%rbp),%eax
	0x00007f6579d21621 <blkid_do_probe+449>:	test   $0x20,%al
	0x00007f6579d21623 <blkid_do_probe+451>:	jne    0x7f6579d2170e <blkid_do_probe+686>
	0x00007f6579d21629 <blkid_do_probe+457>:	test   %al,%al
	0x00007f6579d2162b <blkid_do_probe+459>:	jns    0x7f6579d21697 <blkid_do_probe+567>
	(gdb) 
	(gdb) x/i 0x00007f6579d21613
	0x7f6579d21613 <blkid_do_probe+435>:	test   %eax,%eax
	(gdb) 

Examine a sequence of addresses starting from the given address
**x/<count>i <address>**

:: 

	(gdb) x/10i 0x00007f6579d21613
	0x7f6579d21613 <blkid_do_probe+435>:	test   %eax,%eax
	0x7f6579d21615 <blkid_do_probe+437>:	jne    0x7f6579d21586 <blkid_do_probe+294>
	0x7f6579d2161b <blkid_do_probe+443>:	mov    0x2cc(%rbp),%eax
	0x7f6579d21621 <blkid_do_probe+449>:	test   $0x20,%al
	0x7f6579d21623 <blkid_do_probe+451>:	jne    0x7f6579d2170e <blkid_do_probe+686>
	0x7f6579d21629 <blkid_do_probe+457>:	test   %al,%al
	0x7f6579d2162b <blkid_do_probe+459>:	jns    0x7f6579d21697 <blkid_do_probe+567>
	0x7f6579d2162d <blkid_do_probe+461>:	mov    0x8(%r13),%eax
	0x7f6579d21631 <blkid_do_probe+465>:	lea    0x80cf(%rip),%rsi        # 0x7f6579d29707 <time+46151>
	0x7f6579d21638 <blkid_do_probe+472>:	mov    $0xb,%ecx


Examine address as a hexadecimal memory content

* x (first one): examine the memory
* 32: get 32 of what follows
* x: enable hexadecimal representation
* w: show me Word size data.

::

	(gdb) x/32xw $esp
	0xbffff7e0:    0xb8000ce0 0x08048510 0xbffff848 0xb7eafebc
	0xbffff7f0:    0x00000002 0xbffff874 0xbffff880 0xb8001898
	0xbffff800:    0x00000000 0x00000001 0x00000001 0x00000000
	0xbffff810:    0xb7fd6ff4 0xb8000ce0 0x00000000 0xbffff848
	0xbffff820:    0x40f5f7f0 0x48e0fe81 0x00000000 0x00000000
	0xbffff830:    0x00000000 0xb7ff9300 0xb7eafded 0xb8000ff4
	0xbffff840:    0x00000002 0x08048350 0x00000000 0x08048371
	0xbffff850:    0x08048474 0x00000002 0xbffff874 0x08048510


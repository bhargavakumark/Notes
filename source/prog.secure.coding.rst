Prog : Secure Coding
====================

.. contents::

Format string vulnerabililty
----------------------------
If an attacker is able to provide the format string to an ANSI C format function in part or as a whole, a format string vulnerability is present. By doing so, the behaviour of the format function is changed, and the attacker may get control over the target application.

In the examples below, the string user is supplied by the attacker — he can control the entire ASCIIZ-string, for example through using a command line parameter.

Wrong usage:

.. code-block:: c

        int
        func (char * user)
        {
                printf (user);
        }

Ok:

.. code-block:: c

        int
        func (char * user)
        {
        printf ("%s", user);
        }

The stack and its role at format strings
----------------------------------------

::

        printf ("Number %d has no address, number %d has: %08x\n", i, a, &a);

From within the printf function the stack looks like:

stack top
. . .
<&a>
<a>
<i>
A
. . .
stack bottom

Type 1 (as in Linux rpc.statd, IRIX telnetd). Here the vulnerability lies in the second parameter to the syslog function. The format string is partly
usersupplied.

::

        char tmpbuf[512];
        snprintf (tmpbuf, sizeof (tmpbuf), "foo: %s", user);
        tmpbuf[sizeof (tmpbuf) - 1] = ’\0’;
        syslog (LOG_NOTICE, tmpbuf);

Type 2 (as in wu-ftpd, Qualcomm Popper QPOP 2.53). Here a partly or completely usersupplied string is passed indirectly to a format function.

.. code-block:: c

        int Error (char * fmt, ...);
        ...
        int someotherfunc (char * user)
        {
        ...
        Error (user);
        ...
        }
        ...


Crash of the program
--------------------

By utilizing format strings we can easily trigger some invalid pointer access by just supplying a format string like:

::
        
        printf ("%s%s%s%s%s%s%s%s%s%s%s%s");


Because ‘%s’ displays memory from an address that is supplied on the stack, where a lot of other data is stored, too, our chances are high to read from an illegal address, which is not mapped. Also most format function implementations offer the ‘%n parameter, which can be used to write to the addresses on the stack. If that is done a few times, it should reliably produce a crash, too.

Viewing the stack
-----------------

::

        printf ("%08x.%08x.%08x.%08x.%08x\n");

This is a partial dump of the stack memory, starting from the current bottom upward to the top of the stack — assuming the stack grows towards the low addresses. Depending on the size of the format string buffer and the size of the output buffer, you can reconstruct more or less large parts of the stack memory by using this technique. In some cases you can even retrieve the entire stack memory.

Viewing memory at any location
------------------------------

*    Our format string is usually located on the stack itself, so we already have near to full control over the space, where the format string lies.
*    The format function internally maintains a pointer to the stack location of the current format parameter. If we would be able to get this pointer pointing into a memory space we can control, we can supply an address to the %s parameter.
*    To modify the stack pointer we can simply use dummy parameters that will dig up the stack by printing junk:

::

        printf ("AAA0AAA1_%08x.%08x.%08x.%08x.%08x");

The %08x parameters increase the internal stack pointer of the format function towards the top of the stack. After more or less of this increasing parameters the stack pointer points into our memory: the format string itself. The format function always maintains the lowest stack frame, so if our buffer lies on the stack at all, it lies above the current stack pointer for sure. If we choose the number of %08x parameters correctly, we could just display memory from an arbitrary address, by appending %s to our string. In our case the address is illegal and would be AAA0. Lets replace it with a real one.

Example:
address = 0x08480110
address (encoded as 32 bit le string): \x10\x01\x48\x08

::

        printf ("\x10\x01\x48\x08_%08x.%08x.%08x.%08x.%08x|%s|");


Exploitation - similar to common buffer overflows
-------------------------------------------------

.. code-block:: c

        {
        char outbuf[512];
        char buffer[512];
        sprintf (buffer, "ERR Wrong command: %400s", user);
        sprintf (outbuf, buffer);
        }

Such cases are often hidden deep inside reallife code and are not that obvious as shown in the example above. By supplying a special format
string, we are able to circumvent the %400s limitation: %497d\x3c\xd3\xff\xbf<nops><shellcode>
Everything is similar to a normal buffer overflow exploit string, just

.. code-block:: c

        {
        char outbuf[512];
        char buffer[512];
        sprintf (buffer, "ERR Wrong command: %400s", user);
        sprintf (outbuf, buffer);
        }

Such cases are often hidden deep inside reallife code and are not that obvious as shown in the example above. By supplying a special format
string, we are able to circumvent the %400s limitation:

::

        %497d\x3c\xd3\xff\xbf<nops><shellcode>

Everything is similar to a normal buffer overflow exploit string, just the beginning — the %497d — is different. In normal buffer overflows
we overwrite the return address of a function frame on the stack. As the function that owns this frame returns, it returns to our supplied address.
The address points to somewhere within the <nop> space. There are good articles describing this method of exploitation and if this example is not fully

the beginning — the %497d — is different. In normal buffer overflows we overwrite the return address of a function frame on the stack. As the function that owns this frame returns, it returns to our supplied address. The address points to somewhere within the <nop>space. There are good articles describing this method of exploitation and if this example is not fully clear to you yet, you should consider reading an introductionary article, such as [5], first. It creates a string that is 497 characters long. Together with the error string (“ERR Wrong command: ”) this exceeds the outbuf buffer by four bytes. Although the ‘user’ string is only allowed to be as long as 400 bytes, we can extend its length by abusing format string parameters. Since the second sprintf is not checking the length, this can be used to break out of the boundaries of outbuf. Now we write a return address (0xbfffd33c) and exploit it just the old known way, as we would do it with any buffer overflow. While any format parameter that allows stretching the original format string, such as %50d, %50f or %50s will do, it is desireable to choose a parameter that does not dereference a pointer or may cause a division by zero. This rules out %f and %s. We are left with the integer output parameters: %d, %u and %x.

Exploitation - through pure format strings
------------------------------------------

.. code-block:: c

        {
        char buffer[512];
        snprintf (buffer, sizeof (buffer), user);
        buffer[sizeof (buffer) - 1] = ’\0’;
        }

        int i;
        printf ("foobar%n\n", (int * ) &i);
        printf ("i = %d\n", i);

Would print i = 6. With the same method we used above to print memory from arbitrary addresses, we can write to arbitrary locations:

::

        AAA0_%08x.%08x.%08x.%08x.%08x.%n

With the %08x parameter we increase the internal stack pointer of the format function by four bytes. We do this until this pointer points to the
beginning of our format string (to AAA0). This works, because usually our format string is located on the stack, on top of our normal format
function stack frame. The %n writes to the address 0x30414141, that is represented by the string AAA0. Normally this would crash the program,
since this address is not mapped. But if we supply a correct mapped and writeable address this works and we overwrite four bytes (sizeof (int))
at the address:

::

        \xc0\xc8\xff\xbf_%08x.%08x.%08x.%08x.%08x.%n


Stack Popping
-------------
A problem can arise if the format string is too short to supply a stack popping sequence that will reach your own string. This is a race between
the real distance to your format string and the size of the format string, in which you have to pop at least the real distance. So there is a demand for an effective method to increase the stack pointer with as few bytes as possible. Currently we have used only %u sequences, to show the principle, but there are more effective methods. A %u sequence is two bytes long and pops four bytes, which gives a 1:2 byte ratio (we invest 1 byte to get 2 bytes ahead).
Through using the %f parameter we even get 8 bytes ahead in the stack, while only investing two bytes. But this has a huge drawback, since
if garbage from the stack is printed as floating point number, there may be a division by zero, which will crash the process. To avoid this we can use a special format qualifier, which will only print the integer part of the float number: %.f will walk the stack upwards by eight bytes, using only three bytes in our buffer

Direct Parameter Access
-----------------------

Beside improving the stack popping methods, there is a huge simplification which is known as direct parameter access, a way to directly address a stack parameter from within the format string. Almost all currently in use C libraries do support this features, but not all are useable to apply this
method to format string exploitation.
The direct parameter access is controlled by the $ qualifier:

::

        printf ("%6$d\n", 6, 5, 4, 3, 2, 1);

Prints 1, because the 6$ explicitly addresses the 6th parameter on the stack. Using this method the whole stack pop sequence can be left out.

Response Based Brute Force
--------------------------

If we probe a distance of 32, the format string would look like:

::

        AAAABBBB|%u%u%u%u%u%u%u%u|%08x|

We pop 32 bytes from the stack (8 * %u) and print the four bytes at the 32th byte from the stack hexadecimal. In the ideal case the output would
look like:

::

        AAAABBBB|983217938177639561760134608728913021|41414141|

Alternative targets
-------------------

Common stack based buffer overflows allow only return address overwrites, because those are stored on the stack, too. With format functions however, we can write anywhere into the memory, allowing us to modify the entire writeable process space.

Path Traversal Bugs
-------------------

#. http://vulnerable:6346/........../windows/win.ini
#. http://127.0.0.1:6346/%5c..%5c..%5c..%5cwindows%5cwi n.ini ( %5c == ‘\’ ). Then it tranlates to http://127.0.0.1:6346/\..\..\..\windows\win.ini

how to say yahoo

::

        http://www.yahoo.com
        http://209.191.93.52 (the “vanilla IP address version everyone knows and loves…)
        http://0xD1BF5D34 (hex representation of a yahoo server)
        http://0x123456789D1BF5D34/ (hex representation of a yahoo server is a bunch of numbers in the front “123456789”. Those numbers are disregarded by some browsers.
        http://3518979380/ (decimal representation of an IP)
        http://0321.0277.0135.064 (octal representation of an IP)


XSS vulnerability – Reflection
------------------------------

A vulnerable web site is one that reflects or echoes data back to a user
No storage needed on the vulnerable web site itself <?php echo $input ?>
The attacker creates an html link with some script in it as input to vulnerable web site. This may be in an email, or Malory’s own web site

::

        <A HREF=’http://www.vulnerable.com?input=<malicious  code’>Click here for free stuff!</A>

What happens when Alice clicks on the link?
Alice is taken to the correct site, Malory’s code is echoed by the vulnerable site and executed by Alice’s browser in the context of the vulnerable site


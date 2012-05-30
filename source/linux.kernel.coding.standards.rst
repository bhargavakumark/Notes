Linux : Kernel Coding Standards
===============================

.. contents::

Indentation
-----------
Tabs are 8 characters, and thus indentations are also 8 characters.

::

        /*
         * The preferred way to ease multiple indentation levels 
         * in a switch statement is
         * to align the "switch" and its subordinate "case" labels 
         * in the same column
         * instead of "double-indenting" the "case" labels.  E.g.:
         */

        switch (suffix) {
        case 'G':
        case 'g':
                mem <<= 30;
                break;
        case 'M':
        case 'm':
                mem <<= 20;
                break;
        case 'K':
        case 'k':
                mem <<= 10;
                /* fall through */
        default:
                break;
        }


Breaking long lines
-------------------

::

        void fun(int a, int b, int c)
        {
                if (condition)
                        printk(KERN_WARNING "Warning this is a long printk with "
                                                    "3 parameters a: %u b: %u "
                                                    "c: %u \n", a, b, c);
                next_statement;
        }


Placing Braces
--------------

::

        if (x is true) {
                we do y
        }

        /* functions are a special case, the brace comes in the next line */
        int function(int x)
        {
                body of function
        }


Spaces
------

::

        /* 
         * So use a space after these keywords:
         *        if, switch, case, for, do, while
         * but not with sizeof, typeof, alignof, or __attribute__.  E.g.,
         *        s = sizeof(struct file);
         */

        /*
         * Do not add spaces around (inside) parenthesized expressions.  This example is
         * bad:
         */
                s = sizeof( struct file );

        /* 
         * When declaring pointer data or a function that returns a pointer type, the
         * preferred use of '*' is adjacent to the data name or function name and not
         * adjacent to the type name.  Examples:
         */

                char *linux_banner;
                unsigned long long memparse(char *ptr, char **retptr);
                char *match_strdup(substring_t *s);

        /*
         * Use one space around (on each side of) most binary and ternary operators,
         * such as any of these:
         *
         *        =  +  -  <  >  *  /  %  |  &  ^  <=  >=  ==  !=  ?  :
         *
         * but no space after unary operators:
         *        &  *  +  -  ~  !  sizeof  typeof  alignof  __attribute__  defined
         *
         * no space before the postfix increment & decrement unary operators:
         *        ++  --
         *
         * no space after the prefix increment & decrement unary operators:
         *        ++  --
         *
         * and no space around the '.' and "->" structure member operators.
         */

Functions
---------
The maximum length of a function is inversely proportional to the 
complexity and indentation level of that function.

::

        /* 
         * In source files, separate functions with one blank 
         * line.  If the function is exported, the EXPORT 
         * macro for it should follow immediately after the  
         * closing function brace line.  E.g.:
         */

        int system_is_up(void)
        {
                return system_state == SYSTEM_RUNNING;
        }
        EXPORT_SYMBOL(system_is_up);


Function Prototypes
-------------------
In function prototypes, include parameter names with their data types. 
Although this is not required by the C language, it is preferred in 
Linux because it is a simple way to add valuable information for the 
reader.

GOTOs for exiting
-----------------
The goto statement comes in handy when a function exits from multiple 
locations and some common work such as cleanup has to be done.

The rationale is:

*    unconditional statements are easier to understand and follow
*    nesting is reduced
*    errors by not updating individual exit points when making 
     modifications are prevented
*    saves the compiler work to optimize redundant code away

::

        int fun(int a)
        {
                int result = 0;
                char *buffer = kmalloc(SIZE);

                if (buffer == NULL)
                        return -ENOMEM;

                if (condition1) {
                        while (loop1) {
                                ...
                        }
                        result = 1;
                        goto out;
                }
                ...
        out:
                kfree(buffer);
                return result;
        }


Comments
--------
The preferred style for long (multi-line) comments is:

::

        /*
         * This is the preferred style for multi-line
         * comments in the Linux kernel source code.
         * Please use it consistently.
         *
         * Description:  A column of asterisks on the left side,
         * with beginning and ending almost-blank lines.
         */


Macros
------

*    Names of macros defining constants and labels in enums are capitalized.

	::

		#define CONSTANT 0x12345

*    Enums are preferred when defining several related constants.
*    CAPITALIZED macro names are appreciated but macros resembling functions

may be named in lower case.

*    Generally, inline functions are preferable to macros resembling functions.
*    Macros with multiple statements should be enclosed in a do - while block:

	::

		#define macrofun(a, b, c)                       \
			do {                                    \
				if (a == 5)                     \
					do_this(b, c);          \
			} while (0)


*   Things to avoid when using macros:

   *    macros that affect control flow is a _very_ bad idea. It looks like a function call but exits the "calling" function; don't break the internal parsers of those who will read the code.

	::

		#define FOO(x)                                  \
			do {                                    \
				if (blah(x) < 0)                \
					return -EBUGGERED;      \
			} while(0)


   *    macros that depend on having a local variable with a magic name might look like a good thing, but it's confusing as hell when one reads the code and it's prone to breakage from seemingly innocent changes.

	::

		#define FOO(val) bar(index, val)

   *    macros with arguments that are used as l-values: FOO(x) = y; will bite you if somebody e.g. turns FOO into an inline function.
   *    forgetting about precedence: macros defining constants using expressions must enclose the expression in parentheses. Beware of similar issues with macros using parameters.

	::

		#define CONSTANT 0x4000
		#define CONSTEXP (CONSTANT | 3)


Allocating memory
-----------------

The kernel provides the following general purpose memory 
allocators:kmalloc(), kzalloc(), kcalloc(), and vmalloc(). 
Please refer to the API documentation for further information about them.

The preferred form for passing a size of a struct is the following:

::

        p = kmalloc(sizeof(*p), ...);

The alternative form where struct name is spelled out hurts readability 
and introduces an opportunity for a bug when the pointer variable type 
is changed but the corresponding sizeof that is passed to a memory 
allocator is not.

**sting the return value** which is a void pointer is **redundant**. 
The conversion from void pointer to any other pointer type is 
guaranteed by the C programming language.

inline
------

*	Abundant use of the inline keyword leads to a much bigger kernel, 
	which in turn slows the system as a whole down, due to a bigger 
	icache footprint for the CPU and simply because there is less 
	memory available for the pagecache. Just think about it; a 
	pagecache miss causes a disk seek, which easily takes 5 
	miliseconds. There are a LOT of cpu cycles that can go into 
	these 5 miliseconds.

*	A reasonable rule of thumb is to not put inline at functions 
	that have more than 3 lines of code in them.

*	Often people argue that adding inline to functions that are 
	static and used only once is always a win since there is no space 
	tradeoff. While this is technically correct, gcc is capable of 
	inlining these automatically without help, and the maintenance 
	issue of removing the inline when a second user appears 
	outweighs the potential value of the hint that tells gcc to 
	do something it would have done anyway.


Function return values
----------------------
Functions can return values of many different kinds, and one of the 
most common are

*	value indicating whether the function succeeded or failed. 
	Such a value can be represented as an error-code integer 
	(**-Exxx = failure, 0 = success**)

*	a succeeded **boolean (0 = failure, non-zero = success)**.

If the name of a function is an action or an imperative command, 
the function should return an error-code integer. If the name is 
a predicate, the function should return a succeeded boolean.

::

        /*
         * For example, "add work" is a command, and the 
         * add_work() function returns 0 for success or -EBUSY for failure.  
         * In the same way, "PCI device present" is a predicate,
         * and the pci_dev_present() function returns 1 if it succeeds in
         * finding a matching device or 0 if it doesn't.
         */


References
----------

http://lxr.linux.no/linux/Documentation/CodingStyle

http://www.kroah.com/linux/talks/ols_2002_kernel_codingstyle_talk/html/

http://www.gnu.org/prep/standards/standards.html:

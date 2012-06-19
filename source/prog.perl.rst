Prog : Perl
===========

.. contents::

.. highlight:: perl

References
----------

* **Programming Perl** by **Larry Wall** second edition
* **Learning Perl the Hard Way** by **Allen B. Downey**
* Perl threads  
	* http://perldoc.perl.org/perlthrtut.html
	* http://chicken.genouest.org/perl/multi-threading-with-perl/
* Object Oriented Programming in Perl
	* http://www.datadisk.co.uk/html_docs/perl/oop.htm
	

Perl Data Types
---------------

===========     =========       ==========      =======================================
Type		Character	Example		Is a name for:
===========     =========       ==========      =======================================
Scalar		$		$cents		An individual value (number or string)
Array		@		@large		A list of values, keyed by number
Hash		%		%interest	A group of values, keyed by string
Subroutine	&		&how		A callable chunk of Perl code
Typeglob	\*		struck		Everything named struck
===========     =========       ==========      =======================================

File Test Operators
-------------------

========	===================================================
Operator	Meaning
========	===================================================
-r		File is readable by effective uid/gid.
-w		File is writable by effective uid/gid.
-x		File is executable by effective uid/gid.
-o		File is owned by effective uid.
-R		File is readable by real uid/gid.
-W		File is writable by real uid/gid.
-X		File is executable by real uid/gid.
-O		File is owned by real uid.
-e		File exists.
-z		File has zero size.
-s		File has non-zero size (returns size).
-f		File is a plain file.
-d		File is a directory.
-l		File is a symbolic link.
-p		File is a named pipe (FIFO).
-S		File is a socket.
-b		File is a block special file.
-c		File is a character special file.
-t		Filehandle is opened to a tty.
-u		File has setuid bit set.
-g		File has setgid bit set.
-k		File has sticky bit set.
-T		File is a text file.
-B		File is a binary file (opposite of -T).
-M		Age of file (at startup) in days since modification.
-A		Age of file (at startup) in days since last access.
-C		Age of file (at startup) in days since inode change.
========	===================================================

The -T and -B switches work as follows. The first block or so of the file is examined for odd characters such as strange control codes or characters with the high bit set. If too many odd characters (>30%) are found, it's a -B file, otherwise it's a -T file. 

Also, any file containing null in the first block is considered a binary file. If -T or -B is used on a filehandle, the current input (standard I/O or "stdio") buffer is examined rather than the first block of the file.

True/False
----------

1. Any string is true except for "" and "0".
2. Any number is true except for 0.
3. Any reference is true.
4. Any undefined value is false.

Actually, the last two rules can be derived from the first two. Any reference (rule 3) points to something with an address, and would evaluate to a number or string containing that address, which is never 0. And any undefined value (rule 4) would always evaluate to 0 or the null string.

======================
&& || and or operators
======================

=========	=====	================================
Example		Name	Result
=========	=====	================================
$a && $b	And	$a if $a is false, $b otherwise
$a || $b	Or	$a if $a is true, $b otherwise
! $a		Not	True if $a is not true
$a and $b	And	$a if $a is false, $b otherwise
$a or $b	Or	$a if $a is true, $b otherwise
not $a		Not	True if $a is not true
=========	=====	================================


Arrays and Hashes
-----------------

To assign a list value to an array, you simply group the variables together (with a set of parentheses): Or keyed, or indexed, or subscripted, or looked up. Take your pick.

::

	@home = ("couch", "chair", "table", "stove");

Conversely, if you use @home in a list context, such as on the right side of a list assignment, you get back out the same list you put in. So you could set four scalar variables from the array like this:

::

	($potato, $lift, $tennis, $pipe) = @home;


In an assignment statement, the left side determines the context. If the left side is a scalar, the right side is evaluated in **scalar context**. If the left side is an array, the right side is evaluated in **list context**.

If an array is evaluated in scalar context, it yields the number of elements in the array. 

::

	my $word = @params;
	print "$word\n";

These are called list assignments. They logically happen in parallel, so you can swap two variables by saying:

::

	($alpha,$omega) = ($omega,$alpha);

The following subroutine assigns the first parameter to p1, the second to p2, and a list of the remaining parameters to @params.

::

	sub echo {
		my ($p1, $p2, @params) = @_;
		print "$p1 $p2 @params\n";
	}

Since arrays are ordered, there are various useful operations that you can do on them, such as the stack operations, push and pop. A stack is, after all, just an ordered list, with a beginning and an end.  Especially an end. Perl regards the end of your list as the top of a stack. (Although most Perl programmers think of a list as horizontal, with the top of the stack on the right.)

You can't push or pop a hash though, because it doesn't make sense. A hash has no beginning or end.

Suppose you wanted to translate abbreviated day names to the corresponding full names. You could write the following list assignment.

::

	%longday = ("Sun", "Sunday", "Mon", "Monday", "Tue", "Tuesday",
			"Wed", "Wednesday", "Thu", "Thursday", "Fri",
			"Friday", "Sat", "Saturday");

	%longday = (
		"Sun" => "Sunday",
		"Mon" => "Monday",
		"Tue" => "Tuesday",
		"Wed" => "Wednesday",
		"Thu" => "Thursday",
		"Fri" => "Friday",
		"Sat" => "Saturday",
	);

Not only can you assign a list to a hash, as we did above, but if you use a hash in list context, it'll convert the hash back to a list of key/value pairs, in a weird order. This is occasionally useful. More often people extract a list of just the keys, using the (aptly named) keys function. The key list is also unordered, but can easily be sorted if desired, using the (aptly named) sort function. 


So, for example, if you want to find out the value associated with Wed in the hash above, you would use $longday{"Wed"}. Note again that you are dealing with a scalar value, so you use $, not %.

You can get more than one element at a time from an array by putting a list of indices in brackets.

::

	my @words = @params[0, 2];


File handles
------------

::

	open(SESAME, "filename");                 # read from existing file
	open(SESAME, "<filename");                # (same thing, explicitly)
	open(SESAME, ">filename");                # create file and write to it
	open(SESAME, ">>filename");               # append to existing file
	open(SESAME, "| output-pipe-command");    # set up an output filter
	open(SESAME, "input-pipe-command |");     # set up an input filter


Once opened, the filehandle SESAME can be used to access the file or pipe until it is explicitly closed (with, you guessed it, close(SESAME)), or the filehandle is attached to another file by a subsequent open on the same filehandle.

Once you've opened a filehandle for input (or if you want to use STDIN), you can read a line using the line reading operator, <>. This is also known as the angle operator, because of its shape. The angle operator encloses the filehandle (<SESAME>) you want to read lines from.[20]

::

	$number = <STDIN>; # input the number
	print STDOUT "The number is $number\n"; 

If you try the above example, you may notice that you get an extra blank line. This happens because the read does not automatically remove the newline from your input line (your input would be, for example, "9\n"). For those times when you do want to remove the newline, Perl provides the chop and chomp functions. chop will indiscriminately remove (and return) the last character passed to it, while chomp will only remove the end of record marker (generally, "\n"), and return the number of characters so removed. You'll often see this idiom for inputting a single line:

::

	chop($number = <STDIN>); # input number and remove newline 
	
which means the same thing as

::

	$number = <STDIN>; # input number
	chop($number);

Interpolation
-------------

**Variable interpolation** : When the name of a variable appears in double quotesi (or in other scenarios), it is replaced by the value of the variable.
**Backslash interpolation** : When a sequence beginning with a backslash () appears in double quotes, it is replaced with the character specified by the sequence.

::

	print "@ARGV\n";
	
In this case, the variable appears in double quotes, so it is evaluated in **interpolative context**. It is an array variable, and in interpolative context, the elements of the array are joined using the separator specified by the built-in variable **$"**. The default value is a space.

use strict/warnings
-------------------

::

	use strict;
	user warnings;

Now if you misspell the name of a variable, you get something like this:

::

	Global symbol "@ARG" requires explicit package name.


Operators
---------

=================
Binding Operators
=================

Binary **=~** binds a scalar expression to a pattern match, substitution, or translation. These operations search or modify the string $_ by default.

The return value indicates the success of the operation.

Binary **!~** is just like **=~** except the return value is negated in the logical sense. 

The following expressions are functionally equivalent:

::

	$string !~ /pattern/
	not $string =~ /pattern/

The most spectacular kind of true value is a list value: in a list context, pattern matches can return substrings matched by the parentheses in the pattern. But again, according to the rules of list assignment, the list assignment itself will return true if anything matched and was assigned, and false otherwise. So you sometimes see things like:

::

	if ( ($k,$v) = $string =~ m/(\w+)=(\w*)/ ) {
		print "KEY $k VALUE $v\n";
	}

====================
Relational Operators
====================

=======		======	=========================
Numeric		String	Meaning
=======		======	=========================
>		gt	Greater than
>=		ge	Greater than or equal to
<		lt	Less than
<=		le	Less than or equal to
=======		======	=========================


==================
Equality Operators
==================

The equality operators are much like the relational operators.

=======		======	===============================
Numeric		String	Meaning
=======		======	===============================
==		eq	Equal to
!=		ne	Not equal to
<=>		cmp	Comparison, with signed result
=======		======	===============================

The equal and not-equal operators return 1 for true, and "" for false (just as the relational operators do).

The <=> and cmp operators return -1 if the left operand is less than the right operand, 0 if they are equal, and +1 if the left operand is greater than the right. 

==============
Range Operator
==============

The **..** range operator is really two different operators depending on the context. In a list context, it returns a list of values counting (by ones) from the left value to the right value. This is useful for writing for (1..10) loops and for doing slice operations on arrays.

Be aware that under the current implementation, a temporary array is created, so you'll burn a lot of memory if you write something like this:

::

	for (1 .. 1_000_000) {
		# code
	}

====================
Conditional Operator
====================

Trinary **?:** is the conditional operator, just as in C. It works as:

::

	TEST_EXPR ? IF_TRUE_EXPR : IF_FALSE_EXPR

	$a = $ok ? $b : $c; # get a scalar
	@a = $ok ? @b : @c; # get an array
	$a = $ok ? @b : @c; # get a count of elements in one of the arrays

========================
String Multiply/Addition
========================

There's also a "multiply" operation for strings, also called the repeat operator. Again, it's a separate operator (x) to keep it distinct from numeric multiplication:

::

	$a = 123;
	$b = 3;
	print $a * $b;	# prints 369
	print $a x $b;	# prints 123123123

There is also an "addition" operator for strings that does concatenation. Unlike some languages that confuse this with numeric addition, Perl defines a separate operator (.) for string concatenation:

::

	$a = 123;
	$b = 456;
	print $a + $b;	# prints 579
	print $a . $b;	# prints 123456


	$line .= "\n";	# Append newline to $line.
	$fill x= 80;	# Make string $fill into 80 repeats of itself.
	$val ||= "2";	# Set $val to 2 if it isn't already set.

for/foreach
-----------

A for loop is similar to C

::

	for ($i = 0; $i < 10; $i++) {
		...
	}

A foreach loop

::

	foreach $user (@users) {
		if (-f "$home{$user}/.nexrc") {
			print "$user is cool... they use a perl-aware vi!\n";
		}
	}

In a foreach statement, the expression in parentheses is evaluated to produce a list. Then each element of the list is aliased to the loop variable in turn, and the block of code is executed once for each element. Note that the loop variable becomes a reference to the element itself, rather than a copy of the element. Hence, modifying the loop variable will modify the original array.

A frequently seen idiom is a loop to iterate over the sorted keys of a hash:

::

	foreach $key (sort keys %hash) {
		if ($line =~ /http:/) {
			print $line;
		}
	}

Here, the =~ (pattern binding operator) is telling Perl to look for a match of the regular expression http: in the variable $line. If it finds the expression, the operator returns a true value and the block (a print command) is executed. By the way, if you don't use the =~ binding operator, then Perl will search a default variable instead of $line. This default space is really just a special variable that goes by the odd name of $_. In fact, many of the operators in Perl default to using the $_ variable, so an expert Perl programmer might write the above as:

::

	while (<FILE>) {
		print if /http:/;
	}

Special Variables
-----------------

::

	$digit
	$&	$MATCH
	$`	$PREMATCH
	$'	$POSTMATCH
	$+	$LAST_PAREN_MATCH
	$*	$MULTILINE_MATCHING
	$_	$ARG
	$.	$INPUT_LINE_NUMBER		$NR
	$/	$INPUT_RECORD_SEPARATOR		$RS
	$,	$OUTPUT_FIELD_SEPARATOR		$OFS
	$\	$OUTPUT_RECORD_SEPARATOR	$ORS
	$"	$LIST_SEPARATOR
	$?	$CHILD_ERROR
	$!	$OS_ERROR			$ERRNO
	$@	$EVAL_ERROR
	$$	$PROCESS_ID			$PID
	$<	$REAL_USER_ID			$UID
	$>	$EFFECTIVE_USER_ID		$EUID
	$(	$REAL_GROUP_ID			$GID
	$)	$EFFECTIVE_GROUP_ID		$EGID
	$0	$PROGRAM_NAME

=====================
Global Special Arrays
=====================

::

	@ARGV
	@INC The array containing the list of places to look for Perl scripts to be evaluated by the do EXPR, require, or use constructs. 
	%INC The hash containing entries for the filename of each file that has been included via do or require.
	%ENV The hash containing your current environment. 
	%SIG The hash used to set signal handlers for various signals. Example:
		sub handler {
			# 1st argument is signal name
			local($sig) = @_;
			print "Caught a SIG$sig--shutting down\n";
			close(LOG);
			exit(0);
		}

Some Useful Functions
---------------------

=========
?PATTERN?
=========

::
	
	?PATTERN?

This is just like the /PATTERN/ search, except that it matches only once between calls to reset, so it finds only the first occurrence of something rather than all occurrences.


=====
bless
=====

::
	
	bless REF, CLASSNAME
	bless REF

This function looks up the item pointed to by reference REF and tells the item that it is now an object in the CLASSNAME package - or the current package if no CLASSNAME is specified, which is often the case. It returns the reference for convenience, since a bless is often the last thing in a constructor function. (Always use the two-argument version if the constructor doing the blessing might be inherited by a derived class. In such cases, the class you want to bless your object into will normally be found as the first argument to the constructor in question.) 


======
caller
======

::

	caller EXPR
	caller

This function returns information about the stack of current subroutine calls. Without an argument it returns the package name, filename, and line number that the currently executing subroutine was called from: ($package, $filename, $line) = caller; With an argument it evaluates EXPR as the number of stack frames to go back before the current one. It also reports some additional information.

::

	$i = 0;
	while (($pack, $file, $line, $subname, $hasargs, $wantarray) = caller($i++)) {
		...
	}

Furthermore, when called from within the DB package, caller returns more detailed information: it sets the list variable @DB::args to be the arguments passed in the given stack frame.

=======
confess
=======

confess() is like die except that it prints out a stack backtrace. The error is reported at the line where

confess() is invoked, not at a line in one of the calling routines.


=======
defined
=======

::

	defined EXPR

This function returns a Boolean value saying whether EXPR has a real value or not. A scalar that contains no valid string, numeric, or reference value is known as the undefined value, or undef for short. Many operations return the undefined value under exceptional conditions, such as end of file, uninitialized variable, system error, and such. This function allows you to distinguish between an undefined null string and a defined null string when you're using operators that might return a real null string.

In the next example we use the fact that some operations return the undefined value when you run out of data:

::

	print "$val\n" while defined($val = pop(@ary));

Since symbol tables for packages are stored as hashes (associative arrays), it's possible to check for the existence of a package like this:

::

	die "No XYZ package defined" unless defined %XYZ::;

Finally, it's possible to avoid blowing up on nonexistent subroutines:

::

	sub saymaybe {
		if (defined &say) {
			say(@_);
		}
		else {
			warn "Can't say";
		}
	}

======
delete
======

::

	delete EXPR

This function deletes the specified key and associated value from the specified hash.  Deleting from $ENV{} modifies the environment. 

The following naïve example inefficiently deletes all the values of a hash:

::

	foreach $key (keys %HASH) {
		delete $HASH{$key};
	}

(It would be faster to use the undef command on the whole hash.) 

For normal hashes, the delete function happens to return the value (not the key) that was deleted, but this behavior is not guaranteed for tied hashes, such as those bound to DBM files.

==
do
==

::

	do BLOCK
	do SUBROUTINE(LIST)
	do EXPR

The do BLOCK form executes the sequence of commands in the BLOCK, and returns the value of the last expression evaluated in the block. When modified by a loop modifier, Perl executes the BLOCK once before testing the loop condition. (

====
each
====

::

	each HASH

This function returns a two-element list consisting of the key and value for the next value of a hash. With successive calls to each you can iterate over the entire hash. Entries are returned in an apparently random order. 

::

	while (($key,$value) = each %ENV) {
		print "$key=$value\n";
	}

====
eval
====

::

	eval EXPR
	eval BLOCK

The value expressed by EXPR is parsed and executed as though it were a little Perl program. It is executed in the context of the current Perl program, so that any variable settings remain afterward, as do any subroutine or format definitions. The code of the eval is treated as a block, so any locally scoped variables declared within the eval last only until the eval is done. (See local and my.) As with any code in a block, a final semicolon is not required. If EXPR is omitted, the operator evaluates $_.

Since eval traps otherwise-fatal errors, it is useful for determining whether a particular feature (such as socket or symlink) is implemented. In fact, eval is the way to do all exception handling in Perl. If the code to be executed doesn't vary, you should use the eval BLOCK form to trap run-time errors; 

======
exists
======

::

	exists EXPR

This function returns true if the specified hash key exists in its hash, even if the corresponding value is undefined.

::

	print "Exists\n" if exists $hash{$key};
	print "Defined\n" if defined $hash{$key};
	print "True\n" if $hash{$key};

A hash element can only be true if it's defined, and can only be defined if it exists, but the reverse doesn't necessarily hold true in either case.

====
grep
====

::

	grep EXPR, LIST
	grep BLOCK LIST

This function evaluates EXPR or BLOCK in a Boolean context for each element of LIST, temporarily setting $_ to each element in turn. In list context, it returns a list of those elements for which the expression is true. (The operator is named after a beloved UNIX program that extracts lines out of a file that match a particular pattern. In Perl the expression is often a pattern, but doesn't have to be.) In scalar context, grep returns the number of times the expression was true.  

Presuming @all_lines contains lines of code, this example weeds out comment lines:

::

	@code_lines = grep !/^#/, @all_lines;

See also map. The following two statements are functionally equivalent:

::

	@out = grep { EXPR } @in;
	@out = map { EXPR ? $_ : () } @in

===
hex
===

::

	hex EXPR

This function interprets EXPR as a hexadecimal string and returns the equivalent decimal value. (To interpret strings that might start with 0 or 0x see oct.) If EXPR is omitted, it interprets $_. The following code sets $number to 4,294,906,560:

::

	$number = hex("ffff12c0");

=====
index
=====

::

	index STR, SUBSTR, POSITION
	index STR, SUBSTR

This function returns the position of the first occurrence of SUBSTR in STR. The POSITION, if specified, says where to start looking. Positions are based at 0 (or whatever you've set the $[ variable to - but don't do that). If the substring is not found, the function returns one less than the base, ordinarily -1.  

To work your way through a string, you might say:

::

	$pos = -1;
	while (($pos = index($string, $lookfor, $pos)) > -1) {
		print "Found at $pos\n";
		$pos++;
	}

====
join
====

::

	join EXPR, LIST

This function joins the separate strings of LIST into a single string with fields separated by the value of EXPR, and returns the string. For example:

::

	$_ = join ':', $login,$passwd,$uid,$gid,$gcos,$home,$shell;

====
keys
====

::

	keys HASH

This function returns a list consisting of all the keys of the named hash. The keys are returned in an apparently random order, but it is the same order as either the values or each function produces

::

	@keys = keys %ENV;
	@values = values %ENV;
	while (@keys) {
		print pop(@keys), '=', pop(@values), "\n";
	}

To sort a hash by value, you'll need to provide a comparison function. Here's a descending numeric sort of a hash by its values:

::

	foreach $key (sort { $hash{$b} <=> $hash{$a} } keys %hash) {
		printf "%4d %s\n", $hash{$key}, $key;
	}

====
kill
====

::

	kill LIST

This function sends a signal to a list of processes. The first element of the list must be the signal to send.

::

	$cnt = kill 1, $child1, $child2;
	kill 9, @goners;

==
lc
==

::

	lc EXPR

This function returns a lowercased version of EXPR (or $_ if omitted). 

======
length
======

::

	length EXPR

This function returns the length in bytes of the scalar value EXPR. If EXPR is omitted, the function returns the length of $_, but be careful that the next thing doesn't look like the start of an EXPR, or the tokener will get confused. When in doubt, always put in parentheses.  Do not try to use length to find the size of an array or hash. Use scalar @array for the size of an array, and scalar keys %hash for the size of a hash. (The scalar is typically dropped when redundant, which is typical.)

===
map
===

::

	map BLOCK LIST
	map EXPR, LIST

This function evaluates the BLOCK or EXPR for each element of LIST (locally setting $_ to each element) and returns the list value composed of the results of each such evaluation. It evaluates BLOCK or EXPR in a list context, so each element of LIST may produce zero, one, or more elements in the returned value. These are all flattened into one list. For instance:

::

	@words = map { split ' ' } @lines;

splits a list of lines into a list of words. Often, though, there is a one-to-one mapping between input values and output values:

::

	@chars = map chr, @nums;

===
new
===

::

	new CLASSNAME LIST
	new CLASSNAME

There is no built-in new function. It is merely an ordinary constructor method (subroutine) defined (or inherited) by the CLASSNAME module to let you construct objects of type CLASSNAME. Most constructors are named "new", but only by convention, just to delude C++ programmers into thinking they know what's going on.

==
no
==

::

	no Module LIST

See the use operator, which no is the opposite of, kind of.

===
pop
===

::

	pop ARRAY
	pop

This function treats an array like a stack - it pops and returns the last value of the array, shortening the array by 1. If ARRAY is omitted, the function pops @ARGV (in the main program), or @_ (in subroutines). It has the same effect as:

::

	$tmp = $ARRAY[$#ARRAY--];

======
printf
======

::

	printf FILEHANDLE FORMAT LIST
	printf FORMAT LIST

This function prints a formatted string to FILEHANDLE or, if omitted, the currently selected output filehandle, initially STDOUT. The first item in the LIST must be a string that says how to format the rest of the items. This is similar to the C library's printf(3) and fprintf(3) function, except that the * field width specifier is not supported. The function is equivalent to: 

::

	print FILEHANDLE sprintf LIST

====
push
====

::

	push ARRAY, LIST

This function treats ARRAY as a stack, and pushes the values of LIST onto the end of ARRAY. The length of ARRAY increases by the length of LIST. The function returns this new length. The push function has the same effect as:

::

	foreach $value (LIST) {
		$ARRAY[++$#ARRAY] = $value;
	}

===
ref
===

::

	ref EXPR

The ref operator returns a true value if EXPR is a reference, the null string otherwise. The value returned depends on the type of thing the reference is a reference to. Built-in types include:

::

	REF
	SCALAR
	ARRAY
	HASH
	CODE
	GLOB

If the referenced object has been blessed into a package, then that package name is returned instead. You can think of ref as a "typeof" operator.

::

	if (ref($r) eq "HASH") {
		print "r is a reference to a hash.\n";
	}
	elsif (ref($r) eq "Hump") {
		print "r is a reference to a Hump object.\n";
	}
	elsif (not ref $r) {
		print "r is not a reference at all.\n";
	}

=======
reverse
=======

::

	reverse LIST

In list context, this function returns a list value consisting of the elements of LIST in the opposite order.

This is fairly efficient because it just swaps the pointers around. The function can be used to create descending sequences:

::

	for (reverse 1 .. 10) { ... }

=====
shift
=====

::

	shift ARRAY
	shift

This function shifts the first value of the array off and returns it, shortening the array by 1 and moving everything down. (Or up, or left, depending on how you visualize the array list.) If there are no elements in the array, the function returns the undefined value. If ARRAY is omitted, the function shifts @ARGV (in the main program), or @_ (in subroutines). 

====
sort
====

::

	sort SUBNAME LIST
	sort BLOCK LIST
	sort LIST

This function sorts the LIST and returns the sorted list value. By default, it sorts in standard string comparison order (undefined values sorting before defined null strings, which sort before everything else). SUBNAME, if given, is the name of a subroutine that returns an integer less than, equal to, or greater than 0, depending on how the elements of the list are to be ordered. (The handy <=> and cmp operators can be used to perform three-way numeric and string comparisons.) In the interests of efficiency, the normal calling code for subroutines is bypassed, with the following effects: the subroutine may not be a recursive subroutine, and the two elements to be compared are passed into the subroutine not via @_ but as $a and $b (see the examples below). The variables $a and $b are passed by reference, so don't modify them in the subroutine. SUBNAME may be a scalar variable name (unsubscripted), in which case the value provides the name of (or a reference to) the actual subroutine to use. In place of a SUBNAME, you can provide a BLOCK as an anonymous, in-line sort subroutine.

To do an ordinary numeric sort, say this:

::

	sub numerically { $a <=> $b; }
	@sortedbynumber = sort numerically 53,29,11,32,7;

::

	sub prospects {
		$money{$b} <=> $money{$a}
			or
		$height{$b} <=> $height{$a}
			or
		$age{$a} <=> $age{$b}
			or
		$lastname{$a} cmp $lastname{$b}
			or
		$a cmp $b;
	}
	@sortedclass = sort prospects @class;

To sort fields without regard to case, say:

::

	@sorted = sort { lc($a) cmp lc($b) } @unsorted;

======
splice
======

::

	splice ARRAY, OFFSET, LENGTH, LIST
	splice ARRAY, OFFSET, LENGTH
	splice ARRAY, OFFSET

This function removes the elements designated by OFFSET and LENGTH from an array, and replaces them with the elements of LIST, if any.


Direct Method Splice Equivalent

::

	push(@a, $x, $y) splice(@a, $#a+1, 0, $x, $y)
	pop(@a) splice(@a, -1)
	shift(@a) splice(@a, 0, 1)
	unshift(@a, $x, $y) splice(@a, 0, 0, $x, $y)
	$a[$x] = $y
	splice(@a, $x, 1, $y);

=====
split
=====

::

	split /PATTERN/, EXPR, LIMIT
	split /PATTERN/, EXPR
	split /PATTERN/
	split

This function scans a string given by EXPR for delimiters, and splits the string into a list of substrings, returning the resulting list value in list context, or the count of substrings in scalar context.

Strings of any length can be split:

::

	@chars = split //, $word;
	@fields = split /:/, $line;
	@words = split ' ', $paragraph;
	@lines = split /^/m, $buffer;

The LIMIT parameter is used to split only part of a string:a

::

	($login, $passwd, $remainder) = split /:/, $_, 3;

We said earlier that the delimiters are not returned, but if the PATTERN contains parentheses, then the substring matched by each pair of parentheses is included in the resulting list, interspersed with the fields that are ordinarily returned. Here's a simple case:

::

	split /([-,])/, "1-10,20";

produces the list value:

::

	(1, '-', 10, ',', 20)

=======
sprintf
=======

::

	sprintf FORMAT, LIST

This function returns a string formatted by the usual printf conventions. 

======
substr
======

::

	substr EXPR, OFFSET, LENGTH
	substr EXPR, OFFSET

This function extracts a substring out of the string given by EXPR and returns it. The substring is extracted starting at OFFSET characters from the front of the string.

To prepend the string "Larry" to the current value of $_, use:

::

	substr($_, 0, 0) = "Larry";

To instead replace the first character of $_ with "Moe", use:

::

	substr($_, 0, 1) = "Moe";

and finally, to replace the last character of $_ with "Curly", use:

::

	substr($_, -1, 1) = "Curly";

=======
syscall
=======

::

	syscall LIST

This function calls the system call specified as the first element of the list, passing the remaining elements as arguments to the system call. (Many of these are now more readily available through the POSIX module, and others.) The function produces a fatal error if syscall(2) is unimplemented. The arguments are interpreted as follows: if a given argument is numeric, the argument is passed as a C integer. If not, a pointer to the string value is passed. You are responsible for making sure the string is long enough to receive any result that might be written into it. Otherwise you're looking at a coredump. If your integer arguments are not literals and have never been interpreted in a numeric context, you may need to add 0 to them to force them to look like numbers. (See the following example.)

This example calls the setgroups(2) system call to add to the group list of the current process. (It will only work on machines that support multiple group membership.)

::

	require 'syscall.ph';
	syscall &SYS_setgroups, @groups+0, pack("i*", @groups);

======
system
======

::

	system LIST

This function executes any program on the system for you. It does exactly the same thing as exec LIST except that it does a fork first, and then, after the exec, it waits for the exec'd program to complete. That is (in non-UNIX terms), it runs the program for you, and returns when it's done, unlike exec, which never returns (if it succeeds). 

Because system and backticks block SIGINT and SIGQUIT, killing the program they're running withone of those signals doesn't actually interrupt your program.

::

	@args = ("command", "arg1", "arg2");
	system(@args) == 0
	or die "system @args failed: $?"

Here's a more elaborate example of analyzing the return value from system on a UNIX system to check for all possibilities, including for signals and coredumps.

::

	$rc = 0xffff & system @args;
	printf "system(%s) returned %#04x: ", "@args", $rc;
	if ($rc == 0) {
		print "ran with normal exit\n";
	}
	elsif ($rc == 0xff00) {
		print "command failed: $!\n";
	}
	elsif (($rc & 0xff) == 0) {
		$rc >>= 8;
		print "ran with non-zero exit status $rc\n";
	}
	else {
		print "ran with ";
		if ($rc & 0x80) {
			$rc &= ~0x80;
			print "coredump from ";
		}
		print "signal $rc\n"
	}
	$ok = ($rc == 0);

-----------
system vs `
-----------

::

	$cwd = `pwd`;			# string output from a command
	$exit = system("vi $x");	# numeric status of a command

====
time
====

This function returns the number of non-leap seconds since January 1, 1970, UTC.[10] 

==
uc
==

::

	uc EXPR

This function returns an uppercased version of EXPR

=====
undef
=====

::

	undef EXPR
	undef

This function undefines the value of EXPR, which must be an lvalue. Use only on a scalar value, an entire array or hash, or a subroutine name (using the & prefix).


::

	undef $foo;
	undef $bar{'blurfl'};
	undef @ary;
	undef %assoc;
	undef &mysub;

=======
unshift
=======

::
	
	unshift ARRAY, LIST

This function does the opposite of a shift. (Or the opposite of a push, depending on how you look at it.)

It prepends LIST to the front of the array, and returns the new number of elements in the array:

::

	unshift @ARGV, '-e', $cmd unless $ARGV[0] =~ /^-/;

======
values
======

::

	values HASH

This function returns a list consisting of all the values of the named hash. The values are returned in an apparently random order, but it is the same order as either the keys or each function would produce on the same hash.

====
wait
====

::

	wait

This function waits for a child process to terminate and returns the pid of the deceased process, or -1 if there are no child processes. The status is returned in $?. If you get zombie child processes, you should be calling this function, or waitpid. A common strategy to avoid such zombies is:

::

	$SIG{CHLD} = sub { wait };

If you expected a child and didn't find it, you probably had a call to system, a close on a pipe, or backticks between the fork and the wait. These constructs also do a wait(2) and may have harvested your child process. Use waitpid to avoid this problem.

=======
waitpid
=======

::

	waitpid PID, FLAGS

This function waits for a particular child process to terminate and returns the pid when the process is dead, or -1 if there are no child processes, or 0 if the FLAGS specify non-blocking and the process isn't dead yet. The status of the dead process is returned in $?. To get valid flag values say this:

::

	use POSIX "sys_wait_h";

=========
wantarray
=========

::

	wantarray

This function returns true if the context of the currently executing subroutine is looking for a list value.

The function returns false if the context is looking for a scalar. Here's a typical usage, demonstrating an "unsuccessful" return:

::

	return wantarray ? () : undef;

====
warn
====

::

	warn LIST

This function produces a message on STDERR just like die, but doesn't try to exit or throw an exception.

For example:

::

	warn "Debug enabled" if $debug;

If the message supplied is null, the message "Something's wrong" is used. As with die, a message not ending with a newline will have file and line number information automatically appended.


Regular Expression
------------------

=================
Character Classes
=================

==============	===============	====
Name		Definition	Code
==============	===============	====
Whitespace	[ \\t\\n\\r\\f]	\\s
Word character	[a-zA-Z_0-9]	\\w
Digit		[0-9]		\\d
==============	===============	====

Perl also provides the negation of these classes by using the uppercased character, such as **\\D** for a non-digit character.

We should note that \\w is not always equivalent to [a-zA-Z_0-9]. Some locales define additional alphabetic characters outside the ASCII sequence, and \w respects them.

===========
Quantifiers
===========

You put the two numbers in braces, separated by a comma. For example, if you were trying to match North American phone numbers, **/\d{7,11}/** would match at least seven digits, but no more than eleven digits.

Certain combinations of minimum and maximum occur frequently, so Perl defines special quantifiers for them. We've already seen 

::

	+, which is the same as {1,}, or "at least one of the preceding item"
	*, which is the same as {0,}, or "zero or more of the preceding item"
	?, which is the same as {0,1}, or "zero or one of the preceding item" (that is, the preceding item is optional).

Often, someone will have a string like:

::

	spp:Fe+H20=FeO2;H:2112:100:Stephen P Potter:/home/spp:/bin/tcsh

and try to match "spp:" with **/.+:/**. However, since the **+** quantifier is greedy, this pattern will match everything up to and including "/home/spp:". Sometimes you can avoid this by using a negated character class, that is, by saying **/[^:]+:/**, which says to match one or more non-colon characters (as many as possible), up to the first colon


The other point to be careful about is that regular expressions will try to match as early as possible. This even takes precedence over being greedy. Since scanning happens left-to-right, this means that the pattern will match as far left as possible, even if there is some other place where it could match longer. (Regular expressions are greedy, but they aren't into delayed gratification.) For example, suppose you're using the substitution command (s///) on the default variable space (variable $_, that is), and you want to remove a string of x's from the middle of the string. If you say: Sorry, we didn't pick that notation, so don't blame us. That's just how regular expressions are customarily written in UNIX culture.

::

	$_ = "fred xxxxxxx barney";
	s/x*//;

it will have absolutely no effect. This is because the x* (meaning zero or more "x" characters) will be able to match the "nothing" at the beginning of the string, since the null string happens to be zero characters wide and there's a null string just sitting there plain as day before the "f" of "fred". Even the authors get caught by this from time to time.

There's one other thing you need to know. By default quantifiers apply to a single preceding character, so /bam{2}/ will match "bamm" but not "bambam". To apply a quantifier to more than one character, use parentheses. So to match **"bambam"**, use the pattern **/(bam){2}/**.

================
Minimal Matching
================

In modern versions of Perl, you can force nongreedy, minimal matching by use of a question mark after any quantifier. Our same username match would now be **/.*?:/**. That **.*?** will now try to match as few characters as possible, rather than as many as possible, so it stops at the first colon rather than the last.

=======
Anchors
=======

The special character string \b matches at a word boundary, which is defined as the "nothing" between a word character (\w) and a non-word character (\W), in either order. (The characters that don't exist off the beginning and end of your string are considered to be non-word characters.) For example,

::

	/\bFred\b/

would match both "The Great Fred" and "Fred the Great", but would not match "Frederick the Great" because the "de" in "Frederick" does not contain a word boundary.

==============
Backreferences
==============

A pair of parentheses around a part of a regular expression causes whatever was matched by that part to be remembered for later use. It doesn't change what the part matches, so **/\d+/** and **/(\d+)/** will still match as many digits as possible, but in the latter case they will be remembered in a special variable to be backreferenced later.

How you refer back to the remembered part of the string depends on where you want to do it from.  Within the same regular expression, you use a backslash followed by an integer. The integer corresponding to a given pair of parentheses is determined by counting left parentheses from the beginning of the pattern, starting with one. So for example, to match something similar to an HTML tag (like **"<B>Bold</B>"**, you might use **/<(.*?)>.*?<\/\1>/**. This forces the two parts of the pattern to match the exact same string, such as the "B" above.

Outside the regular expression itself, such as in the replacement part of a substitution, the special variable is used as if it were a normal scalar variable named by the integer. So, if you wanted to swap the first two words of a string, for example, you could use:

::

	s/(\S+)\s+(\S+)/$2 $1/

The right side of the substitution is really just a funny kind of double-quoted string, which is why you can interpolate variables there, including backreference variables. This is a powerful concept: **interpolation** (under controlled circumstances) is one of the reasons Perl is a good text-processing language. The other reason is the pattern matching, of course. Regular expressions are good for picking things apart, and interpolation is good for putting things back together again. Perhaps there's hope for Humpty Dumpty after all.

Backreferences can be nested. For example, the regular expression **((ftp|http):(.*))** creates three variables: **$1** corresponds the outermost cap-
ture sequence, which yields the entire matching string; $2 and $3 correspond to the two nested sequences.

=================
Extended patterns
=================

As regular expressions get longer, they get harder to read and debug. In the previous examples, I have tried to help by assigning the pattern to a variable and then using the variable inside the match operator m//. But that only gets you so far.

An alternative is to use the extended pattern format, which looks like this:

::

	if ($line =~ m{
			(ftp|http)		# protocol
			://
			(.*?)			# machine name (minimal)
			/
			(.*)			# file name
		      }x
	)
	{ print "$1, $2, $3\n" }

The pattern begins with **m{ and ends with }x**. The x indicates extended format; it is one of several modifiers that can appear at the end of a regular expression.

The rest of the statement is standard, except that the arrangement of the statements and punctuation is unusual.  The most important features of the extended format are the use of whitespace and comments, both of which make the expression easier to read and debug.


List Processing
---------------

First, list context has to be provided by something in the "surroundings". In the example above, the list assignment provides it. If you look at the various syntax summaries scattered throughout Chapter 2 and Chapter 3, you'll see various operators that are defined to take a LIST as an argument. Those are the operators that provide a list context. Throughout this book, LIST is used as a specific technical term to mean "a syntactic construct that provides a list context". For example, if you look up sort, you'll find the syntax summary:

::

	sort LIST

That means that sort provides a list context to its arguments.  

Second, at compile time, any operator that takes a LIST provides a list context to each syntactic element of that LIST. So every top-level operator or entity in the LIST knows that it's supposed to produce the best list it knows how to produce. This means that if you say:

::

	sort @guys, @gals, other();	

then each of @guys, @gals, and other() knows that it's supposed to produce a list value.

Finally, at run-time, each of those LIST elements produces its list in turn, and then (this is important) all the separate lists are joined together, end to end, into a single list. And that squashed-flat, one-dimensional list is what is finally handed off to the function that wanted a LIST in the first place. So if **@guys** contains **(Fred,Barney)**, **@gals** contains **(Wilma,Betty)**, and the **other()** function returns the single-element list (Dino), then the LIST that sort sees is

::

	(Fred,Barney,Wilma,Betty,Dino)

and the LIST that sort returns is

::

	(Barney,Betty,Dino,Fred,Wilma)

Some operators produce lists (like keys), some consume them (like print), and some transform lists into other lists (like sort). Operators in the last category can be considered filters; only, unlike in the shell, the flow of data is from right to left, since list operators operate on their arguments passed in from the right.

You can stack up several list operators in a row:

::

	print reverse sort map {lc} keys %hash;

That takes the keys of %hash and returns them to the map function, which lowercases all the keys by applying the lc operator to each of them, and passes them to the sort function, which sorts them, and passes them to the reverse function, which reverses the order of the list elements, and passes them to the print function, which prints them.  As you can see, that's much easier to describe in Perl than in English.

=cut
----

One other lexical oddity is that if a line begins with = in a place where a statement would be legal, Perl ignores everything from that line down to the next line that says **=cut**. The ignored text is assumed to be POD, or plain old documentation. (The Perl distribution has programs that will turn POD commentary into manpages, LaTeX, or HTML documents.)

Variables
---------

There are variable types corresponding to each of the three data types we mentioned. Each of these is introduced (grammatically speaking) by what we call a "funny character". Scalar variables are always named with an initial $, even when referring to a scalar that is part of an array or hash. It works a bit like the English word "the". Thus, we have:

============	===================================================
Construct	Meaning
============	===================================================
$days		Simple scalar value $days
$days[28]	29th element of array @days
$days{'Feb'}	"Feb" value from hash %days
$#days		Last index of array @days
$days->[28]	29th element of array pointed to by reference $days
============	===================================================

Entire arrays or array slices (and also slices of hashes) are named with @, which works much like the words "these" or "those":

==================	=========================================
Construct		Meaning
==================	=========================================
@days			Same as ($days[0], $days[1],... $days[n])
@days[3, 4, 5]		Same as ($days[3], $days[4], $days[5])
@days[3..5]		Same as ($days[3], $days[4], $days[5])
@days{'Jan','Feb'}	Same as ($days{'Jan'},$days{'Feb'})
==================	=========================================

Every variable type has its own namespace. You can, without fear of conflict, use the same name for a scalar variable, an array, or a hash (or, for that matter, a filehandle, a subroutine name, a label, or your pet llama). This means that **$foo and @foo are two different variables**. It also means that **$foo[1] is an element of @foo**, not a part of $foo. This may seem a bit weird, but that's okay, because it is weird.

Since variable names always start with **$, @, or %**, the reserved words can't conflict with variable names.  But they can conflict with nonvariable identifiers, such as labels and filehandles, which don't have an initial funny character. Since reserved words are always entirely lowercase, we recommend that you pick label and filehandle names that do not appear all in lowercase. For example, you could say open(LOG,'logfile') rather than the regrettable open(log,'logfile').[3] Using **uppercase filehandles** also improves readability and protects you from conflict with future reserved words.

Apart from the subscripts of interpolated array and hash variables, there are no multiple levels of interpolation. In particular, contrary to the expectations of shell programmers, backquotes do not interpolate within double quotes, nor do single quotes impede evaluation of variables when used within double quotes.

=========	=======		=============	===============
Customary	Generic		Meaning		Interpolates
=========	=======		=============	===============
''		q//		Literal		No
""		qq//		Literal		Yes
``		qx//		Command		Yes
()		qw//		Word list	No
//		m//		Pattern match	Yes
s///		s///		Substitution	Yes
y///		tr///		Translation	No
=========	=======		=============	===============

Or leave the quotes out entirely

=========
Barewords
=========
A word that has no other interpretation in the grammar will be treated as if it were a quoted string. These are known as **barewords**.

As with filehandles and labels, a bareword that consists entirely of lowercase letters risks conflict with future reserved words. If you use the -w switch, Perl will warn you about barewords.

::

	@days = (Mon,Tue,Wed,Thu,Fri);
	print STDOUT hello, ' ', world, "\n";

sets the array @days to the short form of the weekdays and prints hello world followed by a newline on STDOUT. If you leave the filehandle out, Perl tries to interpret hello as a filehandle, resulting in a syntax error. Because this is so error-prone, some people may wish to outlaw barewords entirely. If you say:

::

	use strict 'subs';

then any bareword that would not be interpreted as a subroutine call produces a compile-time error instead.

The restriction lasts to the end of the enclosing block. An inner block may countermand this by saying:

::

	no strict 'subs';

Note that the bare identifiers in constructs like:

::

	"${verb}able"
	$days{Feb}

are not considered barewords, since they're allowed by explicit rule rather than by having "no other interpretation in the grammar".

==========================
Interpolating array values
==========================

Array variables are interpolated into double-quoted strings by joining all the elements of the array with the delimiter specified in the $" variable[13] (which is a space by default). The following are equivalent:

::

	$temp = join($",@ARGV);
	print $temp;
	print "@ARGV";

====================
Other literal tokens
====================

Two special literals are **__LINE__** and **__FILE__**, which represent the current line number and filename at that point in your program.


List Values and Arrays and context
----------------------------------

Now that we've talked about context, we can talk about list values, and how they behave in context. List values are denoted by separating individual values by commas (and enclosing the list in parentheses where precedence requires it):

::

	(LIST)

In a list context, the value of the list literal is all the values of the list in order. In a scalar context, the value of a list literal is the value of the final element, as with the C comma operator, which always throws away the value on the left and returns the value on the right. (In terms of what we discussed earlier, the left side of the comma operator provides a void context.) For example:

::

	@stuff = ("one", "two", "three");

assigns the entire list value to array @stuff, but:

::

	$stuff = ("one", "two", "three");

assigns only the value three to variable $stuff. The comma operator knows whether it is in a scalar or a list context. An actual array variable also knows its context. In a list context, it would return its entire contents, but in a scalar context it returns only the length of the array (which works out nicely if you mention the array in a conditional). The following assigns to $stuff the value 3:

::

	@stuff = ("one", "two", "three");
	$stuff = @stuff;	# $stuff gets 3, not "three"

Until now we've pretended that LISTs are just lists of literals. But in fact, any expressions that return values may be used within lists. The values so used may either be scalar values or list values. LISTs do automatic interpolation of sublists. That is, when a LIST is evaluated, each element of the list is evaluated in a list context, and the resulting list value is interpolated into LIST just as if each individual element were a member of LIST. Thus arrays lose their identity in a LIST. The list:

::

	(@foo,@bar,&SomeSub)

contains all the elements of @foo, followed by all the elements of @bar, followed by all the elements returned by the subroutine named SomeSub when it's called in a list context. You can use a reference to an array if you do not want it to interpolate.

=========================
Typeglobs and Filehandles
=========================

Perl uses an internal type called a typeglob to hold an entire symbol table entry. The type prefix of a typeglob is a * , because it represents all types. This used to be the preferred way to pass arrays and hashes by reference into a function, but now that we have real references, this mechanism is seldom needed.

Typeglobs (or references thereto) are still used for passing or storing filehandles. If you want to save away a filehandle, do it this way:

::

	$fh = *STDOUT;

or perhaps as a real reference, like this:

::

	$fh = \*STDOUT;

This is also the way to create a local filehandle. For example:

::

	sub newopen {
		my $path = shift;
		local *FH;		# not my!
		open (FH, $path) || return undef;
		return *FH;
	}
	$fh = newopen('/etc/passwd');

But the main use of typeglobs nowadays is to alias one symbol table entry to another symbol table entry. If you say:

::

	*foo = *bar;

it makes everything named "foo" a synonym for every corresponding thing named "bar". You can alias just one of the variables in a typeglob by assigning a reference instead:

::

	*foo = \$bar;

makes $foo an alias for $bar, but doesn't make @foo an alias for @bar, or %foo an alias for %bar.

Aliasing variables like this may seem like a silly thing to want to do, but it turns out that the entire module export/import mechanism is built around this feature, since there's nothing that says the symbol you're aliasing has to be in your namespace.

Command input (backtick) operator
---------------------------------
First of all, we have the command input operator, also known as the backticks operator, because it looks like this:

::

	$info = `finger $user`;

A string enclosed by backticks (grave accents) first undergoes variable interpolation just like a double-quoted string. The result of that is then interpreted as a command by the shell, and the output of that command becomes the value of the pseudo-literal. (This is modeled after a similar operator in some of the UNIX shells.) In scalar context, a single string consisting of all the output is returned. In list context, a list of values is returned, one for each line of output. (You can set $/ to use a different line terminator.) The command is executed each time the pseudo-literal is evaluated. The numeric status value of the command is saved in $? (see the section "Special Variables" later in this chapter for the interpretation of $?). Unlike the csh version of this command, no translation is done on the return data - newlines remain newlines. Unlike any of the shells, single quotes do not hide variable names in the command from interpretation. To pass a $ through to the shell you need to hide it with a backslash. The $user in our example above is interpolated by Perl, not by the shell. (Because the command undergoes shell processing, see Chapter 6, Social Engineering, for security concerns.) The generalized form of backticks is qx// (for "quoted execution"), but the operator works exactly the same way as ordinary backticks. You just get to pick your quote characters.


Pattern Matching
----------------

The two main pattern matching operators are m//, the match operator, and s///, the substitution operator.  There is also a split operator, which takes an ordinary match operator as its first argument but otherwise behaves like a function, and is therefore documented in Chapter 3.  Although we write m// and s/// here, you'll recall that you can pick your own quote characters. On the other hand, for the m// operator only, the m may be omitted if the delimiters you pick are in fact slashes.  (You'll often see patterns written this way, for historical reasons.)

The matching operations can have various modifiers, some of which affect the interpretation of the regular expression inside:

========	====================================================================
Modifier	Meaning
========	====================================================================
i		Do case-insensitive pattern matching.
m		Treat string as multiple lines (^ and $ match internal \n).
s		Treat string as single line (^ and $ ignore \n, but . matches \n).
x		Extend your pattern's legibility with whitespace and comments.
o		Only compile pattern once.
g		Match globally, that is, find all occurrences.
========	====================================================================

These are usually written as "the /x modifier", even though the delimiter in question might not actually be a slash. In fact, any of these modifiers may also be embedded within the regular expression itself using the (?...) construct. 


Unary \\  creates a reference to whatever follows it (see Chapter 4). Do not confuse this behavior with the behavior of backslash within a string, although both forms do convey the notion of protecting the next thing from interpretation. This resemblance is not entirely accidental.  The \\ operator may also be used on a parenthesized list value in a list context, in which case it returns references to each element of the list.


Bare Blocks and Case Structures
-------------------------------

A BLOCK by itself (labeled or not) is semantically equivalent to a loop that executes once. Thus you can use last to leave the block or redo to restart the block.[41] Note that this is not true of the blocks in eval {}, sub {}, or do {} commands, which are not loop blocks and cannot be labeled. They can't be labeled because they're just terms in an expression. Loop control commands may only be used on true loops, just as the return command may only be used within a subroutine or eval. But you can always introduce an extra set of braces to give yourself a bare block, which counts as a loop.

For reasons that may (or may not) become clear upon reflection, a next also exits the once-through block. There is a slight difference, however, in that a next will execute a continue block, while a last won't.  The bare block is particularly nice for doing case structures (multiway switches).

::

	SWITCH: {
		if (/^abc/) { $abc = 1; last SWITCH; }
		if (/^def/) { $def = 1; last SWITCH; }
		if (/^xyz/) { $xyz = 1; last SWITCH; }
		$nothing = 1;
	}

There is no official switch statement in Perl, because there are already several ways to write the equivalent. In addition to the above, you could write: 

::

	SWITCH: {
	$abc = 1, last SWITCH if /^abc/;
	$def = 1, last SWITCH if /^def/;
	$xyz = 1, last SWITCH if /^xyz/;
	$nothing = 1;
	}

or:

::

	SWITCH: {
		/^abc/ && do { $abc = 1; last SWITCH; };
		/^def/ && do { $def = 1; last SWITCH; };
		/^xyz/ && do { $xyz = 1; last SWITCH; };
		$nothing = 1;
	}

Goto
----
Although not for the faint of heart (or the pure of heart, for that matter), Perl does support a goto command. There are three forms: goto LABEL, goto EXPR, and goto &NAME.  The goto LABEL form finds the statement labeled with LABEL and resumes execution there. It may not be used to go inside any construct that requires initialization, such as a subroutine or a foreach loop. It also can't be used to go into a construct that is optimized away. It can be used to go almost anywhere else within the current block or one you were called from, including out of subroutines, but it's usually better to use some other construct. 


Scoped Declarations
-------------------
A package declaration, oddly enough, is lexically scoped, despite the fact that a package is a global entity. But a package declaration merely declares the identity of the default package for the rest of the enclosing block. Undeclared, unqualified variable names will be looked up in that package. In a sense, a package isn't declared at all, but springs into existence when you refer to a variable that belongs in the package. It's all very Perlish.


The most frequently seen form of lexically scoped declaration is the declaration of my variables. A related form of scoping known as dynamic scoping applies to local variables, which are really global variables in disguise. If you refer to a variable that has not been declared, its visibility is global by default, and its lifetime is forever. A variable used at one point in your program is accessible from anywhere else in the program.[45] If this were all there were to the matter, Perl programs would quickly become unwieldy as they grew in size. Fortunately, you can easily create private variables using my, and semi-private values of global variables using local. A my or a local declares the listed variables (in the case of my), or the values of the listed global variables (in the case of local), to be confined to the enclosing block, subroutine, eval, or file.


A local variable is dynamically scoped, whereas a my variable is lexically scoped. The difference is that any dynamic variables are also visible to functions called from within the block in which those variables are declared. Lexical variables are not.  They are totally hidden from the outside world, including any called subroutines (even if it's the same subroutine called from itself or elsewhere - every instance of the subroutine gets its own copy of the variables).

By and large, you should prefer to use my over local because it's faster and safer. But you have to use local if you want to temporarily change the value of an existing global variable, such as any of the special variables listed at the end of this chapter. Only alphanumeric identifiers may be lexically scoped


Subroutines
-----------

To declare a subroutine, use one of these forms:

::

	sub NAME;		# A "forward" declaration.
	sub NAME (PROTO);	# Ditto, but with prototype.

To declare and define a subroutine, use one of these forms:a

::

	sub NAME BLOCK		# A declaration and a definition.
	sub NAME (PROTO) BLOCK	# Ditto, but with prototype.

To define an anonymous subroutine or closure at run-time, use a statement like:

::

	$subref = sub BLOCK;

To import subroutines defined in another package, say:

::

	use PACKAGE qw(NAME1 NAME2 NAME3...);

To call subroutines directly:

::

	NAME(LIST); # & is optional with parentheses.
	NAME LIST;  # Parens optional if predeclared/imported.
	&NAME;      # Passes current @_ to subroutine.


To call subroutines indirectly (by name or by reference):

::

	&$subref(LIST);		# & is not optional on indirect call.
	&$subref;		# Passes current @_ to subroutine.

The Perl model for passing data into and out of a subroutine is simple: all function parameters are passed as one single, flat list of scalars, and multiple return values are likewise returned to the caller as one single, flat list of scalars.

As with any LIST, any arrays or hashes passed in these lists will interpolate their values into the flattened list, losing their identities - but there are several ways to get around this, and the automatic list interpolation is frequently quite useful.

If you call a function with two arguments, those would be stored in $_[0] and $_[1]. Since @_ is an array, you can use any array operations you like on the parameter list. (This is an area where Perl is more orthogonal than the typical computer language.) The array @_ is a local array, but its values are implicit references to the actual scalar parameters. Thus you can modify the actual parameters if you modify the corresponding element of @_.

The elements of the parameter list are aliases for the scalars provided as arguments. An alias is an alternative way to refer to a variable. In other words, @_ can be used to access and modify variables that are used as arguments.

For example, swap takes two parameters and swaps their values:

::

	sub swap {
		($_[0], $_[1]) = ($_[1], $_[0]);
	}

When a list appears as an argument, it is “flattened”; that is; the elements of the list are added to the parameter list. So the following code does not swap two lists:


The return value of the subroutine (or of any other block, for that matter) is the value of the last expression evaluated. Or you may use an explicit return statement to specify the return value and exit the subroutine from any point in the subroutine. Either way, as the subroutine is called in a scalar or list context, so also is the final expression of the routine evaluated in the same scalar or list context.

Do not, however, be tempted to do this:

::

	(@a, @b) = upcase(@list1, @list2);	# WRONG

Why not? Because, like the flat incoming parameter list, the return list is also flat. So all you have managed to do here is store everything in @a and make @b an empty list.


The official name of a subroutine includes the & prefix. A subroutine may be called using the prefix, but the & is usually optional, and so are the parentheses if the subroutine has been predeclared. (Note, however, that the & is not optional when you're just naming the subroutine, such as when it's used as an argument to defined or undef, or when you want to generate a reference to a named subroutine by saying $subref = \&name. Nor is the & optional when you want to do an indirect subroutine call with a subroutine name or reference using the &$subref() or &{$subref}()

==================
Passing References
==================

If you can arrange for the function to receive references as its parameters and return them as its return results, it's cleaner code, although not so nice to look at. Here's a function that takes two array references as arguments, returning the two array references ordered according to how many elements they have in them:

::

	($aref, $bref) = func(\@c, \@d);
	print "@$aref has more than @$bref\n";
	sub func {
		my ($cref, $dref) = @_;
		if (@$cref > @$dref) {
			return ($cref, $dref);
		} else {
			return ($dref, $cref);
		}
	}

==========
Prototypes
==========

Declared as Called as

::

	sub mylink ($$) mylink $old, $new
	sub myvec ($$$) myvec $var, $offset, 1
	sub myindex ($$;$) myindex &getstring, "substr"
	sub mysyswrite ($$$;$) mysyswrite $buf, 0, length($buf) - $off, $off
	sub myreverse (@) myreverse $a,$b,$c
	sub myjoin ($@) myjoin ":",$a,$b,$c
	sub mypop (\@) mypop @array
	sub mysplice (\@$$@) mysplice @array,@array,0,@pushme
	sub mykeys (\%) mykeys %{$hashref}
	sub myopen (*;$) myopen HANDLE, $name
	sub mypipe (**) mypipe READHANDLE, WRITEHANDLE
	sub mygrep (&@) mygrep { /foo/ } $a,$b,$c
	sub myrand ($) myrand 42
	sub mytime () mytime


References and Nested Data Structures
-------------------------------------

Suppose you wanted to build a simple table (two-dimensional array) showing vital statistics - say, age, eye color, and weight - for a group of people. You could do this by first creating an array for each individual:

::

	@john = (47, "brown", 186);
	@mary = (23, "hazel", 128);
	@bill = (35, "blue", 157);

and then constructing a single, additional array consisting of the names of the other arrays:

::

	@vitals = ('john', 'mary', 'bill');

Unfortunately, actually using this table as a two-dimensional data structure is cumbersome. To change John's eyes to "red" after a night on the town, you'd have to say something like:

::

	$vitals = $vitals[0];
	eval "\$${vitals}[1] = 'red'";

========================
Creating Hard References
========================

**The Backslash Operator**

You can create a reference to any named variable or subroutine by using the unary backslash operator.  (You may also use it on an anonymous scalar value.) This works much like the & (address-of) operator in C.

Here are some examples:

::

	$scalarref = \$foo;
	$constref = \186_282.42;
	$arrayref = \@ARGV;
	$hashref = \%ENV;
	$code_ref = \&handler;
	$globref = \*STDOUT;

============================
The Anonymous Array Composer
============================

You can create a reference to an anonymous array by using brackets:

::

	$arrayref = [1, 2, ['a', 'b', 'c']];

Note that taking a reference to an enumerated list is not the same as using brackets - instead it's treated as a shorthand for creating a list of references:

::

	@list = (\$a, \$b, \$c);
	@list = \($a, $b, $c);		# same thing!

===========================
The Anonymous Hash Composer
===========================

You can create a reference to an anonymous hash by using braces:

::

	$hashref = {
		'Adam' => 'Eve',
		'Clyde' => 'Bonnie',
	};

=================================
The Anonymous Subroutine Composer
=================================

You can create a reference to an anonymous subroutine by using sub without a subroutine name:

::

	$coderef = sub { print "Boink!\n" };

Note the presence of the semicolon, which is required here to terminate the expression. (It wouldn't be required after the declaration of a named subroutine.) A nameless sub {} is not so much a declaration as it is an operator - like do {} or eval {} - except that the code inside isn't executed immediately.  Instead, it just generates a reference to the code and returns that.

======================
Filehandle Referencers
======================

References to filehandles can be created by taking a reference to a typeglob. This is currently the best way to pass named filehandles into or out of subroutines, or to store them in larger data structures

::

	splutter(\*STDOUT);
	sub splutter {
		my $fh = shift;
		print $fh "her um well a hmmm\n";
	}
	$rec = get_rec(\*STDIN);
	sub get_rec {
		my $fh = shift;
		return scalar <$fh>;
	}

===================================
Using a Variable as a Variable Name
===================================

Anywhere you might ordinarily put an alphanumeric identifier as part of a variable or subroutine name, you can just replace the identifier with a simple scalar variable containing a reference of the correct type.

For example:

::

	$foo = "two humps";
	$scalarref = \$foo;
	$camel_model = $$scalarref; # $camel_model is now "two humps"

Here are various dereferences:

::

	$bar = $$scalarref;
	push(@$arrayref, $filename);
	$$arrayref[0] = "January";
	$$hashref{"KEY"} = "VALUE";
	&$coderef(1,2,3);
	$bar = ${$scalarref};
	push(@{$arrayref}, $filename);
	${$arrayref}[0] = "January";
	${$hashref}{"KEY"} = "VALUE";
	&{$coderef}(1,2,3);

It's important to understand that we are specifically not dereferencing $arrayref[0] or $hashref{"KEY"} there. The dereferencing of the scalar variable happens before any array or hash lookups.

Therefore, the following prints "howdy":

::

	$refrefref = \\\"howdy";
	print $$$$refrefref;

You can think of the dollar signs as executing right to left.

Admittedly, it's silly to use the braces in these simple cases, but the BLOCK can contain any arbitrary expression. In particular, it can contain subscripted expressions. In the following example, $dispatch{$index} is assumed to contain a reference to a subroutine. The example invokes the subroutine with three arguments.

::

	&{ $dispatch{$index} }(1, 2, 3);

::

	$ $arrayref [0] = "January";
	${ $arrayref }[0] = "January";
	$arrayref->[0] = "January";
	$ $hashref {KEY} = "F#major";
	${ $hashref }{KEY} = "F#major";
	$hashref->{KEY} = "F#major";

	print $array[3]->{"English"}->[0];

One more shortcut here. The arrow is optional between brace- or bracket-enclosed subscripts, so you can shrink the above code down to:

::

	$array[3]{"English"}[0] = "January";

Which, in the case of ordinary arrays, gives you multi-dimensional arrays just like C's arrays:

::

	$answer[$x][$y][$z] += 42;

===================
Symbolic References
===================

What happens if you try to dereference a value that is not a hard reference? The value is then treated as a symbolic reference. That is, the reference (which still has a scalar value) is interpreted as a string. That string is taken to be the name of a variable, rather than a direct link to a (possibly anonymous) thingy.  Here is how it works:

::

	$name = "bam";            # Sets $bam
	$$name = 1;               # Sets $bam
	${$name} = 2;             # Sets $bambam
	${$name x 2} = 3;         # Sets $bam[0]
	$name->[0] = 4;           # Clears @bam
	@$name = ();              # Calls &bam() (as in prior versions of Perl)
	&$name();                 # (Don't use "package" or "pack"!)
	$pkg = "THAT";            # Sets $THAT::bam without eval
	${"${$pkg}::$name"} = 5;


This is very powerful, and slightly dangerous, in that it's possible to intend (with the utmost sincerity) to use a hard reference, and accidentally use a symbolic reference instead. To protect against that, you can say:

::

	use strict 'refs';

and then only hard references will be allowed for the rest of the enclosing block. An inner block may countermand that decree with:

::

	no strict 'refs';


::

	${identifier}; # same as $identifier
	${"identifier"}; # also $identifier, but treated as symbolic reference

=======================================
Hard References Don't Work as Hash Keys
=======================================

Consistent with the foregoing, hash keys are stored internally as strings.[7] If you try to store a hard reference as a key in a hash, the key value will be converted into a string:

::

	$x{ \$a } = $a;
	($key, $value) = each %x;
	print $$key; # WRONG

======================
Composition and Access
======================

Here's how to put together a two-dimensional array value:

::

	# assign to an array a list of list references
	@LoL = (
		[ "fred", "barney" ],
		[ "george", "jane", "elroy" ],
		[ "homer", "marge", "bart" ],
	);
	print $LoL[2][2];	# prints "bart"

The overall list is enclosed by parentheses, not brackets. That's because you're assigning a list to an array.  If you didn't want the result to be a list, but rather a reference to an array, then you would use brackets on the outside:

::

	# assign to a scalar variable a reference to a list of list references
	$ref_to_LoL = [
		[ "fred", "barney", "pebbles", "bambam", "dino", ],
		[ "homer", "bart", "marge", "maggie", ],
		[ "george", "jane", "elroy", "judy", ],
	];
	print $ref_to_LoL->[2][2];	# prints "elroy"

**$ref_to_LoL is a reference to an array, whereas @LoL is an array proper**.


Packages
--------

Like the notion of "home", the notion of "package" is a bit nebulous. Packages are independent of files.  You can have many packages in a single file, or a single package that spans several files, just as your home could be one part of a larger building, if you live in an apartment, or could comprise several buildings, if your name happens to be Queen Elizabeth. But the usual size of a home is one building, and the usual size of a package is one file.

Perl has some special help for people who want to put one package in one file, as long as you're willing to name the file with the same name as the package and give your file an extension of ".pm", which is short for "perl module".

**package main** : The initial current package is **package main**, but at any time you can switch the current package to another one using the package declaration.

**symbol table** : The current package determines which symbol table is used for name lookups (for names that aren't otherwise package-qualified). The notion of "current package" is both a compile-time and run-time concept.

**Scope** : The scope of a package declaration is from the declaration itself through the end of the innermost enclosing block (or until another package declaration at the same level, which hides the earlier one).

**qualifying** : You can refer to identifiers in other packages by prefixing ("qualifying") the identifier with the package name and a double colon: $Package::Variable. 

If the package name is null, the main package is assumed.

**Nested Packages** : Packages may be nested inside other packages: $OUTER::INNER::var. This implies nothing about the order of name lookups, however. There are no fallback symbol tables. All undeclared symbols are either local to the current package, or must be fully qualified from the outer package name down. For instance, there is nowhere within package OUTER that $INNER::var refers to $OUTER::INNER::var


Only identifiers (names starting with letters or underscore) are stored in the current package's symbol table. All other symbols are kept in package main, including all the magical punctuation-only variables like $! and $_. In addition, the identifiers STDIN, STDOUT, STDERR, ARGV, ARGVOUT, ENV, INC, and SIG are forced to be in package main even when used for purposes other than their built-in ones.

**package**
	A package is a simple namespace management device, allowing two different parts of a Perl
	program to have a (different) variable named $fred. These namespaces are managed with the
	package declaration, described in Chapter 5, Packages, Modules, and Object Classes.
	library

**library**
	A library is a set of subroutines for a particular purpose. Often the library declares itself a separate
	package so that related variables and subroutines can be kept together, and so that they won't
	interfere with other variables in your program. Generally, a library is placed in a separate file,
	often ending in ".pl", and then pulled into the main program via require. (This mechanism has
	largely been superseded by the module mechanism, so nowadays we often use the term "library" to
	talk about the whole system of modules that come with Perl. See the title of this chapter, for
	instance.)

**module**
	A module is a library that conforms to specific conventions, allowing the file to be brought in with
	a use directive at compile time. Module filenames end in ".pm", because the use directive insists
	on that. (It also translates the subpackage delimiter :: to whatever your subdirectory delimiter is;
	it is / on UNIX.) Chapter 5 describes Perl modules in greater detail.

**pragma**
	A pragma is a module that affects the compilation phase of your program as well as the execution
	phase. Think of them as hints to the compiler. Unlike modules, pragmas often (but not always)
	limit the scope of their effects to the innermost enclosing block of your program. The names of
	pragmas are by convention all lowercase.

=============
Symbol Tables
=============

The symbol table for a package happens to be stored in a hash whose name is the same as the package name with two colons appended. Likewise, the symbol table for the nested package we mentioned earlier is named %OUTER::INNER::. As it happens, the main symbol table contains all other top-level symbol tables, including itself, so %OUTER::INNER:: is also %main::OUTER::INNER::.

Since package main is a top-level package, it contains a reference to itself, with the result that %main:: is the same as %main::main::, and **%main::main::main::**, and so on, ad infinitum. It's important to check for this special case if you write code to traverse all symbol tables.

The keys in a symbol table hash are the identifiers of the symbols in the symbol table. The values in a symbol table hash are the corresponding typeglob values. So when you use the \*name typeglob notation, you're really just accessing a value in the hash that holds the current package's symbol table. 

following have the same effect, although the first is potentially more efficient because it does the symbol table lookup at compile time:

::

	local *somesym = *main::variable;
	local *somesym = $main::{"variable"};

Since a package is a hash, you can look up the keys of the package, and hence all the variables of the package. Try this:

::

	foreach $symname (sort keys %main::) {
		local *sym = $main::{$symname};
		print "\$$symname is defined\n" if defined $sym;
		print "\@$symname is defined\n" if defined @sym;
		print "\%$symname is defined\n" if defined %sym;
	}

===================================================
Package Constructors and Destructors: BEGIN and END
===================================================

Two special subroutine definitions that function as package constructors and destructors are the BEGIN and END routines. The sub is optional for these routines

A **BEGIN** subroutine is executed as soon as possible, that is, the moment it is completely defined, even before the rest of the containing file is parsed. You may have multiple BEGIN blocks within a file - they will execute in order of definition. Because a BEGIN block executes immediately, it can pull in definitions of subroutines and such from other files in time to be visible during compilation of the rest of the file.

An **END** subroutine, by contrast, is executed as late as possible, that is, when the interpreter is being exited, even if it is exiting as a result of a die function, or from an internally generated exception such as you'd get when you try to call an undefined function. 

You may have multiple END blocks within a file -
	they will execute in reverse order of definition; that is: last in, first out (LIFO). 

Just as eval provides a way to get compilation behavior during run-time, so too BEGIN provides a way to get run-time behavior during compilation. But note that the compiler must execute BEGIN blocks even if you're just checking syntax with the -c switch. By symmetry, END blocks are also executed when syntax checking. Your END blocks should not assume that any or all of your main code ran

=======
Modules
=======

A module is just a reusable package that is defined in a library file whose name is the same as the name of the package (with a .pm on the end). A module may provide a mechanism for exporting some of its symbols into the symbol table of any other package using it.

Most exporter modules rely on the customary exportation semantics supplied by the Exporter module. For example, to create an exporting module called Fred, create a file called Fred.pm and put this at the start of it:

::

	package Fred;
	require Exporter;
	@ISA = qw(Exporter);
	@EXPORT = qw(func1 func2);
	@EXPORT_OK = qw($sally @listabob %harry func3);

Perl modules are included in your program by saying:

::

	use Module;
	
or:

::

	use Module LIST;

This preloads Module at compile time, and then imports from it the symbols you've requested, either implicitly or explicitly. If you do not supply a list of symbols in a LIST, then the list from the module's @EXPORT array is used. (And if you do supply a LIST, all your symbols should be mentioned in either @EXPORT or @EXPORT_OK, or an error will result.) The two declarations above are exactly equivalent to:

::

	BEGIN {
	require "Module.pm";
	Module->import();
	}

or:

::

	BEGIN {
	require "Module.pm";
	Module->import(LIST);
	}

The **use** declaration (in any form) implies a BEGIN block, the module is loaded (and any executable initialization code in it run) as soon as the use declaration is compiled, before the rest of the file is compiled. This is how use is able to function as a pragma mechanism to change the compiler's behavior, and also how modules are able to declare subroutines that are then visible as (unqualified) list operators for the rest of the current file. If, on the other hand, you invoke require instead of use, you must explicitly qualify any invocation of routines within the required package.

::

	require Cwd;
	# make Cwd:: accessible with qualification
	$here = Cwd::getcwd();

	use Cwd;
	# import names from Cwd:: -- no qualification necessary
	$here = getcwd();

In general, use is recommended over require because you get your error messages sooner. But require is useful for pulling in modules lazily at run-time.


if a module's name is, say, Text::Soundex, then its definition is actually found in the library file Text/Soundex.pm (or whatever the equivalent pathname is on your system).

==============
Perl's Objects
==============

Here are three simple definitions that you may find reassuring:
- An object is simply a referenced thingy that happens to know which class it belongs to.
- A class is simply a package that happens to provide methods to deal with objects.
- A method is simply a subroutine that expects an object reference (or a package name, for class methods) as its first argument.  We'll cover these points in more depth now.

===========
Constructor
===========

A constructor is merely a subroutine that returns a reference to a thingy that it has blessed into a class, generally the class in which the subroutine is defined. The constructor does this using the built-in bless function, which marks a thingy as belonging to a particular class.

::

	sub new {
		my $obref = {};		# ref to empty hash
		bless $obref;		# make it an object in this class
		return $obref;		# return it
	}

If you want your constructor method to be (usefully) inheritable, then you must use the two-argument form of bless.

The keys of the hash are the **instance variables** of the object. So, the simplest way to create an object is to create a reference to a hash.

::

	my $nobody = { };
	my $person = { 
			name => "Allen B. Downey",
			webpage => "allendowney.com" 
		};
	bless $person, "Person";

	sub name {
		my $self = shift;
		return $self->{name};
	}
	
In Perl, methods execute in the context of the original base class rather than in the context of the derived class. For example, suppose you have a Polygon class that had a new() method as a constructor. This would work fine when called as Polygon->new(). But then you decide to also have a Square class, which inherits methods from the Polygon class. The only way for that constructor to build an object of the proper class when it is called as Square->new() is by using the two-argument form of bless, as in the following example:

::

	sub new {
		my $class = shift;
		my $self = {};
		bless $self, $class;
		$self->_initialize();
		return $self;
	}

A constructor may re-bless a referenced object currently belonging to another class, but then the new class is responsible for all cleanup later. The previous blessing is forgotten, as an object may only belong to one class at a time.


Perl objects are blessed. References are not. Thingies know which package they belong to.  References do not. 

The bless operator simply uses the reference in order to find the thingy. Consider the following example:

::

	$a = {};	# generate reference to hash
	$b = $a;	# reference assignment (shallow)
	bless $b, Mountain;
	bless $a, Fourteener;
	print "\$b is a ", ref($b), "\n";

This reports $b as being a member of class Fourteener, not a member of class Mountain, because the second blessing operates on the underlying thingy that $a refers to, not on the reference itself. Thus is the first blessing forgotten.

===========================
A Class Is Simply a Package
===========================

Perl doesn't provide any special syntax for class definitions. You just use a package as a class by putting method definitions into the class.

Within each package a special array called **@ISA** tells Perl where else to look for a method if it can't find the method in that package. This is how Perl implements inheritance. Each element of the @ISA array is just the name of another package that happens to be used as a class.

The packages are recursively searched (depth first) for missing methods, in the order that packages are mentioned in @ISA. This means that if you have two different packages (say, Mom and Dad) in a class's @ISA, Perl would first look for missing methods in Mom and all of her ancestor classes before going on to search through Dad and his ancestors. Classes accessible through @ISA are known as base classes of the current class, which is itself called the derived class.

If a method isn't found but an **AUTOLOAD** routine is found, then that routine is called on behalf of the missing method, with that package's $AUTOLOAD variable set to the fully qualified method name.

Perl classes do only method inheritance. Data inheritance is left up to the class itself. By and large, this is not a problem in Perl, because most classes model the attributes of their object using an anonymous hash.  All the object's data fields (termed "instance variables" in some languages) are contained within this anonymous hash instead of being part of the language itself

=============
Class methods
=============

A class method expects a class (package) name as its first argument. (The class name isn't blessed; it's just a string.) These methods provide functionality for the class as a whole, not for any individual object instance belonging to the class. Constructors are typically written as class methods. Many class methods simply ignore their first argument, since they already know what package they're in, and don't care what package they were invoked via.

=======================
Instance/object methods
=======================

An instance method expects an object reference[11] as its first argument. Typically it shifts the first argument into a private variable (often called $self or $this depending on the cultural biases of the programmer), and then it uses the variable as an ordinary reference:

Despite being counterintuitive to object-oriented novices, it's a good idea not to check the type of object that caused the instance method to be invoked. If you do, it can get in the way of inheritance.

===================
Dual-nature methods
===================

Because there is no language-defined distinction between definitions of class methods and instance methods (nor arbitrary functions, for that matter), you could actually have the same method work for both purposes. It just has to check whether it was passed a reference or not.

Here's an example of the two uses of such a method:

::

	$ob1 = StarKnight->new();
	$luke = $ob1->new();

	package StarKnight;
	sub new {
		my $self = shift;
		my $type = ref($self) || $self;
		return bless {}, $type;
	}

=================
Method Invocation
=================

Perl supports two different syntactic forms for explicitly invoking class or instance methods. Unlike normal function calls, method calls always receive, as their first parameter, the appropriate class name or object reference upon which they were invoked.

The first syntax form looks like this:

::

	METHOD CLASS_OR_INSTANCE LIST
	$fred = find Critter "Fred";
	display $fred 'Height', 'Weight';

The second syntax form looks like this:

::

	CLASS_OR_INSTANCE->METHOD(LIST)
	$fred = Critter->find("Fred");
	$fred->display('Height', 'Weight');

There may be occasions when you need to specify which class's method to use. In that case, you could call your method as an ordinary subroutine call, being sure to pass the requisite first argument explicitly:

::

	$fred = MyCritter::find("Critter", "Fred");
	MyCritter::display($fred, 'Height', 'Weight');

However, this does not do any inheritance. If you merely want to specify that Perl should start looking for a method in a particular package, use an ordinary method call, but qualify the method name with the package like this:

::

	$fred = Critter->MyCritter::find("Fred");
	$fred->MyCritter::display('Height', 'Weight');


If you're trying to control where the method search begins and you're executing in the class package itself, then you may use the SUPER pseudoclass, which says to start looking in your base class's @ISA list without having to explicitly name it:

::

	$self->SUPER::display('Height', 'Weight');

The **SUPER** construct is meaningful only when used inside the class methods; while writers of class modules can employ SUPER in their own code, people who merely use class objects cannot.

===========
Destructors
===========

If you want to capture control just before the object is freed, you may define a DESTROY method in your class. It will automatically be called at the appropriate moment, and you can do any extra cleanup you desire.

====================
Using Tied Variables
====================

In older versions of Perl, a user could call dbmopen to tie a hash to a UNIX DBM file. Whenever the hash was accessed, the database file on disk (really just a hash, not a full relational database) would be magically read from or written to. In modern versions of Perl, you can bind any ordinary variable (scalar, array, or hash) to an implementation class by using tie. (The class may or may not implement a DBM file.) You can break this association with untie.

==================
Instance Variables
==================

An anonymous array or anonymous hash can be used to hold instance variables. (The hashes fare better in the face of inheritance.) We'll also show you some nice interactions with named parameters.

::

	package HashInstance;
	sub new {
		my $type = shift;
		my %params = @_;
		my $self = {};
		$self->{High} = $params{High};
		$self->{Low} = $params{Low};
		return bless $self, $type;
	}

	package ArrayInstance;
	sub new {
		my $type   = shift;
		my %params = @_;
		my $self   = [];
		$self->[0] = $params{Left};
		$self->[1] = $params{Right};
		return bless $self, $type;
	}
	package main;

	$a = HashInstance->new( High => 42, Low => 11 );
	print "High=$a->{High}\n";
	print "Low=$a->{Low}\n";
	$b = ArrayInstance->new( Left => 78, Right => 40 );
	print "Left=$b->[0]\n";
	print "Right=$b->[1]\n";

This demonstrates how object references act like ordinary references if you use them like ordinary references, as you often do within the class definitions.

-------------------------
Scalar Instance Variables
-------------------------

An anonymous scalar can be used when only one instance variable is needed.

::

	package ScalarInstance;
	sub new {
		my $type = shift;
		my $self;
		$self = shift;
		return bless \$self, $type;
	}

-----------------------------
Instance Variable Inheritance
-----------------------------

Note that you're pretty much forced to use a hash if you want to do inheritance, since you can't have a reference to multiple types at the same time. A hash allows you to extend your object's little namespace in arbitrary directions, unlike an array, which can only be extended at the end. So, for example, your base class might use the first five elements of your array, but the various derived classes might start fighting over who owns the sixth element. So use a hash instead, like this:

::

	package Base;
	sub new {
		my $type = shift;
		my $self = {};
		$self->{buz} = 42;
		return bless $self, $type;
	}

	package Derived;
	@ISA = qw( Base );
	sub new {
		my $type = shift;
		my $self = Base->new;
		$self->{biz} = 11;
		return bless $self, $type;
	}

	package main;
	$a = Derived->new;
	print "buz = ", $a->{buz}, "\n";
	print "biz = ", $a->{biz}, "\n";

======================================
Containment (the "Has-a" Relationship)
======================================

The following demonstrates how one might implement the "contains" relationship between objects. This is closely related to the "uses" relationship we show later.

::

	package Inner;
	sub new {
		my $type = shift;
		my $self = {};
		$self->{buz} = 42;
		return bless $self, $type;
	}

	package Outer;
	sub new {
		my $type = shift;
		my $self = {};
		$self->{Inner} = Inner->new;
		$self->{biz} = 11;
		return bless $self, $type;
	}

	package main;
	$a = Outer->new;
	print "buz = ", $a->{Inner}->{buz}, "\n";
	print "biz = ", $a->{biz}, "\n";


=============================
Overriding Base Class Methods
=============================

::

	package Buz;
	sub goo { print "here's the goo\n" }

	package Bar;
	@ISA = qw( Buz );
	sub google { print "google here\n" }a

	package Baz;
	sub mumble { print "mumbling\n" }

	package Foo;
	@ISA = qw( Bar Baz );
	sub new {
		my $type = shift;
		return bless [], $type;
	}
	sub grr { print "grumble\n" }
	sub goo {
		my $self = shift;
		$self->SUPER::goo();
	}
	sub mumble {
		my $self = shift;
		$self->SUPER::mumble();
	}
	sub google {
		my $self = shift;
		$self->SUPER::google();
	}

========================
Inheriting a Constructor
========================

An inheritable constructor should use the two-argument form of bless, which allows blessing directly into a specified class. Notice in this example that the object will be a BAR not a FOO, even though the constructor is in class FOO.

::

	package FOO;
	sub new {
		my $type = shift;
		my $self = {};
		return bless $self, $type;
	}
	sub baz {
		print "in FOO::baz()\n";
	}

	package BAR;
	@ISA = qw(FOO);
	sub baz {
		print "in BAR::baz()\n";
	}

	package main;
	$a = BAR->new;
	$a->baz;

Signals
-------

The **%SIG** hash contains references (either symbolic or hard) to user-defined signal handlers. When an event transpires, the handler corresponding to that event is called with one argument containing the name of the signal that triggered it.

For example, to unpack an interrupt signal, set up a handler like this:

::

	sub catch_zap {
	my $signame = shift;
		$shucks++;
		die "Somebody sent me a SIG$signame!";
	}
	$SIG{INT} = 'catch_zap'; # could fail outside of package main
	$SIG{INT} = \&catch_zap; # best strategy


We try to avoid anything more complicated than that, because on most systems the C library is not re-entrant. Signals are delivered asynchronously, so calling any print functions (or even anything that needs to malloc(3) more memory) could in theory trigger a memory fault and subsequent core dump if you were already in a related C library routine when the signal was delivered.  (Even the die routine is a bit unsafe unless the process is executing within an eval, which suppresses the I/O from die, which keeps it from calling the C library. Probably.)

You may also choose to assign either of the strings 'IGNORE' or 'DEFAULT' as the handler, in which case Perl will try to discard the signal or do the default thing.


You can temporarily ignore other signals by using a local signal handler assignment, which goes out of effect once your block is exited. (Remember, though, that local values are inherited by functions called from within that block.)

::

	sub precious {
		local $SIG{INT} = 'IGNORE';
		&more_functions;
	}


Anonymous pipes
---------------

Perl's open function opens a pipe instead of a file when you append or prepend a pipe symbol to the second argument to open. This turns the rest of the argument into a command, which will be interpreted as a process (or set of processes) to pipe a stream of data either into or out of. Here's how to start up a child process that you intend to write to:

::

	open SPOOLER, "| cat -v | lpr -h 2>/dev/null" or die "can't fork: $!";
	local $SIG{PIPE} = sub { die "spooler pipe broke" };
	print SPOOLER "stuff\n";
	close SPOOLER or die "bad spool: $! $?";

And here's how to start up a child process that you intend to read from:

::

	open STATUS, "netstat -an 2>&1 \|" or die "can't fork: $!";
	while (<STATUS>) {
		next if /^(tcp|udp)/;
		print;
	}
	close STATUS or die "bad netstat: $! $?"


You might have noticed that you can use backticks to accomplish the same effect as opening a pipe for reading:

::

	print grep { !/^(tcp|udp)/ } `netstat -an 2>&1`;
	die "bad netstat" if $?;

Be careful to check the return values of both open and close. (If you're writing to a pipe, you should also be prepared to handle the PIPE signal, which is sent to you if the process on the other end dies before you're done sending to it.) The reason you need to check both the open and the close has to do with an idiosyncrasy of UNIX in how piped commands are started up. When you do the open, your process forks a child process that is in charge of executing the command you gave it. The fork(2) system call, if successful, returns immediately within the parent process, and the parent script leaves the open function successfully, even though the child process may not have even run yet. By the time the child process actually tries to run the command, it's already a separately scheduled process. So if it fails to execute the command, it has no easy way to communicate the fact back to the open statement, which may have already exited successfully in the parent. The way the disaster is finally communicated back to the parent is the same way that any other disaster in the child process is communicated back: namely, the exit status of the child process is harvested by the parent process when it eventually does a wait(2) system call. But this happens in the close function, not the open function. And that's why you have to check the return value of your close function. Whew.

===================
Talking to yourself
===================

To represent this to the open function, you use a pseudo-command consisting of a minus. So the second argument to open looks like either "-|" or "\|-"

The open function returns the child's process ID in the parent process, but 0 in the child process. Another asymmetry is that the filehandle is used only in the parent process. 

This is useful for safely opening a file when running under an assumed UID or GID, for example:

::

	use English;

	my $sleep_count = 0;
	do {
		$pid = open(KID_TO_WRITE, "|-");
		unless (defined $pid) {
			warn "cannot fork: $!";
			die "bailing out" if $sleep_count++ > 6;
			sleep 10;
		}
	} until defined $pid;

	if ($pid) { # parent
		print KID_TO_WRITE @some_data;
		close(KID_TO_WRITE) or warn "kid exited $?";
	}
	else {
		# child
		($EUID, $EGID) = ($UID, $GID); # suid progs only
		open (FILE, "> /safe/file")
		or die "can't open /safe/file: $!";
		while (<STDIN>) {
			print FILE; # child's STDIN is parent's KID
		}
		exit; # don't forget this
	}

===========================
Bidirectional communication
===========================

While pipes work reasonably well for unidirectional communication, what about bidirectional communication? The obvious thing you'd like to do doesn't actually work: 

::

	open(PROG_FOR_READING_AND_WRITING, "| some program |") # WRONG!

and if you forget to use the **-w** switch, then you'll miss out entirely on the diagnostic message: Can't do bidirectional pipe at myprog line 3.  The open function won't allow this because it's rather error prone unless you know what you're doing, and can easily result in deadlock, which we'll explain later. But if you really want to do it, you can


Other Topics
------------
For Other advanced topics like **IPC, C/C++/Other-languages interaction, efficiency, debugging** refer to the book.





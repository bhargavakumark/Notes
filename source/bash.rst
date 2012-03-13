Bash
====

.. contents::

References
----------
Advanced Bash Scripting Guide
	http://tldp.org/LDP/abs/html/index.html

Watch Outs
----------

::

	[ 1 -eq 1 ] && [ -n "`echo true 1>&2`" ]   # true
	[ 1 -eq 2 ] && [ -n "`echo true 1>&2`" ]   # (no output)
	# ^^^^^^^ False condition. So far, everything as expected.

	# However ...
	[ 1 -eq 2 -a -n "`echo true 1>&2`" ]       # true
	# ^^^^^^^ False condition. So, why "true" output?

	# Is it because both condition clauses within brackets evaluate?
	[[ 1 -eq 2 && -n "`echo true 1>&2`" ]]     # (no output)
	# No, that's not it.

	# Apparently && and || "short-circuit" while -a and -o do not.

sha-bang
--------
The sha-bang ( #!) at the head of a script tells your system that this file is a set of commands to be fed to the command interpreter indicated. The #! is actually a two-byte [2] magic number , a special marker that designates a file type, or in this case an executable shell script (type man magic for more details on this fascinating topic). Immediately following the sha-bang is a path name. This is the path to the program that interprets the commands in the script, whether it be a shell, a programming language, or a utility. 

Conditional Statements
----------------------

::
	
	# Far more efficient is:
	#
	cd /var/log || {
	  echo "Cannot change to necessary directory." >&2
	  exit $E_XCD;
	}

: null command
--------------

null command [colon]. This is the shell equivalent of a "NOP" (no op, a do-nothing operation). It may be considered a synonym for the shell builtin true. The ":" command is itself a Bash builtin, and its exit status is true (0).

::

	while :
	do

::

	if condition
	then :   # Do nothing and branch ahead
	else     # Or else ...
	   take-some-action
	fi

::

	: ${username=`whoami`}
	# ${username=`whoami`}   Gives an error without the leading :
	#                        unless "username" is a command or builtin...

	: ${1?"Usage: $0 ARGUMENT"}     # From "usage-message.sh example script.

Evaluate string of variables using parameter substitution (as in Example 10-7).

::

	: ${HOSTNAME?} ${USER?} ${MAIL?}
	#  Prints error message
	#+ if one or more of essential environmental variables not set.

Variable expansion / substring replacement.

In combination with the > redirection operator, truncates a file to zero length, without changing its permissions. If the file did not previously exist, creates it.

::

	: > data.xxx   # File "data.xxx" now empty.	      

	# Same effect as   cat /dev/null >data.xxx
	# However, this does not fork a new process, since ":" is a builtin.


? operator
----------

test operator. Within certain expressions, the ? indicates a test for a condition.
  
In a double-parentheses construct, the ? can serve as an element of a C-style trinary operator.

**condition?result-if-true:result-if-false**

::

	(( var0 = var1<98?9:21 ))
	#                ^ ^

	# if [ "$var1" -lt 98 ]
	# then
	#   var0=9
	# else
	#   var0=21
	# fi

() command group
----------------

::

	(a=hello; echo $a)

A listing of commands within parentheses starts a subshell.

Variables inside parentheses, within the subshell, are not visible to the rest of the script. The parent process, the script, cannot read variables created in the child process, the subshell.

::

	a=123
	( a=321; )	      

	echo "a = $a"   # a = 123
	# "a" within parentheses acts like a local variable.

array initialization.

::

	Array=(element1 element2 element3)

{} brace expansion
------------------

::

	echo \"{These,words,are,quoted}\"   # " prefix and suffix
	# "These" "words" "are" "quoted"


	cat {file1,file2,file3} > combined_file
	# Concatenates the files file1, file2, and file3 into combined_file.

	cp file22.{txt,backup}
	# Copies "file22.txt" to "file22.backup"

A command may act upon a comma-separated list of file specs within braces. [4] Filename expansion (globbing) applies to the file specs between the braces.

No spaces allowed within the braces unless the spaces are quoted or escaped.

::

	echo {file1,file2}\ :{\ A," B",' C'}

	file1 : A file1 : B file1 : C file2 : A file2 : B file2 : C

{a..z} Extended Brace expansion.

::

	echo {a..z} # a b c d e f g h i j k l m n o p q r s t u v w x y z
	# Echoes characters between a and z.

	echo {0..3} # 0 1 2 3
	# Echoes characters between 0 and 3.


	base64_charset=( {A..Z} {a..z} {0..9} + / = )
	# Initializing an array, using extended brace expansion.
	# From vladz's "base64.sh" example script.

<, > ASCII comparison
---------------------

::

    veg1=carrots
    veg2=tomatoes

    if [[ "$veg1" < "$veg2" ]]
    then
      echo "Although $veg1 precede $veg2 in the dictionary,"
      echo -n "this does not necessarily imply anything "
      echo "about my culinary preferences."
    else
      echo "What kind of dictionary are you using, anyhow?"
    fi


String Manuipulation
--------------------

=============
String Length
=============

::
	${#string}

===================================================
Length of Matching Substring at Beginning of String
===================================================
expr match "$string" '$substring'	# $substring is a regular expression.

Or

expr "$string" : '$substring'		# $substring is a regular expression.

::

	stringZ=abcABC123ABCabc
	#       |------|
	#       12345678

	echo `expr match "$stringZ" 'abc[A-Z]*.2'`   # 8
	echo `expr "$stringZ" : 'abc[A-Z]*.2'`       # 8

=====
Index
=====
expr index $string $substring

Numerical position in $string of first character in $substring that matches.

::

        stringZ=abcABC123ABCabc
	#       123456 ...
	echo `expr index "$stringZ" C12`             # 6
	# C position.

	echo `expr index "$stringZ" 1c`              # 3
	# 'c' (in #3 position) matches before '1'.

This is the near equivalent of strchr() in C.

====================
Substring Extraction
====================
${string:position} :  Extracts substring from $string at $position.  If the $string parameter is "*" or "@", then this extracts the positional parameters, [1] starting at $position.a

${string:position:length} : Extracts $length characters of substring from $string at $position.

::

	stringZ=abcABC123ABCabc
	#       0123456789.....
	#       0-based indexing.

	echo ${stringZ:0}                            # abcABC123ABCabc
	echo ${stringZ:1}                            # bcABC123ABCabc
	echo ${stringZ:7}                            # 23ABCabc

	echo ${stringZ:7:3}                          # 23A
						     # Three characters of substring.


	# Is it possible to index from the right end of the string?
	 
	 echo ${stringZ:-4}                           # abcABC123ABCabc
	 # Defaults to full string, as in ${parameter:-default}.
	 # However . . .

	 echo ${stringZ:(-4)}                         # Cabc 
	 echo ${stringZ: -4}                          # Cabc
	 # Now, it works.
	 # Parentheses or added space "escape" the position parameter.

The position and length arguments can be "parameterized," that is, represented as a variable, rather than as a numerical constant.

=================
Substring Removal
=================
${string#substring} : Deletes shortest match of $substring from front of $string.

${string##substring} : Deletes longest match of $substring from front of $string.

::

    stringZ=abcABC123ABCabc
    #       |----|          shortest
    #       |----------|    longest

    echo ${stringZ#a*C}      # 123ABCabc
    # Strip out shortest match between 'a' and 'C'.

    echo ${stringZ##a*C}     # abc
    # Strip out longest match between 'a' and 'C'.



    # You can parameterize the substrings.

    X='a*C'

    echo ${stringZ#$X}      # 123ABCabc
    echo ${stringZ##$X}     # abc
                            # As above.

${string%substring} : Deletes shortest match of $substring from back of $string.

::

    For example:

    # Rename all filenames in $PWD with "TXT" suffix to a "txt" suffix.
    # For example, "file1.TXT" becomes "file1.txt" . . .

    SUFF=TXT
    suff=txt

    for i in $(ls *.$SUFF)
    do
      mv -f $i ${i%.$SUFF}.$suff
      #  Leave unchanged everything *except* the shortest pattern match
      #+ starting from the right-hand-side of the variable $i . . .
    done ### This could be condensed into a "one-liner" if desired.

    # Thank you, Rory Winston.

${string%%substring} : Deletes longest match of $substring from back of $string.

======================
Parameter Substitution
======================

${parameter-default}, ${parameter:-default} : If parameter not set, use default. ${parameter-default} and ${parameter:-default} are almost equivalent. The extra : makes a difference only when parameter has been declared, but is null. 

::

    var1=1
    var2=2
    # var3 is unset.

    echo ${var1-$var2}   # 1
    echo ${var3-$var2}   # 2

${parameter=default}, ${parameter:=default} : If parameter not set, set it to default.  Both forms nearly equivalent. The : makes a difference only when $parameter has been declared and is null, [1] as above.

${parameter+alt_value}, ${parameter:+alt_value} : If parameter set, use alt_value, else use null string. Both forms nearly equivalent. The : makes a difference only when parameter has been declared and is null, see below.

${parameter?err_msg}, ${parameter:?err_msg} : If parameter set, use it, else print err_msg and abort the script with an exit status of 1. Both forms nearly equivalent. The : makes a difference only when parameter has been declared and is null, as above.

=====================
Substring Replacement
=====================
${string/substring/replacement} :  Replace first match of $substring with $replacement.

${string//substring/replacement} :  Replace all matches of $substring with $replacement.

${string/#substring/replacement} : If $substring matches front end of $string, substitute $replacement for $substring.

${string/%substring/replacement} : If $substring matches back end of $string, substitute $replacement for $substring.

[[ vs [
-------
The == comparison operator behaves differently within a double-brackets test than within single brackets.

::

	[[ $a == z* ]]   # True if $a starts with an "z" (pattern matching).
	[[ $a == "z*" ]] # True if $a is equal to z* (literal matching).

	[ $a == z* ]     # File globbing and word splitting take place.
	[ "$a" == "z*" ] # True if $a is equal to z* (literal matching).

Loops
-----

::

	# Using brace expansion ...
	# Bash, version 3+.
	for a in {1..10}
	do
	  echo -n "$a "
	done  

	echo; echo

	# +==========================================+

	# Now, let's do the same, using C-like syntax.

	LIMIT=10

	for ((a=1; a <= LIMIT ; a++))  # Double parentheses, and "LIMIT" with no "$".
	do
	  echo -n "$a "
	done                           # A construct borrowed from 'ksh93'.

	# +=========================================================================+

	# Let's use the C "comma operator" to increment two variables simultaneously.

	for ((a=1, b=1; a <= LIMIT ; a++, b++))
	do  # The comma chains together operations.
	  echo -n "$a-$b "
	done

	echo; echo

Command Substitution
--------------------

Command substitution invokes a subshell.

Output of a command to a variable

::

	textfile_listing=`ls *.txt`
	# Variable contains names of all *.txt files in current working directory.
	echo $textfile_listing

	textfile_listing2=$(ls *.txt)   # The alternative form of command substitution.
	echo $textfile_listing2
	# Same result.
	Reading contents of a file 

File contents to a variable

::

	variable1=`<file1`      #  Set "variable1" to contents of "file1".
	variable2=`cat file2`   #  Set "variable2" to contents of "file2".
				#  This, however, forks a new process,
				#+ so the line of code executes slower than the above version.

**Do not set a variable to the contents of a long text file unless you have a very good reason for doing so. Do not set a variable to the contents of a binary file, even as a joke.**

**The $(...) form has superseded backticks for command substitution.**

The $(...) form of command substitution permits nesting

::

	word_count=$( wc -w $(echo * | awk '{print $8}') )

Arthimetic Expansion
--------------------

::

    z=`expr $z + 3`          # The 'expr' command performs the expansion.
    z=$(($z+3))
    z=$((z+3))                                  #  Also correct.
                                                #  Within double parentheses,
                                                #+ parameter dereferencing
                                                #+ is optional.

    # $((EXPRESSION)) is arithmetic expansion.  #  Not to be confused with
                                                #+ command substitution.



    # You may also use operations within double parentheses without assignment.

      n=0
      echo "n = $n"                             # n = 0

      (( n += 1 ))                              # Increment.
    # (( $n += 1 )) is incorrect!
      echo "n = $n"                             # n = 1


    let z=z+3
    let "z += 3"  #  Quotes permit the use of spaces in variable assignment.
                  #  The 'let' operator actually performs arithmetic evaluation,
                  #+ rather than expansion.

Internal Variables
------------------

==============
$BASH_SUBSHELL
==============

A variable indicating the subshell level. This is a new addition to Bash, version 3.

========
$BASHPID
========
Process ID of the current instance of Bash. This is not the same as the $$ variable, but it often gives the same result.

::

    bash4$ echo $$
    11015


    bash4$ echo $BASHPID
    11015


    bash4$ ps ax | grep bash4
    11015 pts/2    R      0:00 bash4
	      
But ...

::

    #!/bin/bash4

    echo "\$\$ outside of subshell = $$"                              # 9602
    echo "\$BASH_SUBSHELL  outside of subshell = $BASH_SUBSHELL"      # 0
    echo "\$BASHPID outside of subshell = $BASHPID"                   # 9602

    echo

    ( echo "\$\$ inside of subshell = $$"                             # 9602
      echo "\$BASH_SUBSHELL inside of subshell = $BASH_SUBSHELL"      # 1
      echo "\$BASHPID inside of subshell = $BASHPID" )                # 9603
      # Note that $$ returns PID of parent process.

=================
$BASH_VERSINFO[n]
=================
A 6-element array containing version information about the installed release of Bash. This is similar to $BASH_VERSION, below, but a bit more detailed.

::

    # Bash version info:

    for n in 0 1 2 3 4 5
    do
      echo "BASH_VERSINFO[$n] = ${BASH_VERSINFO[$n]}"
    done  

    # BASH_VERSINFO[0] = 3                      # Major version no.
    # BASH_VERSINFO[1] = 00                     # Minor version no.
    # BASH_VERSINFO[2] = 14                     # Patch level.
    # BASH_VERSINFO[3] = 1                      # Build version.
    # BASH_VERSINFO[4] = release                # Release status.
    # BASH_VERSINFO[5] = i386-redhat-linux-gnu  # Architecture
                                                # (same as $MACHTYPE).

=============
$BASH_VERSION
=============
The version of Bash installed on the system

::

    bash$ echo $BASH_VERSION
    3.2.25(1)-release

=========
$FUNCNAME
=========

Name of the current function

====
$IFS
====
internal field separator

This variable determines how Bash recognizes fields, or word boundaries, when it interprets character strings.

$IFS defaults to whitespace (space, tab, and newline), but may be changed, for example, to parse a comma-separated data file. Note that $* uses the first character held in $IFS. See Example 5-1.

::

    bash$ echo "$IFS"
    
    (With $IFS set to default, a blank line displays.)
	      
    bash$ echo "$IFS" | cat -vte
     ^I$
     $
    (Show whitespace: here a single space, ^I [horizontal tab],
      and newline, and display "$" at end-of-line.)



    bash$ bash -c 'set w x y z; IFS=":-;"; echo "$*"'
    w:x:y:z
    (Read commands from string and assign any arguments to pos params.)
	      

Caution	: $IFS does not handle whitespace the same as it does other characters.

::

    #!/bin/bash
    # ifs.sh


    var1="a+b+c"
    var2="d-e-f"
    var3="g,h,i"

    IFS=+
    # The plus sign will be interpreted as a separator.
    echo $var1     # a b c
    echo $var2     # d-e-f
    echo $var3     # g,h,i

    echo

    IFS="-"
    # The plus sign reverts to default interpretation.
    # The minus sign will be interpreted as a separator.
    echo $var1     # a+b+c
    echo $var2     # d e f
    echo $var3     # g,h,i

    echo

    IFS=","
    # The comma will be interpreted as a separator.
    # The minus sign reverts to default interpretation.
    echo $var1     # a+b+c
    echo $var2     # d-e-f
    echo $var3     # g h i

    echo

    IFS=" "
    # The space character will be interpreted as a separator.
    # The comma reverts to default interpretation.
    echo $var1     # a+b+c
    echo $var2     # d-e-f
    echo $var3     # g,h,i

    # ======================================================== #

    # However ...
    # $IFS treats whitespace differently than other characters.

    output_args_one_per_line()
    {
      for arg
      do
        echo "[$arg]"
      done #  ^    ^   Embed within brackets, for your viewing pleasure.
    }

    echo; echo "IFS=\" \""
    echo "-------"

    IFS=" "
    var=" a  b c   "
    #    ^ ^^   ^^^
    output_args_one_per_line $var  # output_args_one_per_line `echo " a  b c   "`
    # [a]
    # [b]
    # [c]


    echo; echo "IFS=:"
    echo "-----"

    IFS=:
    var=":a::b:c:::"               # Same pattern as above,
    #    ^ ^^   ^^^                #+ but substituting ":" for " "  ...
    output_args_one_per_line $var
    # []
    # [a]
    # []
    # [b]
    # [c]
    # []
    # []

    # Note "empty" brackets.
    # The same thing happens with the "FS" field separator in awk.


    echo

    exit

=======
$LINENO
=======
This variable is the line number of the shell script in which this variable appears. It has significance only within the script in which it appears, and is chiefly useful for debugging purposes.

===========
$PIPESTATUS
===========

Array variable holding exit status(es) of last executed foreground pipe.

::

	bash$ who | grep nobody | sort
	bash$ echo ${PIPESTATUS[*]}
	0 1 0

===============
$PROMPT_COMMAND
===============
A variable holding a command to be executed just before the primary prompt, $PS1 is to be displayed.

====
$PS1
====
This is the main prompt, seen at the command-line.

====
$PS2
====
The secondary prompt, seen when additional input is expected. It displays as ">".

====
$PS3
====
The tertiary prompt, displayed in a select loop (see Example 11-29).

====
$PS4
====
The quartenary prompt, shown at the beginning of each line of output when invoking a script with the -x option. It displays as "+".

========
$SECONDS
========

The number of seconds the script has been running.

======
$TMOUT
======
If the $TMOUT environmental variable is set to a non-zero value time, then the shell prompt will time out after $time seconds. This will cause a logout.

As of version 2.05b of Bash, it is now possible to use $TMOUT in a script in combination with read.

Positional Parameters
---------------------
$0, $1, $2, etc.
	Positional parameters, passed from command line to script, passed to a function, or set to a variable (see Example 4-5 and Example 15-16)
$#
	Number of command-line arguments [4] or positional parameters (see Example 36-2)
$*
	All of the positional parameters, seen as a single word
	Note	"$*" must be quoted.
$@
	Same as $*, but each parameter is a quoted string, that is, the parameters are passed on intact, without interpretation or expansion. This means, among other things, that each parameter in the argument list is seen as a separate word.

Example 9-7. Inconsistent $* and $@ behavior

::

	#!/bin/bash

	#  Erratic behavior of the "$*" and "$@" internal Bash variables,
	#+ depending on whether they are quoted or not.
	#  Inconsistent handling of word splitting and linefeeds.


	set -- "First one" "second" "third:one" "" "Fifth: :one"
	# Setting the script arguments, $1, $2, etc.

	echo

	echo 'IFS unchanged, using "$*"'
	c=0
	for i in "$*"               # quoted
	do echo "$((c+=1)): [$i]"   # This line remains the same in every instance.
				    # Echo args.
	done
	echo ---

	echo 'IFS unchanged, using $*'
	c=0
	for i in $*                 # unquoted
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	echo 'IFS unchanged, using "$@"'
	c=0
	for i in "$@"
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	echo 'IFS unchanged, using $@'
	c=0
	for i in $@
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	IFS=:
	echo 'IFS=":", using "$*"'
	c=0
	for i in "$*"
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	echo 'IFS=":", using $*'
	c=0
	for i in $*
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	var=$*
	echo 'IFS=":", using "$var" (var=$*)'
	c=0
	for i in "$var"
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	echo 'IFS=":", using $var (var=$*)'
	c=0
	for i in $var
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	var="$*"
	echo 'IFS=":", using $var (var="$*")'
	c=0
	for i in $var
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	echo 'IFS=":", using "$var" (var="$*")'
	c=0
	for i in "$var"
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	echo 'IFS=":", using "$@"'
	c=0
	for i in "$@"
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	echo 'IFS=":", using $@'
	c=0
	for i in $@
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	var=$@
	echo 'IFS=":", using $var (var=$@)'
	c=0
	for i in $var
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	echo 'IFS=":", using "$var" (var=$@)'
	c=0
	for i in "$var"
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	var="$@"
	echo 'IFS=":", using "$var" (var="$@")'
	c=0
	for i in "$var"
	do echo "$((c+=1)): [$i]"
	done
	echo ---

	echo 'IFS=":", using $var (var="$@")'
	c=0
	for i in $var
	do echo "$((c+=1)): [$i]"
	done

	echo

	# Try this script with ksh or zsh -y.

	exit 0

	# This example script by Stephane Chazelas,
	# and slightly modified by the document author.

Note : The $@ and $* parameters differ only when between double quotes.

Example 9-8. $* and $@ when $IFS is empty

::

	#!/bin/bash

	#  If $IFS set, but empty,
	#+ then "$*" and "$@" do not echo positional params as expected.

	mecho ()       # Echo positional parameters.
	{
	echo "$1,$2,$3";
	}


	IFS=""         # Set, but empty.
	set a b c      # Positional parameters.

	mecho "$*"     # <abc>
	#                   ^^
	mecho $*       # a,b,c

	mecho $@       # a,b,c
	mecho "$@"     # a,b,c

	#  The behavior of $* and $@ when $IFS is empty depends
	#+ on which Bash or sh version being run.
	#  It is therefore inadvisable to depend on this "feature" in a script.


	# Thanks, Stephane Chazelas.

	exit

==
$!
==
PID (process ID) of last job run in background

==
$_
==
Special variable set to final argument of previous command executed.


$RANDOM
-------
Anyone who attempts to generate random numbers by deterministic means is, of course, living in a state of sin.
	--John von Neumann

$RANDOM is an internal Bash function (not a constant) that returns a pseudorandom [1] integer in the range 0 - 32767. It should not be used to generate an encryption key.




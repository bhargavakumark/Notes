Prog : Bash
==========

.. contents::

.. highlight:: bash

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

read
----

::

	while IFS=: read name passwd uid gid fullname ignore
	do
	  echo "$name ($fullname)"
	done </etc/passwd   # I/O redirection.

However, as Bjön Eriksson shows: Problems reading from a pipe

::

	### shopt -s lastpipe

	last="(null)"
	cat $0 |
	while read line
	do
	    echo "{$line}"
	    last=$line
	done

	echo
	echo "++++++++++++++++++++++"
	printf "\nAll done, last: $last\n" #  The output of this line
					   #+ changes if you uncomment line 5.
					   #  (Bash, version -ge 4.2 required.)

	exit 0  # End of code.
		# (Partial) output of script follows.
		# The 'echo' supplies extra brackets.

	#############################################

	./readpipe.sh 

	{#!/bin/sh}
	{last="(null)"}
	{cat $0 |}
	{while read line}
	{do}
	{echo "{$line}"}
	{last=$line}
	{done}
	{printf "nAll done, last: $lastn"}


	All done, last: (null)

	The variable (last) is set within the loop/subshell
	but its value does not persist outside the loop.	

eval
----

::

    eval arg1 [arg2] ... [argN]

    Combines the arguments in an expression or list of expressions and evaluates them. Any variables within the expression are expanded. The net result is to convert a string into a command.

    Tip	

    The eval command can be used for code generation from the command-line or within a script.

    bash$ command_string="ps ax"
    bash$ process="ps ax"
    bash$ eval "$command_string" | grep "$process"
    26973 pts/3    R+     0:00 grep --color ps ax
     26974 pts/3    R+     0:00 ps ax
	      

Each invocation of eval forces a re-evaluation of its arguments.

::

    a='$b'
    b='$c'
    c=d

    echo $a             # $b
                        # First level.
    eval echo $a        # $c
                        # Second level.
    eval eval echo $a   # d
                        # Third level.

    # Thank you, E. Choroba.

set
---

The set command changes the value of internal script variables/options. One use for this is to toggle option flags which help determine the behavior of the script. Another application for it is to reset the positional parameters that a script sees as the result of a command (set `command`). The script can then parse the fields of the command output.

::

	set `uname -a` # Sets the positional parameters to the output of the command `uname -a`

Invoking set without any options or arguments simply lists all the environmental and other variables that have been initialized.

unset
-----

The unset command deletes a shell variable, effectively setting it to null. Note that this command does not affect positional parameters.

wait
----
Suspend script execution until all jobs running in background have terminated, or until the job number or process ID specified as an option terminates. Returns the exit status of waited-for command.

You may use the wait command to prevent a script from exiting before a background job finishes executing (this would create a dreaded orphan process).

Optionally, wait can take a job identifier as an argument, for example, wait%1 or wait $PPID. [1] See the job id table.

find
----

-exec COMMAND \;
	Carries out COMMAND on each file that find matches. The command sequence terminates with ; (the ";" is escaped to make certain the shell passes it to find literally, without interpreting it as a special character).

::

    bash$ find ~/ -name '*.txt'
    /home/bozo/.kde/share/apps/karm/karmdata.txt
     /home/bozo/misc/irmeyc.txt
     /home/bozo/test-scripts/1.txt
	      

If COMMAND contains {}, then find substitutes the full path name of the selected file for "{}".

::

    find ~/ -name 'core*' -exec rm {} \;
    # Removes all core dump files from user's home directory.

xargs
-----
A filter for feeding arguments to a command, and also a tool for assembling the commands themselves. It breaks a data stream into small enough chunks for filters and commands to process.

**ls | xargs -p -l gzip** gzips every file in current directory, one at a time, prompting before each operation.

An interesting xargs option is -n NN, which limits to NN the number of arguments passed.
	**ls | xargs -n 8** echo lists the files in the current directory in 8 columns.

Another useful option is -0, in combination with find -print0 or grep -lZ. This allows handling arguments containing whitespace or quotes.
	**find / -type f -print0 | xargs -0 grep -liwZ GUI | xargs -0 rm -f**

The -P option to xargs permits running processes in parallel. This speeds up execution in a machine with a multicore CPU.

As in find, a **curly bracket pair** serves as a placeholder for replacement text.

expand, unexpand
----------------
The expand filter converts tabs to spaces. It is often used in a pipe.

The unexpand filter converts spaces to tabs. This reverses the effect of expand.

whereis
-------
Similar to which, above, whereis command gives the full path to "command," but also to its manpage.

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


I/O Redirection
---------------

::

   1>filename
      # Redirect stdout to file "filename."
   1>>filename
      # Redirect and append stdout to file "filename."
   2>filename
      # Redirect stderr to file "filename."
   2>>filename
      # Redirect and append stderr to file "filename."
   &>filename
      # Redirect both stdout and stderr to file "filename."
      # This operator is now functional, as of Bash 4, final release.

   M>N
     # "M" is a file descriptor, which defaults to 1, if not explicitly set.
     # "N" is a filename.
     # File descriptor "M" is redirect to file "N."
   M>&N
     # "M" is a file descriptor, which defaults to 1, if not set.
     # "N" is another file descriptor.


   0< FILENAME
    < FILENAME
      # Accept input from a file.
      # Companion command to ">", and often used in combination with it.
      #
      # grep search-word <filename

      exec 3<> File             # Open "File" and assign fd 3 to it.
      read -n 4 <&3             # Read only 4 characters.
      echo -n . >&3             # Write a decimal point there.
      exec 3>&-                 # Close fd 3.

Closing File Descriptors

::

	n<&-
	    Close input file descriptor n.
	0<&-, <&-
	    Close stdin.
	n>&-
	    Close output file descriptor n.
	1>&-, >&-
	    Close stdout.

Redirecting stdin using exec

::

	#!/bin/bash
	# Redirecting stdin using 'exec'.


	exec 6<&0          # Link file descriptor #6 with stdin.
			   # Saves stdin.

	exec < data-file   # stdin replaced by file "data-file"

	exec 0<&6 6<&-
	#  Now restore stdin from fd #6, where it had been saved,
	#+ and close fd #6 ( 6<&- ) to free it for other processes to use.
	#
	# <&6 6<&-    also works.

exec N > filename affects the entire script or current shell. Redirection in the PID of the script or shell from that point on has changed. However . . .

N > filename affects only the newly-forked process, not the entire script or shell.

Thank you, Ahmed Darwish, for pointing this out.

Process Substituion
-------------------
Process substitution feeds the output of a process (or processes) into the stdin of another process.

Template

Command list enclosed within parentheses
* >(command_list)
* <(command_list)

Process substitution uses /dev/fd/<n> files to send the results of the process(es) within parentheses to another process. [1]

Caution	: There is no space between the the "<" or ">" and the parentheses. Space there would give an error message.

.. code-block:: bash

	bash$ echo >(true)
	/dev/fd/63

	bash$ echo <(true)
	/dev/fd/63

	bash$ echo >(true) <(true)
	/dev/fd/63 /dev/fd/62



	bash$ wc <(cat /usr/share/dict/linux.words)
	 483523  483523 4992010 /dev/fd/63

	bash$ grep script /usr/share/dict/linux.words | wc
	    262     262    3601

	bash$ wc <(grep script /usr/share/dict/linux.words)
	    262     262    3601 /dev/fd/63

Bash creates a pipe with two file descriptors, --fIn and fOut--. The stdin of true connects to fOut (dup2(fOut, 0)), then Bash passes a /dev/fd/fIn argument to echo. On systems lacking /dev/fd/<n> files, Bash may use temporary files. (Thanks, S.C.) 

Process substitution can compare the output of two different commands, or even the output of different options to the same command.

.. code-block:: bash

	bash$ comm <(ls -l) <(ls -al)
	total 12
	-rw-rw-r--    1 bozo bozo       78 Mar 10 12:58 File0
	-rw-rw-r--    1 bozo bozo       42 Mar 10 12:58 File2
	-rw-rw-r--    1 bozo bozo      103 Mar 10 12:58 t2.sh
		total 20
		drwxrwxrwx    2 bozo bozo     4096 Mar 10 18:10 .
		drwx------   72 bozo bozo     4096 Mar 10 17:58 ..
		-rw-rw-r--    1 bozo bozo       78 Mar 10 12:58 File0
		-rw-rw-r--    1 bozo bozo       42 Mar 10 12:58 File2
		-rw-rw-r--    1 bozo bozo      103 Mar 10 12:58 t2.sh

.. code-block:: bash

	sort -k 9 <(ls -l /bin) <(ls -l /usr/bin) <(ls -l /usr/X11R6/bin)
	# Lists all the files in the 3 main 'bin' directories, and sorts by filename.
	# Note that three (count 'em) distinct commands are fed to 'sort'.

	 
	diff <(command1) <(command2)    # Gives difference in command output.

======================================
Code block redirection without forking
======================================

.. code-block:: bash

	#!/bin/bash
	# wr-ps.bash: while-read loop with process substitution.

	# This example contributed by Tomas Pospisek.
	# (Heavily edited by the ABS Guide author.)

	echo

	echo "random input" | while read i
	do
	  global=3D": Not available outside the loop."
	  # ... because it runs in a subshell.
	done

	echo "\$global (from outside the subprocess) = $global"
	# $global (from outside the subprocess) =

	echo; echo "--"; echo

	while read i
	do
	  echo $i
	  global=3D": Available outside the loop."
	  # ... because it does not run in a subshell.
	done < <( echo "random input" )
	#    ^ ^

	echo "\$global (using process substitution) = $global"
	# Random input
	# $global (using process substitution) = 3D: Available outside the loop.

Arrays
------

==================
Simple array usage
==================

.. code-block:: bash

	#!/bin/bash


	area[11]=23
	area[13]=37
	area[51]=UFOs

	#  Array members need not be consecutive or contiguous.

::

	# Another way of assigning array variables...
	# array_name=( XXX YYY ZZZ ... )

	area2=( zero one two three four )

	# Yet another way of assigning array variables...
	# array_name=([xx]=XXX [yy]=YYY ...)

	area3=([17]=seventeen [24]=twenty-four)

	base64_charset=( {A..Z} {a..z} {0..9} + / = )
		       #  Using extended brace expansion
		       #+ to initialize the elements of the array.                
		       #  Excerpted from vladz's "base64.sh" script
		       #+ in the "Contributed Scripts" appendix.

================
Basic Operations
================
Bash permits array operations on variables, even if the variables are not explicitly declared as arrays.

::

	string=abcABC123ABCabc
	echo ${string[@]}               # abcABC123ABCabc
	echo ${string[*]}               # abcABC123ABCabc 
	echo ${string[0]}               # abcABC123ABCabc
	echo ${string[1]}               # No output!
					# Why?
	echo ${#string[@]}              # 1
					# One element in the array.
					# The string itself.

	# Thank you, Michael Zick, for pointing this out.

Various Array operations

::

	echo ${array[0]}       #  zero
	echo ${array:0}        #  zero
			       #  Parameter expansion of first element,
			       #+ starting at position # 0 (1st character).
	echo ${array:1}        #  ero
			       #  Parameter expansion of first element,
			       #+ starting at position # 1 (2nd character).

	echo "--------------"

	echo ${#array[0]}      #  4
			       #  Length of first element of array.
	echo ${#array}         #  4
			       #  Length of first element of array.
			       #  (Alternate notation)

	echo ${#array[1]}      #  3
			       #  Length of second element of array.
			       #  Arrays in Bash have zero-based indexing.

	echo ${#array[*]}      #  6
			       #  Number of elements in array.
	echo ${#array[@]}      #  6
			       #  Number of elements in array.

	# The ${!array[@]} operator, which expands to all the indices of a given array.
	for i in ${!Array[@]}
	do
	  echo ${Array[i]} # element-zero
			   # element-one
			   # element-two
			   # element-three
			   #
			   # All the elements in Array.
	done

===========================
String operations on arrays
===========================

::

	#!/bin/bash
	# array-strops.sh: String operations on arrays.

	# Script by Michael Zick.
	# Used in ABS Guide with permission.
	# Fixups: 05 May 08, 04 Aug 08.

	#  In general, any string operation using the ${name ... } notation
	#+ can be applied to all string elements in an array,
	#+ with the ${name[@] ... } or ${name[*] ...} notation.


	arrayZ=( one two three four five five )

	echo

	# Trailing Substring Extraction
	echo ${arrayZ[@]:0}     # one two three four five five
	#                ^        All elements.

	echo ${arrayZ[@]:1}     # two three four five five
	#                ^        All elements following element[0].

	echo ${arrayZ[@]:1:2}   # two three
	#                  ^      Only the two elements after element[0].

	echo "---------"

=================
Substring Removal
=================

::

	# Removes shortest match from front of string(s).

	echo ${arrayZ[@]#f*r}   # one two three five five
	#               ^       # Applied to all elements of the array.
				# Matches "four" and removes it.

	# Longest match from front of string(s)
	echo ${arrayZ[@]##t*e}  # one two four five five
	#               ^^      # Applied to all elements of the array.
				# Matches "three" and removes it.

	# Shortest match from back of string(s)
	echo ${arrayZ[@]%h*e}   # one two t four five five
	#               ^       # Applied to all elements of the array.
				# Matches "hree" and removes it.

	# Longest match from back of string(s)
	echo ${arrayZ[@]%%t*e}  # one two four five five
	#               ^^      # Applied to all elements of the array.
				# Matches "three" and removes it.

=====================
Substring Replacement
=====================

::

	# Replace first occurrence of substring with replacement.
	echo ${arrayZ[@]/fiv/XYZ}   # one two three four XYZe XYZe
	#               ^           # Applied to all elements of the array.

	# Replace all occurrences of substring.
	echo ${arrayZ[@]//iv/YY}    # one two three four fYYe fYYe
				    # Applied to all elements of the array.

	# Delete all occurrences of substring.
	# Not specifing a replacement defaults to 'delete' ...
	echo ${arrayZ[@]//fi/}      # one two three four ve ve
	#               ^^          # Applied to all elements of the array.

	# Replace front-end occurrences of substring.
	echo ${arrayZ[@]/#fi/XY}    # one two three four XYve XYve
	#                ^          # Applied to all elements of the array.

	# Replace back-end occurrences of substring.
	echo ${arrayZ[@]/%ve/ZZ}    # one two three four fiZZ fiZZ
	#                ^          # Applied to all elements of the array.

	echo ${arrayZ[@]/%o/XX}     # one twXX three four five five
	#                ^          # Why?

=======================================
unset/Remove array or elements of array
=======================================

::

	# The "unset" command deletes elements of an array, or entire array.
	unset colors[1]              # Remove 2nd element of array.
				     # Same effect as   colors[1]=
	echo  ${colors[@]}           # List array again, missing 2nd element.

	unset colors                 # Delete entire array.
				     #  unset colors[*] and
				     #+ unset colors[@] also work.

======================================
Extending/Inserting/Removing an Array
======================================

::

	array0[${#array0[*]}]="new2"

	# When extended as above, arrays are 'stacks' ...
	# Above is the 'push' ...
	# The stack 'height' is:
	height=${#array2[@]}
	echo
	echo "Stack height for array2 = $height"

	# The 'pop' is:
	unset array2[${#array2[@]}-1]   #  Arrays are zero-based,
	height=${#array2[@]}            #+ which means first element has index 0.
	echo
	echo "POP"
	echo "New stack height for array2 = $height"

	# List only 2nd and 3rd elements of array0.
	from=1		    # Zero-based numbering.
	to=2
	array3=( ${array0[@]:1:2} )

================
Copying an array
================

::

	array2=( "${array1[@]}" )
	# or
	array2="${array1[@]}"
	#
	#  However, this fails with "sparse" arrays,
	#+ arrays with holes (missing elements) in them,
	#+ as Jochen DeSmet points out.

====================
Concatenating arrays
====================

::

	dest=( ${array1[@]} ${array2[@]} )

===============================================
Embedded Arrays, Hashes and Indirect References
===============================================

::

	#!/bin/bash
	# embedded-arrays.sh
	# Embedded arrays and indirect references.

	# This script by Dennis Leeuw.
	# Used with permission.
	# Modified by document author.


	ARRAY1=(
		VAR1_1=value11
		VAR1_2=value12
		VAR1_3=value13
	)

	ARRAY2=(
		VARIABLE="test"
		STRING="VAR1=value1 VAR2=value2 VAR3=value3"
		ARRAY21=${ARRAY1[*]}
	)       # Embed ARRAY1 within this second array.

	function print () {
		OLD_IFS="$IFS"
		IFS=$'\n'       #  To print each array element
				#+ on a separate line.
		TEST1="ARRAY2[*]"
		local ${!TEST1} # See what happens if you delete this line.
		#  Indirect reference.
		#  This makes the components of $TEST1
		#+ accessible to this function.


		#  Let's see what we've got so far.
		echo
		echo "\$TEST1 = $TEST1"       #  Just the name of the variable.
		echo; echo
		echo "{\$TEST1} = ${!TEST1}"  #  Contents of the variable.
					      #  That's what an indirect
					      #+ reference does.
		echo
		echo "-------------------------------------------"; echo
		echo


		# Print variable
		echo "Variable VARIABLE: $VARIABLE"
		
		# Print a string element
		IFS="$OLD_IFS"
		TEST2="STRING[*]"
		local ${!TEST2}      # Indirect reference (as above).
		echo "String element VAR2: $VAR2 from STRING"

		# Print an array element
		TEST2="ARRAY21[*]"
		local ${!TEST2}      # Indirect reference (as above).
		echo "Array element VAR1_1: $VAR1_1 from ARRAY21"
	}

	print
	echo

	exit 0

	#   As the author of the script notes,
	#+ "you can easily expand it to create named-hashes in bash."
	#   (Difficult) exercise for the reader: implement this.

============================
Passing and returning arrays
============================

::

	#!/bin/bash
	# array-function.sh: Passing an array to a function and ...
	#                   "returning" an array from a function


	Pass_Array ()
	{
	  local passed_array   # Local variable!
	  passed_array=( `echo "$1"` )
	  echo "${passed_array[@]}"
	  #  List all the elements of the new array
	  #+ declared and set within the function.
	}


	original_array=( element1 element2 element3 element4 element5 )

	echo
	echo "original_array = ${original_array[@]}"
	#                      List all elements of original array.


	# This is the trick that permits passing an array to a function.
	# **********************************
	argument=`echo ${original_array[@]}`
	# **********************************
	#  Pack a variable
	#+ with all the space-separated elements of the original array.
	#
	# Attempting to just pass the array itself will not work.


	# This is the trick that allows grabbing an array as a "return value".
	# *****************************************
	returned_array=( `Pass_Array "$argument"` )
	# *****************************************
	# Assign 'echoed' output of function to array variable.

	echo "returned_array = ${returned_array[@]}"

Indirect Reference
------------------

The actual notation is \$$var, usually preceded by an eval (and sometimes an echo). This is called an indirect reference.

::

	G=letter_of_alphabet   # Variable "a" holds the name of another variable.
	letter_of_alphabet=z

	echo

	# Direct reference.
	echo "a = $a"          # a = letter_of_alphabet

	# Indirect reference.
	  eval a=\$$a

	echo "Now a = ${!a}"    # Indirect reference.
	#  The ${!variable} notation is more intuitive than the old
	#+ eval var1=\$$var2
	# Available in which bash versions ?


Trapping Signals
----------------

Specifies an action on receipt of a signal; also useful for debugging. 

A simple instance:

::

	trap '' 2
	# Ignore interrupt 2 (Control-C), with no action specified. 

	trap 'echo "Control-C disabled."' 2
	# Message when Control-C pressed.


Newer Bash features
-------------------

The ${!array[@]} operator, which expands to all the indices of a given array.

::

	for i in ${!Array[@]}
	do
	  echo ${Array[i]} # element-zero
			   # element-one
			   # element-two
			   # element-three
			   #
			   # All the elements in Array.
	done

The =~ Regular Expression matching operator within a double brackets test expression. (Perl has a similar operator.)

::

	#!/bin/bash

	variable="This is a fine mess."

	echo "$variable"

	# Regex matching with =~ operator within [[ double brackets ]].
	if [[ "$variable" =~ T.........fin*es* ]]
	# NOTE: As of version 3.2 of Bash, expression to match no longer quoted.
	then
	  echo "match found"
	      # match found
	fi

The += operator is now permitted in in places where previously only the = assignment operator was recognized.

Here, += functions as a string concatenation operator. Note that its behavior in this particular context is different than within a let construct.

::

	a=1
	echo $a        # 1

	a+=5           # Won't work under versions of Bash earlier than 3.1.
	echo $a        # 15

	a+=Hello
	echo $a        # 15Hello

Commenting out a block of code

::

	#!/bin/bash
	# commentblock.sh

	: <<COMMENTBLOCK
	echo "This line will not echo."
	This is a comment line missing the "#" prefix.
	This is another comment line missing the "#" prefix.

	&*@!!++=
	The above line will cause no error message,
	because the Bash interpreter will ignore it.
	COMMENTBLOCK

	echo "Exit value of above \"COMMENTBLOCK\" is $?."   # 0
	# No error shown.
	echo


Exit Codes With Special Meanings
--------------------------------

================	==========================================================	=========================================================================================================
Exit Code Number	Meaning								Example			Comments
================	==========================================================	=========================================================================================================
1			Catchall for general errors					let "var1 = 1/0"	Miscellaneous errors, such as "divide by zero" and other impermissible operations
2			Misuse of shell builtins (according to Bash documentation)	empty_function() {}	Seldom seen, usually defaults to exit code 1
126			Command invoked cannot execute								Permission problem or command is not an executable
127			"command not found"						illegal_command		Possible problem with $PATH or a typo
128			Invalid argument to exit					exit 3.14159		exit takes only integer args in the range 0 - 255 (see first footnote)
128+n			Fatal error signal "n"						kill -9 $PPID of script	$? returns 137 (128 + 9)
130			Script terminated by Control-C								Control-C is fatal error signal 2, (130 = 128 + 2, see above)
255*			Exit status out of range								exit -1	exit takes only integer args in the range 0 - 255
================	==========================================================	=========================================================================================================


Shell Script Tips
-----------------

=====================
Hash in Shell Scripts
=====================

::

        where n="TEST"

        typeset val_${n}=3


the value of ${val_TEST} will be seen to be 3, checked using set or env. Reading the value is a little trickier. It can be performed directly if the key name is constant:

::

        echo "${val_TEST}"


However, to use a variable key, perform the following:

::

        echo "$(eval echo \$val_${n})"


This acts as a pointer and should then return 3.

In order to run the hash, set or env can be used along with a pattern matching utility, i.e. grep or egrep, especially if the variable name prefix is very specific (i.e. ``val_``).


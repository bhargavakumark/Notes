Shell Script Tips
=================

.. contents::

Hash in Shell Scripts
---------------------

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


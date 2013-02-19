vim
===

.. contents::

References
----------

* http://www.viemu.com/a-why-vi-vim.html
* http://www.keyxl.com/aaa8263/290/VIM-keyboard-shortcuts.htm

C++ omni complete
-----------------

Download the C++ omnicomplete script from 

* http://www.vim.org/scripts/script.php?script_id=1520

Read documentation inside vim using 

* :help omnicppcomplete

Tabs
----

::

    :help tab-page-intro        # Help

    :tabnew [filename]          # Open a new tab

    gt or :tabnext              # Navigate between tabs

    :tabm <number>              # Move tabs around

    :tabdo %s/foo/bar/g         # Run a command on all tabs

References:

* https://www.linux.com/learn/tutorials/442422-vim-tips-using-tabs

Windows
-------

::

    :sp [filename]              # split window horizontally

    :vsp [filename]             # Split window vertically

    Ctrl-w j                    # Navigate down

    Ctrl-w k                    # Navigate up

    Ctrl-w w                    # Navigate down or cycle
    
    Ctrl-w [number]+|-          # Increate or decrease size of window

References:

* https://www.linux.com/learn/tutorials/442415-vim-tips-using-viewports

Folding
-------

::

    :help folding

    zc          # close a fold
    zC          # close fold at all levels from here
    zo          # open a fold
    zO          # open a fold at all levels from here
    zr          # open fold for the whole buffer/file
    zR          # open folds at all levels in buffer/file
    zm          # close folds at current level in buffer
    zM          # close folds at all levels in the buffer

C++ scripts
-----------

=====
CTree
=====

* http://www.vim.org/scripts/script.php?script_id=1518

::

    :CTree              # display Class hierarchy

=======
TagList
=======

* http://www.vim.org/scripts/script.php?script_id=273

::

    :help TlistToggle       # show help for taglist
    :help taglist.txt       # show help for taglist

    :TlistOpen              # open taglist window

    :TlistClose             # close taglist window



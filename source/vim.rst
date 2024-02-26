vim
===

.. contents::

References
----------

* http://www.viemu.com/a-why-vi-vim.html
* http://www.keyxl.com/aaa8263/290/VIM-keyboard-shortcuts.htm

Compiling
---------

Checkout source from **git clone https://github.com/vim/vim.git**

https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source

::
    ./configure --enable-multibyte --enable-rubyinterp --enable-pythoninterp --enable-perlinterp --enable-luainterp --enable-gui=gtk2 --enable-cscope --with-features=huge --prefix=/usr  --enable-fail-if-missing

    sudo make install

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

Linux
=====

Install Vundle
--------------

Install vundle from here https://github.com/VundleVim/Vundle.vim

::

    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

    Add the following to .vimrc

	set nocompatible              " be iMproved, required
	filetype off                  " required

	" set the runtime path to include Vundle and initialize
	set rtp+=~/.vim/bundle/Vundle.vim
	call vundle#begin()
	" alternatively, pass a path where Vundle should install plugins
	"call vundle#begin('~/some/path/here')

	" let Vundle manage Vundle, required
	Plugin 'VundleVim/Vundle.vim'

	call vundle#end()            " required
	filetype plugin indent on    " required

When adding new plugins, add the plugin in .vimrc. Reopen vim, and run :PluginInstall

Install taghighlight
--------------------

Install from https://github.com/kendling/TagHighlight
* Add "Plugin 'kendling/taghighlight'" to .vimrc. Reload vim and run :PluginInstall. After install go to a folder with ctags files and open any cpp file and run :UpdateTagsFile
* Some :UpdateTagsFile fails with python, use the vim script below

Install from the vim script https://www.vim.org/scripts/script.php?script_id=2646
* Download and extract in .vim folder
* After install go to a folder with ctags files and open any cpp file and run :UpdateTagsFile

Install YouCompleteMe
---------------------

Install YouCompleteMe from https://github.com/ycm-core/YouCompleteMe

Use :YcmToggleLogs to check YCM logs if tags are not getting loaded


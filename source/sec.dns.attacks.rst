Security : DNS Attacks
======================

.. contents::

DNS Spoofing
------------

**DNS Spoofing** attacks against web browsers are primarly intended to trick a browser into violating the same origin policy. Since same-origin applies to hosts, but not IP addresses, an attacker could use a DNS server he controls to erase the distinction between two different servers. This is the basic attack sequence

#.   Get the victim browser a site (probably using XSS) on a attacker-controlled domain.
#.   The victim browser queries the DNS server for the attack domain and receives the attacker-controlled IP address.
#.   The victim browser requests content from the attack server and becomes infected with the attack code.
#.   The attack pauses long enough for the DNS record's TTL to expire.
#.   The attack code initiates a new request to the DNS server, and requeries DNS server.
#.   The attack DNS server responds with the IP address of the victim server.
#.   The attack code connects to the victim server, and does something useful
#.   The results are returned to the user


DNS Pinning
-----------

To prevent DNS Spoofing attacks, browser makers introduced DNS pinning. This forces the browser into using a single IP address for any given host. Once the DNS response has been received, the browser will pin it in the cache as long as the browser is running.

Fundamentals of Anti-DNS Pinning Attacks
----------------------------------------

Most techinques for defeating DNS pinning exploit the necessity to eventually expire the DNS record. One method has this sequence

#.   The victim browser load the attack code
#.   The victim broswer closes, either by user action or by attack
#.   When the browser is opened, the attack code is loaded from the disk cache
#.   The attack code initiates a request to the attack web server ( should be victim web server ? )
#.   The attack DNS-server responds with the IP address of the victim server


This technique is difficult to defeat by browser design because the browser must dump its DNS cache eventually, and becasue a disk based content cache is considered critical for modern browsers.

Considering that major web browsers do not fully implement DNS pinning, there is a much simpler attack. To support DNS-based fault tolerance, browsers will dump their DNS cache if the web browser becomes unavailable. The attack sequence becomes much simpler to execute

#.   The victim browser loads the attack code
#.   The attacker firewalls the attack web server
#.   The attack code initiates a request to the attack web server
#.   The request times out and the browser dumps its DNS cache
#.   The browser requeries and receives the IP address of the victim server


Practical Anti-DNS Attacks Using Javascript
-------------------------------------------

**Victim Browser** : Tricked into visiitng a malicious site, probably via XSS, the victim browser loads code that periodically polls the attack server for new commands. Ex. Javascript appends a new script tag onto the document body. The source of the tag is a request to the controller script, which returns either a blank document, or new JavaScript commands.

**Browser based JavaScript Proxy** : The primary purpose of this code is to relay requests and responses between the attack server and the victim web server. In the demonstatrion, it is loaded in an iFrame from the attack server by the victim browser's polling process.

**Controller script** : A CGI script with many functions identified by a 'command' parameter. The script is hosted on two IP addresses; one is used for performing the anti-DNS pinning attack with the randomly generated hostname, the other is used for communicating commands between other components. Key functions include

#.   An attack console listing all active victim browsers, and commands that can be sent
#.   Periodically polled by the victim browser for new commands
#.   Changes DNS records and firewall rules as needed to facilitate the actual anti-DNS pinning attack
#.   Periodically polled by the Javascript proxy for new requests to process
#.   Receives the HTTP responses from the JavaScript proxy


Data Exchange
-------------

**JavaScript Proxy and victim web server**
        The XMLHTTPRequest ( XHR) object is used to initiate requests to the web server. Normally XHR can only handle text data and will effectively strip off the high ASCII bit. By setting the character to 'x-user-defined', the browser will retain all 8-bits of data, allowing for full binary data support.

**Javascript Proxy to Controller Script**
        Because of the same origin rule, XHR is not suitable for returning data to the attack server. There are two methods used in the demonstration. If it is a small amount of text data, an image object is created with the source pointing at the controller script. The data is included as a parameter value in the URL's query string. When the image is appended to the document, the browser will automatically generate the request. No image is actually returned by the controller script.

**Controller script to JavaScript Proxy**
        Since a browser cannot accept inbound network connections, the JavaScript proxy must initiate all communication. When the JavaScript proxy polls the contorller script for data (such as the next HTTP request to process), the response is JavaScript file with the data set in variables that can be retrieved by the JavaScript proxy.

In essence, this is intentional XSS: the document is loaded the randomly generated hostname, but the script is loaded from the attack server's secondary IP address (or secondary hostname). As a result, some anti-XSS filters might block this request. However, no XSS is required for a successful attack.

There are several other methods to transfer data from the controller script besided XSS. While the same-origin policy prevents most explicit data exchange, JavaScript can still infer data about content from different origins. For example: the dimensions of an image are accessible in JavaScript, regardless of which server provided the file. This allows for a series of images to be requested by JavaScript with one byte encoded in the width and one byte in the height. Firefox will load bitmap with headers, but no graphic content, allowing the files to be stripped down to 66-bytes. While this technique is slow, it is effective. Considering that cross-domain image loading is very common on the internet, it would be extermely difficult to detext and block.

A similar technique tunnels data through dynamically loaded Cascading Style Sheets. Again, most data in a different origin CSS cannot be directly accessed by JavaScript. However, some data in a style class can be inferred once it is applied to a document component. Margin sizes are one example, Firefox allows margins to be set to millions to pixels, allowing at least two bytes of data to be encoded in each margin setting. Bulk data can be transferred by creating series of sequentially named classes. Once the style sheet is loaded, it is trivial for JavaScript to apply each class to a DIV tag, measure the actual margin sizes, and then decode the data. Since an unlimited number of classes can be defined in a single style sheet, performance is much better than the image dimension method, and approaches the XSS method.


Web 2.0
=======

.. contents::

Web 2.0
-------
It facilitates collaboration and sharing. Social networking sites , wikis, podcasts, RSS feeds are all based on Web2.0. Web 2.0 does not have any changes to any technical specifications. It mostly evolved by collaboration between different users of web. It allows the use of internet as a platform for interlinking rather than isolated information. Web.2.0 allows web applications to run like locally-available software in the perception of the user.

Web2.0 allows users to do more than just retrieve information, it allows users to change information. Users can run applications directly from their browser. It is very interactive.

Examples are

*    Altavista vs Google
*    Hotmail vs Yahoo mail
*    Mapquest vs Google maps
*    geocities vx blogger


Rich Internet Applications
--------------------------
Web applications which are as interactive as desktop applications. Examples are

*    AJAX
*    FLEX
*    OpenLazlo
*    Silverlight
*    JavaFX

These applications are run in a secure environment called a sandbox. These applications use server push techniques.

Ajax
----
Aysnchronous javascript and xml. Uses XMLHttpRequestObject to make asynchronous calls to the browser. User performs a page, javascript makes a asynchronous call to the server behind the scene and gives the callback function which should be called when data returns. When the server sends back the informatoin it is updated on the page without refreshing the whole page. It reduces the amount of data that has to be sent on the network and the page need not be in hanged state waiting for the reply from the server to come.
Javascript is an interpreted language.

Example

::

        function ajax(url, vars, callbackFunction){
                var request = window.XMLHttpRequest ? new XMLHttpRequest (): new ActiveXObject("MSXML2.XMLHTTP.3.0");
                request.open("POST", url, true);
                reuqest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");  
                request.onreadyStateChange = function(){
                        if(request.readyState == 4 && request.status == 200 )
                                if(request.responseText)
                                        callbackFunction(request.responseText);
                };
                request.send(vars);
                }


Adobe FLEX
----------
It allows flash movies to be specified in XML called MXML. FLEX SDK compiles MXML into a flash movie. The advantage here is now flash file is a text file which can be viewed and diffed.

Microsoft Silverlight
---------------------
Similar to FLEX used to create animation, vector graphics, audio-video playback. .NET languages and development tools can be used to create silverlight applications. It is scriptable with JavaScript. Also works with XAML (XML-based language created and used by microsoft for use in the .NET framwork 3.0 technologies).

DOM (document-object model)
---------------------------
Allows a platform and language-independent object model for representing HTML and XML and related formats. AJAX uses DOMs to refresh a part of the page without refreshing the whole page.

Cascading Style Sheets
----------------------
It is a language to describe the colours, fonts, layout, and other presentation aspects of a document. It allows separating of persentation from the content. It allows to specify a priority scheme to determine which style sheet to use incase of multiple style sheets, hence called "cascading".

DHTML
-----
It is a collection of technologies used together to create interactive web sites. It allows combining of HTML, Javascript, CSS and DOM> It allows DOM objects to be exposed to javascript, so that javascript can modify these dom objects.

REST or XML or JSON(Javascript object notation) APIs
----------------------------------------------------
These APIs provide a way for applications like AJAX to send RPCs to the server and retrieve information.

REST
----
Representational State Transfer. Its a way of sending RPCs across network.

SOAP
----
Simple Object Access Protocol. Its a protocol for exchanging XML-based RPC messages over computer networks normally using HTTP/HTTPS, similar to REST.

RSS (Really Simple Syndication)
-------------------------------
Allows new content to be sent to subscribers. Websites would tell in a standard format what are the new changes.

Mashups
-------
combine web content from various source and create your own website.


Copyright, center and left
--------------------------
Thw way it was charcterized politcally, you had copyright which is what the big companies use to lock everything up; you had copyleft, which is free software's way of making sure they can't lock it up; and then berkley had what we called 'copycenter', which is 'take it down to the copy center and make as many copies as you want.'

Kirk McKusick, BSDCon 1999

Offline RIA applications
------------------------
Its a breed of applications which can work offline, they synchronise state when network is available. Google Gears is one of the example. Google Gears installs a database engine, based on SQLite on the client system which locally caches the data. Pages can use this local cache rather than from the online service and synchronise when necessary. This data store can bee accessed via a javascript API.

Single Sign on
--------------
Single Sign on allows multiple webserver to assume same authentication server and avoid multiple logons. When user logs into a webserver mail.yahoo.com we provide the username and password, and when we visit another website say maps.yahoo.com then the website would automtically redirect to the authentication server which would find that the user has already authenticated when, and would send a key-id to maps.yahoo.com giving information about the user. 

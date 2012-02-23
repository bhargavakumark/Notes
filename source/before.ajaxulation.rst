Before Ajaxulation
==================

In order to make partial page updates more useful, it can be worthwhile to increase the granuality of your server-side functions. It would be pointless to expose a single Do-It operation that provides no user feedback while it is processing. Providing more finely grained server-side api helps third party websites to create effective mashups from your application. On the other hand, attackers can easily subver the intended application workflow and call functions out of order, change the parameter values of the calls, or omit the calls entirely

A real world example of this design flaw is a function which updates the password for a user

.. code-block:: c

        public string updatePassword(string custID, string newPassword)

There are not authentication ro authorization checks enforced on this code. anyone can call this function and change any user's password to any desired value. This code was probably originally a private method called during a page postback, and auth was enforced earlier in the call stack. However once the application was converted to ajax and the method visibility change to publc, the code became vulnerable.

Asynchrous operation implies mutli-threaded operations. The use of multiple threads of execution opens the door to classic threading problems such as race conditions and deadlocks.


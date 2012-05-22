Security : Interface Fuzzing
============================

**Fuzzing** is a technique that sends various different inputs into the test target. It may send malformed characters or special characters such as a single quote.

The result of fuzzing is usually analysed using two different approaches

*   Signature analysis
*   Behaviour analysis

**Signature analysis** analyses the response to see whether anything in the reponse matches any of the known signatures that have been known to be indications that a vulnerability exists.

**Behaviour analysis** is looking for a particular string to appear in the response, this approach looks at the behaviour of the application. Are the results same as before ? How has the response changed?

**Fuzzing** is simply another term for interface robustness testing. Robustness testing often indicates security testing of user accessible interfaces, often called the attack surface.

**White box fuzzing** indicates access to source code. Black-box indicates the ability to supply data to running program, but no source code. In Grey box while no access to source code is directly granted, it is possible to monitor the running executable in as much detail as a debugger and/or static binary analysis will permit.

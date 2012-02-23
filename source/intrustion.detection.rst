Intrustion Detection
====================

.. contents::

Network Intrusion Detection Systems (NIDS)
------------------------------------------

Web Application Firewalls (WAFs), work by interfacing with the web server running the web application at the top level of the network stack, thus having the ability to analyzing encrypted data ( the web server performs the decryption) as well as HTTP meta data.

Signature Based Systems (SBS) based on pattern matching engines, use a database containing signatures of well-known attacks to detect malicious activities. Attack patterns can be found in lict data, generating false positive alerts.

Anamoly-Based systems (ABSs) usually establish an ad hoc model describing the behaviour of the monitored system and flag any deviating activity as suspicious. Therefore these systems are able to detect new attacks as they take place, without any previous knowledge, however an extensive training phase is required to build the model and because of their nature, ABSs are well-known to generate a higher false positive rate than SBSs.


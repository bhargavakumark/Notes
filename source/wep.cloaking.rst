WEP Cloaking
============

WEP cracking tools work by collecting WEP encrypted packets over the air, then run them through these statistical attack filters and try to converge to the authorised network's key. Only those packets containing weak IVs help in the cracking process. An IV is the initialisation vector which is transmitted in the clear with each WEP encrypted packet and is used along with the WEP key to decrypt the packet. A weak IV is an IV which satisfies one or more of the FMS and Korek statistical attack conditions.

WEP Cloaking technique sends spoofed WEP encrypted packets a.k.a 'chaff' into the air. These packets are spefically crafted to try and confuse WEP cracking tools which subsequently fail to crack the WEP key. The MAC header would be spoofed o use addresses of the Access Points and clients of the authorized network that the technique is intended to protect. The chagg packtes thus get homegenously mixed with authorized network packets and it is difficult to tell them apart by glancing at a pakcet trace.

WEP cracking is byte by byte process. Once the first byte is cracked we move on tot the next byte. All the guessed bytes will be used in guessing into the next bytes. Aircrack prints the votes in favor of the possibilites for that byte and choosed the 'guessed byte' as the one with the highest vote. In prescence of chaffing we will demonstrate that the votes for each possibility for the byte in question show an abnormal bias towards same values.

Sequence number based analysis is a well established way of detecting spoofed packets. Because the sequence number space is small and rewinds quite often, we also use IV based analysis for detecting spoofed packets. By using the sequence number and IV tracing as the preprocessor WEP cracking tools such as Aircrack are easily able to crack the key in the prescence of chaffing.


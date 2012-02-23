whois
=====

The whois service can also help you figure out the purpose of a given domain. Unfortunately, there are many whois serversmost good administrators of top-level domains run oneand they don't talk to each other like nameservers do. Consequently, the first step to using whois is finding the right whois server.

One of the easiest places to start your search for the right whois server is at http://www.allwhois.com (Figure 3-1). We mentioned earlier that this site has a list of the web sites for each country code's top-level domain; it also sports a unified whois search facility.

::

        $ nslookup 7dyn94.ztm.casema.net
           
        Name: 7dyn94.ztm.casema.net
        Address: 212.64.110.94

        $ whois 212.64.110.94@whois.arin.net
        [whois.arin.net]
        European Regional Internet Registry/RIPE NCC (NET-RIPE-NCC-)
           These addresses have been further assigned to European users.
            Contact information can be found in the RIPE database, via the
            WHOIS and TELNET servers at whois.ripe.net, and at
            http://www.ripe.net/db/whois.html
        Netname: RIPE-NCC-212
        Netblock: 212.0.0.0 - 212.255.255.255
        Maintainer: RIPE
        Coordinator:
        RIPE Network Coordination Centre  (RIPE-NCC-ARIN) nicdb@RIPE.NET
        +31 20 535 4444
        Fax- - +31 20 535 4445
        Domain System inverse mapping provided by:
        NS.RIPE.NET                  193.0.0.193
        NS.EU.NET                    192.16.202.11
        AUTH03.NS.UU.NET             198.6.1.83
        NS2.NIC.FR                   192.93.0.4
        SUNIC.SUNET.SE               192.36.125.2
        MUNNARI.OZ.AU                128.250.1.21
        NS.APNIC.NET                 203.37.255.97
        To search on arbitrary strings, see the Database page on
        the RIPE NCC web-site at http://www.ripe.net/db/
        Record last updated on 16-Oct-1998.
        Database last updated on 9-Nov-2000 07:02:34 EDT.
        The ARIN Registration Services Host contains ONLY Internet
        network information: Networks, ASNs and related POCs.
        Use the whois server at rs.internic.net for DOMAIN related
        Information and whois.nic.mil for NIPRNET Information.

        $ whois casema.net@whois.networksolutions.com 
        Registrant:
        N.V. Casema (CASEMA-DOM)
            P.O. Box 345
            Delft, 2600 AH
            THE NETHERLANDS
            Domain Name: CASEMA.NET
            Administrative Contact:
            Network Operations Centre  (NOC137-ORG)  domain-tech@EURO.NET
            EuroNet Internet BV
            Muiderstraat 1
            Amsterdam
            NL
            +31 20 5355555
            Fax- +31 20 5355400
            Technical Contact, Zone Contact:
            Davids, Marco  (MD2446)  domaintech1@CASEMA.NET
            N.V. Casema - IKC
            Brassersplein 2
            Delft
            ZH
            2612 CT
            NL
            +31(0)15 8881000 (FAX) +31(0)15 8881099
            Billing Contact:
            Finance Departement  (FD5-ORG)  nic-invoices@EURONET.NL
            EuroNet Internet BV
            Postbus 11095
            Amsterdam
            NL
            +31 20 5355555
            Fax- +31 20 5355400
            Record last updated on 13-Jun-2000.
            Record expires on 30-Jan-2001.
            Record created on 28-Jan-1997.
            Database last updated on 7-Nov-2000 19:15:09 EST.
            Domain servers in listed order:
            NS.CASEMA.NL                 195.96.96.97
            NS1.CASEMA.NET               195.96.96.33


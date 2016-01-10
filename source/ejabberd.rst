ejabberd
++++++++

Change admin users and hostname to

::

    %% Admin user
    {acl, admin, {user, "bhargava", "useless"}}.
    {acl, admin, {user, "bhargava", "localhost"}}.

    %% Hostname
    {hosts, ["useless"]}.

Adding entry for your hostname in DNS or /etc/hosts

Ports
=====

::

    tcp        0      0 0.0.0.0:5269            0.0.0.0:*               LISTEN     
    tcp        0      0 0.0.0.0:5280            0.0.0.0:*               LISTEN     
    tcp        0      0 0.0.0.0:5222            0.0.0.0:*               LISTEN     



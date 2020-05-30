VMware: SDK
===========

* SDK 7.0   - file:///Users/bhargava/VMware/SDK-7.0/vSphereManagementSDKReadme.html
* SDK 6.7.1 - file:///Users/bhargava/VMware/SDK-6.7.3/vSphereManagementSDKReadme.html
* SDK 6.7.3 - file:///Users/bhargava/VMware/SDK-6.7.1/vSphereManagementSDKReadme.html
* SDK 6.5   - file:///Users/bhargava/VMware/SDK-6.5/vSphereManagementSDKReadme.html
* SDK 6.0   - file:///Users/bhargava/VMware/SDK-6.0/vSphereManagementSDKReadme.html
* SDK 5.5   - file:///Users/bhargava/VMware/SDK-5.5/vSphereManagementSDKReadme.html
* SDK 5.1   - file:///Users/bhargava/VMware/SDK-5.1/vSphereManagementSDKReadme.html
* SDK 5.0   - file:///Users/bhargava/VMware/SDK-5.0/vSphereManagementSDKReadme.html
* SDK 4.1   - file:///Users/bhargava/VMware/SDK-4.1/doc/ReferenceGuide/index.html
* SDK 5.5 perl  - file:///Users/bhargava/VMware/SDK-5.5-perl

Esxcli from SDK
===============

.. code-block:: powershell

    pwsh

    PS > Connect-VIServer <VCenter> -User <username> -Password <12!Pass345>

    PS > Get-EsxCli -VMhost <ESX-name> -V2

    # Invoke an esxcli command without args
    PS > $esxcli.storage.core.device.inquirycache.list.Invoke()

    # Create args using type
    PS > $params=$esxcli.storage.core.device.inquirycache.set.CreateArgs()
    PS > $params.applyall=$false
    PS > $params.ignore = $true
    PS > $params.device='naa.638a95f2258000039000000000000620'
    PS > $params

    # Or create args like a hash
    PS > $params = @{ device = "naa.638a95f000000211ec9dffe0000114a1"; perenniallyreserved = "true" }

    # Invoke with args
    PS > $esxcli.storage.core.device.setconfig.Invoke($params)

    PS > $params = @{ device = "naa.638a95f000000211ec9dffe0000114a1" }
    PS > $esxcli.storage.core.device.list.Invoke($params)

    # Run a command and gather logs output
    PS > $errorCode = { $esxcli.storage.core.device.setconfig.Invoke($params) }
    PS > Get-ErrorReport -ProblemScript $errorCode -Destination device.setconfig.trace 



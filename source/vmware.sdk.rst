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

Running from mob viewer

* Find the host-* entry for the ESX. If for ESX esx1.abc.com, moid is host-10, then use ManagedMethodExecuter-10
* Connect to mobviewer https://<vcenter>/mob/?moid=ManagedMethodExecuter-10&method=executeSoap

::

    moid : ha-cli-handler-storage-core-device-inquirycache
    version : vim25/5.0
    method : vim.EsxCLI.storage.core.device.inquirycache.set
    argument :
          <argument xmlns="urn:internalreflect">
            <name>applyall</name>
            <val>&lt;applyall xmlns="urn:vim25"&gt;False&lt;/applyall&gt;</val>
          </argument>
          <argument xmlns="urn:internalreflect">
            <name>device</name>
            <val>&lt;device xmlns="urn:vim25"&gt;naa.638a95f2258000039000000000000620&lt;/device&gt;</val>
          </argument>
          <argument xmlns="urn:internalreflect">
            <name>ignore</name>
            <val>&lt;ignore xmlns="urn:vim25"&gt;True&lt;/ignore&gt;</val>
          </argument>




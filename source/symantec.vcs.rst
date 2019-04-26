Symantec : VCS
==============

.. contents:: 

Agents/Agent Framework
----------------------
*  The agent framework ensures that only one entry point is running for a given resource at one time. If multiple requests are received or multiple events are scheduled for the same resource, the agent queues them and processes them one at a time.

===================
Monitor Entry Point
===================
The monitor entry point receives a resource name and ArgList attribute values as input (see “ArgList reference attributes” on page 144). 
 
*  A C++ entry point can return a confidence level of 0–100. A script entry point combines the status and the confidence level in a single number.

A script entry point combines the status and the confidence level in the exit value. For example:
* 99 indicates unknown.
* 100 indicates offline.
* 101 indicates online and a confidence level of 10.
* 102–109 indicates online and confidence levels 20–90.
* 110 indicates online and confidence level 100.
* 200 indicates intentional offline.

==================
Online Entry Point
==================
The online entry point receives a resource name and ArgList attribute values as input. It returns an integer indicating the number of seconds to wait for the online to take effect.

===================
Offline Entry Point
===================
When the offline procedure completes, the monitor entry point is automatically called by the framework to verify that the resource is offline.  If the return value is not zero, the agent framework waits the number of seconds indicated by the return value to call the monitor entry point for the resource.

=================
Clean Entry Point
=================
The reason for calling the entry point is encoded according to the following enum type:

.. code-block:: c

	enum VCSAgWhyClean {
		VCSAgCleanOfflineHung,
		VCSAgCleanOfflineIneffective,
		VCSAgCleanOnlineHung,
		VCSAgCleanOnlineIneffective,
		VCSAgCleanUnexpectedOffline,
		VCSAgCleanMonitorHung
	};

For script-based Clean entry points, the Clean reason is passed as an integer:

.. code-block:: bash

	0 ==> offline hung
	1 ==> offline ineffective
	2 ==> online hung
	3 ==> online ineffective
	4 ==> unexpected offline
	5 ==> monitor hung

The agent supports the following tasks when the clean entry point is implemented:
*  Automatically restarts a resource on the local system when the resource faults. (See the RestartLimit attribute for the resource type.)
*  Automatically retries the online entry point when the attempt to bring a resource online fails. (See the OnlineRetryLimit attribute for the resource type.)
*  Enables the engine to bring a resource online on another system when the online entry point for the resource fails on the local system.
*  For the above actions to occur, the clean entry point must run successfully, that is, return an exit code of 0.

==================
Action Entry Point
==================
Each action is identified by an action_token. The action_token is a name for an action. The list of supported actions (described by the action_tokens) for a resource type is described in the SupportedActions keylist.

Make sure the action scripts reside within an action directory under the agent directory. Create a script for each action. Use the correct action_token as the script name.

The action entry point exits with a 0 if it is successful, or 1 if not successful.  The command hares -action exits with 0 if the action entry point exits with a 0 and 1 if the action entry point is not successful.  The agent framework limits the action entry point output to 2048 bytes.

========================
attr_changed entry point
========================
This entry point provides a way to respond to resource attribute value changes.  The attr_changed entry point is called when a resource attribute is modified, and only if that resource is registered with the agent framework for notification.  The attr_changed entry point receives as input the resource name registered with the agent framework for notification, the name of the changed resource, the name of the changed attribute, and the new attribute value.

.. code-block:: sh

	attr_changed <resource_name> <changed_resource_name> <changed_attribute_name> <new_attribute_value>

The exit value is ignored.

================
Open entry point
================
When an agent starts, the open entry point of each resource defined in the configuration file is called before its online, offline, or monitor entry points are called. This allows you to include initialization for specific resources.  Most agents do not require this functionality and will not implement this entry point.  The open entry point is called whenever the Enabled attribute for the resource changes from 0 to 1.

=================
Close entry point
=================
The close entry point is called whenever the Enabled attribute changes from 1 to 0, or when a resource is deleted from the configuration on a running cluster and the state of the resource permits running the close entry point.

====================
shutdown entry point
====================
The shutdown entry point is called before the agent shuts down. It performs any agent cleanup required before the agent exits. It receives no input and returns no value.

=================
Logging in agents
=================

**VCSAG_SET_ENVS**
	he VCSAG_SET_ENVS function is used in each script-based entry point file. Its purpose is to set and export environment variables that identify the agent’s category ID, the agent’s name, the resource’s name, and the entry point’s name.  With this information set up in the form of environment variables, the logging functions can handle messages and their arguments in the unified logging format without repetition within the scripts.


**VCSAG_LOG_MSG** 
	function can be used to pass normal agent messages to the halog utility.

::

	Severity Levels (sev)	: “C” - critical, “E” - error, “W” - warning, “N” - notice, “I” - information; place error code in quotes

	Message (msg)		: A text message within quotes; for example: “One file copied”

	Message ID (msgid)	: An integer between 0 and 65535

	Encoding Format		: UTF-8, ASCII, or UCS-2 in the form: “-encoding format”

	Parameters		: Parameters (up to six), each within quotes

::

	VCSAG_LOG_MSG "C" "$count files found" 140 "-encoding utf8" "$count"

**VCSAG_LOGDBG_MSG**
	This function can be used to pass debug messages to the halog utility.

::

	Severity (dbg)		: An integer indicating a severity level, 1 to 21.
	Message (msg)		: A text message in quotes; for example: “One file copied”
	Encoding		: Format UTF-8, ASCII, or UCS-2 in the form: “-encoding format”
	Parameters		: Parameters (up to six), each within quotes

::

	VCSAG_LOGDBG_MSG <dbg> "<msg>"
	VCSAG_LOGDBG_MSG 1 "This is string number 1"

	VCSAG_LOGDBG_MSG <dbg> "<msg>" "-encoding <format>" "$count"

**Using the functions in scripts**
	The script-based entry points require a line that specifies the file defining the logging functions. Include the following line exactly once in each script. The line should precede the use of any of the log functions.

Shell Script include file

::

	${VCS_HOME:-/opt/VRTSvcs}/bin/ag_i18n_inc.sh

Perl Script include file

::

	use ag_i18n_inc;

Static attributes
-----------------
You can remove the overridden values of static attributes by using the hares -undo_override option from the command line.

=============
ActionTimeout
=============
After the hares -action command has instructed the agent to perform a specified action, the action entry point has the time specified by the ActionTimeout attribute (scalar-integer) to perform the action. The value of 

ActionTimeout may be set for individual resources, if overridden.

Whether overridden or not, no matter what value is specified for ActionTimeout, the value is internally limited to the value of MonitorInterval/2. MonitorInterval attribute description is given below.

============
ConfInterval
============
Specifies an interval in seconds. When a resource has remained online for the designated interval (all monitor invocations during the interval reported ONLINE), any earlier faults or restart attempts of that resource are ignored.  This attribute is used with ToleranceLimit to allow the monitor entry point to report OFFLINE several times before the resource is declared FAULTED. If monitor reports OFFLINE more often than the number set in ToleranceLimit, the resource is declared FAULTED. However, if the resource remains online for the interval designated in ConfInterval, any earlier reports of OFFLINE are not counted against ToleranceLimit.

The agent framework uses the values of MonitorInterval (MI), MonitorTimeout (MT), and ToleranceLimit (TL) to determine how low to set the value of ConfInterval. The agent framework ensures that ConfInterval (CI) cannot be less than that expressed by the following relationship:
	(MI + MT) * TL + MI + 10

Lesser specified values of ConfInterval are ignored. For example, assume that the values are 60 for MI, 60 for MT, and 0 for TL. If you specify any value lower than 70 for CI, the agent framework ignores the specified value and sets the value to 70.

ConfInterval is also used with RestartLimit to prevent the engine from restarting the resource indefinitely. The engine attempts to restart the resource on the same system according to the number set in RestartLimit within ConfInterval before giving up and failing over. However, if the resource remains online for the interval designated in ConfInterval, earlier attempts to restart are not counted against RestartLimit. Default is 600 seconds.

============
ManageFaults
============
A service group level attribute. ManageFaults specifies if VCS manages resource failures within the service group by calling clean entry point for the resources. This attribute value can be set to ALL or NONE. Default = ALL.  If set to NONE, VCS does not call clean entry point for any resource in the group. User intervention is required to handle resource faults/failures. When ManageFaults is set to NONE and one of the following events occur, the resource enters the ADMIN_WAIT state:

===============
OnlineWaitLimit
===============
Number of monitor intervals to wait after completing the online procedure, and before the resource is brought online. If the resource is not brought online after the designated monitor intervals, the online attempt is considered ineffective.  This attribute is meaningful only if the clean entry point is implemented.

=======
RegList
=======
RegList is a type level keylist attribute that can be used to store, or register, a list of certain resource level attributes. The agent calls the attr_changed entry point for a resource when the value of an attribute listed in RegList is modified.

By default, the attribute RegList is not included in a resource’s type definition, but it can be added using either of the two methods shown below.

.. code-block:: bash

	haattr -add -static resource_type RegList -keylist
	hatype -modify resource_type RegList attribute_name

============
RestartLimit
============
A non-zero value for RestartLimit causes the invocation of the online entry point instead of the failover of the service group to another system. The engine attempts to restart the resource according to the number set in RestartLimit before it gives up and attempts failover. However, if the resource remains online for the interval designated in ConfInterval, earlier attempts to restart are not counted against RestartLimit.

================
SupportedActions
================
The SupportedActions (string-keylist) attribute lists all possible actions defined for an agent, including those defined by the agent developer. The engine validates the action_token value specified in the hares -action resource action_token command against the SupportedActions attribute.

==============
ToleranceLimit
==============
A non-zero ToleranceLimit allows the monitor entry point to return OFFLINE several times before the ONLINE resource is declared FAULTED. If the monitor entry point reports OFFLINE more times than the number set in ToleranceLimit, the resource is declared FAULTED. However, if the resource remains online for the interval designated in ConfInterval, any earlier reports of OFFLINE are not counted against ToleranceLimit. Default is 0. The ToleranceLimit attribute value can be overridden.



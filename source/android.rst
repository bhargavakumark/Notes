Android Development
+++++++++++++++++++

.. contents::

Genymotion
==========

* Launch **genymotion** and start the device
* Get the device ip address using

::

    genyshell -c "devices list" | grep 192.168 | awk -F '|' '{print $5}'

* Connect adb to genymotion

::

    adb connect <ip>

adb
===

* Devices list - **adb devices**
* Connect to a device - **adb connect**
* Install apk - **adb install <apk-path>**
* Reinstall apk - **adb install -r <apk-path>**
* connect to logging - **adb logcat**
* starting an app - **adb shell am start -n "com.example.bhargava.useless_tvapp/.MainActivity"**
* shell - **adb shell**

SQLite
======

Connecting to sqlite from adb

::
    
    adb shell
    stty rows 60 cols 156
    sqlite3 -column -header data/data/com.example.bhargava.useless_tvapp/databases/Useless.db

    # optional if not passing this as command line
    sqlite> .header on
    sqlite> .mode column

    # List tables
    sqlite> .tables

    # normal sql queries
    sqlite> select * from reminder;

Layout
======

Resource Objects
----------------

Resource Objects

A resource object is a unique integer name that's associated with an app resource, such as a bitmap, layout file, or string.

Every resource has a corresponding resource object defined in your project's gen/R.java file. You can use the object names in the R class to refer to your resources, such as when you need to specify a string value for the **android:hint** attribute. You can also create arbitrary resource IDs that you associate with a view using the android:id attribute, which allows you to reference that view from other code.

The SDK tools generate the R.java file each time you compile your app. You should never modify this file by hand.

LinearLayout
------------

**LinearLayout** is a view group (a subclass of **ViewGroup**) that lays out child views in either a vertical or horizontal orientation, as specified by the **android:orientation** attribute. Each child of a LinearLayout appears on the screen in the order in which it appears in the XML.

Two other attributes, **android:layout_width** and **android:layout_height**, are required for all views in order to specify their size.

Because the LinearLayout is the root view in the layout, it should fill the entire screen area that's available to the app by setting the width and height to **"match_parent"**. This value declares that the view should expand its width or height to match the width or height of the parent view.

::

    <LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:tools="http://schemas.android.com/tools"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="horizontal" >
    </LinearLayout>

Fields
======

Text Field
----------

::

    <EditText android:id="@+id/edit_message"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:hint="@string/edit_message">
    </EditText>

* **android:id** uniqueid for each view. 
    * **@** is required when referring to any resource object in XML
    * **+** when defining a resourceid for first time
    * **id** resource type
    * **/edit_message** resource name

* **"wrap_content"** value specifies that the view should be only as big as needed to fit the contents of the view

* **android:hint** - This is a default string to display when the text field is empty. Instead of using a hard-coded string as the value, the "@string/edit_message" value refers to a string resource defined in a separate file. Because this refers to a concrete resource (not just an identifier), it does not need the plus sign. 

* **edit_message** should be declared in **res/values/strings.xml**

::

    <?xml version="1.0" encoding="utf-8"?>
    <resources>
        <string name="app_name">My First App</string>
        <string name="edit_message">Enter a message</string>
        <string name="button_send">Send</string>
        <string name="action_settings">Settings</string>
        <string name="title_activity_main">MainActivity</string>
    </resources>

Button
------

::

    <Button
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/button_send">
        android:onClick="sendMessage">
    </Button>

**"sendMessage"**, is the name of a method in your activity that the system calls when the user clicks the button.

Actions
-------

::

    /** Called when the user clicks the Send button */
    public void sendMessage(View view) {
        // Do something in response to button
    }

::

    public void sendMessage(View view) {
        Intent intent = new Intent(this, DisplayMessageActivity.class);
        EditText editText = (EditText) findViewById(R.id.edit_message);
        String message = editText.getText().toString();
        intent.putExtra(<some message code>, message);
        startActivity(intent);
    }

JSON jackson parser
===================

* http://www.journaldev.com/2324/jackson-json-processing-api-in-java-example-tutorial

Navigation keyboard/tab
=======================

* https://developer.android.com/training/keyboard-input/navigation.html


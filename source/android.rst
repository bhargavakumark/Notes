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

Installing google apps in genymotion : https://stackoverflow.com/questions/21986237/installing-google-apps-on-genymotion

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
    resize      # or run with custom size as "stty rows 60 cols 156" 
    sqlite3 -column -header data/data/com.example.bhargava.useless_tvapp/databases/Useless.db

    # optional if not passing this as command line
    sqlite> .header on
    sqlite> .mode column

    # List tables
    sqlite> .tables

    # normal sql queries
    sqlite> select * from reminder;

* http://touchlabblog.tumblr.com/post/24474398246/android-sqlite-locking - There is only one connection to DB, for both getReadableDatabase and getWriteableDatabase
* http://touchlabblog.tumblr.com/post/24474750219/single-sqlite-connection - why having single connection to DB which is never closed is fine
* https://stackoverflow.com/questions/14727006/sqlite-database-in-samsung-tab2-external-micro-sd-card/14744166#14744166 - SQLite on SD card on samsung
* https://stackoverflow.com/questions/11281010/how-can-i-get-external-sd-card-path-for-android-4-0
* http://v4all123.blogspot.in/2013/03/sqlite-databases-with-external-db.html

Material Design
===============

* http://android-developers.blogspot.in/2014/10/implementing-material-design-in-your.html

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

layout_weight
-------------

* https://stackoverflow.com/questions/3995825/what-does-androidlayout-weight-mean

**layout_weight** tells Android how to distribute your Views in a LinearLayout. Android then first calculates the total proportion required for all Views that have a weight specified and places each View according to what fraction of the screen it has specified it needs. In the following example, Android sees that the TextViews have a layout_weight of 0 (this is the default) and the EditTexts have a layout_weight of 2 each, while the Button has a weight of 1. So Android allocates 'just enough' space to display tvUsername and tvPassword and then divides the remainder of the screen width into 5 equal parts, two of which are allocated to etUsername, two to etPassword and the last part to bLogin:

::

    <LinearLayout android:orientation="horizontal" ...>
        <TextView android:id="@+id/tvUsername" android:text="Username" android:layout_width="wrap_content" ... />
        <EditText android:id="@+id/etUsername" android:layout_width="0dp" android:layout_weight="2" ... />
        <TextView android:id="@+id/tvPassword" android:text="Password" android:layout_width="wrap_content" />
        <EditText android:id="@+id/etPassword" android:layout_width="0dp" android:layout_weight="2" ... />
        <Button android:id="@+id/bLogin" android:layout_width="0dp" android:layout_weight="1" android:text="Login"... />
    </LinearLayout>

gravity vs layout_gravity 
-------------------------

* **android:gravity** sets the gravity of the content of the View its used on.
* **android:layout_gravity** sets the gravity of the View or Layout in its parent.

Don't use gravity/layout_gravity with a RelativeLayout. Use them for Views in LinearLayouts and FrameLayouts.

If I hadn't made the width and height of the TextViews larger than the text, then setting the gravity would have had no effect. So if you're using wrap_content on the TextView then gravity won't do anything. In the same way, if the LinearLayout had been set to wrap_content, then the layout_gravity would have had no effect on the TextViews.

* https://stackoverflow.com/questions/3482742/gravity-and-layout-gravity-on-android/26190050#26190050
* http://developer.android.com/reference/android/widget/LinearLayout.LayoutParams.html

margin vs padding
-----------------

Padding is inside of the border, margin is outside

* https://stackoverflow.com/questions/4619899/difference-between-a-views-padding-and-margin

ViewStub -  Views on demand
---------------------------

* https://developer.android.com/training/improving-layouts/loading-ondemand.html#ViewStub

ViewStub is a lightweight view with no dimension and doesn’t draw anything or participate in the layout. As such, it's cheap to inflate and cheap to leave in a view hierarchy. Each ViewStub simply needs to include the android:layout attribute to specify the layout to inflate.

The following ViewStub is for a translucent progress bar overlay. It should be visible only when new items are being imported into the application.

::

    <ViewStub
        android:id="@+id/stub_import"
        android:inflatedId="@+id/panel_import"
        android:layout="@layout/progress_overlay"
        android:layout_width="fill_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom" />

When you want to load the layout specified by the ViewStub, either set it visible by calling setVisibility(View.VISIBLE) or call inflate().

::

    ((ViewStub) findViewById(R.id.stub_import)).setVisibility(View.VISIBLE);
    // or
    View importPanel = ((ViewStub) findViewById(R.id.stub_import)).inflate();

Note: The inflate() method returns the inflated View once complete. so you don't need to call findViewById() if you need to interact with the layout.

Once visible/inflated, the ViewStub element is no longer part of the view hierarchy. It is replaced by the inflated layout and the ID for the root view of that layout is the one specified by the android:inflatedId attribute of the ViewStub. (The ID android:id specified for the ViewStub is valid only until the ViewStub layout is visible/inflated.)


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

Landscape/Portrait mode
=======================

::

    <activity android:name=".SomeActivity"
        android:label="@string/app_name"
        android:screenOrientation="portrait">

Android Support Library
=======================

* http://android-developers.blogspot.in/2015/04/android-support-library-221.html

Optimising Layout Hierarchies
=============================

* https://developer.android.com/training/improving-layouts/optimizing-layout.html

Fragment backstack
==================

* https://developer.android.com/guide/components/fragments.html
* https://stackoverflow.com/questions/12529499/problems-with-android-fragment-back-stack

dpi - dp/dip
============

::

    Logical Density    Friendly Name          Scale
    ===============    =============          =====
    160                  M DPI                1x
    240                  H DPI                1.5x
    320                 XH DPI                2x
    480                XXH DPI                3x

1dp == one pixel in 160dpi (MDPI) screen and scaled proportionally on higher and lower density screens

DP units keep things roughly **the same physical size** on every android device

Image Loader
============

* Universal Image Loader - https://github.com/nostra13/Android-Universal-Image-Loader
* Volley - https://developer.android.com/training/volley/index.html

Animations
==========

CardFlip
--------

https://developer.android.com/training/animation/cardflip.html

Saving State
============

http://trickyandroid.com/saving-android-view-state-correctly/

TV - Android TV
===============

Style for TV - https://developer.android.com/design/tv/style.html
Typography - https://www.google.com/design/spec/style/typography.html#
https://developer.android.com/training/tv/playback/browse.html
https://developer.android.com/training/tv/playback/card.html
https://developer.android.com/training/tv/playback/details.html
https://developer.android.com/training/tv/playback/now-playing.html
https://developer.android.com/training/tv/discovery/index.html
https://developer.android.com/training/tv/tif/index.html

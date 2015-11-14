IR - Infrared
+++++++++++++

IR Receiver in MAC
==================

* https://mauroandres.wordpress.com/2013/01/14/enabling-the-remote-on-a-macbook-pro-running-ubuntu-12-10/

Edit **/etc/lirc/hardware.conf** as

::

    REMOTE=”Apple Mac mini USB IR Receiver”
    REMOTE_MODULES=”usbhid”
    REMOTE_DRIVER=”macmini”
    REMOTE_DEVICE=”/dev/usb/hiddev0″

To use with irrecord

::

    sudo irrecord --device=/dev/usb/hiddev0 --driver=macmini testfile

IR Receiver - USB
=================

* http://www.irdroid.com/usb-infrared-transmitter/

The above link says its based on IRman driver (but still not able to use with that driver)

To use with irrecord

::

    sudo irrecord --device=/dev/ttyACM0 --driver=irman testfile

LIRC Client
===========

Save in **~/.lircrc**

::

    ##################################################
    #### Save as ~/.lircrc ###########################
    #### After modifying: ############################
    #### sudo /etc/init.d/lirc restart ###############
    ##################################################

    #############
    #### VLC ####
    #############

    begin
    prog = vlc
    button = KEY_PLAYPAUSE
    config = key-play-pause
    repeat = 0
    end

    begin
    prog = vlc
    button = KEY_MENU
    config = key-stop
    repeat = 0
    end

    begin
    prog = vlc
    button = KEY_REWIND
    config = key-jump-short
    repeat = 1
    end

    begin
    prog = vlc
    button = KEY_FORWARD
    config = key-jump+short
    repeat = 1
    end

    begin
    prog = vlc
    button = KEY_VOLUMEUP
    config = key-vol-up
    repeat = 1
    end

    begin
    prog = vlc
    button = KEY_VOLUMEDOWN
    config = key-vol-down
    repeat = 1
    end

    #################
    #### MPlayer ####
    #################

    #begin mplayer
    begin
    prog = mplayer
    button = KEY_PLAYPAUSE
    config = pause
    repeat = 15
    end

    begin
    prog = mplayer
    button = KEY_MENU
    config = stop
    repeat = 15
    end

    begin
    prog = mplayer
    button = KEY_REWIND
    config = seek -10
    repeat = 10
    end

    begin
    prog = mplayer
    button = KEY_FORWARD
    config = seek +10
    repeat = 10
    end

    begin
    prog = mplayer
    button = KEY_VOLUMEUP
    config = volume 1
    repeat = 1
    end

    begin
    prog = mplayer
    button = KEY_VOLUMEDOWN
    config = volume -1
    repeat = 1
    end
    #end mplayer

    ###############
    #### Totem ####
    ###############

    begin
    prog = Totem
    button = KEY_PLAYPAUSE
    config = play_pause
    end

    begin
    prog = Totem
    button = KEY_MENU
    config = fullscreen
    end

    begin
    prog = Totem
    button = KEY_FORWARD
    config = seek_forward
    end

    begin
    prog = Totem
    button = KEY_REWIND
    config = seek_backward
    end

    begin
    prog = Totem
    button = KEY_VOLUMEUP
    config = volume_up
    repeat = 1
    end

    begin
    prog = Totem
    button = KEY_VOLUMEDOWN
    config = volume_down
    repeat = 1
    end

    ###################
    #### Audacious ####
    ###################

    begin
    prog = audacious
    button = KEY_PLAYPAUSE
    config = PAUSE
    repeat = 16
    end

    begin
    prog = audacious
    button = KEY_MENU
    config = STOP
    repeat = 0
    end

    begin
    prog = audacious
    button = KEY_FORWARD
    config = NEXT
    repeat = 16
    end

    begin
    prog = audacious
    button = KEY_REWIND
    config = PREV
    repeat = 16
    end

    ################################################## ##############################
    #### Turn up and down the volume (Working by default on Feisty) ####
    ################################################## ##############################

    #begin
    #prog = irexec
    #button = KEY_VOLUMEUP
    #config = amixer set PCM 9+ & #amixer set PCM 3%+ &
    #repeat = 2
    #end

    #begin
    #prog = irexec
    #button = KEY_VOLUMEDOWN
    #config = amixer set PCM 9- & #amixer set PCM 3%- &
    #repeat = 2
    #end

    ##############################################
    #### Evince y OpenOffice (Presentations) ####
    #### start with line command:
    #### $ irxevent -d
    #### and kill with:
    #### $ killall irxevent
    ##############################################

    begin
    prog = irxevent
    button = KEY_PLAYPAUSE
    config = Key F11 CurrentWindow
    config = Key F5 CurrentWindow
    repeat = 0
    end

    begin
    prog = irxevent
    button = KEY_MENU
    config = Key Escape CurrentWindow
    repeat = 0
    end

    begin
    prog = irxevent
    button = KEY_REWIND
    config = Key Prior CurrentWindow
    repeat = 1
    end

    begin
    prog = irxevent
    button = KEY_FORWARD
    config = Key Next CurrentWindow
    repeat = 1
    end

    begin
    prog = irxevent
    button = KEY_VOLUMEUP
    config = Key ctrl-plus CurrentWindow
    repeat = 0
    end

    begin
    prog = irxevent
    button = KEY_VOLUMEDOWN
    config = Key ctrl-minus CurrentWindow
    repeat = 0
    end

IR Codes Database
=================

* http://www.irdroid.com/db/database/
* http://winlirc.sourceforge.net/remotes2/

Airtel IR Codes
===============

* http://www.hifi-remote.com/forums/viewtopic.php?t=15020&start=0&postdays=0&postorder=asc&highlight=

airtel remote control code 30014 ?

IrDroid
=======

* Remotes database - http://www.irdroid.com/db/database/
* USB Infrared transmitter - http://www.irdroid.com/usb-infrared-transmitter/
* USB Irdroid app source - https://github.com/Irdroid/Irdroid-USB/tree/master/UsbIrdroid

* USB IR transmitter design by Albert - http://www.huitsing.nl/irftdi/


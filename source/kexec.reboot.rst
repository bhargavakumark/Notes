kexec reboot
============

A package called kexec can speed up your reboots.

The system is simple, and consists of two parts: a kexec-enabled kernel and the kexec-tools package. Most modern kernels already support kexec functionality. As for the second part, you can get the kexec-tools software either from your distribution's repositories or from the kexec project page.To check if the current kernel suports kexec or not

::

	grep CONFIG_KEXEC=y /boot/config-`uname -r` && echo yes || echo no


When you load a new kernel by running kexec you are overwriting the existing kernel with the kernel you specify. While this has the effect of rebooting the system quickly, it also skips the process that resets all of your hardware to a "clean" state, which can have some unpredictable consequences depending on the hardware that you use. For example, the video card on my system is an old Nvidia GeForce2 Go, and I had been using the legacy driver from Nvidia for it. After using kexec to reboot, the video never worked correctly. When I switched to the open source driver, the video came up just fine. Outcomes like this may be as varied as the kinds of hardware that exist. You just need to be aware of the possibility of problems in case something happens that you don't expect.

You also need to know that kexec only reboots the kernel — it does not take care of any cleanup such as shutting down applications or unmounting disks. We are going to set up a script that will take care of the whole process.

Sample script to use (in /etc/init.d/reboot ?)

::

	do_stop () {

		UNAMER=`uname -r` # this checks the version of the kernel 

	       #This just puts all of the parameters for loading in one place
		KPARAMS="-l " # tells kexec to load the kernel

		# --append tells the kernel all of its parameters
		# cat /proc/cmdline gets the current kernel's command line
		KPARAMS=$KPARAMS"--append=\"`cat /proc/cmdline`\" "

		# this tells the kernel what initrd image to use
		KPARAMS=$KPARAMS"--initrd=/boot/initrd.img-$UNAMER "

		# this tells the kexec what kernel to load
		KPARAMS=$KPARAMS"/boot/vmlinuz-$UNAMER"
		
		# Message should end with a newline since kFreeBSD may
		# print more stuff (see #323749)
		log_action_msg "Will now restart"

		if [ -x `which kexec` ]; then # check for the kexec executable
			kexec $KPARAMS  # load the kernel with the correct parameters
			sync            # sync all of the disks so as not to lose data
			umount -a       # make sure all disks are unmounted
			kexec -e        # reboot the kernel
		fi

		#This next line should never happen.
		reboot -d -f -i
	}

You want to load the new kernel with the current command line because it is not going to get a command line from a bootloader. Also, you have to use the vmlinuz image because kexec doesn't support compressed images. The sync command simply makes sure that all of the data that might be cached is written to the disk; remember, kexec doesn't care about the state of the disks, but if you boot a new kernel without properly handling the disks, you will run into problems. The umount -a command then makes sure that all of your disks are not open for business, and kexec -e reboots the computer.

Unless you have a driver issue you should be presented with your normal login when the system comes back up. If you aren't, you might be able to log in with SSH or a serial terminal and shut your system down properly. If not, you will probably have to hard boot. When you get control over your computer again, check all of the commands and their syntax — you may have a typo. If not, you are probably looking at a driver issue. Look at /var/log/messages and the output of the dmesg command; they may give you a clue.

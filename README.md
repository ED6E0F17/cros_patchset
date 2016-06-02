Chromium OS for Raspberry Pi
============================

Initial notes:
--------------

* Don't expect to build this and have it work perfectly on a Raspberry Pi, it's a work-in-progress
* This guide will be much easier to follow if you've built Chromium OS before for another platform. If you've having trouble following it, try following the developer guide (linked before) to build an x86-generic image first, and then come back.
* If you want to help out, find me in #raspberrypi on Freenode IRC or submit a pull request

Prerequisites:
--------------

To get started, make sure you have the following:

* a 64-bit build machine, running Ubuntu version 15.04 (better running headless. Other versions/distros might work)
* an account with sudo access
* at least 8GB of RAM (whilst you might be able to build with less, it will be painfully slow, especially when it comes to building Chrome)
* a fast Internet connection - you'll need to download several gigabytes of source code, if your connection is slow, that won't be fun

Get the code:
-------------

First, you'll need to download the Chromium OS source code. To learn do so, and also how to setup your environment, check out this link: http://www.chromium.org/chromium-os/developer-guide

Once you've downloaded the code and you've reached the "4.3 Select a board" step, continue below.

Add the overlay:
----------------

The raspberrypi overlay is already part of ChromiumOS, although it does not build X or Chromium.

To build for the Raspberry Pi2B, you'll need to use the raspberrypi2 overlay provided by this repo. Until this is merged upstream into the Chromium OS project, you'll have to copy it manually across.

Find the folder named "overlays" in the "src" folder of the code you checked out. You'll see a number of folders with names starting "overlay-". Place the overlay-raspberrypi2 folder in this folder alongside the other overlays.

To build for RPI 2B use "raspberrypi2" instead of "raspberrypi" in the following guide.

Chromium (53) does not support arm64, use "raspberryp2" armv7 build for Pi 3B.

Board setup:
------------

You only need to run this once (unless you nuke the chroot):

<pre>
./setup_board --board=raspberrypi
</pre>

If you want to re-create the board root, run:

<pre>
./setup_board --board=raspberrypi --force
</pre>

You'll probably want to set the "backdoor" password for a development image to let yourself into a shell when the UI isn't working, to do that, use the following command:

<pre>
./set_shared_user_password
</pre>

Once prompted, enter a password, then press enter. As above, you only need to do this once.

Building an image:
------------------

Before we can build an image, we need to build all the required packages. Enter the following command to build those (and pray everything compiles):

<pre>
./build_packages --board=raspberrypi --withdev --nowithdebug --nowithautotest
</pre>

Go get a nice cup of tea, and maybe read a book.

Once all the packages have been successfully built, we can build a USB image by running the following command:

<pre>
./build_image dev --board=raspberrypi --noenable_rootfs_verification
</pre>

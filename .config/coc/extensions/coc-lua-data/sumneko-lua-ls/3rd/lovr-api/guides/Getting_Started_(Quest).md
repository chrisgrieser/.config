Getting Started
===

This guide explains how to use LÖVR on Oculus Android devices like the Oculus Quest.

After setting the device up for development, the LÖVR Android .apk is "sideloaded" onto the device.
From there, a LÖVR project on a PC can be sync'd to the device.

Device Setup
---

First, make sure your device is set up for development.  Oculus has an official device setup guide
for the [Oculus Quest](https://developer.oculus.com/documentation/quest/latest/concepts/mobile-device-setup-quest/),
but there are lots of other guides on the internet for how to do this.  The key things are:

- Enabling development mode on the device.
- Installing the `adb` tool used to communicate with the device.

Install the APK
---

Download the latest Android APK from the [Downloads page](https://lovr.org/downloads).

Install it to the device:

```
$ adb install lovr.apk
```

Try running it by navigating to the "Library" -> "Unknown Sources" menu of the headset and running
the `org.lovr.app` app.  You should see the no game screen.

Running a Project
---

Now we can create a LÖVR project, which is a folder with some code and assets in it.  Create a
folder called `hello-world` and add this code to a file named `main.lua` in there:

```
function lovr.draw()
  lovr.graphics.print('hello world', 0, 1.7, -3, .5)
end
```

Then use `adb` to sync it to the device:

```
$ adb push --sync /path/to/hello-world/. /sdcard/Android/data/org.lovr.app/files
```

Note the trailing `.` in the path to the project, it's important.

Restart the app.  You should see the "hello world" message!

Tips
---

- It is possible to restart the app from the command line by running:

```
adb shell am force-stop org.lovr.app
adb shell am start org.lovr.app/org.lovr.app.Activity
```

- For even faster restarts, use [`lodr`](https://github.com/mcclure/lodr) for live reloading.
- If you need to use `print` in Lua for debug messages, you can see those in a terminal by running
  `adb logcat -s LOVR`.

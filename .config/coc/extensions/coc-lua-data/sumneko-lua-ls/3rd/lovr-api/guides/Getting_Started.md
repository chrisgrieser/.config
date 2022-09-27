Getting Started
===

This guide will teach you how to install LÖVR, create a project, and run it. TL;DR version:

<img src="https://lovr.org/static/img/gettingStarted.png" width="400" height="515" class="flat">

Installing LÖVR
---

First, download LÖVR from the home page or click [here](https://lovr.org/download).  Extract the
zip archive and open up the folder.  You should see the `lovr.exe` executable and a bunch of `.dll`
files.

![Archive Contents](https://lovr.org/static/img/dlls.png)

Double click on `lovr.exe` to open LÖVR.  You should see a window with the LÖVR logo in it.  This is
what's shown if you run LÖVR without specifying a project.

![The Default Project](https://lovr.org/static/img/defaultProject.png)

> Note: If you're using a VR headset, you'll only see the logo if your headset is pointing in the
> forward direction.

We're going to make a project so we see something more interesting than the logo.

Creating a Project
---

A LÖVR project is just a folder.  The folder can have anything necessary for your app, like 3D
models, sound files, or Lua code.  There isn't any required structure for the folder, so you can
organize it however you want.

There is one special file that LÖVR looks for though, called `main.lua`.  If you put a `main.lua`
file in your project folder, LÖVR will run the code in there when the project starts.

Create a file called `main.lua` in a project folder and type the following Lua code in it:

```
function lovr.draw()
  lovr.graphics.print('hello world', 0, 1.7, -3, .5)
end
```

Don't worry if you're confused about the code, it's not important to understand it all right now.
In short, we declared the `lovr.draw` callback and used `lovr.graphics.print` in there to render
some text in the world.  We'll learn more about how this works in the next guide.

Running a Project
---

To run a LÖVR project, drop its folder onto `lovr.exe`.  You can also run `lovr.exe` from the
command line and pass the path to the project as the first argument.

![Drag and Drop](https://lovr.org/static/img/dragonDrop.png)

On macOS and Linux, the project can be run by running the `lovr` executable with the path to the
project as an argument (on macOS, the executable is located at `LÖVR.app/Contents/MacOS/lovr`).

If you followed the example above, you should see the following in VR:

![Hello World](https://lovr.org/static/img/helloWorld.png)

Tips
---

- If you need to use `print` in Lua for debug messages, you can drag and drop the project onto
  `lovrc.bat` instead of `lovr.exe`, or specify the `--console` flag when running on the command
  line.
- If you have the headset module disabled, be sure to set the y value of the cube to 0 instead of
  1.7.

Next Steps
---

The next guide will teach you how to make fancier projects using <a data-key="Callbacks_and_Modules">Callbacks and Modules</a>.

If you want to learn more about Lua, some good resources are:

1. [Programming in Lua](https://www.lua.org/pil/contents.html)
2. [Learn Lua in 15 Minutes](http://tylerneylon.com/a/learn-lua/)

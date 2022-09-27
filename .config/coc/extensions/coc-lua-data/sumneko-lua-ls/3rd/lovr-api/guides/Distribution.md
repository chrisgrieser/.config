Distribution
===

LÖVR projects can be exported to standalone executables or WebXR projects.  This guide will teach you
how to export and distribute a project.

Creating an Archive
---

The first step is to create an archive of your project, which is a zipped up version of its
contents.  On Windows you can select all the files in a project (**not** the project folder), right
click them, and choose "Send to" -> "Compressed (zip) folder".  On Unix systems, the `zip` utility
can be used:

```
$ zip -9qr .
```

A zip archive can be run with LÖVR but isn't a standalone executable yet.

Creating an Executable
---

Once you have a project archive, it can be appended to the LÖVR binary to create a standalone
executable.  On Windows, this can be done using the command prompt:

```
$ copy /b lovr.exe+MyProject.zip MyProject.exe
```

On Unix systems, the `cat` utility can be used to concatenate the two files.

> Once you have an executable, be sure to distribute it with all the `.dll` files that came with the
original LÖVR download.

macOS
---

To create a .app on macOS, first get the stock LÖVR.app, either by downloading it
[here](https://lovr.org/download/mac) or by setting the `-DLOVR_BUILD_BUNDLE=ON` flag when building
with CMake.

Then, to get the .app to run a custom project instead of the nogame screen, put a .lovr archive in
the `LÖVR.app/Contents/Resources` folder (right click and use "Show Package Contents" to get to the
Contents folder).

Next, the `Contents/Info.plist` should be modified.  The `CFBundleName` entry should be changed from
"LÖVR" to the name of the project, and the `CFBundleIdentifier` should also be changed to a unique
ID for the project/studio name.  The `Resources/lovr.icns` file can be replaced with a custom icon
as well.

Finally, `LÖVR.app` can be renamed to `Awesome VR Project.app` and distributed as a zip.

WebXR
---

To package a project for running a browser, first follow the steps in the "Creating an Archive"
section above to get a zip file of the project.

Next, you'll need an HTML file to visit in the browser.  See [`lovr.html`](https://github.com/bjornbytes/lovr/blob/master/src/resources/lovr.html)
for a small example file that can be customized.  You can also create your own page, but at a
minimum it should:

- Have a `<canvas>` element with an id of `canvas`.
- Declare a `Module` global in JavaScript to configure various settings.
- Include a `preRun` function to download the archive and add it to the virtual filesystem.
- Include a `<script>` tag with a web build of LÖVR.
  - The latest web build is hosted at `https://lovr.org/static/f/lovr.js`.
  - Versioned web builds are hosted at `https://lovr.org/static/f/<version>/lovr.js`.
  - You can also use a custom web build, see the Compiling guide for more on that.

The `Module.preRun` array contains functions to run before starting up LÖVR.  One of the functions
in this array should use emscripten's `Module.FS_createPreloadedFile` function to download the
project's archive and add it to the virtual filesystem.  The path in the filesystem should then be
added as a command line argument by adding it to the `Module.arguments` array.  This will cause LÖVR
to run the project file when it starts up, just like on the command line.  Here's an example:

```
var path = '/MegaExperience.lovr'; // The path in the virtual filesystem
var url = '/projects/MegaExperience.lovr'; // The url to download

// Add a preRun task to download the archive and put it in the filesystem
Module.preRun.push(function() {
  Module.FS_createPreloadedFile('/', path, url, true, false);
});

// Pass the filesystem path as a virtual command line argument
Module.arguments = [path];
```

Optionally, the page can include a button to enter and exit immersive VR mode, using
`Module.lovr.enterVR` and `Module.lovr.exitVR`:

```
// Only do button-related things if WebXR is supported and working
if (navigator.xr) {
  navigator.xr.isSessionSupported('immersive-vr').then(function(supported) {
    if (!supported) {
      return;
    }

    // Ok, VR is supported.  Add a button to the page.
    var button = document.createElement('button');
    document.body.appendChild(button);
    button.textContent = 'VR!';

    // Keep track of whether VR is active.
    var active = false;

    // When the button is clicked, toggle VR state.
    button.addEventListener('click', function() {
      if (!active) {
        Module.lovr.enterVR().then(function(session) {

          // Once this promise resolves, VR is active.
          active = true;

          // The raw WebXR session object is accessible here.
          // Listen for when the session ends.
          session.addEventListener('end', function() {
            active = false;
          });
        });
      } else {
        Module.lovr.exitVR().then(function() {
          active = false;
        });
      }
    });
  });
}
```

The HTML file and zip file can then be distributed on a web server.

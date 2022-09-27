Plugins
===

LÖVR has a small core.  Extra features can be provided by <a data-key="Libraries">Libraries</a>
written in Lua, or by plugins.  Plugins are similar to libraries -- they can be `require`d from Lua
to access their features.  However, instead of Lua files in a project folder, plugins are native
libraries (`.dll` or `.so` files) that are placed next to the lovr executable.

Using Plugins
---

To use a plugin, place its library file next to the lovr executable and `require` it from Lua:

```
-- myplugin.dll is next to lovr.exe
local myplugin = require 'myplugin'

function lovr.load()
  myplugin.dothething()
end
```

> On Unix systems, some plugin files might be prefixed with `lib` (e.g. `liblovr-plugin.so`).
> In this case, be sure to require the plugin with the lib prefix: `require 'liblovr-plugin'`.

> On Android, plugins are searched for in the `lib/arm64-v8a` folder of the APK.

Plugins are not officially supported in WebAssembly yet, but this is theoretically possible.

List of Plugins
---

<table>
  <tbody>
    <tr>
      <td><a href="https://github.com/bjornbytes/lua-cjson">lua-cjson</a></td>
      <td>Fast native JSON encoder/decoder</td>
    </tr>
    <tr>
      <td><a href="https://github.com/bjornbytes/lua-enet">lua-enet</a></td>
      <td>enet for UDP multiplayer servers/clients</td>
    </tr>
    <tr>
      <td><a href="https://github.com/brainrom/lovr-luasocket">lovr-luasocket</a></td>
      <td>HTTP and socket support via luasocket</td>
    </tr>
    <tr>
      <td><a href="https://github.com/bjornbytes/lua-deepspeech">lua-deepspeech</a></td>
      <td>Speech recognition using Mozilla's DeepSpeech library</td>
    </tr>
  </tbody>
</table>

Building Plugins with CMake
---

LÖVR's CMake build system has support for automatically building plugins from source code.  In the
main lovr folder, a `plugins` folder can be created, containing a subfolder for each plugin to
build.  CMake will check all the subfolders of `plugins`, building anything with a `CMakeLists.txt`
file.  Their libraries will automatically be moved next to the final lovr executable, or packaged
into the apk on Android.

Inside the plugins' `CMakeLists.txt` scripts, the `LOVR` variable will be set to `1`, so libraries
can detect when they're being built as lovr plugins.  Plugins also automatically have access to the
version of Lua used by LÖVR, no calls to `find_package` are needed.

This makes it easier to manage plugins -- they can be copied, symlinked, cloned with git, or added
as git submodules.  A fork of lovr can be created that has this custom plugins folder, making it
easy to quickly get a set of plugins on multiple machines.  Version control also means that the
plugins are versioned and tied to a known version of lovr.

> By default, the libraries from all CMake targets in the plugin's build script will be moved
> to the executable folder.  Plugins can override this by setting the `LOVR_PLUGIN_TARGETS` variable
> to a semicolon-separated list of targets.

Creating Plugins
---

Internally, a plugin is no different from a regular native Lua library.  A plugin library only needs
to have a Lua C function with a symbol named after the plugin:

```
int luaopen_supermegaplugin(lua_State* L) {
  // This code gets run when the plugin is required,
  // and anything it returns on the stack is used
  // as the require's return value.
}
```

All of [Lua's rules](https://www.lua.org/manual/5.1/manual.html#pdf-package.loaders) for native
plugin loading, including processing of dots and hyphens and all-in-one loading, apply to LÖVR
plugins.  However, note that LÖVR plugins do **not** use `package.cpath` or Lua's default loader.
The `lovr.filesystem` module has its own loader for loading plugins (it always looks for plugins
next to the executable, and checks the `lib/arm64-v8a` folder of the APK).

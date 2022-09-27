FAQ
===

Frequently asked questions.

> Can I use LÖVR without a VR headset?

Yes, LÖVR will automatically use a fake headset system that you can control with your keyboard/mouse
if there isn't any VR hardware detected.

You can also set the `t.modules.headset` flag to false in `lovr.conf` to disable VR completely and
develop a traditional 3D desktop application.

Keep in mind that LÖVR is primarily designed for creating VR experiences, which have their own
design considerations.  Practically this means that LÖVR does not prioritize features common in
other engines like advanced control over the desktop window, mouse input, joystick support, and
touchscreens.  There are some plugins available that help bridge this gap.

> Is there any way to access keyboard/mouse input?

Yes, there are `lovr.keypressed`, `lovr.keyreleased`, and `lovr.textinput` callbacks.  For mouse
input, see `lovr-mouse` on the <a data-key="Libraries">Libraries</a> page.

> How do I get LÖVR to work with OpenXR?

Currently, OpenXR support is not included by default.  You can compile from source and add the
`-DLOVR_USE_OPENXR=ON` CMake option.  There are upcoming plans to include OpenXR by default.

> Are there macOS binaries available?

Yes, you can download them from <https://lovr.org/download/mac>.

> Does LÖVR work on Linux?

Yes, Linux is an officially supported platform and there are precompiled binaries distributed as
AppImages.  LÖVR is compatible with Steam's OpenXR runtime and monado, an open source OpenXR
runtime.

> Does LÖVR support AR?

LÖVR does not currently support the Magic Leap or "magic window" style AR on phones.  There are some
ways to experiment with AR on LÖVR using passthrough devices like the North Star or SteamVR's Room
View 3D.  LÖVR's direction is guided by the community, and as more AR hardware comes out there will
likely be future demand and development on AR support.

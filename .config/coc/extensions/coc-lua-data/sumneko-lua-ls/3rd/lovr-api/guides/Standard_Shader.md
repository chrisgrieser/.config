Standard Shader
===

LÖVR has a built in "standard" shader that uses physically based rendering (PBR) techniques, which
can be used to render realistic materials.  This material system is used in lots of engines and it's
the default material type in glTF, making it easy to import pretty assets and use them with LÖVR.

This guide will show you how to create a LÖVR project that imports PBR assets and renders them using
the standard shader.

Models
---

The glTF model format is perfect for the standard shader because glTF uses PBR materials by default.
LÖVR can import these models and their materials without any extra setup required.  Here are a few
places to get glTF assets:

- [Official glTF sample models](https://github.com/KhronosGroup/glTF-Sample-Models)
- [Sketchfab](https://sketchfab.com)
- [Blender](https://www.blender.org) can export to glTF

To add a model to a project, copy its glTF file (and any accompanying .bin files or textures) into
the main LÖVR project folder.  From there, the glTF file can be loaded using `lovr.graphics.newModel`
in `lovr.load`.

Skybox
---

TODO

Shader Setup
---

TODO

Tips
---

TODO

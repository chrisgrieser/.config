return {
  tag = 'graphicsObjects',
  summary = 'Create a new Shader.',
  description = 'Creates a new Shader.',
  arguments = {
    vertex = {
      type = 'string',
      description = [[
        The code or filename of the vertex shader.  If nil, the default vertex shader is used.
      ]]
    },
    fragment = {
      type = 'string',
      description = [[
        The code or filename of the fragment shader.  If nil, the default fragment shader is used.
      ]]
    },
    default = {
      type = 'DefaultShader',
      description = 'A builtin shader to use for the shader code.'
    },
    options = {
      type = 'table',
      default = '{}',
      description = 'Optional settings for the Shader.',
      table = {
        {
          name = 'flags',
          type = 'table',
          default = '{}',
          description = 'A table of key-value options passed to the Shader.'
        },
        {
          name = 'stereo',
          type = 'boolean',
          default = 'true',
          description = [[
            Whether the Shader should be configured for stereo rendering (Currently Android-only).
          ]]
        }
      }
    }
  },
  returns = {
    shader = {
      type = 'Shader',
      description = 'The new Shader.'
    }
  },
  variants = {
    {
      description = 'Create a Shader with custom GLSL code.',
      arguments = { 'vertex', 'fragment', 'options' },
      returns = { 'shader' },
    },
    {
      description = 'Create a new instance of a built-in Shader.',
      arguments = { 'default', 'options' },
      returns = { 'shader' },
    }
  },
  notes = [[
    The `flags` table should contain string keys, with boolean or numeric values.  These flags can
    be used to customize the behavior of Shaders from Lua, by using the flags in the shader source
    code.  Numeric flags will be available as constants named `FLAG_<flagName>`.  Boolean flags can
    be used with `#ifdef` and will only be defined if the value in the Lua table was `true`.

    The following flags are used by shaders provided by LÖVR:

    - `animated` is a boolean flag that will cause the shader to position vertices based on the pose
      of an animated skeleton.  This should usually only be used for animated `Model`s, since it
      needs a skeleton to work properly and is slower than normal rendering.
    - `alphaCutoff` is a numeric flag that can be used to implement simple "cutout" style
      transparency, where pixels with alpha below a certain threshold will be discarded.  The value
      of the flag should be a number between 0.0 and 1.0, representing the alpha threshold.
    - `uniformScale` is a boolean flag used for optimization.  If the Shader is only going to be
      used with objects that have a *uniform* scale (i.e. the x, y, and z components of the scale
      are all the same number), then this flag can be set to use a faster method to compute the
      `lovrNormalMatrix` uniform variable.
    - `multicanvas` is a boolean flag that should be set when rendering to multiple Textures
      attached to a `Canvas`.  When set, the fragment shader should implement the `colors` function
      instead of the `color` function, and can write color values to the `lovrCanvas` array instead
      of returning a single color.  Each color in the array gets written to the corresponding
      texture attached to the canvas.
    - `highp` is a boolean flag specific to mobile GPUs that changes the default precision for
      fragment shaders to use high precision instead of the default medium precision.  This can fix
      visual issues caused by a lack of precision, but isn't guaranteed to be supported on some
      lower-end systems.
    - The following flags are used only by the `standard` PBR shader:
      - `normalMap` should be set to `true` to render objects with a normal map, providing a more
      detailed, bumpy appearance.  Currently, this requires the model to have vertex tangents.
      - `emissive` should be set to `true` to apply emissive maps to rendered objects.  This is
        usually used to apply glowing lights or screens to objects, since the emissive texture is
        not affected at all by lighting.
      - `indirectLighting` is an *awesome* boolean flag that will apply realistic reflections and
        lighting to the surface of an object, based on a specially-created skybox.  See the
        `Standard Shader` guide for more information.
      - `occlusion` is a boolean flag that uses the ambient occlusion texture in the model.  It only
        affects indirect lighting, so it will only have an effect if the `indirectLighting` flag is
        also enabled.
      - `skipTonemap` is a flag that will skip the tonemapping process.  Tonemapping is an important
        process that maps the high definition physical color values down to a 0 - 1 range for
        display.  There are lots of different tonemapping algorithms that give different artistic
        effects.  The default tonemapping in the standard shader is the ACES algorithm, but you can
        use this flag to turn off ACES and use your own tonemapping.

    Currently, up to 32 shader flags are supported.

    The `stereo` option is only necessary for Android.  Currently on Android, only stereo shaders
    can be used with stereo Canvases, and mono Shaders can only be used with mono Canvases.
  ]],
  related = {
    'lovr.graphics.setShader',
    'lovr.graphics.getShader',
    'lovr.graphics.newComputeShader'
  }
}

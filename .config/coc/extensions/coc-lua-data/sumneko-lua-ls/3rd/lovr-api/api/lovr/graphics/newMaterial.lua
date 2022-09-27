return {
  tag = 'graphicsObjects',
  summary = 'Create a new Material.',
  description = [[
    Creates a new Material.  Materials are sets of colors, textures, and other parameters that
    affect the appearance of objects.  They can be applied to `Model`s, `Mesh`es, and most graphics
    primitives accept a Material as an optional first argument.
  ]],
  arguments = {
    texture = {
      type = 'Texture',
      description = 'The diffuse texture.'
    },
    canvas = {
      type = 'Canvas',
      description = 'A Canvas to use as the diffuse texture.'
    },
    r = {
      type = 'number',
      default = '1',
      description = 'The red component of the diffuse color.'
    },
    g = {
      type = 'number',
      default = '1',
      description = 'The green component of the diffuse color.'
    },
    b = {
      type = 'number',
      default = '1',
      description = 'The blue component of the diffuse color.'
    },
    hex = {
      type = 'number',
      default = '0xffffff',
      description = 'A hexcode to use for the diffuse color.'
    },
    a = {
      type = 'number',
      default = '1',
      description = 'The alpha component of the diffuse color.'
    }
  },
  returns = {
    material = {
      type = 'Material',
      description = 'The new Material.'
    }
  },
  variants = {
    {
      arguments = {},
      returns = { 'material' }
    },
    {
      arguments = { 'texture', 'r', 'g', 'b', 'a' },
      returns = { 'material' }
    },
    {
      arguments = { 'canvas', 'r', 'g', 'b', 'a' },
      returns = { 'material' }
    },
    {
      arguments = { 'r', 'g', 'b', 'a' },
      returns = { 'material' }
    },
    {
      arguments = { 'hex', 'a' },
      returns = { 'material' }
    }
  },
  notes = [[
    - Scalar properties will default to `1.0`.
    - Color properties will default to `(1.0, 1.0, 1.0, 1.0)`, except for `emissive` which will
      default to `(0.0, 0.0, 0.0, 0.0)`.
    - Textures will default to `nil` (a single 1x1 white pixel will be used for them).
  ]]
}

return {
  tag = 'graphicsPrimitives',
  summary = 'Draw a plane.',
  description = 'Draws a plane with a given position, size, and orientation.',
  arguments = {
    material = {
      type = 'Material',
      description = 'The material to apply to the plane.'
    },
    mode = {
      type = 'DrawStyle',
      description = 'How to draw the plane.'
    },
    x = {
      type = 'number',
      default = '0',
      description = 'The x coordinate of the center of the plane.'
    },
    y = {
      name = 'y',
      type = 'number',
      default = '0',
      description = 'The y coordinate of the center of the plane.'
    },
    z = {
      type = 'number',
      default = '0',
      description = 'The z coordinate of the center of the plane.'
    },
    width = {
      type = 'number',
      default = '1',
      description = 'The width of the plane, in meters.'
    },
    height = {
      type = 'number',
      default = '1',
      description = 'The height of the plane, in meters.'
    },
    angle = {
      type = 'number',
      default = '0',
      description = 'The number of radians to rotate around the rotation axis.'
    },
    ax = {
      type = 'number',
      default = '0',
      description = 'The x component of the rotation axis.'
    },
    ay = {
      type = 'number',
      default = '1',
      description = 'The y component of the rotation axis.'
    },
    az = {
      type = 'number',
      default = '0',
      description = 'The z component of the rotation axis.'
    },
    u = {
      type = 'number',
      default = '0.0',
      description = 'The u coordinate of the texture.'
    },
    v = {
      type = 'number',
      default = '0.0',
      description = 'The v coordinate of the texture.'
    },
    w = {
      type = 'number',
      default = '1.0 - u',
      description = 'The width of the texture UVs to render.'
    },
    h = {
      type = 'number',
      default = '1.0 - v',
      description = 'The height of the texture UVs to render.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'mode', 'x', 'y', 'z', 'width', 'height', 'angle', 'ax', 'ay', 'az', 'u', 'v', 'w', 'h' },
      returns = {}
    },
    {
      description = 'Draw a plane with a custom material.',
      arguments = { 'material', 'x', 'y', 'z', 'width', 'height', 'angle', 'ax', 'ay', 'az', 'u', 'v', 'w', 'h' },
      returns = {}
    }
  },
  notes = [[
    The `u`, `v`, `w`, `h` arguments can be used to select a subregion of the diffuse texture to
    apply to the plane.  One efficient technique for rendering many planes with different textures
    is to pack all of the textures into a single image, and then use the uv arguments to select
    a sub-rectangle to use for each plane.
  ]]
}

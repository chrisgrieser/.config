return {
  tag = 'modules',
  summary = 'Renders graphics.',
  description = [[
    The `lovr.graphics` module renders graphics to displays.  Anything rendered using this module
    will automatically show up in the VR headset if one is connected, otherwise it will just show up
    in a window on the desktop.
  ]],
  sections = {
    {
      name = 'Drawing',
      tag = 'graphicsPrimitives',
      description = 'Simple functions for drawing simple shapes.'
    },
    {
      name = 'Objects',
      tag = 'graphicsObjects',
      description = [[
        Several graphics-related objects can be created with the graphics module.  Try to avoid
        calling these functions in `lovr.update` or `lovr.draw`, because then the objects will be
        loaded every frame, which can really slow things down!
      ]]
    },
    {
      name = 'Transforms',
      tag = 'graphicsTransforms',
      description = [[
        These functions manipulate the 3D coordinate system.  By default the negative z axis points
        forwards and the positive y axis points up.  Manipulating the coordinate system can be used
        to create a hierarchy of rendered objects.  Thinking in many different coordinate systems
        can be challenging though, so be sure to brush up on 3D math first!
      ]]
    },
    {
      name = 'State',
      tag = 'graphicsState',
      description = [[
        These functions get or set graphics state.  Graphics state is is a collection of small
        settings like the background color of the scene or the active shader.  Keep in mind that all
        this state is **global**, so if you change a setting, the change will persist until that
        piece of state is changed again.
      ]]
    },
    {
      name = 'Window',
      tag = 'window',
      description = [[
        Get info about the desktop window or operate on the underlying graphics context.
      ]]
    }
  }
}

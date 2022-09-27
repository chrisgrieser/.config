return {
  tag = 'graphicsState',
  summary = 'Get renderer stats for the current frame.',
  description = 'Returns graphics-related performance statistics for the current frame.',
  arguments = {},
  returns = {
    {
      name = 'stats',
      type = 'table',
      description = 'The table of stats.',
      table = {
        {
          name = 'drawcalls',
          type = 'number',
          description = 'The number of draw calls.'
        },
        {
          name = 'renderpasses',
          type = 'number',
          description = 'The number of times the canvas has been switched.'
        },
        {
          name = 'shaderswitches',
          type = 'number',
          description = 'The number of times the shader has been switched.'
        },
        {
          name = 'buffers',
          type = 'number',
          description = 'The number of buffers.'
        },
        {
          name = 'textures',
          type = 'number',
          description = 'The number of textures.'
        },
        {
          name = 'buffermemory',
          type = 'number',
          description = 'The amount of memory used by buffers, in bytes.'
        },
        {
          name = 'texturememory',
          type = 'number',
          description = 'The amount of memory used by textures, in bytes.'
        }
      }
    }
  }
}

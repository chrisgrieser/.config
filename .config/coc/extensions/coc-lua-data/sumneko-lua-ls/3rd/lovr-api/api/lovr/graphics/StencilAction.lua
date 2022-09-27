return {
  summary = 'Different stencil operations available.',
  description = [[
    How to modify pixels in the stencil buffer when using `lovr.graphics.stencil`.
  ]],
  values = {
    {
      name = 'replace',
      description = 'Stencil values will be replaced with a custom value.',
    },
    {
      name = 'increment',
      description = 'Stencil values will increment every time they are rendered to.',
    },
    {
      name = 'decrement',
      description = 'Stencil values will decrement every time they are rendered to.',
    },
    {
      name = 'incrementwrap',
      description = [[
        Similar to `increment`, but the stencil value will be set to 0 if it exceeds 255.
      ]],
    },
    {
      name = 'decrementwrap',
      description = [[
        Similar to `decrement`, but the stencil value will be set to 255 if it drops below 0.
      ]],
    },
    {
      name = 'invert',
      description = 'Stencil values will be bitwise inverted every time they are rendered to.'
    }
  }
}

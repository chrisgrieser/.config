return {
  tag = 'window',
  summary = 'Start a timer on the GPU.',
  description = 'Starts a named timer on the GPU, which can be stopped using `lovr.graphics.tock`.',
  arguments = {
    {
      name = 'label',
      type = 'string',
      description = 'The name of the timer.'
    }
  },
  returns = {},
  notes = [[
    The timer can be stopped by calling `lovr.graphics.tock` using the same name.  All drawing
    commands between the tick and the tock will be timed.  It is not possible to nest calls to tick
    and tock.

    GPU timers are not supported on all systems.  Check the `timers` feature using
    `lovr.graphics.getFeatures` to see if it is supported on the current system.
  ]],
  example = [[
    function lovr.draw()
      lovr.graphics.tick('tim')

      -- Draw a bunch of cubes
      for x = -4, 4 do
        for y = -4, 4 do
          for z = -4, 4 do
            lovr.graphics.cube('fill', x, y, z, .2)
          end
        end
      end

      print('it took ' .. (lovr.graphics.tock('tim') or 0) .. ' seconds')
    end
  ]],
  related = {
    'lovr.graphics.tock',
    'lovr.graphics.getFeatures'
  }
}

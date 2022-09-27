return {
  tag = 'window',
  summary = 'Stop a timer on the GPU.',
  description = 'Stops a named timer on the GPU, previously started with `lovr.graphics.tick`.',
  arguments = {
    {
      name = 'label',
      type = 'string',
      description = 'The name of the timer.'
    }
  },
  returns = {
    {
      name = 'time',
      type = 'number',
      description = 'The number of seconds elapsed, or `nil` if the data isn\'t ready yet.'
    }
  },
  notes = [[
    All drawing commands between tick and tock will be timed.  It is not possible to nest calls to
    tick and tock.

    The results are delayed, and might be `nil` for the first few frames.  This function returns
    the most recent available timer value.

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
    'lovr.graphics.tick',
    'lovr.graphics.getFeatures'
  }
}

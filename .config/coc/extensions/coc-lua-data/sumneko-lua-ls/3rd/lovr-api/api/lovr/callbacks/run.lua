return {
  tag = 'callbacks',
  summary = 'The main entry point.',
  description = [[
    This callback is the main entry point for a LÖVR program.  It is responsible for calling
    `lovr.load` and returning the main loop function.
  ]],
  arguments = {},
  returns = {
    {
      name = 'loop',
      type = 'function',
      arguments = {},
      returns = {
        {
          name = 'result',
          type = '*'
        }
      },
      description = [[
        The main loop function.  It should return nil to continue running, "restart" to restart the
        app, or a number representing an exit status.

        Most users should overload lovr.load, lovr.update and lovr.draw instead, since if a custom
        lovr.run does not do everything it is expected that some features may not work. For example,
        if lovr.run does not respond to "quit" events the program will not be able to quit, and if
        it does not call "present" then no graphics will be drawn.
      ]]
    }
  },
  example = {
    description = 'The default `lovr.run`:',
    code = [[
      function lovr.run()
        lovr.timer.step()
        if lovr.load then lovr.load() end
        return function()
          lovr.event.pump()
          for name, a, b, c, d in lovr.event.poll() do
            if name == 'quit' and (not lovr.quit or not lovr.quit()) then
              return a or 0
            end
            if lovr.handlers[name] then lovr.handlers[name](a, b, c, d) end
          end
          local dt = lovr.timer.step()
          if lovr.headset then
            lovr.headset.update(dt)
          end
          if lovr.audio then
            lovr.audio.update()
            if lovr.headset then
              lovr.audio.setOrientation(lovr.headset.getOrientation())
              lovr.audio.setPosition(lovr.headset.getPosition())
              lovr.audio.setVelocity(lovr.headset.getVelocity())
            end
          end
          if lovr.update then lovr.update(dt) end
          if lovr.graphics then
            lovr.graphics.origin()
            if lovr.draw then
              if lovr.headset then
                lovr.headset.renderTo(lovr.draw)
              end
              if lovr.graphics.hasWindow() then
                lovr.mirror()
              end
            end
            lovr.graphics.present()
          end
          lovr.math.drain()
        end
      end
    ]],
  },
  related = {
    'lovr.load',
    'lovr.quit'
  }
}

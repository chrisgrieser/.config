return {
  tag = 'callbacks',
  summary = 'Called every frame to update the application logic.',
  description = [[
    The `lovr.update` callback should be used to update your game's logic.  It receives a single
    parameter, `dt`, which represents the amount of elapsed time between frames.  You can use this
    value to scale timers, physics, and animations in your game so they play at a smooth, consistent
    speed.
  ]],
  arguments = {
    {
      name = 'dt',
      type = 'number',
      description = 'The number of seconds elapsed since the last update.'
    }
  },
  returns = {},
  example = [[
    function lovr.update(dt)
      ball.vy = ball.vy + ball.gravity * dt
      ball.y = ball.y + ball.vy * dt
    end
  ]],
  related = {
    'lovr.timer.getDelta'
  }
}

return {
  tag = 'modules',
  summary = 'Handles events from the operating system.',
  description = [[
    The `lovr.event` module handles events from the operating system.

    Due to its low-level nature, it's rare to use `lovr.event` in simple projects.
  ]],
  notes = [[
    You can define your own custom events by adding a function to the `lovr.handlers` table with a
    key of the name of the event you want to add.  Then, push the event using `lovr.event.push`.
  ]],
  example = {
    description = 'Adding a custom event.',
    code = [[
      function lovr.load()
        lovr.handlers['customevent'] = function(a, b, c)
          print('custom event handled with args:', a, b, c)
        end

        lovr.event.push('customevent', 1, 2, 3)
      end
    ]]
  }
}

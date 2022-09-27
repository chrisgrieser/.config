return {
  tag = 'callbacks',
  summary = 'Called when a message is logged.',
  description = [[
    This callback is called when a message is logged.  The default implementation of this callback
    prints the message to the console using `print`, but it's possible to override this callback to
    render messages in VR, write them to a file, filter messages, and more.

    The message can have a "tag" that is a short string representing the sender, and a "level"
    indicating how severe the message is.

    The `t.graphics.debug` flag in `lovr.conf` can be used to get log messages from the GPU driver
    (tagged as `GL`).  It is also possible to emit your own log messages using `lovr.event.push`.
  ]],
  arguments = {
    {
      name = 'message',
      type = 'string',
      description = 'The log message.  It may end in a newline.'
    },
    {
      name = 'level',
      type = 'string',
      description = 'The log level (`debug`, `info`, `warn`, or `error`).'
    },
    {
      name = 'tag',
      type = 'string',
      description = 'The log tag.'
    }
  },
  returns = {},
  related = {
    'lovr.graphics.print'
  }
}

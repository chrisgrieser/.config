return {
  summary = 'A message channel for communicating between threads.',
  description = [[
    A Channel is an object used to communicate between `Thread` objects.  Channels are obtained by
    name using `lovr.thread.getChannel`.  Different threads can send messages on the same Channel to
    communicate with each other.  Messages can be sent and received on a Channel using
    `Channel:push` and `Channel:pop`, and are received in a first-in-first-out fashion. The
    following types of data can be passed through Channels: nil, boolean, number, string, and any
    LÖVR object.
  ]],
  constructor = 'lovr.thread.getChannel'
}

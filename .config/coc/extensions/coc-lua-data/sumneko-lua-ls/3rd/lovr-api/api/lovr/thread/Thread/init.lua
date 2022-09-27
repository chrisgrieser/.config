return {
  summary = 'A separate thread of execution that can run code in parallel with other threads.',
  description = [[
    A Thread is an object that runs a chunk of Lua code in the background.  Threads are completely
    isolated from other threads, meaning they have their own Lua context and can't access the
    variables and functions of other threads.  Communication between threads is limited and is
    accomplished by using `Channel` objects.

    To get `require` to work properly, add `require 'lovr.filesystem'` to the thread code.
  ]],
  constructor = 'lovr.thread.newThread',
  related = {
    'lovr.threaderror',
    'lovr.system.getCoreCount',
    'Channel'
  }
}

function lovr.load()
  -- This holds the thread code
  -- This must be wrapped with [[]] or '' to allow the engine to run it as Lua
  threadCode = [[
    local lovr = { thread = require 'lovr.thread' }
    local channel = lovr.thread.getChannel('test')
    local x = 0
    while true do
      x = x + 1
      channel:push(x)
    end
  ]]

  -- Create a new test channel
  channel = lovr.thread.getChannel('test')

  -- Create a new thread called 'thread' using the code above
  thread = lovr.thread.newThread(threadCode)

  -- Start the thread
  thread:start()
end

function lovr.update(dt)
  -- Read and delete the message
  message = channel:pop()
end

function lovr.draw()
  -- Display the message on screen/headset
  lovr.graphics.print(tostring(message), 0, 1.7, -5)
end

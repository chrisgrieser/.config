return {
  summary = 'A chunk of binary data.',
  description = [[
    A Blob is an object that holds binary data.  It can be passed to most functions that take
    filename arguments, like `lovr.graphics.newModel` or `lovr.audio.newSource`.  Blobs aren't
    usually necessary for simple projects, but they can be really helpful if:

    - You need to work with low level binary data, potentially using the LuaJIT FFI for increased
      performance.
    - You are working with data that isn't stored as a file, such as programmatically generated data
      or a string from a network request.
    - You want to load data from a file once and then use it to create many different objects.

    A Blob's size cannot be changed once it is created.
  ]],
  constructors = { 'lovr.data.newBlob', 'lovr.filesystem.newBlob' }
}

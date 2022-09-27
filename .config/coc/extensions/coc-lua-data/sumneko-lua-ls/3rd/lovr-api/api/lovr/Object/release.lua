return {
  summary = 'Immediately release the Lua reference to an object.',
  description = [[
    Immediately destroys Lua's reference to the object it's called on.  After calling this function
    on an object, it is an error to do anything with the object from Lua (call methods on it, pass
    it to other functions, etc.).  If nothing else is using the object, it will be destroyed
    immediately, which can be used to destroy something earlier than it would normally be garbage
    collected in order to reduce memory.
  ]],
  arguments = {},
  returns = {},
  notes = [[
    The object may not be destroyed immediately if something else is referring to it (e.g. it is
    pushed to a Channel or exists in the payload of a pending event).
  ]]
}

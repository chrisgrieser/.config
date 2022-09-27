return {
  summary = 'The base object.',
  description = [[
    This is not a real object, but describes the behavior shared by all objects.  Think of it as the
    superclass of all LÖVR objects.

    In addition to the methods here, all objects have a `__tostring` metamethod that returns the
    name of the object's type.  So to check if a LÖVR object is an instance of "Blob", you can do
    `tostring(object) == 'Blob'`.
  ]]
}

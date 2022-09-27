files   = {'resty/redis%.lua'}
configs = {
    {
        key    = 'Lua.runtime.version',
        action = 'set',
        value  = 'LuaJIT',
    },
}

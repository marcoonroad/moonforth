local misc   = require 'forth.extra.misc'
local reason = require 'forth.extra.reason'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    interpreter.module.dictionary.vocabulary 'stack'
    interpreter.module.dictionary.definitions 'stack'

    function dictionary.length (...)
        if interpreter: skipping ( ) then return ... end

        return select ('#', ...), ...
    end

    function dictionary.empty (...)
        if interpreter: skipping ( ) then return ... end

        return -- clears the stack --
    end

    function dictionary.dup (x, ...)
        if interpreter: skipping ( ) then return x, ... end

        return x, x, ...
    end

    function dictionary.swap (x, y, ...)
        if interpreter: skipping ( ) then return x, y, ... end

        return y, x, ...
    end

    function dictionary.drop (x, ...)
        if interpreter: skipping ( ) then return x, ... end

        return ...
    end

    function dictionary.rot (x, y, z, ...)
        if interpreter: skipping ( ) then return x, y, z, ... end

        return z, x, y, ...
    end

    interpreter.module.dictionary.definitions 'forth'
end

return functor
local misc   = require 'forth.extra.misc'
local reason = require 'forth.extra.reason'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    interpreter.module.dictionary.vocabulary 'memory'
    interpreter.module.dictionary.definitions 'memory'

    -- variables can be generalized in some way  --
    -- to provide both arrays and hash tables... --
    function dictionary.variable (...)
        if interpreter: skipping ( ) then return ... end

        local token   = interpreter.state.next ( )
        local pointer = { }

        dictionary[ token ] = function (...)
            return pointer, ...
        end

        return ...
    end

    dictionary[ "!" ] = function (pointer, x, ...)
        if interpreter: skipping ( ) then return pointer, x, ... end

        pointer[ 1 ] = x

        return ...
    end

    dictionary[ '@' ] = function (pointer, ...)
        if interpreter: skipping ( ) then return pointer, ... end

        return pointer[ 1 ], ...
    end

    interpreter.module.dictionary.definitions 'forth'
end

return functor
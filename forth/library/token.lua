local misc   = require 'forth.extra.misc'
local reason = require 'forth.extra.reason'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    interpreter.module.dictionary.vocabulary 'token'
    interpreter.module.dictionary.definitions 'token'

    dictionary[ "next-number" ] = function (...)
        if interpreter: skipping ( ) then return ... end

        local word    = interpreter.state.next ( )
        local literal = tonumber (word)

        if literal == nil then
            error (reason.no_number)
        else
            return literal, ...
        end
    end

    function dictionary.next (...)
        if interpreter: skipping ( ) then return ... end

        local token = interpreter.state.next ( )

        if token then
            return token, ...
        else
            error (reason.eol)
        end
    end

    function dictionary.expand (word, ...)
        if interpreter: skipping ( ) then return ... end

        interpreter.state.expand (word)

        return ...
    end

    dictionary[ "dup-tokens" ] = function (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.state[ "dup-tokens" ] ( )

        return ...
    end

    dictionary[ "swap-tokens" ] = function (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.state[ "swap-tokens" ] ( )

        return ...
    end

    dictionary[ "rot-tokens" ] = function (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.state[ "rot-tokens" ] ( )

        return ...
    end

    dictionary[ "over-tokens" ] = function (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.state[ "over-tokens" ] ( )

        return ...
    end

    interpreter.module.dictionary.definitions 'forth'
end

return functor
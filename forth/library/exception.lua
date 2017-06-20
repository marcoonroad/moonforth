local misc   = require 'forth.extra.misc'
local reason = require 'forth.extra.reason'
local prompt = require 'forth.extra.prompt'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    interpreter.module.dictionary.vocabulary 'exception'
    interpreter.module.dictionary.definitions 'exception'

    function dictionary.throw (x, ...)
        if interpreter: skipping ( ) then return x, ... end

        error (tostring (x), 2)

        -- clears the stack? NO! --
    end

    function dictionary.catch (handler, procedure, ...)
        if interpreter: skipping ( ) then return x, ... end

        local arguments = misc.pack (...)

        local result = misc.pack (xpcall (function ( )
            return procedure (misc.unpack (arguments, 1, arguments.n))
        end, function (reason)
            return handler (reason), misc.unpack (arguments, 1, arguments.n)
        end))

        return misc.unpack (result, 2, result.n)
    end

    interpreter.module.dictionary.definitions 'forth'
end

return functor
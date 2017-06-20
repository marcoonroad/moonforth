local misc   = require 'forth.extra.misc'
local reason = require 'forth.extra.reason'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    interpreter.module.dictionary.vocabulary 'collector'
    interpreter.module.dictionary.definitions 'collector'

    dictionary[ 'full-step' ] = function (...)
        if interpreter: skipping ( ) then return ... end

        collectgarbage ("collect")

        return ...
    end

    dictionary[ 'get-count' ] = function (...)
        if interpreter: skipping ( ) then return ... end

        return collectgarbage ("count") * 1024, ...
    end

    dictionary[ 'is-running' ] = function (...)
        if interpreter: skipping ( ) then return ... end

        return collectgarbage ("isrunning"), ...
    end

    dictionary[ 'manual-mode' ] = function (...)
        if interpreter: skipping ( ) then return ... end

        collectgarbage ("stop")

        return ...
    end

    dictionary[ 'automatic-mode' ] = function (...)
        if interpreter: skipping ( ) then return ... end

        collectgarbage ("restart")

        return ...
    end

    interpreter.module.dictionary.definitions 'forth'
end

return functor
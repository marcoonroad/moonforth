local reason = require 'forth.extra.reason'
local misc   = require 'forth.extra.misc'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    function dictionary.also (...)
        if interpreter: skipping ( ) then return ... end

        local word = interpreter.state.next ( )

        interpreter.module.dictionary.also (word)

        return ...
    end

    function dictionary.except (...)
        if interpreter: skipping ( ) then return ... end

        local word = interpreter.state.next ( )

        interpreter.module.dictionary.except (word)

        return ...
    end

    function dictionary.reset (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.module.dictionary.reset ( )

        return ...
    end

    function dictionary.definitions (...)
        if interpreter: skipping ( ) then return ... end

        local word = interpreter.state.next ( )

        interpreter.module.dictionary.definitions (word)

        return ...
    end

    function dictionary.vocabulary (...)
        if interpreter: skipping ( ) then return ... end

        local word = interpreter.state.next ( )

        interpreter.module.dictionary.vocabulary (word)

        return ...
    end
end

return functor
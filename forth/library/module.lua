local misc   = require 'forth.extra.misc'
local reason = require 'forth.extra.reason'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    interpreter.module.dictionary.vocabulary 'module'
    interpreter.module.dictionary.definitions 'module'

    function dictionary.active (...)
        if interpreter: skipping ( ) then return ... end

        return interpreter.module.dictionary.active ( ), ...
    end

    function dictionary.vocabularies (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.module.dictionary.vocabularies ( )

        return ...
    end

    function dictionary.imports (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.module.dictionary.imports ( )

        return ...
    end

    function dictionary.cite (...)
        if interpreter: skipping ( ) then return ... end

        local word = interpreter.state.next ( )

        interpreter.module.dictionary.isolate (true)
        interpreter.module.dictionary.cite (word)
        interpreter.module.dictionary.isolate (false)

        return ...
    end

    function dictionary.reload (...)
        if interpreter: skipping ( ) then return ... end

        local word = interpreter.state.next ( )

        interpreter.module.dictionary.reload (word)

        return ...
    end

    interpreter.module.dictionary.definitions 'forth'
end

return functor
local reason = require 'forth.extra.reason'
local misc   = require 'forth.extra.misc'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    interpreter.module.dictionary.vocabulary 'runtime'
    interpreter.module.dictionary.definitions 'runtime'

    dictionary[ 'to-string' ] = function (value, ...)
        if interpreter: skipping ( ) then return ... end

        return tostring (value), ...
    end

    function dictionary.type (x, ...)
        if interpreter: skipping ( ) then return x, ... end

        return type (x), ...
    end

    function dictionary.see (...)
        if interpreter: skipping ( ) then return ... end

        local word = interpreter.state.next ( )

        if interpreter.module.tokenizer.string (word) then
            word = "\"" .. tostring (word) .. "\""
        end
        
        interpreter: find (word) -- ensures definition --

        local source = interpreter.state.source[ word ] or "<?>"

        if interpreter.state.recursive[ word ] then
            print ((":rec %s\n\t%s ;"): format (word, source))
        else
            print ((": %s\n\t%s ;"): format (word, source))
        end

        return ...
    end

    interpreter.module.dictionary.definitions 'forth'
end

return functor
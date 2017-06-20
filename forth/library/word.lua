local misc   = require 'forth.extra.misc'
local reason = require 'forth.extra.reason'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    interpreter.module.dictionary.vocabulary 'word'
    interpreter.module.dictionary.definitions 'word'

    function dictionary.immediate (...)
        if interpreter: skipping ( ) then return ... end

        if interpreter.state.recent == nil then
            error (reason.word.no_recent)
        elseif interpreter.state.immediate[ interpreter.state.recent ] then
            error (reason.word.already_immediate: format (interpreter.state.recent))
        else
            interpreter.state.immediate[ interpreter.state.recent ] = true
        end

        return ...
    end

    function dictionary.find (word, ...)
        if interpreter: skipping ( ) then return ... end

        return interpreter: find (word), ...
    end

--[[
    function dictionary[ "find-vocabulary-for" ] (word, ...)
        interpreter: __vocabulary_for ( )
    end
]]--

    function dictionary.alias (...)
        if interpreter: skipping ( ) then return ... end

        local name = interpreter.state.next ( )
        local word = interpreter.state.next ( )

        dictionary[ name ] = interpreter: find (word)

        return ...
    end

    dictionary[ 'immediate?' ] = function (word, ...)
        if interpreter: skipping ( ) then return ... end

        if not dictionary[ word ] then
            interpreter.module.exception.unknown (word)
        end

        local bool = interpreter.state.immediate[ word ]

        if bool then
            return true, ...
        else
            return false, ...
        end
    end

    dictionary[ "," ] = function (value, ...)
        if interpreter: skipping ( ) then return value, ... end

        interpreter.state.chunks = misc.compose (interpreter.state.chunks, interpreter: literal (value))
        interpreter.state.buffer = ("%s %s"): format (interpreter.state.buffer, tostring (value))

        return ...
    end

    function dictionary.forget (...)
        if interpreter: skipping ( ) then return ... end

        local token = interpreter.state.next ( )

        dictionary[ token ]                  = nil
        interpreter.state.immediate[ token ] = nil

        return ...
    end

    function dictionary.defer (...)
        if interpreter: skipping ( ) then return ... end

        local word = interpreter.state.next ( )

        dictionary[ word ] = setmetatable ({ }, interpreter.deferred)

        return ...
    end

    function dictionary.is (xt, ...)
        if interpreter: skipping ( ) then return xt, ... end

        local word = interpreter.state.next ( )

        dictionary[ word ][ 1 ] = xt

        return ...
    end

    dictionary[ "'" ] = function (...)
        if interpreter: skipping ( ) then return ... end

        local word = interpreter.state.next ( )
        local xt   = interpreter: find (word)

        return xt, ...
    end

    dictionary[ "[']" ] = function (...)
        if interpreter: skipping ( ) then return ... end

        local word = interpreter.state.next ( )
        local xt   = interpreter: find (word)

        interpreter.state.chunks = misc.compose (interpreter.state.chunks, xt)

        return ...
    end

    dictionary[ ":" ] = function (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.state.definition = interpreter.state.definition + 1
        interpreter.state.state      = true

        local word = interpreter.state.next ( )

        if interpreter.module.tokenizer.string (word) then
            word = "\"" .. tostring (word) .. "\""
        end

        if word then
            interpreter.state.recent = word
            interpreter.state.chunks = misc.id
            interpreter.state.buffer = ""
        else
            error (reason.eol)
        end

        return ...
    end

    dictionary[ ":rec" ] = function (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.state.definition = interpreter.state.definition + 1
        interpreter.state.state      = true

        local word = interpreter.state.next ( )

        if interpreter.module.tokenizer.string (word) then
            word = "\"" .. tostring (word) .. "\""
        end

        if word then
            interpreter.state.recent = word
            interpreter.state.buffer = ""
            interpreter.state.chunks = misc.id

            local pointer = { }
            interpreter.state.recurse[ pointer ] = word
            interpreter.state.recursive[ word ] = true
    
            setmetatable (pointer, interpreter.fixpoint)

            dictionary[ word ] = pointer
        else
            error (reason.eol)
        end

        return ...
    end

    dictionary[ ":fun" ] = function (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.state.definition = interpreter.state.definition + 1
        interpreter.state.state      = true
        interpreter.state.noname     = true
        interpreter.state.buffer     = ""
        interpreter.state.chunks     = misc.id

        return ...
    end

    dictionary[ ";" ] = function (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.state.definition = interpreter.state.definition - 1
        interpreter.state.state      = false

        if interpreter.state.noname then
            local xt = interpreter.state.chunks

            interpreter.state.noname = false
            interpreter.state.buffer = nil
            interpreter.state.chunks = nil

            return xt, ...
        else
            dictionary[ interpreter.state.recent ]               = interpreter.state.chunks
            interpreter.state.source[ interpreter.state.recent ] = interpreter.state.buffer

            interpreter.state.buffer = nil
            interpreter.state.chunks = nil

            return ...
        end
    end

    dictionary[ "[" ] = function (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.state.state = false

        return ...
    end

    dictionary[ "]" ] = function (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.state.state = true

        return ...
    end

    function dictionary.postpone (...)
        if interpreter: skipping ( ) then return ... end

        local word = interpreter.state.next ( )
        local xt   = interpreter: find (word)

        interpreter.state.buffer = misc.compose (interpreter.state.buffer, xt)

        return ...
    end

    function dictionary.execute (f, ...)
        if interpreter: skipping ( ) then return f, ... end

        return f (...)
    end

    function dictionary.literal (x, ...)
        if interpreter: skipping ( ) then return x, ... end

        local number = tonumber (x)

        if number then
            return number, ...
        else
            return interpreter.module.exception.invalid (x)
        end
    end

    -- set of immediate words in this submodule --
    interpreter.state.immediate[ "," ]   = true
    interpreter.state.immediate[ "[" ]   = true
    interpreter.state.immediate[ ";" ]   = true
    interpreter.state.immediate.postpone = true
    interpreter.state.immediate[ "[']" ] = true

    interpreter.module.dictionary.definitions 'forth'
end

return functor
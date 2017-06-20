local misc   = require 'forth.extra.misc'
local reason = require 'forth.extra.reason'
local prompt = require 'forth.extra.prompt'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    interpreter.module.dictionary.vocabulary 'world'
    interpreter.module.dictionary.definitions 'world'

    dictionary[ 'clear-screen' ] = function (...)
        if interpreter: skipping ( ) then return ... end

        os.execute 'clear'

        return ...
    end

    dictionary[ '.' ] = function (x, ...)
        if interpreter: skipping ( ) then return x, ... end

        print (prompt.output .. " " .. tostring (x))

        return ...
    end

    dictionary[ '.s' ] = function (...)
        if interpreter: skipping ( ) then return ... end

        local arguments = misc.pack (...)

        if arguments.n > 0 then
            for index = 1, arguments.n do
                arguments[ index ] = tostring (arguments[ index ])
            end

            print (prompt.output .. " " .. table.concat (arguments, ", "))
        else
            print (prompt.output .. " nil")
        end

        return ...
    end

    function dictionary.words (...)
        if interpreter: skipping ( ) then return ... end

        local output = prompt.output

        for word in pairs (dictionary) do
            output = ("%s %s"): format (output, word)
        end

        print (output)

        return ...
    end

    dictionary[ 'all-words-for' ] = function (...)
        if interpreter: skipping ( ) then return ... end

        local token = interpreter.state.next ( )

        if not token then error (reason.eol) end

        local entries = interpreter.module.dictionary.lookup (token)
        local output  = prompt.output

        for word in pairs (entries) do
            output = ("%s %s"): format (output, word)
        end

        print (output)

        return ...
    end

    function dictionary.bye (...)
        if interpreter: skipping ( ) then return ... end

        interpreter.state.alive = false
        interpreter.state.next  = misc.noop

        return -- clears the stack --
    end

    interpreter.module.dictionary.definitions 'forth'
end

return functor
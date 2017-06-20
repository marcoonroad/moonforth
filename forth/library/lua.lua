local misc   = require 'forth.extra.misc'
local reason = require 'forth.extra.reason'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    interpreter.module.dictionary.vocabulary 'lua'
    interpreter.module.dictionary.definitions 'lua'

    function dictionary.random (to, from, ...)
        if interpreter: skipping ( ) then return ... end

        return math.random (from, to), ...
    end

    function dictionary.command (command, ...)
        if interpreter: skipping ( ) then return ... end

        os.execute (command)

        return ...
    end

    function dictionary.require (...)
        local library = interpreter.next ( )

        return require (library), ...
    end

    function dictionary.at (struct, ...)
        local word = interpreter.next ( )

        return struct[ word ], ...
    end

    function dictionary.invoke (argc, ...)
        local word  = interpreter.next ( )
        local xt    = misc.load ("return " .. word) ( )
        local stack = misc.pack (...)

        assert (type (xt) ~= 'nil', reason.selector: format (word))

        if argc <= -1 then
            return xt, misc.unpack (stack)
        else
            return xt (misc.unpack (stack, 1, argc)), misc.unpack (stack, argc + 1, stack.n)
        end
    end

    interpreter.module.dictionary.definitions 'forth'
end

return functor
local reason = require 'forth.extra.reason'
local misc   = require 'forth.extra.misc'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    interpreter.module.dictionary.vocabulary 'math'
    interpreter.module.dictionary.definitions 'math'

    dictionary[ '+' ] = function (x, y, ...)
        if interpreter: skipping ( ) then return x, y, ... end

        local z = x + y

        return z, ...
    end

    dictionary[ '*' ] = function (x, y, ...)
        if interpreter: skipping ( ) then return x, y, ... end

        local z = x * y

        return z, ...
    end

    dictionary[ '/' ] = function (x, y, ...)
        if interpreter: skipping ( ) then return x, y, ... end

        local z = y / x

        return z, ...
    end

    dictionary[ '-' ] = function (x, y, ...)
        if interpreter: skipping ( ) then return x, y, ... end

        local z = y - x

        return z, ...
    end

    function dictionary.sqrt (x, ...)
        if interpreter: skipping ( ) then return x, ... end

        return math.sqrt (x), ...
    end

    dictionary[ 'true' ] = function (...)
        if interpreter: skipping ( ) then return ... end

        return true, ...
    end

    dictionary[ 'false' ] = function (...)
        if interpreter: skipping ( ) then return ... end

        return false, ...
    end

    dictionary[ '=' ] = function (x, y, ...)
        if interpreter: skipping ( ) then return x, y, ... end

        local z = x == y

        return z, ...
    end

    dictionary[ '<' ] = function (x, y, ...)
        if interpreter: skipping ( ) then return x, y, ... end

        local z = y < x

        return z, ...
    end

    dictionary[ '|' ] = function (x, y, ...)
        if interpreter: skipping ( ) then return x, y, ... end

        local z = x or y

        return z, ...
    end

    dictionary[ '&' ] = function (x, y, ...)
        if interpreter: skipping ( ) then return x, y, ... end

        local z = x and y

        return z, ...
    end

    dictionary[ 'not' ] = function (x, ...)
        if interpreter: skipping ( ) then return x, ... end

        local y = not x

        return y, ...
    end

    dictionary[ 'if' ] = function (x, ...)
        interpreter.state.branching = interpreter.state.branching + 1

        if interpreter: skipping ( ) then return x, ... end

        if x == true then
            table.insert (interpreter.state.condition, {
                condition = true,
                branching = interpreter.state.branching, -- original [ if ] branch --
            })

        elseif x == false then
            table.insert (interpreter.state.condition, {
                condition = false,
                branching = interpreter.state.branching, -- original [ if ] branch --
            })

        else
            error (reason.condition.not_boolean: format (tostring (x)))
        end

        return ...
    end

    dictionary[ 'else' ] = function (...)
        if (interpreter.state.branching > 0) and
            (interpreter.state.shifting ~= interpreter.state.branching) then

            local recent = interpreter.state.condition[ #interpreter.state.condition ]

            if recent.branching == interpreter.state.branching then
                recent.condition = (recent.condition == false)
            end

            interpreter.state.shifting = interpreter.state.shifting + 1

            return ...
        else
            error (reason.condition.noif)
        end
end

    dictionary[ 'then' ] = function (...)
        if interpreter.state.branching > 0 then
            local recent = interpreter.state.condition[ #interpreter.state.condition ]

            if recent.branching == interpreter.state.branching then
                table.remove (interpreter.state.condition)
            end

            interpreter.state.branching = interpreter.state.branching - 1
            interpreter.state.shifting  = math.max (0, interpreter.state.shifting - 1)

            return ...
        else
            error (reason.condition.unmatched_ifs)
        end
    end

    interpreter.module.dictionary.definitions 'forth'
end

return functor
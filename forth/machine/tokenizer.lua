local string = { }

local metatable = {
    __tostring = function (self)
        return string[ self ]
    end,
}

local function tokenizer (input)
    local next = input: gmatch "."

    local line   = 1
    local column = 0
    local buffer = ""
    local state  = { }

    function state.initial (char)
        if char == "\n" or char == "\r" then
            column = 0
            line   = line + 1

            return state.space (next ( ))

        elseif char == " " or char == "\t" then
            column = column + 1

            return state.space (next ( ))

        elseif char == "\"" then
            column = column + 1

            return state.string (next ( ))

        elseif char == nil then
            return

        else
            column = column + 1
            buffer = buffer .. char

            return state.word (next ( ))
        end
    end

    function state.space (char)
        if char == "\r" or char == "\n" then
            column = 0
            line   = line + 1

            return state.space (next ( ))

        elseif char == " " or char == "\t" then
            column = column + 1

            return state.space (next ( ))

        elseif char == "\"" then
            column = column + 1

            return state.string (next ( ))

        elseif char == nil then
            return

        else
            column = column + 1
            buffer = buffer .. char

            return state.word (next ( ))
        end
    end

    function state.string (char)
        if char == "\\" then
            column = column + 1
            buffer = buffer .. char

            local char = next ( )

            if char == nil then
                error (("Expected something after [\\] at line <%d>!"): format (line))
            else
                return state.string (next ( ))
            end

        elseif char == "\"" then
            local reference = { }

            string[ reference ] = buffer
            setmetatable (reference, metatable)

            coroutine.yield (reference)

            column = column + 1
            buffer = ""

            return state.initial (next ( ))

        elseif char == nil then
            error (("Missing a [\"] to close ongoing string (at line <%d>)!"): format (line))

        else
            if char == "\n" or char == "\r" then
                column = 0
                line   = line + 1
            else
                column = column + 1
            end

            buffer = buffer .. char

            return state.string (next ( ))
        end
    end

    function state.word (char)
        if char == "\n" or char == "\r" then
            coroutine.yield (buffer)

            line   = line + 1
            column = 0
            buffer = ""

            return state.space (next ( ))

        elseif char == " " or char == "\t" then
            coroutine.yield (buffer)

            column = column + 1
            buffer = ""

            return state.space (next ( ))

        elseif char == "\"" then
            coroutine.yield (buffer)

            column = column + 1
            buffer = ""

            return state.string (next ( ))

        elseif char == nil then
            coroutine.yield (buffer)

            return

        else
            column = column + 1
            buffer = buffer .. char

            return state.word (next ( ))
        end
    end

    return coroutine.wrap (function ( )
        return state.initial (next ( ))
    end)
end

-- stack object --
local function stack (next)
    local self = { }
    local list = { }

    function self.pop ( )
        if #list == 0 then
            return next ( )
        else
            return table.remove (list, 1)
        end
    end

    function self.push (value)
        return table.insert (list, 1, value)
    end

    function self.swap ( )
        local first  = self.pop ( )
        local second = self.pop ( )

        self.push (first)
        self.push (second)
    end

    function self.rot ( )
        local first  = self.pop ( )
        local second = self.pop ( )
        local third  = self.pop ( )

        self.push (second)
        self.push (first)
        self.push (third)
    end

    function self.over ( )
        local first  = self.pop ( )
        local second = self.pop ( )

        self.push (second)
        self.push (first)
        self.push (second)
    end

    function self.dup ( )
        local first = self.pop ( )

        self.push (first)
        self.push (first)
    end

    return self
end

local function functor (interpreter)
    local export = { }

    function export.lines (filename)
        for line in io.lines (filename) do
            local tokens = stack (tokenizer (line))

            interpreter.state.next   = tokens.pop
            interpreter.state.expand = tokens.push

            interpreter.state.mode.decoder ( )
        end
    end

    function export.input ( )
        local tokens = stack (tokenizer (io.read ( )))

        interpreter.state.next   = tokens.pop
        interpreter.state.expand = tokens.push

        interpreter.state[ "swap-tokens" ] = tokens.swap
        interpreter.state[ "rot-tokens" ]  = tokens.rot
        interpreter.state[ "over-tokens" ] = tokens.over
        interpreter.state[ "dup-tokens" ]  = tokens.dup

        interpreter.state.mode.decoder ( )
    end

    function export.string (reference)
        return string[ reference ]
    end

    return export
end

return functor
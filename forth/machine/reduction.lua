local misc = require 'forth.extra.misc'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    function interpreter.state.mode.compiler (token)
        local xt = nil

        if interpreter.module.tokenizer.string (token) then
            xt = dictionary[ "\"" .. tostring (token) .. "\"" ]
        else
            xt = dictionary[ token ]
        end

        if xt then
            if interpreter.state.immediate[ token ] then
                interpreter.state.stack = { xt (misc.unpack (interpreter.state.stack)) }
            else
                interpreter.state.chunks = misc.compose (interpreter.state.chunks, xt)
                interpreter.state.buffer = ("%s %s"): format (interpreter.state.buffer, token)
            end

        else
            local literal = interpreter.module.tokenizer.string (token)

            if literal == nil then
                literal = tonumber (token)
            end

            if literal == nil then
                return interpreter.module.exception.unknown (token)
            else
                interpreter.state.chunks = misc.compose (interpreter.state.chunks, interpreter: literal (literal))

                if interpreter.module.tokenizer.string (token) then
                    token = "\"" .. literal .. "\""
                end

                interpreter.state.buffer = interpreter.state.buffer .. " " .. token
            end
        end

        return interpreter.state.mode.decoder ( )
    end

    function interpreter.state.mode.interpreter (token)
        local xt = nil

        if interpreter.module.tokenizer.string (token) then
            xt = dictionary[ "\"" .. tostring (token) .. "\"" ]
        else
            xt = dictionary[ token ]
        end

        if xt then
            if false -- interpreter.state.immediate[ tostring (token) ] --
            then
                return interpreter.module.exception.cant_interpret (token)
            else
                interpreter.state.stack = misc.pack (xt (misc.unpack (interpreter.state.stack)))
            end

        else
            if interpreter: skipping ( ) then return interpreter.state.mode.decoder ( ) end

            local literal = interpreter.module.tokenizer.string (token)

            if literal == nil then literal = tonumber (token) end

            if literal == nil then
                return interpreter.module.exception.unknown (token)
            else
                table.insert (interpreter.state.stack, 1, literal)
            end
        end

        return interpreter.state.mode.decoder ( )
    end

    function interpreter.state.mode.decoder ( )
        local token = interpreter.state.next ( )

        if token == nil then return end

        if type (token) == 'string' then token = token: lower ( ) end

        if interpreter.state.state then
            return interpreter.state.mode.compiler (token)
        else
            return interpreter.state.mode.interpreter (token)
        end
    end
end

return functor
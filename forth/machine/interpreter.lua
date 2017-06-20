-- forth.machine.interpreter --

local misc      = require 'forth.extra.misc'
local reason    = require 'forth.extra.reason'
local exception = require 'forth.extra.exception' (reason)

local trait  = { }

local metaobject = {
    __index     = trait,
    __metatable = "<meta-object>",
}

function trait: skipping ( )
    local recent = self.state.condition[ #self.state.condition ]

    if recent ~= nil then
        return (not recent.condition)
    else
        return false
    end
end

function trait: clone ( )
    local interpreter = require 'forth.machine.interpreter' ( )

    for key, value in pairs (self.state) do
        if type (value) == 'table' then
            interpreter.state[ key ] = { }

            misc.copy (value, interpreter.state[ key ])

        else
            interpreter.state[ key ] = value
        end
    end

    return interpreter
end

function trait: literal (x)
    return function (...)
        if self: skipping ( ) then return ... end

        return x, ...
    end
end

function trait: find (token)
    local chunk = nil

    if self.module.tokenizer.string (token) then
        chunk = self.state.dictionary[ "\"" .. tostring (token) .. "\"" ]
    else
        chunk = self.state.dictionary[ token ]
    end

    if chunk then
        return chunk
    else
        return self.module.exception.unknown (token)
    end
end

local function functor ( )
    local self   = { }
    local state  = { } -- internal state of the interpreter object --
    local module = { } -- loaded modules for this interpreter object --

    state.alive      = false  -- is running? --
    state.state      = false  -- compiling = true, interpreting = false --

    state.branching  = 0      -- [ if ] counter --
    state.shifting   = 0      -- [ else ] counter --
    state.condition  = { }    -- skip-word-execution flag for [ then ] --

    state.next       = nil   -- word name generator --
    state.recent     = nil   -- last word compiled --
    state.chunks     = nil   -- compiled chunks of words --
    state.buffer     = nil   -- saved source code of recent word --
    state.noname     = false -- literal lambda flag --
    state.definition = 0     -- how many definitions are us running? --

    state.stack      = { }   -- data stack --
    state.dictionary = nil   -- dictionary --

    state.source     = { }   -- source code of words --
    state.recursive  = { }   -- is the definition is recursive? --
    state.immediate  = { }   -- immediate word flag --
    state.compile    = { }   -- compile-only flag --
    state.mode       = { }   -- state machine --
    state.recurse    = { }   -- deferred proxy word --

    self.deferred = {
      __call = function (reference, ...)
        if self: skipping ( ) then return ... end

        return reference[ 1 ] (...)
      end,
    }

    self.fixpoint = {
      __call = function (reference, ...)
        if self: skipping ( ) then return ... end

        return self.state.dictionary[ self.state.recurse[ reference ] ] (...)
      end,
    }

    self.state  = state
    self.module = module

    self.module.exception = exception

    setmetatable (self, metaobject)

    return self
end

return functor
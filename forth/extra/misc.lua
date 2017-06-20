local export = { }

local metatable = { }

metatable.weakness = { }
metatable.weakness.key   = { __mode = 'k' }
metatable.weakness.value = { __mode = 'v' }
metatable.weakness.pair  = { __mode = 'kv' }

export.weak = { }

function export.weak.key (struct)
    struct = struct or { }

    return setmetatable (struct, metatable.weakness.key)
end

function export.weak.value (struct)
    struct = struct or { }

    return setmetatable (struct, metatable.weakness.value)
end

function export.weak.pair (struct)
    struct = struct or { }

    return setmetatable (struct, metatable.weakness.pair)
end

local function pack (...)
    return { n = select ('#', ...), ... }
end

export.unpack = unpack     or table.unpack
export.pack   = table.pack or pack
export.load   = loadstring or load

local function noop ( )
end

local function id (...)
    return ...
end

local function compose (f, g)
    return function (...) return g (f (...)) end
end

local function copy (source, target)
    for key, value in pairs (source) do
        target[ key ] = value
    end

    for index = 1, #source do
        target[ index ] = source[ index ]
    end
end

export.noop    = noop
export.id      = id
export.compose = compose
export.copy    = copy

return export
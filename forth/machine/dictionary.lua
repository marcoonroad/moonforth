local misc      = require 'forth.extra.misc'
local reason    = require 'forth.extra.reason'
local prompt    = require 'forth.extra.prompt'
local whitelist = require 'forth.extra.whitelist'

local function functor (interpreter)
    local export = { }
    local self   = { }
    local forth  = { }

    local isolated   = false
    local vocabulary = { forth = forth, }

    local dictionary = misc.weak.value {
        forth  = forth,
        active = forth,
    }

    local name = misc.weak.key { [ vocabulary.forth ] = 'forth', }

    local metaobject = { }

    -- lookup order: active -> stack of vocabularies -> forth --
    function metaobject: __index (word)
        local value = dictionary.active[ word ]

        if isolated and not whitelist[ word ] then
            error (reason.vocabulary.isolated: format (word))
        end

        if value == nil then
            for index = 1, #dictionary do
                value = dictionary[ index ][ word ]

                if value ~= nil then return value end
            end

            return dictionary.forth[ word ]
        else
            return value
        end
    end

    function metaobject: __newindex (word, literal)
        dictionary.active[ word ] = literal
    end

    function metaobject: __pairs ( )
        return pairs (dictionary.active)
    end

    function export.vocabulary (word)
        if not vocabulary[ word ] then
            local entries = { }

            vocabulary[ word ] = entries
            name[ entries ]    = word
        else
            error (reason.vocabulary.already_defined: format (word))
        end
    end

    function export.lookup (name)
        return assert (vocabulary[ name ], reason.vocabulary.no_such: format (name))
    end

    function export.active ( )
        return name[ dictionary.active ]
    end

    function export.reset ( )
        dictionary = misc.weak.value {
            forth  = dictionary.forth,
            active = dictionary.active,
        }
    end

    function export.cite (library)
        if vocabulary[ library ] then return end
        
        local filename = ("%s.%s"): format (library: gsub ("%.", "/"), "fth")

        export.vocabulary (library)

        local active   = dictionary.active
        local previous = interpreter.next

        -- dictionary.active = vocabulary[ library ]
        -- interpreter.module.dictionary.vocabulary (library)

        interpreter.module.dictionary.definitions (library)

        interpreter.module.tokenizer.lines (filename)

        interpreter.next  = previous
        dictionary.active = active

        -- interpreter.module.dictionary.definitions 'forth'

        local entries = assert (vocabulary[ library ], reason.vocabulary.no_such: format (library))

        table.insert (dictionary, 1, entries)
    end

    function export.reload (library)
        export.except (library)
        vocabulary[ library ] = nil

        return export.cite (library)
    end

    function export.imports ( )
        local output = ("%s %s"): format (prompt.output, name[ dictionary.active ])

        for index = 1, #dictionary do
            output = ("%s %s"): format (output, name[ dictionary[ index ] ])
        end

        print (output)
    end

    function export.also (word)
        local entries = assert (vocabulary[ word ], reason.vocabulary.no_such: format (word))

        table.insert (dictionary, 1, entries)
    end

    function export.except (word)
        if word == 'forth' then
            error (reason.vocabulary.cant_unload: format (word))
        end

        local expected = assert (vocabulary[ word ], reason.vocabulary.no_such: format (word))
        local inactive = false
        local unloaded = false

        if dictionary.active == expected then
            local entries = table.remove (dictionary, 1)

            if entries == nil then
                dictionary.active = dictionary.forth
            else
                dictionary.active = entries
            end

            inactive = true
        end

        if not inactive then
            for index = 1, #dictionary do
                local entries = dictionary[ index ]

                if entries == nil then
                    break
                elseif entries == expected then
                    table.remove (dictionary, index)

                    unloaded = true
                    break
                end
            end
        end

        if (not unloaded) and (not inactive) then error (reason.vocabulary.not_loaded: format (word)) end
    end

    function export.definitions (word)
        local entries = assert (vocabulary[ word ], reason.vocabulary.no_such: format (word))

        dictionary.active = entries
    end

    function export.vocabularies ( )
        local output = prompt.output

        for word in pairs (vocabulary) do
            output = ("%s %s"): format (output, word)
        end

        print (output)
    end

    setmetatable (self, metaobject)

    function export.dictionary ( )
        return self
    end

    function export.isolate (flag) flag = flag or true
        isolated = flag
    end

    return export
end

return functor
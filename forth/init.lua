local reason      = require 'forth.extra.reason'
local misc        = require 'forth.extra.misc'
local prompt      = require 'forth.extra.prompt'
local interpreter = require 'forth.machine.interpreter' ( )
local dictionary  = require 'forth.machine.dictionary' (interpreter)
local reduction   = require 'forth.machine.reduction'
local tokenizer   = require 'forth.machine.tokenizer'
local core        = require 'forth.library'
local export      = { }

interpreter.module.dictionary = dictionary
interpreter.state.dictionary  = dictionary.dictionary ( )
interpreter.module.tokenizer  = tokenizer (interpreter)
interpreter.module.reduction  = reduction (interpreter)

core (interpreter)

function export.script (filename)
    interpreter.state.alive = true

    interpreter.module.tokenizer.lines 'forth/forth/init.fth'
    interpreter.module.tokenizer.lines (filename)
end

function export.run ( )
    interpreter.state.alive = true
    local message = {
        "==== Booting Forth REPL... ====",
        "",
        "Type:",
        "\tbye                        - to exit,",
        "\twords                      - to see current scope definitions,",
        "\tall-words-for <identifier> - to see the list of definitions for given vocabulary,",
        "\tvocabularies               - to see the list of defined vocabularies,",
        "\tvocabulary <identifier>    - to create an empty separated vocabulary,",
        "\timports                    - to see the lookup stack of imported vocabularies,",
        "\talso <identifier>          - to import the given vocabulary named <identifier>,",
        "\treset                      - to clear the stack of imports in its default state,",
        "\tonly <identifier>          - to clear the imports and import only the <identifier>,",
        "\texcept <identifier>        - to unimport topmost vocabulary named <identifier>,",
        "\tactive                     - to see the current vocabulary of scope definitions,",
        "\tdefinitions <identifier>   - to change the target vocabulary where words are compiled into,",
        "\tsee <word>                 - to see the source code for user definition <word>,",
        "\talias <new-word> <word>    - to provide an in-scope alias definition for an already existent <word>,",
        "\tforget <word>              - to erase the latest definition for <word>,",
        "\tcite <module>              - to load a file <module>.fth in a separated vocabulary definition,",
        "\treload <module>            - to reload a separated vocabulary from associated file <module>.fth,",
        "",
        "==== Forth REPL is ready! ====",
    }

    print (table.concat (message, "\n"))

    interpreter.module.tokenizer.lines 'forth/forth/init.fth'

    while interpreter.state.alive do
        xpcall (function ( )
            if interpreter.state.definition > 0 then
                io.write (prompt.continue .. " ")
            else
                io.write (prompt.query .. " ")
            end

            interpreter.module.tokenizer.input ( )
        end, function (reason)
            interpreter.state.state      = false
            interpreter.state.chunks     = nil
            interpreter.state.buffer     = nil
            interpreter.state.recent     = nil
            interpreter.state.branching  = 0
            interpreter.state.shifting   = 0
            interpreter.state.condition  = { }
            interpreter.state.definition = 0

            print (prompt.error .. " " .. reason)
        end)
    end

    print "==== See you. ===="
end

return export
local function functor (reason)
    local export = { }

    function export.cant_interpret (word)
        error (reason.word.interpret_immediate: format (word))
    end

    function export.invalid (any)
        error (reason.literal.invalid: format (tostring (any)))
    end

    function export.unknown (word)
        error (reason.word.unknown: format (word))
    end

    return export
end

return functor
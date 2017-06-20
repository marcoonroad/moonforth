local socket = require 'socket'
local reason = require 'forth.extra.reason'

local function functor (interpreter)
    local dictionary = interpreter.state.dictionary

    interpreter.module.dictionary.vocabulary 'socket'
    interpreter.module.dictionary.definitions 'socket'

    function dictionary.bind (port, address, ...)
        if interpreter: skipping ( ) then return port, address, ... end

        local server = assert (socket.bind (address, port), reason.socket.bind: format (address, port))

        return server, ...
    end

    dictionary[ 'random-socket' ] = function (...)
        if interpreter: skipping ( ) then return ... end

        local server = assert (socket.bind ('*', 0), reason.socket.random)

        return server, ...
    end

    function dictionary.udp (...)
        if interpreter: skipping ( ) then return ... end

        local udp = assert (socket.udp ( ), reason.socket.udp)

        return udp, ...
    end

    function dictionary.shutdown (mode, client, ...)
        if interpreter: skipping ( ) then return mode, client, ... end

        client: shutdown (mode)

        return ...
    end

    function dictionary.connect (port, address, master, ...)
        if interpreter: skipping ( ) then return port, address, master, ... end

        assert (master: connect (address, port), reason.socket.bind: format (address, port))

        return ...
    end

    dictionary[ 'get-socket-name' ] = function (socket, ...)
        if interpreter: skipping ( ) then return socket, ... end

        local address, port = assert (socket: getsockname ( ), reason.socket.sockname)

        return port, address, ...
    end

    dictionary[ 'get-peer-name' ] = function (client, ...)
        if interpreter: skipping ( ) then return client, ... end

        local address, port = assert (client: getpeername ( ), reason.socket.sockname)

        return port, address, ...
    end

    function dictionary.accept (server, ...)
        if interpreter: skipping ( ) then return server, ... end

        local client = server: accept ( )

        return client, ...
    end

    dictionary[ 'set-timeout' ] = function (timeout, master, ...)
        if interpreter: skipping ( ) then return timeout, master, ... end

        master: settimeout (timeout)

        return ...
    end

    function dictionary.sleep (seconds, ...)
        if interpreter: skipping ( ) then return seconds, ... end

        return socket.sleep (seconds), ...
    end

    function dictionary.send (message, client, ...)
        if interpreter: skipping ( ) then return message, client, ... end

        client: send (message .. "\n")

        return ...
    end

    function dictionary.close (socket, ...)
        if interpreter: skipping ( ) then return socket, ... end

        socket: close ( )

        return ...
    end

    dictionary[ 'get-stats' ] = function (socket, ...)
        if interpreter: skipping ( ) then return socket, ... end

        return socket: getstats ( ), ...
    end

    function dictionary.listen (clients, server, ...)
        if interpreter: skipping ( ) then return clients, server, ... end

        assert (server: listen (clients), "Failed on performing [ listen ] operation!")

        return ...
    end

    function dictionary.receive (socket, ...)
        if interpreter: skipping ( ) then return socket, ... end

        return socket: receive ( ), ...
    end

    dictionary[ 'send-to' ] = function (port, address, message, socket, ...)
        if interpreter: skipping ( ) then return port, address, message, socket, ... end

        assert (socket: sendto (message, address, port),
            reason.socket.send: format (message, address, port))

        return ...
    end

    interpreter.module.dictionary.definitions 'forth'
end

return functor
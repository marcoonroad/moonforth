local export = { }

local vocabulary = { }
vocabulary.already_defined = "Vocabulary [ %s ] is already defined!"
vocabulary.no_such         = "No such vocabulary [ %s ]!"
vocabulary.not_loaded      = "Vocabulary [ %s ] is not loaded!"
vocabulary.cant_unload     = "Can't unload the vocabulary [ %s ]!"
vocabulary.isolated        = "Word [ %s ] belongs to a dictionary outside the whitelist."

local word = { }
word.interpret_immediate = "Can't interpret immediate word [ %s ]!"
word.unknown             = "Unknown word [ %s ]!"
word.no_recent           = "No such recently compiled word!"
word.already_immediate   = "Word [ %s ] already is immediate!"

local literal = { }
literal.invalid = "Invalid literal [ %s ]!"

local condition = { }
condition.not_boolean  = "[ %s ] isn't a boolean!"
condition.no_if        = "This [ else ] is missing a [ if ]!"
condition.unmatched_if = "Unmatched number of [ if ]s and [ then ]s!"

local socket = { }
socket.bind     = "Failed to bind address [ %s ] to port [ %s ]!"
socket.random   = "Failed to create a random socket!"
socket.sockname = "Failed to get the socket socket address and port!"
socket.udp      = "Failed to create a random UDP socket!"
socket.send     = "Failed to send message [ %s ] through address [ %s ] at port [ %s ]!"

export.vocabulary       = vocabulary
export.word             = word
export.condition        = condition
export.socket           = socket
export.literal          = literal
export.unexpected_eof   = "Unexpected end of line!"
export.unbound_selector = "Unbound selector [%s]!"
export.no_number        = "No such number!"

return export
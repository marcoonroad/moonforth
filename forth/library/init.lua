local misc   = require 'forth.extra.misc'
local reason = require 'forth.extra.reason'

local function functor (interpreter)
    require 'forth.library.stack'      (interpreter)
    require 'forth.library.word'       (interpreter)
    require 'forth.library.world'      (interpreter)
    require 'forth.library.system'     (interpreter)
    require 'forth.library.module'     (interpreter)
    require 'forth.library.math'       (interpreter)
    require 'forth.library.exception'  (interpreter)
    require 'forth.library.lua'        (interpreter)
    require 'forth.library.collector'  (interpreter)
    require 'forth.library.socket'     (interpreter)
    require 'forth.library.runtime'    (interpreter)
    require 'forth.library.memory'     (interpreter)
    require 'forth.library.token'      (interpreter)
end

return functor
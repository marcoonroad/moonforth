local forth = require 'forth'

if arg[ 1 ] then
    forth.script (arg[ 1 ])
else
    forth.run ( )
end
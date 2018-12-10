require! 'jsdoc-api'
debug = require 'debug' <| 'jsdoc'

# :: Buffer → Promise Object
export explain-buffer = (buf) ->
    debug 'jsdoc-explain-buffer'
    jsdoc-api.explain { source: buf.to-string! }

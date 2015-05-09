require! 'bluebird': Promise
require! 'ramda': {is-empty}
require! 'child_process': {spawn}
require! 'concat-stream'
debug = require 'debug' <| 'jsdoc'
temp-write = Promise.promisify <| require 'temp-write'

JSDOC_BIN = "#{require.main.paths.0}/jsdoc/jsdoc.js"

# :: String → Promise Object
export explain = Promise.promisify (file, cb) ->
    debug {file}, 'jsdoc-explain'
    spawn JSDOC_BIN, [ '--explain', file ]
        ..stdout.pipe concat-stream -> cb null, JSON.parse it.to-string!
        ..stderr.pipe concat-stream -> cb it if !is-empty it

# :: Buffer → Promise Object
export explain-buffer = (buf) ->
    debug 'jsdoc-explain-buffer'
    temp-write buf, 'script.js'
        .then explain
        .tap -> debug 'jsdoc-explain-buffer done'
